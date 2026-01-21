mod db;
mod ui;

use anyhow::{Context, Result};
use clap::{Parser, Subcommand};
use colored::Colorize;
use std::path::{Path, PathBuf};
use std::process::Command;
use walkdir::WalkDir;

use db::{Database, NewClient, NewProject, NewDocument};
use ui::InteractiveUI;

#[derive(Parser)]
#[command(name = "docgen")]
#[command(author = "Typst Business Templates")]
#[command(version = "0.2.0")]
#[command(about = "Generate professional business documents with Typst", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand)]
enum Commands {
    /// Initialize a new document project
    Init {
        /// Project directory name
        name: String,
    },
    /// Compile a single document from JSON to PDF
    Compile {
        /// Path to JSON data file
        input: PathBuf,
        /// Output PDF path (optional)
        #[arg(short, long)]
        output: Option<PathBuf>,
        /// Template type (invoice, offer, credentials, concept)
        #[arg(short, long)]
        template: Option<String>,
    },
    /// Build all documents in a directory
    Build {
        /// Directory containing JSON files
        #[arg(default_value = "documents")]
        path: PathBuf,
        /// Output directory for PDFs
        #[arg(short, long, default_value = "output")]
        output: PathBuf,
    },
    /// Watch for changes and rebuild automatically
    Watch {
        /// Directory to watch
        #[arg(default_value = "documents")]
        path: PathBuf,
    },
    /// Client management
    Client {
        #[command(subcommand)]
        action: ClientAction,
    },
    /// Project management  
    Project {
        #[command(subcommand)]
        action: ProjectAction,
    },
}

#[derive(Subcommand)]
enum ClientAction {
    /// List all clients
    List,
    /// Add a new client
    Add {
        /// Client name
        #[arg(short, long)]
        name: Option<String>,
    },
    /// Show client details
    Show {
        /// Client number (e.g., 1) or K-number (e.g., K-001)
        id: String,
    },
}

#[derive(Subcommand)]
enum ProjectAction {
    /// List projects for a client
    List {
        /// Client ID or number
        client: String,
    },
    /// Add a new project
    Add {
        /// Client ID or number
        client: String,
        /// Project name
        name: String,
    },
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        // No command = interactive mode
        None => {
            let db = Database::open_default()?;
            let mut ui = InteractiveUI::new(db);
            ui.run()
        }
        Some(Commands::Init { name }) => init_project(&name),
        Some(Commands::Compile { input, output, template }) => compile_document(&input, output, template),
        Some(Commands::Build { path, output }) => build_all(&path, &output),
        Some(Commands::Watch { path }) => watch_directory(&path),
        Some(Commands::Client { action }) => handle_client(action),
        Some(Commands::Project { action }) => handle_project(action),
    }
}

fn handle_client(action: ClientAction) -> Result<()> {
    let db = Database::open_default()?;
    
    match action {
        ClientAction::List => {
            let clients = db.list_clients()?;
            if clients.is_empty() {
                println!("Keine Kunden vorhanden.");
                println!("Erstellen Sie einen mit: docgen client add");
                return Ok(());
            }
            
            println!("{}", "Kunden".bold());
            println!("{:-<60}", "");
            for c in clients {
                println!("{:8} │ {:30} │ {}", 
                    c.formatted_number().cyan(),
                    c.display_name(),
                    c.city.unwrap_or_default()
                );
            }
        }
        ClientAction::Add { name } => {
            let name = match name {
                Some(n) => n,
                None => {
                    use dialoguer::Input;
                    Input::new().with_prompt("Name").interact_text()?
                }
            };
            
            let new_client = NewClient {
                name,
                ..Default::default()
            };
            
            let client = db.add_client(&new_client)?;
            println!("{} Kunde {} angelegt", "✓".green(), client.formatted_number().cyan());
        }
        ClientAction::Show { id } => {
            let client_id = parse_client_id(&db, &id)?;
            let client = db.get_client(client_id)?;
            let projects = db.list_projects_for_client(client_id)?;
            let documents = db.list_documents_for_client(client_id)?;
            
            println!();
            println!("{} {}", client.formatted_number().cyan(), client.display_name().bold());
            println!("{}", client.full_address());
            if let Some(email) = &client.email {
                println!("{}", email);
            }
            
            if !projects.is_empty() {
                println!();
                println!("{}", "Projekte:".bold());
                for p in projects {
                    println!("  {} │ {} │ {}", 
                        p.formatted_number(client.number),
                        p.name,
                        p.status
                    );
                }
            }
            
            if !documents.is_empty() {
                println!();
                println!("{}", "Letzte Dokumente:".bold());
                for d in documents.iter().take(5) {
                    println!("  {} │ {} │ {}", 
                        d.doc_number,
                        d.type_display(),
                        d.status_display()
                    );
                }
            }
        }
    }
    Ok(())
}

fn handle_project(action: ProjectAction) -> Result<()> {
    let db = Database::open_default()?;
    
    match action {
        ProjectAction::List { client } => {
            let client_id = parse_client_id(&db, &client)?;
            let client = db.get_client(client_id)?;
            let projects = db.list_projects_for_client(client_id)?;
            
            println!("{} - {}", "Projekte für".bold(), client.display_name());
            println!("{:-<60}", "");
            
            if projects.is_empty() {
                println!("Keine Projekte vorhanden.");
            } else {
                for p in projects {
                    println!("{:12} │ {:30} │ {}", 
                        p.formatted_number(client.number).cyan(),
                        p.name,
                        p.status
                    );
                }
            }
        }
        ProjectAction::Add { client, name } => {
            let client_id = parse_client_id(&db, &client)?;
            let client_data = db.get_client(client_id)?;
            
            let new_project = NewProject::new(client_id, name);
            let project = db.add_project(&new_project)?;
            
            println!("{} Projekt {} angelegt", 
                "✓".green(), 
                project.formatted_number(client_data.number).cyan()
            );
        }
    }
    Ok(())
}

fn parse_client_id(db: &Database, input: &str) -> Result<i64> {
    // Try direct number
    if let Ok(num) = input.parse::<i64>() {
        // Check if it's a client number or ID
        let clients = db.list_clients()?;
        if let Some(c) = clients.iter().find(|c| c.number == num || c.id == num) {
            return Ok(c.id);
        }
    }
    
    // Try K-XXX format
    if input.to_uppercase().starts_with("K-") {
        if let Ok(num) = input[2..].parse::<i64>() {
            let clients = db.list_clients()?;
            if let Some(c) = clients.iter().find(|c| c.number == num) {
                return Ok(c.id);
            }
        }
    }
    
    anyhow::bail!("Kunde nicht gefunden: {}", input)
}

fn init_project(name: &str) -> Result<()> {
    println!("{} Initialisiere Projekt: {}", "→".blue(), name.green());
    
    let base = Path::new(name);
    
    let dirs = ["data", "documents/invoices", "documents/offers", 
                "documents/credentials", "documents/concepts", 
                "output", "templates"];
    
    for dir in dirs {
        std::fs::create_dir_all(base.join(dir))?;
    }
    
    // Create company.json
    let company = r#"{
  "name": "Ihre Firma",
  "address": {
    "street": "Straße",
    "house_number": "1",
    "postal_code": "12345",
    "city": "Stadt",
    "country": "Deutschland"
  },
  "contact": {
    "phone": "+49 123 456789",
    "email": "info@example.com",
    "website": "www.example.com"
  },
  "tax_id": "123/456/78901",
  "vat_id": "DE123456789",
  "business_owner": "Ihr Name",
  "bank_account": {
    "bank_name": "Bank",
    "account_holder": "Ihre Firma",
    "iban": "DE00 0000 0000 0000 0000 00",
    "bic": "BANKDEFFXXX"
  }
}"#;
    std::fs::write(base.join("data/company.json"), company)?;
    
    // Create .gitignore
    std::fs::write(base.join(".gitignore"), "output/*.pdf\ndata/docgen.db\n")?;
    
    println!("{} Projekt erstellt!", "✓".green());
    println!();
    println!("Nächste Schritte:");
    println!("  cd {}", name);
    println!("  # Firmendaten bearbeiten:");
    println!("  nano data/company.json");
    println!("  # Interaktiv starten:");
    println!("  docgen");
    
    Ok(())
}

fn compile_document(input: &Path, output: Option<PathBuf>, template: Option<String>) -> Result<()> {
    if !input.exists() {
        anyhow::bail!("Datei nicht gefunden: {}", input.display());
    }
    
    let doc_type = template.unwrap_or_else(|| detect_document_type(input).unwrap_or("invoice".to_string()));
    let template_path = format!("templates/{}/default.typ", doc_type);
    let output_path = output.unwrap_or_else(|| input.with_extension("pdf"));
    
    println!("{} Kompiliere {} → {}", 
        "→".blue(), 
        input.display().to_string().cyan(),
        output_path.display().to_string().green()
    );
    
    let data_path = format!("/{}", input.display());
    
    let status = Command::new("typst")
        .args(["compile", "--root", ".", &template_path, "--input", &format!("data={}", data_path), &output_path.to_string_lossy()])
        .status()
        .context("Typst nicht gefunden. Ist Typst installiert?")?;
    
    if status.success() {
        println!("{} Erfolgreich kompiliert!", "✓".green());
        Ok(())
    } else {
        anyhow::bail!("Kompilierung fehlgeschlagen")
    }
}

fn build_all(path: &Path, output: &Path) -> Result<()> {
    println!("{} Baue alle Dokumente in {}", "→".blue(), path.display());
    
    std::fs::create_dir_all(output)?;
    
    let mut count = 0;
    let mut errors = 0;
    
    for entry in WalkDir::new(path)
        .into_iter()
        .filter_map(|e| e.ok())
        .filter(|e| e.path().extension().map_or(false, |ext| ext == "json"))
    {
        let input = entry.path();
        let output_file = output.join(input.file_stem().unwrap()).with_extension("pdf");
        
        match compile_document(input, Some(output_file), None) {
            Ok(_) => count += 1,
            Err(e) => {
                eprintln!("{} Fehler bei {}: {}", "✗".red(), input.display(), e);
                errors += 1;
            }
        }
    }
    
    println!();
    println!("{} {} Dokumente erstellt ({} Fehler)", 
        if errors == 0 { "✓".green() } else { "!".yellow() },
        count, errors
    );
    
    Ok(())
}

fn watch_directory(path: &Path) -> Result<()> {
    use notify::{Config, RecommendedWatcher, RecursiveMode, Watcher, EventKind};
    use std::sync::mpsc::channel;
    use std::time::Duration;
    
    println!("{} Überwache {} (Strg+C zum Beenden)", "→".blue(), path.display());
    
    let (tx, rx) = channel();
    let mut watcher = RecommendedWatcher::new(tx, Config::default())?;
    watcher.watch(path, RecursiveMode::Recursive)?;
    
    loop {
        match rx.recv_timeout(Duration::from_secs(1)) {
            Ok(Ok(event)) => {
                if matches!(event.kind, EventKind::Modify(_) | EventKind::Create(_)) {
                    for path in event.paths {
                        if path.extension().map_or(false, |ext| ext == "json") {
                            println!();
                            println!("{} Änderung: {}", "⟳".yellow(), path.display());
                            let _ = compile_document(&path, None, None);
                        }
                    }
                }
            }
            Ok(Err(e)) => eprintln!("Fehler: {}", e),
            Err(_) => {}
        }
    }
}

fn detect_document_type(path: &Path) -> Option<String> {
    let s = path.to_string_lossy().to_lowercase();
    if s.contains("invoice") || s.contains("rechnung") || s.contains("/re-") { Some("invoice".to_string()) }
    else if s.contains("offer") || s.contains("angebot") || s.contains("/an-") { Some("offer".to_string()) }
    else if s.contains("credential") || s.contains("zugang") || s.contains("/zd-") { Some("credentials".to_string()) }
    else if s.contains("concept") || s.contains("konzept") || s.contains("/ko-") { Some("concept".to_string()) }
    else { None }
}

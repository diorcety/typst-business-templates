mod db;
mod encrypt;
mod locale;
mod ui;

use anyhow::{Context, Result};
use clap::{Parser, Subcommand};
use colored::Colorize;
use std::path::{Path, PathBuf};
use std::process::Command;
use walkdir::WalkDir;

use db::{Database, NewClient, NewProject};
use locale::{t, tf};
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
        /// Encrypt the PDF with password protection
        #[arg(short, long)]
        encrypt: bool,
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
    // Initialize locale system
    locale::init();

    let cli = Cli::parse();

    match cli.command {
        // No command = interactive mode
        None => {
            let db = Database::open_default()?;
            let mut ui = InteractiveUI::new(db);
            ui.run()
        }
        Some(Commands::Init { name }) => init_project(&name),
        Some(Commands::Compile {
            input,
            output,
            template,
            encrypt,
        }) => compile_document(&input, output, template, encrypt),
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
                println!("{}", t("client", "no_clients"));
                println!("{}", t("client", "create_with"));
                return Ok(());
            }

            println!("{}", t("client", "clients").bold());
            println!("{:-<60}", "");
            for c in clients {
                println!(
                    "{:8} │ {:30} │ {}",
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
                    Input::new()
                        .with_prompt(t("common", "name"))
                        .interact_text()?
                }
            };

            let new_client = NewClient {
                name,
                ..Default::default()
            };

            let client = db.add_client(&new_client)?;
            println!(
                "{} {}",
                "✓".green(),
                tf("client", "created", &[&client.formatted_number()])
            );
        }
        ClientAction::Show { id } => {
            let client_id = parse_client_id(&db, &id)?;
            let client = db.get_client(client_id)?;
            let projects = db.list_projects_for_client(client_id)?;
            let documents = db.list_documents_for_client(client_id)?;

            println!();
            println!(
                "{} {}",
                client.formatted_number().cyan(),
                client.display_name().bold()
            );
            println!("{}", client.full_address());
            if let Some(email) = &client.email {
                println!("{}", email);
            }

            if !projects.is_empty() {
                println!();
                println!("{}:", t("project", "projects").bold());
                for p in projects {
                    println!(
                        "  {} │ {} │ {}",
                        p.formatted_number(client.number),
                        p.name,
                        p.status
                    );
                }
            }

            if !documents.is_empty() {
                println!();
                println!("{}:", t("document", "last_documents").bold());
                for d in documents.iter().take(5) {
                    println!(
                        "  {} │ {} │ {}",
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

            println!(
                "{} - {}",
                t("project", "for_client").bold(),
                client.display_name()
            );
            println!("{:-<60}", "");

            if projects.is_empty() {
                println!("{}", t("project", "no_projects"));
            } else {
                for p in projects {
                    println!(
                        "{:12} │ {:30} │ {}",
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

            println!(
                "{} {}",
                "✓".green(),
                tf(
                    "project",
                    "created",
                    &[&project.formatted_number(client_data.number)]
                )
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

    anyhow::bail!("{}: {}", t("client", "not_found"), input)
}

fn init_project(name: &str) -> Result<()> {
    println!(
        "{} {}: {}",
        "→".blue(),
        t("init", "initializing"),
        name.green()
    );

    let base = Path::new(name);

    // Get current year for initial directory structure
    let current_year = chrono::Local::now().format("%Y").to_string();

    let dirs = [
        "data",
        &format!("documents/invoices/{}", current_year),
        &format!("documents/offers/{}", current_year),
        &format!("documents/credentials/{}", current_year),
        &format!("documents/concepts/{}", current_year),
        &format!("documents/documentation/{}", current_year),
        &format!("output/{}", current_year),
        "templates",
    ];

    for dir in dirs {
        std::fs::create_dir_all(base.join(dir))?;
    }

    // Create company.json with language field
    let company = r##"{
  "name": "Your Company",
  "language": "en",
  "address": {
    "street": "Street",
    "house_number": "1",
    "postal_code": "12345",
    "city": "City",
    "country": "Country"
  },
  "contact": {
    "phone": "+1 234 567890",
    "email": "info@example.com",
    "website": "www.example.com"
  },
  "tax_id": "123/456/78901",
  "vat_id": "XX123456789",
  "business_owner": "Your Name",
  "bank_account": {
    "bank_name": "Bank",
    "account_holder": "Your Company",
    "iban": "XX00 0000 0000 0000 0000 00",
    "bic": "BANKXXXX"
  },
  "branding": {
    "accent_color": "#E94B3C",
    "primary_color": "#2c3e50",
    "font_preset": "inter"
  },
  "numbering": {
    "year_format": "short",
    "prefixes": {
      "invoice": "RE",
      "offer": "AN",
      "credentials": "ZD",
      "concept": "KO",
      "documentation": "DOC"
    }
  },
  "structure": {
    "organize_by_year": true
  },
  "default_terms": {
    "hourly_rate": "95.00",
    "currency": "EUR",
    "payment_days": 14,
    "warranty_months": 12,
    "vat_rate": 19,
    "standard_terms": [
      "All prices are net plus statutory VAT.",
      "Payment due within 14 days without deduction.",
      "Copyright remains with the contractor until full payment."
    ]
  }
}"##;
    std::fs::write(base.join("data/company.json"), company)?;

    // Create .gitignore
    std::fs::write(base.join(".gitignore"), "output/*.pdf\ndata/docgen.db\n")?;

    println!("{} {}", "✓".green(), t("init", "created"));
    println!();
    println!("{}:", t("init", "next_steps"));
    println!("  cd {}", name);
    println!("  # {}", t("init", "edit_company"));
    println!("  nano data/company.json");
    println!("  # {}", t("init", "start_interactive"));
    println!("  docgen");

    Ok(())
}

fn compile_document(input: &Path, output: Option<PathBuf>, template: Option<String>, encrypt: bool) -> Result<()> {
    if !input.exists() {
        anyhow::bail!("{}: {}", t("compile", "file_not_found"), input.display());
    }

    let doc_type =
        template.unwrap_or_else(|| detect_document_type(input).unwrap_or("invoice".to_string()));
    let template_path = format!("templates/{}/default.typ", doc_type);
    let output_path = output.unwrap_or_else(|| input.with_extension("pdf"));

    println!(
        "{} {}",
        "→".blue(),
        tf(
            "compile",
            "compiling",
            &[
                &input.display().to_string(),
                &output_path.display().to_string()
            ]
        )
    );

    let data_path = format!("/{}", input.display());

    let status = Command::new("typst")
        .args([
            "compile",
            "--root",
            ".",
            &template_path,
            "--input",
            &format!("data={}", data_path),
            &output_path.to_string_lossy(),
        ])
        .status()
        .context(t("compile", "typst_not_found"))?;

    if status.success() {
        println!("{} {}", "✓".green(), t("compile", "success"));
        
        // Handle encryption if requested
        if encrypt {
            // Check if qpdf is available first
            encrypt::check_qpdf_available()?;
            
            println!("{} {}", "→".blue(), "Encrypting PDF...");
            let encryption_opts = encrypt::prompt_encryption_options()?;
            let temp_path = output_path.with_extension("pdf.tmp");
            
            // Rename original to temp
            std::fs::rename(&output_path, &temp_path)?;
            
            // Encrypt temp to final output
            encrypt::encrypt_pdf(&temp_path, &output_path, encryption_opts)?;
            
            // Remove temp file
            std::fs::remove_file(&temp_path)?;
            
            println!("{} {}", "✓".green(), "PDF encrypted successfully");
        }
        
        Ok(())
    } else {
        anyhow::bail!("{}", t("compile", "failed"))
    }
}

fn build_all(path: &Path, output: &Path) -> Result<()> {
    println!(
        "{} {}",
        "→".blue(),
        tf("build", "building_all", &[&path.display().to_string()])
    );

    std::fs::create_dir_all(output)?;

    let mut count = 0;
    let mut errors = 0;

    for entry in WalkDir::new(path)
        .into_iter()
        .filter_map(|e| e.ok())
        .filter(|e| e.path().extension().map_or(false, |ext| ext == "json"))
    {
        let input = entry.path();
        let output_file = output
            .join(input.file_stem().unwrap())
            .with_extension("pdf");

        match compile_document(input, Some(output_file), None, false) {
            Ok(_) => count += 1,
            Err(e) => {
                eprintln!(
                    "{} {}: {}",
                    "✗".red(),
                    tf("compile", "error_at", &[&input.display().to_string()]),
                    e
                );
                errors += 1;
            }
        }
    }

    println!();
    println!(
        "{} {}",
        if errors == 0 {
            "✓".green()
        } else {
            "!".yellow()
        },
        tf(
            "build",
            "documents_created",
            &[&count.to_string(), &errors.to_string()]
        )
    );

    Ok(())
}

fn watch_directory(path: &Path) -> Result<()> {
    use notify::{Config, EventKind, RecommendedWatcher, RecursiveMode, Watcher};
    use std::sync::mpsc::channel;
    use std::time::Duration;

    println!(
        "{} {}",
        "→".blue(),
        tf("watch", "watching", &[&path.display().to_string()])
    );

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
                            println!(
                                "{} {}: {}",
                                "⟳".yellow(),
                                t("watch", "change_detected"),
                                path.display()
                            );
                            let _ = compile_document(&path, None, None, false);
                        }
                    }
                }
            }
            Ok(Err(e)) => eprintln!("{}: {}", t("common", "error"), e),
            Err(_) => {}
        }
    }
}

fn detect_document_type(path: &Path) -> Option<String> {
    let s = path.to_string_lossy().to_lowercase();
    if s.contains("invoice") || s.contains("rechnung") || s.contains("/re-") {
        Some("invoice".to_string())
    } else if s.contains("offer") || s.contains("angebot") || s.contains("/an-") {
        Some("offer".to_string())
    } else if s.contains("credential") || s.contains("zugang") || s.contains("/zd-") {
        Some("credentials".to_string())
    } else if s.contains("concept") || s.contains("konzept") || s.contains("/ko-") {
        Some("concept".to_string())
    } else {
        None
    }
}

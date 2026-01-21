use anyhow::{Context, Result};
use clap::{Parser, Subcommand};
use colored::Colorize;
use serde_json::Value;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use walkdir::WalkDir;

#[derive(Parser)]
#[command(name = "docgen")]
#[command(author = "Typst Business Templates")]
#[command(version = "0.1.0")]
#[command(about = "Generate professional business documents with Typst", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
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
        /// Output PDF path (optional, defaults to same name as input)
        #[arg(short, long)]
        output: Option<PathBuf>,
        /// Template type (invoice, offer, credentials, concept)
        #[arg(short, long)]
        template: Option<String>,
    },
    /// Build all documents in a directory
    Build {
        /// Directory containing JSON files (default: current directory)
        #[arg(default_value = ".")]
        path: PathBuf,
        /// Output directory for PDFs
        #[arg(short, long, default_value = "output")]
        output: PathBuf,
    },
    /// Watch for changes and rebuild automatically
    Watch {
        /// Directory to watch (default: current directory)
        #[arg(default_value = ".")]
        path: PathBuf,
    },
    /// Validate JSON files against schemas
    Validate {
        /// Path to JSON file or directory
        input: PathBuf,
    },
    /// Create a new document from template
    New {
        /// Document type (invoice, offer, credentials, concept)
        doc_type: String,
        /// Document ID/number
        id: String,
    },
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Commands::Init { name } => init_project(&name),
        Commands::Compile { input, output, template } => compile_document(&input, output, template),
        Commands::Build { path, output } => build_all(&path, &output),
        Commands::Watch { path } => watch_directory(&path),
        Commands::Validate { input } => validate_json(&input),
        Commands::New { doc_type, id } => create_new_document(&doc_type, &id),
    }
}

fn init_project(name: &str) -> Result<()> {
    println!("{} Initializing new document project: {}", "→".blue(), name.green());
    
    let base = Path::new(name);
    
    // Create directory structure
    let dirs = [
        "data",
        "invoices",
        "offers", 
        "credentials",
        "concepts",
        "output",
        "templates/common",
    ];
    
    for dir in dirs {
        fs::create_dir_all(base.join(dir))
            .with_context(|| format!("Failed to create directory: {}", dir))?;
    }
    
    // Create company.json template
    let company_template = r#"{
  "name": "Your Company Name",
  "address": {
    "street": "Street Name",
    "house_number": "123",
    "postal_code": "12345",
    "city": "City",
    "country": "Deutschland"
  },
  "contact": {
    "phone": "+49 123 456789",
    "email": "info@example.com",
    "website": "www.example.com"
  },
  "tax_id": "123/456/78901",
  "vat_id": "DE123456789",
  "business_owner": "Your Name",
  "bank_account": {
    "bank_name": "Bank Name",
    "account_holder": "Your Company Name",
    "iban": "DE89 3704 0044 0532 0130 00",
    "bic": "COBADEFFXXX"
  }
}"#;
    
    fs::write(base.join("data/company.json"), company_template)?;
    
    // Create .gitignore
    let gitignore = "output/*.pdf\n*.pdf\n.DS_Store\n";
    fs::write(base.join(".gitignore"), gitignore)?;
    
    println!("{} Project created successfully!", "✓".green());
    println!("\nNext steps:");
    println!("  1. Edit {}/data/company.json with your company data", name);
    println!("  2. Copy templates from typst-business-templates to {}/templates", name);
    println!("  3. Create documents with: docgen new invoice INV-2025-001");
    println!("  4. Compile with: docgen compile invoices/INV-2025-001.json");
    
    Ok(())
}

fn compile_document(input: &Path, output: Option<PathBuf>, template: Option<String>) -> Result<()> {
    if !input.exists() {
        anyhow::bail!("Input file not found: {}", input.display());
    }
    
    // Determine template type from filename or argument
    let doc_type = template.unwrap_or_else(|| {
        detect_document_type(input).unwrap_or_else(|| "invoice".to_string())
    });
    
    let template_path = format!("templates/{}/default.typ", doc_type);
    
    // Determine output path
    let output_path = output.unwrap_or_else(|| {
        input.with_extension("pdf")
    });
    
    println!("{} Compiling {} → {}", 
        "→".blue(), 
        input.display().to_string().cyan(),
        output_path.display().to_string().green()
    );
    
    // Build typst command
    let data_path = format!("/{}", input.display());
    
    let status = Command::new("typst")
        .args([
            "compile",
            "--root", ".",
            &template_path,
            "--input", &format!("data={}", data_path),
            &output_path.to_string_lossy(),
        ])
        .status()
        .context("Failed to execute typst. Is Typst installed?")?;
    
    if status.success() {
        println!("{} Document compiled successfully!", "✓".green());
        Ok(())
    } else {
        anyhow::bail!("Typst compilation failed")
    }
}

fn build_all(path: &Path, output: &Path) -> Result<()> {
    println!("{} Building all documents in {}", "→".blue(), path.display());
    
    fs::create_dir_all(output)?;
    
    let mut count = 0;
    let mut errors = 0;
    
    for entry in WalkDir::new(path)
        .into_iter()
        .filter_map(|e| e.ok())
        .filter(|e| e.path().extension().map_or(false, |ext| ext == "json"))
        .filter(|e| !e.path().to_string_lossy().contains("schema"))
        .filter(|e| !e.path().to_string_lossy().contains("company.json"))
    {
        let input = entry.path();
        let output_file = output.join(input.file_stem().unwrap()).with_extension("pdf");
        
        match compile_document(input, Some(output_file), None) {
            Ok(_) => count += 1,
            Err(e) => {
                eprintln!("{} Error compiling {}: {}", "✗".red(), input.display(), e);
                errors += 1;
            }
        }
    }
    
    println!("\n{} Built {} documents ({} errors)", 
        if errors == 0 { "✓".green() } else { "!".yellow() },
        count,
        errors
    );
    
    Ok(())
}

fn watch_directory(path: &Path) -> Result<()> {
    use notify::{Config, RecommendedWatcher, RecursiveMode, Watcher, EventKind};
    use std::sync::mpsc::channel;
    use std::time::Duration;
    
    println!("{} Watching for changes in {}", "→".blue(), path.display());
    println!("Press Ctrl+C to stop\n");
    
    let (tx, rx) = channel();
    
    let mut watcher = RecommendedWatcher::new(tx, Config::default())?;
    watcher.watch(path, RecursiveMode::Recursive)?;
    
    loop {
        match rx.recv_timeout(Duration::from_secs(1)) {
            Ok(Ok(event)) => {
                if matches!(event.kind, EventKind::Modify(_) | EventKind::Create(_)) {
                    for path in event.paths {
                        if path.extension().map_or(false, |ext| ext == "json") {
                            println!("\n{} Change detected: {}", "⟳".yellow(), path.display());
                            let _ = compile_document(&path, None, None);
                        }
                    }
                }
            }
            Ok(Err(e)) => eprintln!("Watch error: {}", e),
            Err(_) => {} // Timeout, continue
        }
    }
}

fn validate_json(input: &Path) -> Result<()> {
    println!("{} Validating {}", "→".blue(), input.display());
    
    let content = fs::read_to_string(input)?;
    let json: Value = serde_json::from_str(&content)
        .context("Invalid JSON syntax")?;
    
    // Basic validation
    if json.get("metadata").is_none() {
        println!("{} Warning: No 'metadata' field found", "!".yellow());
    }
    
    println!("{} JSON is valid", "✓".green());
    Ok(())
}

fn create_new_document(doc_type: &str, id: &str) -> Result<()> {
    let template = match doc_type {
        "invoice" => include_str!("../templates/invoice.json"),
        "offer" => include_str!("../templates/offer.json"),
        "credentials" => include_str!("../templates/credentials.json"),
        "concept" => include_str!("../templates/concept.json"),
        _ => anyhow::bail!("Unknown document type: {}. Use: invoice, offer, credentials, concept", doc_type),
    };
    
    // Replace placeholder ID
    let content = template.replace("DOCUMENT_ID", id);
    
    let dir = match doc_type {
        "invoice" => "invoices",
        "offer" => "offers",
        "credentials" => "credentials",
        "concept" => "concepts",
        _ => doc_type,
    };
    
    fs::create_dir_all(dir)?;
    let output_path = format!("{}/{}.json", dir, id);
    
    fs::write(&output_path, content)?;
    
    println!("{} Created {}", "✓".green(), output_path.cyan());
    println!("Edit the file and run: docgen compile {}", output_path);
    
    Ok(())
}

fn detect_document_type(path: &Path) -> Option<String> {
    let path_str = path.to_string_lossy().to_lowercase();
    
    if path_str.contains("invoice") || path_str.contains("rechnung") {
        Some("invoice".to_string())
    } else if path_str.contains("offer") || path_str.contains("angebot") {
        Some("offer".to_string())
    } else if path_str.contains("credential") || path_str.contains("zugang") || path_str.contains("acc-") {
        Some("credentials".to_string())
    } else if path_str.contains("concept") || path_str.contains("konzept") || path_str.contains("kon-") {
        Some("concept".to_string())
    } else {
        None
    }
}

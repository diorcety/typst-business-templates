use anyhow::Result;
use colored::Colorize;

use crate::local_templates;
use crate::TemplateAction;

pub fn handle(action: TemplateAction) -> Result<()> {
    match action {
        TemplateAction::Init => {
            println!("{} Initializing project templates...", "→".blue());
            local_templates::init_project()?;
            println!("{} Project initialized successfully!", "✓".green());
            println!();
            println!("Created:");
            println!("  .docgen/templates/  (standard templates, auto-updated)");
            println!("  templates/          (custom templates, stable)");
            println!("  .gitignore          (updated to exclude .docgen/)");
            println!();
            println!("Import in .typ files:");
            println!("  #import \"/.docgen/templates/concept/default.typ\": concept");
        }

        TemplateAction::Fork { template, name } => {
            println!(
                "{} Forking template '{}' to 'templates/{}'...",
                "→".blue(),
                template,
                name
            );
            local_templates::fork_template(&template, &name)?;
            println!("{} Template forked successfully!", "✓".green());
            println!();
            println!("Custom template created at: templates/{}/", name);
            println!("This template is now stable and will never be auto-updated.");
            println!();
            println!("Import in .typ files:");
            println!(
                "  #import \"/templates/{}/default.typ\": {}",
                name,
                name.replace('-', "_")
            );
            println!();
            println!("Commit to Git:");
            println!("  git add templates/{}/", name);
            println!("  git commit -m \"Add custom template: {}\"", name);
        }

        TemplateAction::List => {
            // List standard templates
            let standard_dir = local_templates::get_local_templates_dir();
            println!("{}", "Standard Templates (.docgen/templates/):".bold());
            println!("{}", "(Auto-updated on every compile)".dimmed());
            println!("{:-<60}", "");

            if standard_dir.exists() {
                for template in local_templates::get_available_templates() {
                    let template_path = standard_dir.join(&template);
                    if template_path.exists() {
                        println!("  {} {}", "→".blue(), template);
                    }
                }
            } else {
                println!(
                    "  {}",
                    "Not initialized. Run: docgen template init".yellow()
                );
            }

            println!();

            // List custom templates
            let custom_dir = local_templates::get_custom_templates_dir();
            println!("{}", "Custom Templates (templates/):".bold());
            println!("{}", "(Stable, never auto-updated)".dimmed());
            println!("{:-<60}", "");

            if custom_dir.exists() {
                let mut found_custom = false;
                if let Ok(entries) = std::fs::read_dir(&custom_dir) {
                    for entry in entries.filter_map(|e| e.ok()) {
                        if entry.file_type().ok().map(|t| t.is_dir()).unwrap_or(false) {
                            let name = entry.file_name();
                            let name_str = name.to_string_lossy();
                            if name_str != ".gitkeep" {
                                println!("  {} {}", "→".green(), name_str);
                                found_custom = true;
                            }
                        }
                    }
                }
                if !found_custom {
                    println!("  {}", "No custom templates. Fork with: docgen template fork <name> --name <custom-name>".yellow());
                }
            } else {
                println!(
                    "  {}",
                    "Not initialized. Run: docgen template init".yellow()
                );
            }
        }

        TemplateAction::Update => {
            println!("{} Updating standard templates...", "→".blue());
            local_templates::ensure_local_templates_updated()?;
            println!(
                "{} Standard templates updated to v{}",
                "✓".green(),
                local_templates::get_docgen_version()
            );
        }
    }
    Ok(())
}

use anyhow::Result;
use colored::Colorize;

use crate::commands::client::parse_client_id;
use crate::data::{ClientStore, CounterStore, NewProject, ProjectStore};
use crate::locale::{t, tf};
use crate::ProjectAction;

pub fn handle(action: ProjectAction) -> Result<()> {
    let client_store = ClientStore::default();
    let project_store = ProjectStore::default();
    let mut counter_store = CounterStore::default();

    match action {
        ProjectAction::List { client } => {
            let client_id = parse_client_id(&client_store, &client)?;
            let client = client_store
                .get(client_id)?
                .ok_or_else(|| anyhow::anyhow!("Client not found"))?;
            let projects = project_store.list_by_client(client_id)?;

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
            let client_id = parse_client_id(&client_store, &client)?;
            let client_data = client_store
                .get(client_id)?
                .ok_or_else(|| anyhow::anyhow!("Client not found"))?;

            let new_project = NewProject::new(client_id, name);
            let project = project_store.add(new_project, &mut counter_store)?;

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
        ProjectAction::Delete { id } => {
            // Parse project ID (e.g., "P-001-01")
            let parts: Vec<&str> = id.trim_start_matches("P-").split('-').collect();
            if parts.len() != 2 {
                anyhow::bail!("Invalid project ID format. Expected: P-XXX-YY");
            }

            let projects = project_store.list()?;
            let project = projects
                .iter()
                .find(|p| {
                    let expected = format!("P-{:03}-{:02}", p.client_id, p.number);
                    expected == id
                        || format!("P-{}-{}", parts[0], parts[1])
                            == format!("P-{}-{}", p.client_id, p.number)
                })
                .ok_or_else(|| anyhow::anyhow!("Project not found: {}", id))?;

            let client = client_store
                .get(project.client_id)?
                .ok_or_else(|| anyhow::anyhow!("Client not found"))?;

            println!(
                "{} Deleting project {} - {}",
                "⚠".yellow(),
                project.formatted_number(client.number).cyan(),
                project.name
            );

            project_store.delete(project.id)?;
            println!("{} Project deleted successfully", "✓".green());
        }
    }
    Ok(())
}

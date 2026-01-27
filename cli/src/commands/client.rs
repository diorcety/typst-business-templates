use anyhow::Result;
use colored::Colorize;

use crate::data::{ClientStore, CounterStore, NewClient, ProjectStore};
use crate::locale::{t, tf};
use crate::ClientAction;

pub fn handle(action: ClientAction) -> Result<()> {
    let client_store = ClientStore::default();
    let mut counter_store = CounterStore::default();

    match action {
        ClientAction::List => {
            let clients = client_store.list()?;
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
            let name = name.ok_or_else(|| {
                anyhow::anyhow!("Name required. Usage: docgen client add --name \"Client Name\"")
            })?;

            let new_client = NewClient {
                name,
                ..Default::default()
            };

            let client = client_store.add(new_client, &mut counter_store)?;
            println!(
                "{} {}",
                "✓".green(),
                tf("client", "created", &[&client.formatted_number()])
            );
        }
        ClientAction::Show { id } => {
            let client_id = parse_client_id(&client_store, &id)?;
            let client = client_store
                .get(client_id)?
                .ok_or_else(|| anyhow::anyhow!("Client not found"))?;

            let project_store = ProjectStore::default();
            let projects = project_store.list_by_client(client_id)?;

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
        }
        ClientAction::Delete { id } => {
            let client_id = parse_client_id(&client_store, &id)?;
            let client = client_store
                .get(client_id)?
                .ok_or_else(|| anyhow::anyhow!("Client not found"))?;

            println!(
                "{} Deleting client {} - {}",
                "⚠".yellow(),
                client.formatted_number().cyan(),
                client.display_name()
            );

            // Check if client has projects
            let project_store = ProjectStore::default();
            let projects = project_store.list_by_client(client_id)?;

            if !projects.is_empty() {
                println!(
                    "{} Client has {} project(s). Delete projects first or use --force (not implemented yet)",
                    "✗".red(),
                    projects.len()
                );
                anyhow::bail!("Cannot delete client with existing projects");
            }

            client_store.delete(client_id)?;
            println!("{} Client deleted successfully", "✓".green());
        }
    }
    Ok(())
}

/// Parse client ID from various input formats (K-001, 1, etc.)
pub fn parse_client_id(store: &ClientStore, input: &str) -> Result<i64> {
    // Try direct number
    if let Ok(num) = input.parse::<i64>() {
        // Check if it's a client number or ID
        let clients = store.list()?;
        if let Some(c) = clients.iter().find(|c| c.number == num || c.id == num) {
            return Ok(c.id);
        }
    }

    // Try K-XXX format
    if input.to_uppercase().starts_with("K-") {
        if let Ok(num) = input[2..].parse::<i64>() {
            let clients = store.list()?;
            if let Some(c) = clients.iter().find(|c| c.number == num) {
                return Ok(c.id);
            }
        }
    }

    anyhow::bail!("Client not found: {}", input)
}

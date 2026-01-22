use anyhow::Result;
use comfy_table::{presets::UTF8_FULL_CONDENSED, ContentArrangement, Table};
use console::{style, Term};
use dialoguer::{Confirm, Input, Select};

use crate::db::{Client, Database, Document, NewClient, NewDocument, NewProject, Project};
use crate::locale::{t, tf};

pub struct InteractiveUI {
    db: Database,
    term: Term,
}

impl InteractiveUI {
    pub fn new(db: Database) -> Self {
        Self {
            db,
            term: Term::stdout(),
        }
    }

    pub fn run(&mut self) -> Result<()> {
        loop {
            self.clear_screen();
            self.print_header();

            match self.main_menu()? {
                MainAction::SelectClient(id) => self.client_view(id)?,
                MainAction::NewClient => self.new_client()?,
                MainAction::Quit => break,
            }
        }
        Ok(())
    }

    fn clear_screen(&self) {
        let _ = self.term.clear_screen();
    }

    fn print_header(&self) {
        let title = t("app", "name");
        let padding = 55 - title.len() - 2;
        println!(
            "{}",
            style("╔═══════════════════════════════════════════════════════╗").cyan()
        );
        println!(
            "{}",
            style(format!("║  {}{:width$}║", title, "", width = padding)).cyan()
        );
        println!(
            "{}",
            style("╚═══════════════════════════════════════════════════════╝").cyan()
        );
        println!();
    }

    fn main_menu(&self) -> Result<MainAction> {
        let clients = self.db.list_clients()?;

        if clients.is_empty() {
            println!("{}", style(t("client", "no_clients")).dim());
            println!();

            if Confirm::new()
                .with_prompt(t("client", "create_first"))
                .default(true)
                .interact()?
            {
                return Ok(MainAction::NewClient);
            }
            return Ok(MainAction::Quit);
        }

        // Display client table
        println!(
            "{} ({})",
            style(t("client", "clients")).bold(),
            clients.len()
        );
        println!();

        let mut table = Table::new();
        table.load_preset(UTF8_FULL_CONDENSED);
        table.set_content_arrangement(ContentArrangement::Dynamic);
        table.set_header(vec![
            "#",
            "Nr.",
            t("common", "name").as_str(),
            t("client", "city").as_str(),
            t("common", "email").as_str(),
        ]);

        for (i, client) in clients.iter().enumerate() {
            table.add_row(vec![
                format!("{}", i + 1),
                client.formatted_number(),
                client.display_name(),
                client.city.clone().unwrap_or_default(),
                client.email.clone().unwrap_or_default(),
            ]);
        }

        println!("{table}");
        println!();

        // Build selection items
        let mut items: Vec<String> = clients
            .iter()
            .enumerate()
            .map(|(i, c)| format!("{} - {}", i + 1, c.display_name()))
            .collect();
        items.push(format!("+ {}", t("client", "new_client")));
        items.push(t("common", "quit"));

        let selection = Select::new()
            .with_prompt(t("common", "selection"))
            .items(&items)
            .default(0)
            .interact()?;

        if selection < clients.len() {
            Ok(MainAction::SelectClient(clients[selection].id))
        } else if selection == clients.len() {
            Ok(MainAction::NewClient)
        } else {
            Ok(MainAction::Quit)
        }
    }

    fn client_view(&mut self, client_id: i64) -> Result<()> {
        loop {
            self.clear_screen();

            let client = self.db.get_client(client_id)?;
            let projects = self.db.list_projects_for_client(client_id)?;
            let documents = self.db.list_documents_for_client(client_id)?;

            // Client header
            println!(
                "{}",
                style("╔═══════════════════════════════════════════════════════╗").green()
            );
            println!(
                "{}  {:50} {}",
                style("║").green(),
                style(client.display_name()).bold(),
                style(format!("{}║", client.formatted_number())).green()
            );
            if !client.full_address().is_empty() {
                println!(
                    "{}  {:53}{}",
                    style("║").green(),
                    client.full_address(),
                    style("║").green()
                );
            }
            if let Some(email) = &client.email {
                println!("{}  {:53}{}", style("║").green(), email, style("║").green());
            }
            println!(
                "{}",
                style("╚═══════════════════════════════════════════════════════╝").green()
            );
            println!();

            // Projects
            if !projects.is_empty() {
                println!(
                    "{} ({})",
                    style(t("project", "projects")).bold(),
                    projects.len()
                );
                let mut table = Table::new();
                table.load_preset(UTF8_FULL_CONDENSED);
                table.set_header(vec![
                    "Nr.",
                    t("common", "name").as_str(),
                    t("common", "status").as_str(),
                ]);
                for p in &projects {
                    table.add_row(vec![
                        p.formatted_number(client.number),
                        p.name.clone(),
                        p.status.clone(),
                    ]);
                }
                println!("{table}");
                println!();
            }

            // Documents
            if !documents.is_empty() {
                println!("{}", style(t("document", "last_documents")).bold());
                let mut table = Table::new();
                table.load_preset(UTF8_FULL_CONDENSED);
                table.set_header(vec![
                    t("document", "number").as_str(),
                    t("document", "type").as_str(),
                    t("common", "date").as_str(),
                    t("common", "amount").as_str(),
                    t("common", "status").as_str(),
                ]);
                for d in &documents {
                    table.add_row(vec![
                        d.doc_number.clone(),
                        d.type_display().to_string(),
                        d.created_at
                            .split('T')
                            .next()
                            .unwrap_or(&d.created_at)
                            .to_string(),
                        d.amount.map(|a| format!("{:.2} €", a)).unwrap_or_default(),
                        d.status_display().to_string(),
                    ]);
                }
                println!("{table}");
                println!();
            }

            // Actions
            let items = vec![
                t("document", "create_invoice"),
                t("document", "create_offer"),
                t("document", "create_credentials"),
                t("document", "create_concept"),
                t("project", "new_project"),
                format!("← {}", t("common", "back")),
            ];

            let selection = Select::new()
                .with_prompt(t("common", "action"))
                .items(&items)
                .default(0)
                .interact()?;

            match selection {
                0 => self.create_document(&client, &projects, "invoice")?,
                1 => self.create_document(&client, &projects, "offer")?,
                2 => self.create_document(&client, &projects, "credentials")?,
                3 => self.create_document(&client, &projects, "concept")?,
                4 => self.new_project(client_id)?,
                5 => break,
                _ => {}
            }
        }
        Ok(())
    }

    fn new_client(&mut self) -> Result<()> {
        self.clear_screen();
        println!("{}", style(t("client", "add_new")).bold().underlined());
        println!();

        let name: String = Input::new()
            .with_prompt(t("client", "contact_name"))
            .interact_text()?;

        let company: String = Input::new()
            .with_prompt(format!(
                "{} ({})",
                t("client", "company"),
                t("common", "optional")
            ))
            .allow_empty(true)
            .interact_text()?;

        let street: String = Input::new()
            .with_prompt(t("client", "street"))
            .allow_empty(true)
            .interact_text()?;

        let house_number: String = Input::new()
            .with_prompt(t("client", "house_number"))
            .allow_empty(true)
            .interact_text()?;

        let postal_code: String = Input::new()
            .with_prompt(t("client", "postal_code"))
            .allow_empty(true)
            .interact_text()?;

        let city: String = Input::new()
            .with_prompt(t("client", "city"))
            .allow_empty(true)
            .interact_text()?;

        let email: String = Input::new()
            .with_prompt(t("common", "email"))
            .allow_empty(true)
            .interact_text()?;

        let phone: String = Input::new()
            .with_prompt(t("common", "phone"))
            .allow_empty(true)
            .interact_text()?;

        let new_client = NewClient {
            name,
            company: if company.is_empty() {
                None
            } else {
                Some(company)
            },
            street: if street.is_empty() {
                None
            } else {
                Some(street)
            },
            house_number: if house_number.is_empty() {
                None
            } else {
                Some(house_number)
            },
            postal_code: if postal_code.is_empty() {
                None
            } else {
                Some(postal_code)
            },
            city: if city.is_empty() { None } else { Some(city) },
            email: if email.is_empty() { None } else { Some(email) },
            phone: if phone.is_empty() { None } else { Some(phone) },
            ..Default::default()
        };

        let client = self.db.add_client(&new_client)?;

        println!();
        println!(
            "{} {}",
            style("✓").green(),
            tf("client", "created", &[&client.formatted_number()])
        );

        std::thread::sleep(std::time::Duration::from_secs(1));
        Ok(())
    }

    fn new_project(&mut self, client_id: i64) -> Result<()> {
        println!();
        println!("{}", style(t("project", "add_new")).bold());
        println!();

        let name: String = Input::new()
            .with_prompt(t("project", "name"))
            .interact_text()?;

        let description: String = Input::new()
            .with_prompt(format!(
                "{} ({})",
                t("project", "description"),
                t("common", "optional")
            ))
            .allow_empty(true)
            .interact_text()?;

        let hourly_rate: String = Input::new()
            .with_prompt(format!(
                "{} ({})",
                t("project", "hourly_rate"),
                t("common", "optional")
            ))
            .allow_empty(true)
            .interact_text()?;

        let new_project = NewProject {
            client_id,
            name,
            description: if description.is_empty() {
                None
            } else {
                Some(description)
            },
            hourly_rate: hourly_rate.parse().ok(),
            status: "active".to_string(),
        };

        let client = self.db.get_client(client_id)?;
        let project = self.db.add_project(&new_project)?;

        println!();
        println!(
            "{} {}",
            style("✓").green(),
            tf(
                "project",
                "created",
                &[&project.formatted_number(client.number)]
            )
        );

        std::thread::sleep(std::time::Duration::from_secs(1));
        Ok(())
    }

    fn create_document(
        &mut self,
        client: &Client,
        projects: &[Project],
        doc_type: &str,
    ) -> Result<()> {
        println!();

        // Select project (optional)
        let project_id = if !projects.is_empty() {
            let mut items: Vec<String> = projects.iter().map(|p| p.name.clone()).collect();
            items.push(t("project", "without"));

            let selection = Select::new()
                .with_prompt(t("project", "select"))
                .items(&items)
                .default(0)
                .interact()?;

            if selection < projects.len() {
                Some(projects[selection].id)
            } else {
                None
            }
        } else {
            None
        };

        // Determine file path
        let folder = match doc_type {
            "invoice" => "invoices",
            "offer" => "offers",
            "credentials" => "credentials",
            "concept" => "concepts",
            _ => "documents",
        };

        // Create document in database first to get number
        let mut new_doc = NewDocument::new(doc_type, String::new());
        new_doc.client_id = Some(client.id);
        new_doc.project_id = project_id;

        let doc = self.db.add_document(&new_doc)?;

        // Now create the actual file path
        let file_path = format!("documents/{}/{}.json", folder, doc.doc_number);

        // Create JSON file with client data pre-filled
        self.create_document_json(&doc, client, project_id)?;

        println!();
        println!(
            "{} {}",
            style("✓").green(),
            tf("document", "created", &[&doc.doc_number])
        );
        println!("  → {}", file_path);
        println!();
        println!("{}:", t("document", "edit_and_compile"));
        println!("  docgen compile {}", file_path);

        std::thread::sleep(std::time::Duration::from_secs(2));
        Ok(())
    }

    fn create_document_json(
        &self,
        doc: &Document,
        client: &Client,
        project_id: Option<i64>,
    ) -> Result<()> {
        let folder = match doc.doc_type.as_str() {
            "invoice" => "invoices",
            "offer" => "offers",
            "credentials" => "credentials",
            "concept" => "concepts",
            _ => "documents",
        };

        let dir_path = format!("documents/{}", folder);
        std::fs::create_dir_all(&dir_path)?;

        let file_path = format!("{}/{}.json", dir_path, doc.doc_number);

        let project_name = if let Some(pid) = project_id {
            self.db.get_project(pid).ok().map(|p| p.name)
        } else {
            None
        };

        let json_content = match doc.doc_type.as_str() {
            "invoice" => self.invoice_json(doc, client, project_name),
            "offer" => self.offer_json(doc, client, project_name),
            "credentials" => self.credentials_json(doc, client, project_name),
            "concept" => self.concept_json(doc, client, project_name),
            _ => "{}".to_string(),
        };

        std::fs::write(&file_path, json_content)?;
        Ok(())
    }

    fn invoice_json(&self, doc: &Document, client: &Client, project: Option<String>) -> String {
        let today = chrono::Local::now();
        let due = today + chrono::Duration::days(14);

        format!(
            r#"{{
  "metadata": {{
    "invoice_number": "{}",
    "invoice_date": "{}",
    "due_date": "{}",
    "customer_number": "{}"
  }},
  "recipient": {{
    "name": "{}",
    "company": {},
    "address": {{
      "street": "{}",
      "house_number": "{}",
      "postal_code": "{}",
      "city": "{}"
    }}
  }},
  "project": {},
  "items": [
    {{
      "description": "Leistungsbeschreibung",
      "quantity": 1,
      "unit": "Stück",
      "unit_price": "0,00 EUR",
      "total_price": "0,00 EUR"
    }}
  ],
  "totals": {{
    "subtotal": "0,00 EUR",
    "tax_rate": "19%",
    "tax_amount": "0,00 EUR",
    "total": "0,00 EUR"
  }},
  "notes": null,
  "terms": null
}}"#,
            doc.doc_number,
            today.format("%d.%m.%Y"),
            due.format("%d.%m.%Y"),
            client.formatted_number(),
            client.name,
            client
                .company
                .as_ref()
                .map(|c| format!("\"{}\"", c))
                .unwrap_or("null".to_string()),
            client.street.as_deref().unwrap_or(""),
            client.house_number.as_deref().unwrap_or(""),
            client.postal_code.as_deref().unwrap_or(""),
            client.city.as_deref().unwrap_or(""),
            project
                .map(|p| format!("\"{}\"", p))
                .unwrap_or("null".to_string()),
        )
    }

    fn offer_json(&self, doc: &Document, client: &Client, project: Option<String>) -> String {
        let today = chrono::Local::now();
        let valid = today + chrono::Duration::days(30);

        format!(
            r#"{{
  "metadata": {{
    "offer_number": "{}",
    "offer_date": "{}",
    "valid_until": "{}",
    "version": "1.0"
  }},
  "recipient": {{
    "name": "{}",
    "company": {},
    "address": {{
      "street": "{}",
      "house_number": "{}",
      "postal_code": "{}",
      "city": "{}"
    }}
  }},
  "project": {},
  "items": [
    {{
      "position": 1,
      "title": "Leistung",
      "description": "Beschreibung",
      "quantity": 1,
      "unit": "Pauschal",
      "unit_price": "0,00 EUR",
      "total": "0,00 EUR",
      "sub_items": []
    }}
  ],
  "totals": {{
    "subtotal": "0,00 EUR",
    "total": "0,00 EUR"
  }},
  "terms": {{
    "validity": "30 Tage",
    "payment_terms": "14 Tage nach Rechnungsstellung",
    "delivery_terms": null
  }},
  "notes": null
}}"#,
            doc.doc_number,
            today.format("%d.%m.%Y"),
            valid.format("%d.%m.%Y"),
            client.name,
            client
                .company
                .as_ref()
                .map(|c| format!("\"{}\"", c))
                .unwrap_or("null".to_string()),
            client.street.as_deref().unwrap_or(""),
            client.house_number.as_deref().unwrap_or(""),
            client.postal_code.as_deref().unwrap_or(""),
            client.city.as_deref().unwrap_or(""),
            project
                .map(|p| format!("\"{}\"", p))
                .unwrap_or("null".to_string()),
        )
    }

    fn credentials_json(&self, doc: &Document, client: &Client, project: Option<String>) -> String {
        let today = chrono::Local::now();

        format!(
            r#"{{
  "metadata": {{
    "document_number": "{}",
    "title": "Zugangsdaten {}",
    "client_name": "{}",
    "project_name": "{}",
    "created_at": "{}",
    "tags": ["Zugangsdaten"]
  }},
  "services": [
    {{
      "name": "Service Name",
      "provider": null,
      "description": null,
      "technical": [],
      "ports": [],
      "credentials": [
        {{
          "name": "Admin",
          "username": "admin",
          "password": "CHANGE_ME",
          "role": "Administrator",
          "notes": null
        }}
      ],
      "notes": null
    }}
  ]
}}"#,
            doc.doc_number,
            project.as_deref().unwrap_or("Projekt"),
            client.display_name(),
            project.clone().unwrap_or_else(|| "Projekt".to_string()),
            today.format("%d.%m.%Y"),
        )
    }

    fn concept_json(&self, doc: &Document, client: &Client, project: Option<String>) -> String {
        let today = chrono::Local::now();

        format!(
            r#"{{
  "metadata": {{
    "document_number": "{}",
    "title": "Konzept: {}",
    "client_name": "{}",
    "project_name": "{}",
    "version": "1.0",
    "status": "draft",
    "created_at": "{}",
    "tags": ["Konzept"],
    "show_toc": false
  }},
  "content": "= Einleitung\n\nHier beginnt der Inhalt.\n\n= Analyse\n\n== Ist-Zustand\n\nBeschreibung.\n\n== Soll-Zustand\n\nZiel.\n\n= Umsetzung\n\nVorgehensweise."
}}"#,
            doc.doc_number,
            project.as_deref().unwrap_or("Projekt"),
            client.display_name(),
            project.clone().unwrap_or_else(|| "Projekt".to_string()),
            today.format("%d.%m.%Y"),
        )
    }
}

enum MainAction {
    SelectClient(i64),
    NewClient,
    Quit,
}

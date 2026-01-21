use anyhow::{Context, Result};
use rusqlite::{Connection, params};
use std::path::Path;

pub mod models;
pub use models::*;

pub struct Database {
    conn: Connection,
}

impl Database {
    pub fn open(path: &Path) -> Result<Self> {
        let conn = Connection::open(path)
            .with_context(|| format!("Failed to open database: {}", path.display()))?;
        
        let db = Self { conn };
        db.init_schema()?;
        Ok(db)
    }

    pub fn open_default() -> Result<Self> {
        let path = Path::new("data/docgen.db");
        if let Some(parent) = path.parent() {
            std::fs::create_dir_all(parent)?;
        }
        Self::open(path)
    }

    fn init_schema(&self) -> Result<()> {
        self.conn.execute_batch(r#"
            CREATE TABLE IF NOT EXISTS clients (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                number INTEGER UNIQUE NOT NULL,
                name TEXT NOT NULL,
                company TEXT,
                street TEXT,
                house_number TEXT,
                postal_code TEXT,
                city TEXT,
                country TEXT DEFAULT 'Deutschland',
                email TEXT,
                phone TEXT,
                notes TEXT,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP
            );

            CREATE TABLE IF NOT EXISTS projects (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                number INTEGER NOT NULL,
                client_id INTEGER NOT NULL,
                name TEXT NOT NULL,
                description TEXT,
                hourly_rate REAL,
                status TEXT DEFAULT 'active',
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (client_id) REFERENCES clients(id),
                UNIQUE(client_id, number)
            );

            CREATE TABLE IF NOT EXISTS documents (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                doc_type TEXT NOT NULL,
                doc_number TEXT UNIQUE NOT NULL,
                client_id INTEGER,
                project_id INTEGER,
                file_path TEXT NOT NULL,
                amount REAL,
                status TEXT DEFAULT 'draft',
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                due_date TEXT,
                FOREIGN KEY (client_id) REFERENCES clients(id),
                FOREIGN KEY (project_id) REFERENCES projects(id)
            );

            CREATE TABLE IF NOT EXISTS counters (
                name TEXT PRIMARY KEY,
                value INTEGER NOT NULL DEFAULT 0
            );

            INSERT OR IGNORE INTO counters (name, value) VALUES ('client', 0);
            INSERT OR IGNORE INTO counters (name, value) VALUES ('invoice', 0);
            INSERT OR IGNORE INTO counters (name, value) VALUES ('offer', 0);
            INSERT OR IGNORE INTO counters (name, value) VALUES ('credentials', 0);
            INSERT OR IGNORE INTO counters (name, value) VALUES ('concept', 0);
        "#)?;
        Ok(())
    }

    pub fn next_number(&self, counter_name: &str) -> Result<i64> {
        self.conn.execute(
            "UPDATE counters SET value = value + 1 WHERE name = ?",
            params![counter_name],
        )?;
        let num: i64 = self.conn.query_row(
            "SELECT value FROM counters WHERE name = ?",
            params![counter_name],
            |row| row.get(0),
        )?;
        Ok(num)
    }

    // Client methods
    pub fn add_client(&self, client: &NewClient) -> Result<Client> {
        let number = self.next_number("client")?;
        
        self.conn.execute(
            r#"INSERT INTO clients (number, name, company, street, house_number, postal_code, city, country, email, phone, notes)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"#,
            params![
                number,
                client.name,
                client.company,
                client.street,
                client.house_number,
                client.postal_code,
                client.city,
                client.country,
                client.email,
                client.phone,
                client.notes,
            ],
        )?;

        let id = self.conn.last_insert_rowid();
        self.get_client(id)
    }

    pub fn get_client(&self, id: i64) -> Result<Client> {
        self.conn.query_row(
            "SELECT id, number, name, company, street, house_number, postal_code, city, country, email, phone, notes, created_at FROM clients WHERE id = ?",
            params![id],
            |row| Ok(Client {
                id: row.get(0)?,
                number: row.get(1)?,
                name: row.get(2)?,
                company: row.get(3)?,
                street: row.get(4)?,
                house_number: row.get(5)?,
                postal_code: row.get(6)?,
                city: row.get(7)?,
                country: row.get(8)?,
                email: row.get(9)?,
                phone: row.get(10)?,
                notes: row.get(11)?,
                created_at: row.get(12)?,
            }),
        ).context("Client not found")
    }

    pub fn list_clients(&self) -> Result<Vec<Client>> {
        let mut stmt = self.conn.prepare(
            "SELECT id, number, name, company, street, house_number, postal_code, city, country, email, phone, notes, created_at FROM clients ORDER BY number"
        )?;
        
        let clients = stmt.query_map([], |row| {
            Ok(Client {
                id: row.get(0)?,
                number: row.get(1)?,
                name: row.get(2)?,
                company: row.get(3)?,
                street: row.get(4)?,
                house_number: row.get(5)?,
                postal_code: row.get(6)?,
                city: row.get(7)?,
                country: row.get(8)?,
                email: row.get(9)?,
                phone: row.get(10)?,
                notes: row.get(11)?,
                created_at: row.get(12)?,
            })
        })?.collect::<Result<Vec<_>, _>>()?;

        Ok(clients)
    }

    // Project methods
    pub fn add_project(&self, project: &NewProject) -> Result<Project> {
        // Get next project number for this client
        let number: i64 = self.conn.query_row(
            "SELECT COALESCE(MAX(number), 0) + 1 FROM projects WHERE client_id = ?",
            params![project.client_id],
            |row| row.get(0),
        )?;

        self.conn.execute(
            r#"INSERT INTO projects (number, client_id, name, description, hourly_rate, status)
               VALUES (?, ?, ?, ?, ?, ?)"#,
            params![
                number,
                project.client_id,
                project.name,
                project.description,
                project.hourly_rate,
                project.status,
            ],
        )?;

        let id = self.conn.last_insert_rowid();
        self.get_project(id)
    }

    pub fn get_project(&self, id: i64) -> Result<Project> {
        self.conn.query_row(
            "SELECT id, number, client_id, name, description, hourly_rate, status, created_at FROM projects WHERE id = ?",
            params![id],
            |row| Ok(Project {
                id: row.get(0)?,
                number: row.get(1)?,
                client_id: row.get(2)?,
                name: row.get(3)?,
                description: row.get(4)?,
                hourly_rate: row.get(5)?,
                status: row.get(6)?,
                created_at: row.get(7)?,
            }),
        ).context("Project not found")
    }

    pub fn list_projects_for_client(&self, client_id: i64) -> Result<Vec<Project>> {
        let mut stmt = self.conn.prepare(
            "SELECT id, number, client_id, name, description, hourly_rate, status, created_at FROM projects WHERE client_id = ? ORDER BY number"
        )?;
        
        let projects = stmt.query_map(params![client_id], |row| {
            Ok(Project {
                id: row.get(0)?,
                number: row.get(1)?,
                client_id: row.get(2)?,
                name: row.get(3)?,
                description: row.get(4)?,
                hourly_rate: row.get(5)?,
                status: row.get(6)?,
                created_at: row.get(7)?,
            })
        })?.collect::<Result<Vec<_>, _>>()?;

        Ok(projects)
    }

    // Document methods
    pub fn add_document(&self, doc: &NewDocument) -> Result<Document> {
        let year = chrono::Local::now().format("%Y").to_string();
        let num = self.next_number(&doc.doc_type)?;
        
        let prefix = match doc.doc_type.as_str() {
            "invoice" => "RE",
            "offer" => "AN",
            "credentials" => "ZD",
            "concept" => "KO",
            _ => "DOC",
        };
        
        let doc_number = format!("{}-{}-{:03}", prefix, year, num);

        self.conn.execute(
            r#"INSERT INTO documents (doc_type, doc_number, client_id, project_id, file_path, amount, status, due_date)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?)"#,
            params![
                doc.doc_type,
                doc_number,
                doc.client_id,
                doc.project_id,
                doc.file_path,
                doc.amount,
                doc.status,
                doc.due_date,
            ],
        )?;

        let id = self.conn.last_insert_rowid();
        self.get_document(id)
    }

    pub fn get_document(&self, id: i64) -> Result<Document> {
        self.conn.query_row(
            "SELECT id, doc_type, doc_number, client_id, project_id, file_path, amount, status, created_at, due_date FROM documents WHERE id = ?",
            params![id],
            |row| Ok(Document {
                id: row.get(0)?,
                doc_type: row.get(1)?,
                doc_number: row.get(2)?,
                client_id: row.get(3)?,
                project_id: row.get(4)?,
                file_path: row.get(5)?,
                amount: row.get(6)?,
                status: row.get(7)?,
                created_at: row.get(8)?,
                due_date: row.get(9)?,
            }),
        ).context("Document not found")
    }

    pub fn list_documents_for_client(&self, client_id: i64) -> Result<Vec<Document>> {
        let mut stmt = self.conn.prepare(
            "SELECT id, doc_type, doc_number, client_id, project_id, file_path, amount, status, created_at, due_date FROM documents WHERE client_id = ? ORDER BY created_at DESC LIMIT 10"
        )?;
        
        let docs = stmt.query_map(params![client_id], |row| {
            Ok(Document {
                id: row.get(0)?,
                doc_type: row.get(1)?,
                doc_number: row.get(2)?,
                client_id: row.get(3)?,
                project_id: row.get(4)?,
                file_path: row.get(5)?,
                amount: row.get(6)?,
                status: row.get(7)?,
                created_at: row.get(8)?,
                due_date: row.get(9)?,
            })
        })?.collect::<Result<Vec<_>, _>>()?;

        Ok(docs)
    }
}

use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::fs;
use std::path::{Path, PathBuf};

pub mod models;
pub use models::*;

/// Simple JSON-based storage for clients
pub struct ClientStore {
    path: PathBuf,
}

impl ClientStore {
    pub fn new<P: AsRef<Path>>(path: P) -> Self {
        Self {
            path: path.as_ref().to_path_buf(),
        }
    }

    pub fn default() -> Self {
        Self::new("data/clients.json")
    }

    /// Ensure data directory exists
    fn ensure_dir(&self) -> Result<()> {
        if let Some(parent) = self.path.parent() {
            fs::create_dir_all(parent)?;
        }
        Ok(())
    }

    /// Initialize empty clients file if it doesn't exist
    pub fn init(&self) -> Result<()> {
        self.ensure_dir()?;
        if !self.path.exists() {
            fs::write(&self.path, "[]")?;
        }
        Ok(())
    }

    /// List all clients
    pub fn list(&self) -> Result<Vec<Client>> {
        if !self.path.exists() {
            return Ok(Vec::new());
        }

        let content = fs::read_to_string(&self.path)
            .with_context(|| format!("Failed to read {}", self.path.display()))?;

        let clients: Vec<Client> = serde_json::from_str(&content)
            .with_context(|| format!("Failed to parse {}", self.path.display()))?;

        Ok(clients)
    }

    /// Get client by ID
    pub fn get(&self, id: i64) -> Result<Option<Client>> {
        let clients = self.list()?;
        Ok(clients.into_iter().find(|c| c.id == id))
    }

    /// Get client by number (K-XXX)
    pub fn get_by_number(&self, number: i64) -> Result<Option<Client>> {
        let clients = self.list()?;
        Ok(clients.into_iter().find(|c| c.number == number))
    }

    /// Add new client (assigns ID and number automatically)
    pub fn add(&self, new_client: NewClient, counter: &mut CounterStore) -> Result<Client> {
        self.init()?;

        let mut clients = self.list()?;
        let next_id = clients.iter().map(|c| c.id).max().unwrap_or(0) + 1;
        let next_number = counter.next("client")?;

        let client = Client {
            id: next_id,
            number: next_number,
            name: new_client.name,
            company: new_client.company,
            street: new_client.street,
            house_number: new_client.house_number,
            postal_code: new_client.postal_code,
            city: new_client.city,
            country: new_client.country,
            email: new_client.email,
            phone: new_client.phone,
            notes: new_client.notes,
            created_at: chrono::Utc::now().to_rfc3339(),
        };

        clients.push(client.clone());
        self.save(&clients)?;

        Ok(client)
    }

    /// Save all clients
    fn save(&self, clients: &[Client]) -> Result<()> {
        let json = serde_json::to_string_pretty(clients)?;
        fs::write(&self.path, json)
            .with_context(|| format!("Failed to write {}", self.path.display()))?;
        Ok(())
    }
}

/// Simple JSON-based storage for projects
pub struct ProjectStore {
    path: PathBuf,
}

impl ProjectStore {
    pub fn new<P: AsRef<Path>>(path: P) -> Self {
        Self {
            path: path.as_ref().to_path_buf(),
        }
    }

    pub fn default() -> Self {
        Self::new("data/projects.json")
    }

    fn ensure_dir(&self) -> Result<()> {
        if let Some(parent) = self.path.parent() {
            fs::create_dir_all(parent)?;
        }
        Ok(())
    }

    pub fn init(&self) -> Result<()> {
        self.ensure_dir()?;
        if !self.path.exists() {
            fs::write(&self.path, "[]")?;
        }
        Ok(())
    }

    pub fn list(&self) -> Result<Vec<Project>> {
        if !self.path.exists() {
            return Ok(Vec::new());
        }

        let content = fs::read_to_string(&self.path)
            .with_context(|| format!("Failed to read {}", self.path.display()))?;

        let projects: Vec<Project> = serde_json::from_str(&content)
            .with_context(|| format!("Failed to parse {}", self.path.display()))?;

        Ok(projects)
    }

    pub fn list_by_client(&self, client_id: i64) -> Result<Vec<Project>> {
        let projects = self.list()?;
        Ok(projects
            .into_iter()
            .filter(|p| p.client_id == client_id)
            .collect())
    }

    pub fn get(&self, id: i64) -> Result<Option<Project>> {
        let projects = self.list()?;
        Ok(projects.into_iter().find(|p| p.id == id))
    }

    pub fn add(&self, new_project: NewProject, counter: &mut CounterStore) -> Result<Project> {
        self.init()?;

        let mut projects = self.list()?;
        let next_id = projects.iter().map(|p| p.id).max().unwrap_or(0) + 1;

        // Project number is per-client
        let client_projects = projects
            .iter()
            .filter(|p| p.client_id == new_project.client_id)
            .map(|p| p.number)
            .max()
            .unwrap_or(0);
        let next_number = client_projects + 1;

        let project = Project {
            id: next_id,
            number: next_number,
            client_id: new_project.client_id,
            name: new_project.name,
            description: new_project.description,
            hourly_rate: new_project.hourly_rate,
            status: new_project.status,
            created_at: chrono::Utc::now().to_rfc3339(),
        };

        projects.push(project.clone());
        self.save(&projects)?;

        Ok(project)
    }

    fn save(&self, projects: &[Project]) -> Result<()> {
        let json = serde_json::to_string_pretty(projects)?;
        fs::write(&self.path, json)
            .with_context(|| format!("Failed to write {}", self.path.display()))?;
        Ok(())
    }
}

/// Counter store for auto-incrementing document numbers
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Counters {
    #[serde(default)]
    pub client: i64,
    #[serde(default)]
    pub invoice: i64,
    #[serde(default)]
    pub offer: i64,
    #[serde(default)]
    pub credentials: i64,
    #[serde(default)]
    pub concept: i64,
    #[serde(default)]
    pub documentation: i64,
}

impl Default for Counters {
    fn default() -> Self {
        Self {
            client: 0,
            invoice: 0,
            offer: 0,
            credentials: 0,
            concept: 0,
            documentation: 0,
        }
    }
}

pub struct CounterStore {
    path: PathBuf,
}

impl CounterStore {
    pub fn new<P: AsRef<Path>>(path: P) -> Self {
        Self {
            path: path.as_ref().to_path_buf(),
        }
    }

    pub fn default() -> Self {
        Self::new("data/counters.json")
    }

    fn ensure_dir(&self) -> Result<()> {
        if let Some(parent) = self.path.parent() {
            fs::create_dir_all(parent)?;
        }
        Ok(())
    }

    pub fn init(&self) -> Result<()> {
        self.ensure_dir()?;
        if !self.path.exists() {
            let counters = Counters::default();
            self.save(&counters)?;
        }
        Ok(())
    }

    fn load(&self) -> Result<Counters> {
        if !self.path.exists() {
            return Ok(Counters::default());
        }

        let content = fs::read_to_string(&self.path)
            .with_context(|| format!("Failed to read {}", self.path.display()))?;

        let counters: Counters = serde_json::from_str(&content)
            .with_context(|| format!("Failed to parse {}", self.path.display()))?;

        Ok(counters)
    }

    fn save(&self, counters: &Counters) -> Result<()> {
        let json = serde_json::to_string_pretty(counters)?;
        fs::write(&self.path, json)
            .with_context(|| format!("Failed to write {}", self.path.display()))?;
        Ok(())
    }

    /// Get next number for a counter type
    pub fn next(&mut self, counter_type: &str) -> Result<i64> {
        self.init()?;

        let mut counters = self.load()?;

        let next = match counter_type {
            "client" => {
                counters.client += 1;
                counters.client
            }
            "invoice" => {
                counters.invoice += 1;
                counters.invoice
            }
            "offer" => {
                counters.offer += 1;
                counters.offer
            }
            "credentials" => {
                counters.credentials += 1;
                counters.credentials
            }
            "concept" => {
                counters.concept += 1;
                counters.concept
            }
            "documentation" => {
                counters.documentation += 1;
                counters.documentation
            }
            _ => anyhow::bail!("Unknown counter type: {}", counter_type),
        };

        self.save(&counters)?;
        Ok(next)
    }

    /// Get current value without incrementing
    pub fn get(&self, counter_type: &str) -> Result<i64> {
        let counters = self.load()?;

        Ok(match counter_type {
            "client" => counters.client,
            "invoice" => counters.invoice,
            "offer" => counters.offer,
            "credentials" => counters.credentials,
            "concept" => counters.concept,
            "documentation" => counters.documentation,
            _ => anyhow::bail!("Unknown counter type: {}", counter_type),
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use tempfile::TempDir;

    #[test]
    fn test_client_store_basic() {
        let tmp = TempDir::new().unwrap();
        let path = tmp.path().join("clients.json");
        let store = ClientStore::new(&path);
        let mut counter = CounterStore::new(tmp.path().join("counters.json"));

        // Initially empty
        assert_eq!(store.list().unwrap().len(), 0);

        // Add client
        let new_client = NewClient {
            name: "Test Client".to_string(),
            company: Some("Test Co".to_string()),
            ..Default::default()
        };

        let client = store.add(new_client, &mut counter).unwrap();
        assert_eq!(client.number, 1);
        assert_eq!(client.name, "Test Client");

        // List clients
        let clients = store.list().unwrap();
        assert_eq!(clients.len(), 1);
        assert_eq!(clients[0].name, "Test Client");
    }

    #[test]
    fn test_counter_store() {
        let tmp = TempDir::new().unwrap();
        let path = tmp.path().join("counters.json");
        let mut store = CounterStore::new(&path);

        // First call returns 1
        assert_eq!(store.next("invoice").unwrap(), 1);

        // Second call returns 2
        assert_eq!(store.next("invoice").unwrap(), 2);

        // Different counter
        assert_eq!(store.next("offer").unwrap(), 1);

        // Get without incrementing
        assert_eq!(store.get("invoice").unwrap(), 2);
        assert_eq!(store.get("offer").unwrap(), 1);
    }

    #[test]
    fn test_project_store_per_client_numbering() {
        let tmp = TempDir::new().unwrap();
        let path = tmp.path().join("projects.json");
        let store = ProjectStore::new(&path);
        let mut counter = CounterStore::new(tmp.path().join("counters.json"));

        // Add two projects for client 1
        let p1 = store
            .add(NewProject::new(1, "Project 1".to_string()), &mut counter)
            .unwrap();
        let p2 = store
            .add(NewProject::new(1, "Project 2".to_string()), &mut counter)
            .unwrap();

        assert_eq!(p1.number, 1); // P-001-01
        assert_eq!(p2.number, 2); // P-001-02

        // Add project for client 2
        let p3 = store
            .add(NewProject::new(2, "Project 1".to_string()), &mut counter)
            .unwrap();
        assert_eq!(p3.number, 1); // P-002-01 (numbering resets per client)
    }
}

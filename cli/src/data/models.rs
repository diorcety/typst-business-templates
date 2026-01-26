use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Client {
    pub id: i64,
    pub number: i64,
    pub name: String,
    pub company: Option<String>,
    pub street: Option<String>,
    pub house_number: Option<String>,
    pub postal_code: Option<String>,
    pub city: Option<String>,
    pub country: Option<String>,
    pub email: Option<String>,
    pub phone: Option<String>,
    pub notes: Option<String>,
    pub created_at: String,
}

impl Client {
    pub fn display_name(&self) -> String {
        if let Some(company) = &self.company {
            if !company.is_empty() {
                return company.clone();
            }
        }
        self.name.clone()
    }

    pub fn formatted_number(&self) -> String {
        format!("K-{:03}", self.number)
    }

    pub fn full_address(&self) -> String {
        let mut parts = Vec::new();

        if let (Some(street), Some(num)) = (&self.street, &self.house_number) {
            parts.push(format!("{} {}", street, num));
        }

        if let (Some(postal), Some(city)) = (&self.postal_code, &self.city) {
            parts.push(format!("{} {}", postal, city));
        }

        parts.join(", ")
    }
}

#[derive(Debug, Clone)]
pub struct NewClient {
    pub name: String,
    pub company: Option<String>,
    pub street: Option<String>,
    pub house_number: Option<String>,
    pub postal_code: Option<String>,
    pub city: Option<String>,
    pub country: Option<String>,
    pub email: Option<String>,
    pub phone: Option<String>,
    pub notes: Option<String>,
}

impl Default for NewClient {
    fn default() -> Self {
        Self {
            name: String::new(),
            company: None,
            street: None,
            house_number: None,
            postal_code: None,
            city: None,
            country: Some("Deutschland".to_string()),
            email: None,
            phone: None,
            notes: None,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Project {
    pub id: i64,
    pub number: i64,
    pub client_id: i64,
    pub name: String,
    pub description: Option<String>,
    pub hourly_rate: Option<f64>,
    pub status: String,
    pub created_at: String,
}

impl Project {
    pub fn formatted_number(&self, client_number: i64) -> String {
        format!("P-{:03}-{:02}", client_number, self.number)
    }
}

#[derive(Debug, Clone)]
pub struct NewProject {
    pub client_id: i64,
    pub name: String,
    pub description: Option<String>,
    pub hourly_rate: Option<f64>,
    pub status: String,
}

impl NewProject {
    pub fn new(client_id: i64, name: String) -> Self {
        Self {
            client_id,
            name,
            description: None,
            hourly_rate: None,
            status: "active".to_string(),
        }
    }
}

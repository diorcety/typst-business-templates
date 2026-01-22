use serde::Deserialize;
use serde_json::Value;
use std::collections::HashMap;
use std::path::Path;
use std::sync::OnceLock;

static LOCALE: OnceLock<Locale> = OnceLock::new();

#[derive(Debug, Clone, Deserialize)]
pub struct Locale {
    #[serde(flatten)]
    sections: HashMap<String, HashMap<String, Value>>,
}

impl Locale {
    /// Get a localized string by section and key
    pub fn get(&self, section: &str, key: &str) -> String {
        self.sections
            .get(section)
            .and_then(|s| s.get(key))
            .and_then(|v| v.as_str())
            .unwrap_or(key)
            .to_string()
    }

    /// Get a localized string with placeholder replacement
    /// Use {} as placeholder, replaced in order
    pub fn get_fmt(&self, section: &str, key: &str, args: &[&str]) -> String {
        let template = self.get(section, key);
        let mut result = template;
        for arg in args {
            result = result.replacen("{}", arg, 1);
        }
        result
    }
}

/// Initialize the locale system
/// Tries to read language from company.json, falls back to "de"
pub fn init() -> &'static Locale {
    LOCALE.get_or_init(|| {
        let lang = detect_language();
        load_locale(&lang)
            .unwrap_or_else(|_| load_locale("de").expect("Default locale (de) must exist"))
    })
}

/// Initialize with a specific language
#[allow(dead_code)]
pub fn init_with_lang(lang: &str) -> &'static Locale {
    LOCALE.get_or_init(|| {
        load_locale(lang)
            .unwrap_or_else(|_| load_locale("de").expect("Default locale (de) must exist"))
    })
}

/// Detect language from company.json if it exists
fn detect_language() -> String {
    // Try to read from data/company.json
    let paths = ["data/company.json", "../data/company.json"];

    for path in paths {
        if let Ok(content) = std::fs::read_to_string(path) {
            if let Ok(json) = serde_json::from_str::<Value>(&content) {
                if let Some(lang) = json.get("language").and_then(|v| v.as_str()) {
                    return lang.to_string();
                }
            }
        }
    }

    // Fallback to system locale or default
    std::env::var("LANG")
        .ok()
        .and_then(|l| l.split('_').next().map(String::from))
        .filter(|l| ["de", "en", "fr", "es", "it", "nl", "pt"].contains(&l.as_str()))
        .unwrap_or_else(|| "de".to_string())
}

/// Load locale from embedded or file
fn load_locale(lang: &str) -> Result<Locale, String> {
    // First, try to load from cli/locales/ directory (for development)
    let dev_paths = [
        format!("cli/locales/{}.json", lang),
        format!("locales/{}.json", lang),
    ];

    for path in &dev_paths {
        if Path::new(path).exists() {
            if let Ok(content) = std::fs::read_to_string(path) {
                if let Ok(locale) = serde_json::from_str(&content) {
                    return Ok(locale);
                }
            }
        }
    }

    // Fallback to embedded locales
    let content = match lang {
        "de" => include_str!("../locales/de.json"),
        "en" => include_str!("../locales/en.json"),
        "fr" => include_str!("../locales/fr.json"),
        "es" => include_str!("../locales/es.json"),
        "it" => include_str!("../locales/it.json"),
        "nl" => include_str!("../locales/nl.json"),
        "pt" => include_str!("../locales/pt.json"),
        _ => return Err(format!("Unknown language: {}", lang)),
    };

    serde_json::from_str(content).map_err(|e| e.to_string())
}

/// Helper function to get localized string (shorthand)
pub fn t(section: &str, key: &str) -> String {
    init().get(section, key)
}

/// Helper function to get localized string with formatting
pub fn tf(section: &str, key: &str, args: &[&str]) -> String {
    init().get_fmt(section, key, args)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_locale_loading() {
        let locale = load_locale("de").unwrap();
        assert_eq!(locale.get("client", "clients"), "Kunden");
    }

    #[test]
    fn test_locale_formatting() {
        let locale = load_locale("de").unwrap();
        let result = locale.get_fmt("client", "created", &["K-001"]);
        assert_eq!(result, "Kunde K-001 angelegt");
    }
}

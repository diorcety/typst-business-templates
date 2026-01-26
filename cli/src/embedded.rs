// Embedded locales (templates now handled by local_templates.rs with include_dir)

// Locales
pub const LOCALE_DE: &str = include_str!("../locales/de.json");
pub const LOCALE_EN: &str = include_str!("../locales/en.json");
pub const LOCALE_ES: &str = include_str!("../locales/es.json");
pub const LOCALE_FR: &str = include_str!("../locales/fr.json");
pub const LOCALE_IT: &str = include_str!("../locales/it.json");
pub const LOCALE_NL: &str = include_str!("../locales/nl.json");
pub const LOCALE_PT: &str = include_str!("../locales/pt.json");

pub struct EmbeddedFile {
    pub path: &'static str,
    pub content: &'static str,
}

pub fn get_locales() -> Vec<EmbeddedFile> {
    vec![
        EmbeddedFile {
            path: "de.json",
            content: LOCALE_DE,
        },
        EmbeddedFile {
            path: "en.json",
            content: LOCALE_EN,
        },
        EmbeddedFile {
            path: "es.json",
            content: LOCALE_ES,
        },
        EmbeddedFile {
            path: "fr.json",
            content: LOCALE_FR,
        },
        EmbeddedFile {
            path: "it.json",
            content: LOCALE_IT,
        },
        EmbeddedFile {
            path: "nl.json",
            content: LOCALE_NL,
        },
        EmbeddedFile {
            path: "pt.json",
            content: LOCALE_PT,
        },
    ]
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_locales_loaded() {
        let locales = get_locales();
        assert!(locales.len() > 0, "No locales loaded!");
        for l in locales {
            println!("Locale: {} (length: {})", l.path, l.content.len());
            assert!(l.content.len() > 0, "Locale {} is empty!", l.path);
        }
    }
}

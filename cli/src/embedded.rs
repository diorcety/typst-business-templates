// Embedded templates and locales

// Templates
pub const TEMPLATE_INVOICE: &str = include_str!("../../templates/invoice/default.typ");
pub const TEMPLATE_OFFER: &str = include_str!("../../templates/offer/default.typ");
pub const TEMPLATE_CREDENTIALS: &str = include_str!("../../templates/credentials/default.typ");
pub const TEMPLATE_CONCEPT: &str = include_str!("../../templates/concept/default.typ");
pub const TEMPLATE_DOCUMENTATION: &str = include_str!("../../templates/documentation/default.typ");
pub const TEMPLATE_COMMON_STYLES: &str = include_str!("../../templates/common/styles.typ");

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

pub fn get_templates() -> Vec<EmbeddedFile> {
    vec![
        EmbeddedFile {
            path: "invoice/default.typ",
            content: TEMPLATE_INVOICE,
        },
        EmbeddedFile {
            path: "offer/default.typ",
            content: TEMPLATE_OFFER,
        },
        EmbeddedFile {
            path: "credentials/default.typ",
            content: TEMPLATE_CREDENTIALS,
        },
        EmbeddedFile {
            path: "concept/default.typ",
            content: TEMPLATE_CONCEPT,
        },
        EmbeddedFile {
            path: "documentation/default.typ",
            content: TEMPLATE_DOCUMENTATION,
        },
        EmbeddedFile {
            path: "common/styles.typ",
            content: TEMPLATE_COMMON_STYLES,
        },
    ]
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
    fn test_templates_loaded() {
        let templates = get_templates();
        assert!(templates.len() > 0, "No templates loaded!");
        for t in templates {
            println!("Template: {} (length: {})", t.path, t.content.len());
            assert!(t.content.len() > 0, "Template {} is empty!", t.path);
        }
    }

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

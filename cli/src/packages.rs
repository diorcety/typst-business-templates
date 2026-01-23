// Package management for @local/docgen-* templates
use anyhow::{Context, Result};
use std::fs;
use std::path::PathBuf;

/// Get the Typst local packages directory
/// On macOS: ~/Library/Application Support/typst/packages/local/
/// On Linux: ~/.local/share/typst/packages/local/
/// On Windows: %APPDATA%/typst/packages/local/
pub fn get_packages_dir() -> Result<PathBuf> {
    let base = if cfg!(target_os = "macos") {
        dirs::home_dir()
            .context("Could not find home directory")?
            .join("Library/Application Support/typst/packages/local")
    } else if cfg!(target_os = "linux") {
        dirs::home_dir()
            .context("Could not find home directory")?
            .join(".local/share/typst/packages/local")
    } else if cfg!(target_os = "windows") {
        dirs::data_dir()
            .context("Could not find app data directory")?
            .join("typst/packages/local")
    } else {
        anyhow::bail!("Unsupported operating system");
    };

    Ok(base)
}

/// Get the current docgen version from Cargo.toml
pub fn get_docgen_version() -> String {
    env!("CARGO_PKG_VERSION").to_string()
}

/// Check if a package is installed
pub fn is_package_installed(package_name: &str, version: Option<&str>) -> Result<bool> {
    let packages_dir = get_packages_dir()?;
    let default_version = get_docgen_version();
    let version = version.unwrap_or(&default_version);
    let package_path = packages_dir
        .join(format!("docgen-{}", package_name))
        .join(version);

    Ok(package_path.exists())
}

/// Install a package from embedded templates
pub fn install_package(package_name: &str, version: Option<&str>) -> Result<()> {
    let default_version = get_docgen_version();
    let version = version.unwrap_or(&default_version);
    let packages_dir = get_packages_dir()?;
    let package_path = packages_dir
        .join(format!("docgen-{}", package_name))
        .join(version);

    // Create package directory
    fs::create_dir_all(&package_path)?;

    // Get template content from embedded templates
    let template_content = crate::embedded::get_templates()
        .into_iter()
        .find(|t| t.path.starts_with(&format!("{}/", package_name)))
        .context(format!(
            "Template '{}' not found in embedded files",
            package_name
        ))?;

    // Get common styles
    let styles_content = crate::embedded::get_templates()
        .into_iter()
        .find(|t| t.path == "common/styles.typ")
        .context("Common styles not found in embedded files")?;

    // Create typst.toml
    let typst_toml = format!(
        r#"[package]
name = "docgen-{}"
version = "{}"
entrypoint = "lib.typ"
authors = ["CASOON IT-Services"]
license = "MIT"
description = "{} template for docgen"
"#,
        package_name,
        version,
        package_name.to_uppercase()
    );
    fs::write(package_path.join("typst.toml"), typst_toml)?;

    // Create lib.typ
    let lib_typ = format!(
        r#"#import "template.typ": {name}
#import "styles.typ": *

#let version = "{version}"
"#,
        name = package_name,
        version = version
    );
    fs::write(package_path.join("lib.typ"), lib_typ)?;

    // Write template.typ (rename from default.typ)
    // Replace the styles import to use the local styles.typ in the package
    let template_fixed = template_content.content.replace(
        r#"#import "../common/styles.typ": *"#,
        r#"#import "styles.typ": *"#,
    );
    fs::write(package_path.join("template.typ"), template_fixed)?;

    // Write styles.typ
    fs::write(package_path.join("styles.typ"), styles_content.content)?;

    // Create locale directory and copy locale files
    let locale_dir = package_path.join("locale");
    fs::create_dir_all(&locale_dir)?;
    for locale in crate::embedded::get_locales() {
        fs::write(locale_dir.join(locale.path), locale.content)?;
    }

    Ok(())
}

/// List all installed docgen packages
pub fn list_installed_packages() -> Result<Vec<(String, String)>> {
    let packages_dir = get_packages_dir()?;
    let mut packages = Vec::new();

    if !packages_dir.exists() {
        return Ok(packages);
    }

    for entry in fs::read_dir(packages_dir)? {
        let entry = entry?;
        let package_name = entry.file_name().to_string_lossy().to_string();

        // Only list docgen-* packages
        if !package_name.starts_with("docgen-") {
            continue;
        }

        // Find all versions
        for version_entry in fs::read_dir(entry.path())? {
            let version_entry = version_entry?;
            if version_entry.file_type()?.is_dir() {
                let version = version_entry.file_name().to_string_lossy().to_string();
                packages.push((package_name.clone(), version));
            }
        }
    }

    packages.sort();
    Ok(packages)
}

/// Remove a specific package version
pub fn remove_package(package_name: &str, version: &str) -> Result<()> {
    let packages_dir = get_packages_dir()?;
    let package_path = packages_dir
        .join(format!("docgen-{}", package_name))
        .join(version);

    if !package_path.exists() {
        anyhow::bail!(
            "Package @local/docgen-{}:{} is not installed",
            package_name,
            version
        );
    }

    fs::remove_dir_all(&package_path)?;

    // Remove parent directory if empty
    let parent = package_path.parent().unwrap();
    if parent.read_dir()?.next().is_none() {
        fs::remove_dir(parent)?;
    }

    Ok(())
}

/// Get all available template types from embedded templates
pub fn get_available_templates() -> Vec<String> {
    crate::embedded::get_templates()
        .into_iter()
        .filter_map(|t| {
            let path = t.path;
            if path.contains('/') && !path.starts_with("common/") {
                Some(path.split('/').next().unwrap().to_string())
            } else {
                None
            }
        })
        .collect::<std::collections::HashSet<_>>()
        .into_iter()
        .collect()
}

/// Update all docgen packages to the current version
pub fn update_all_packages() -> Result<Vec<(String, String, String)>> {
    let current_version = get_docgen_version();
    let installed = list_installed_packages()?;
    let mut updated = Vec::new();

    for (package_name, old_version) in installed {
        // Extract the template name (remove "docgen-" prefix)
        let template_name = package_name.strip_prefix("docgen-").unwrap();

        // Check if update is needed
        if old_version != current_version {
            install_package(template_name, Some(&current_version))?;
            updated.push((
                template_name.to_string(),
                old_version,
                current_version.clone(),
            ));
        }
    }

    Ok(updated)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_get_packages_dir() {
        let dir = get_packages_dir().unwrap();
        println!("Packages directory: {}", dir.display());
        assert!(dir.to_string_lossy().contains("typst"));
    }

    #[test]
    fn test_version() {
        let version = get_docgen_version();
        println!("Current version: {}", version);
        assert!(!version.is_empty());
    }
}

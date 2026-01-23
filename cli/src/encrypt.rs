use anyhow::{Context, Result};
use dialoguer::{Confirm, Password};
use std::path::Path;
use std::process::Command as ProcessCommand;
use colored::Colorize;

pub struct EncryptionOptions {
    pub user_password: String,
    pub allow_printing: bool,
    pub allow_copying: bool,
    pub allow_modification: bool,
}

pub fn check_qpdf_available() -> Result<()> {
    match ProcessCommand::new("qpdf")
        .arg("--version")
        .output()
    {
        Ok(output) if output.status.success() => {
            let version = String::from_utf8_lossy(&output.stdout);
            println!("{} qpdf found: {}", "✓".green(), version.trim());
            Ok(())
        }
        Ok(_) => {
            anyhow::bail!(
                "{}\n\n\
                PDF encryption requires 'qpdf' to be installed.\n\
                \n\
                Installation:\n\
                  macOS:   brew install qpdf\n\
                  Linux:   apt-get install qpdf  (Debian/Ubuntu)\n\
                           yum install qpdf      (RHEL/CentOS)\n\
                  Windows: choco install qpdf\n\
                \n\
                Or download from: https://github.com/qpdf/qpdf/releases",
                "Error: qpdf not found".red()
            )
        }
        Err(e) => {
            anyhow::bail!(
                "{} {}\n\n\
                PDF encryption requires 'qpdf' to be installed.\n\
                \n\
                Installation:\n\
                  macOS:   brew install qpdf\n\
                  Linux:   apt-get install qpdf  (Debian/Ubuntu)\n\
                           yum install qpdf      (RHEL/CentOS)\n\
                  Windows: choco install qpdf\n\
                \n\
                Or download from: https://github.com/qpdf/qpdf/releases",
                "Error: qpdf not found".red(),
                format!("({})", e).dimmed()
            )
        }
    }
}

pub fn prompt_encryption_options() -> Result<EncryptionOptions> {
    println!("\n🔒 {}\n", "PDF Encryption Settings".bold());

    let user_password: String = Password::new()
        .with_prompt("User password (required to open PDF)")
        .with_confirmation("Confirm password", "Passwords don't match")
        .interact()?;

    let allow_printing = Confirm::new()
        .with_prompt("Allow printing?")
        .default(true)
        .interact()?;

    let allow_copying = Confirm::new()
        .with_prompt("Allow copying text/images?")
        .default(false)
        .interact()?;

    let allow_modification = Confirm::new()
        .with_prompt("Allow document modification?")
        .default(false)
        .interact()?;

    Ok(EncryptionOptions {
        user_password,
        allow_printing,
        allow_copying,
        allow_modification,
    })
}

pub fn encrypt_pdf(input_path: &Path, output_path: &Path, options: EncryptionOptions) -> Result<()> {
    // Build qpdf command with AES-256 encryption
    let mut cmd = ProcessCommand::new("qpdf");
    cmd.arg("--encrypt")
        .arg(&options.user_password)
        .arg(&options.user_password)  // Same password for owner
        .arg("256");  // AES-256 encryption

    // Add permission restrictions
    if !options.allow_printing {
        cmd.arg("--print=none");
    }
    if !options.allow_copying {
        cmd.arg("--extract=n");
    }
    if !options.allow_modification {
        cmd.arg("--modify=none");
    }

    cmd.arg("--")
        .arg(input_path)
        .arg(output_path);

    let output = cmd.output()
        .context("Failed to execute qpdf command")?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("qpdf encryption failed:\n{}", stderr);
    }

    Ok(())
}

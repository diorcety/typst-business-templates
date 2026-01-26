use anyhow::{Context, Result};
use colored::Colorize;
use std::io::{self, Write};
use std::path::Path;
use std::process::Command as ProcessCommand;

pub struct EncryptionOptions {
    pub user_password: String,
    pub allow_printing: bool,
    pub allow_copying: bool,
    pub allow_modification: bool,
}

pub fn check_qpdf_available() -> Result<()> {
    match ProcessCommand::new("qpdf").arg("--version").output() {
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

    // Get password from stdin (simple prompt, no masking)
    print!("Enter password (will be visible): ");
    io::stdout().flush()?;

    let mut password = String::new();
    io::stdin().read_line(&mut password)?;
    let password = password.trim().to_string();

    if password.is_empty() {
        anyhow::bail!("Password cannot be empty");
    }

    // Default permissions: allow printing, no copying/modification
    Ok(EncryptionOptions {
        user_password: password,
        allow_printing: true,
        allow_copying: false,
        allow_modification: false,
    })
}

pub fn encrypt_pdf(
    input_path: &Path,
    output_path: &Path,
    options: EncryptionOptions,
) -> Result<()> {
    // Build qpdf command with AES-256 encryption
    let mut cmd = ProcessCommand::new("qpdf");
    cmd.arg("--encrypt")
        .arg(&options.user_password)
        .arg(&options.user_password) // Same password for owner
        .arg("256"); // AES-256 encryption

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

    cmd.arg("--").arg(input_path).arg(output_path);

    let output = cmd.output().context("Failed to execute qpdf command")?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("qpdf encryption failed:\n{}", stderr);
    }

    Ok(())
}

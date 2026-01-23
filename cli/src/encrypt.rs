use anyhow::{Context, Result};
use dialoguer::{Confirm, Password};
use std::path::Path;
use std::process::Command as ProcessCommand;

pub struct EncryptionOptions {
    pub user_password: String,
    pub allow_printing: bool,
    pub allow_copying: bool,
    pub allow_modification: bool,
}

pub fn prompt_encryption_options() -> Result<EncryptionOptions> {
    println!("\n🔒 PDF Encryption Settings\n");

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
    // Use qpdf for reliable encryption
    let mut permissions = vec![];
    
    if !options.allow_printing {
        permissions.push("--print=none");
    }
    if !options.allow_copying {
        permissions.push("--extract=n");
    }
    if !options.allow_modification {
        permissions.push("--modify=none");
    }

    let mut cmd = ProcessCommand::new("qpdf");
    cmd.arg("--encrypt")
        .arg(&options.user_password)
        .arg(&options.user_password)
        .arg("256")
        .arg("--");
    
    for perm in permissions {
        cmd.arg(perm);
    }
    
    cmd.arg(input_path)
        .arg(output_path);

    let status = cmd.status()
        .context("Failed to run qpdf. Is it installed?")?;

    if !status.success() {
        anyhow::bail!("qpdf encryption failed");
    }

    Ok(())
}

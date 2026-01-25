# Template Architecture Concept

## Overview

docgen uses a **project-local template system** that balances ease of use with flexibility. All templates live in your project directory for maximum portability and Git integration.

## Design Goals

1. **Portability** - Everything needed for document generation lives in the project directory
2. **No System Dependencies** - No global package installations, works on any machine
3. **Auto-Updates** - Standard templates stay current with docgen version
4. **Customization** - Fork templates when you need control
5. **Git-Friendly** - Custom templates in version control, standard templates excluded

## Architecture

### Directory Structure

```
project/
├── .docgen/
│   └── templates/          # Standard templates (auto-updated, .gitignore'd)
│       ├── concept/
│       ├── credentials/
│       ├── documentation/
│       ├── invoice/
│       └── offer/
├── templates/              # Custom templates (stable, committed to Git)
│   └── my-custom-concept/
├── data/
│   ├── company.json
│   └── logo.png
└── documents/
    ├── concepts/
    │   └── 2026/
    │       └── project.typ
    └── invoices/
        └── 2026/
            └── invoice.json
```

### Template Types

| Type | Location | Updated | Git | Use Case |
|------|----------|---------|-----|----------|
| **Standard** | `.docgen/templates/` | Auto | Ignored | Normal business documents |
| **Custom** | `templates/` | Never | Committed | Branded/customized layouts |

## Workflows

### 1. JSON Workflow (Structured Documents)

**Best for:** Invoices, Offers, Credentials

```json
{
  "metadata": {
    "document_number": "RE-2026-001",
    "client_name": "Acme Corp"
  },
  "items": [...]
}
```

**Compilation:**
```bash
docgen compile documents/invoices/2026/RE-2026-001.json
```

**Process:**
1. docgen reads JSON file
2. Auto-updates `.docgen/templates/invoice/` if needed
3. Invokes Typst with template path: `.docgen/templates/invoice/default.typ`
4. Outputs PDF to `output/`

### 2. .typ Workflow (Rich Documents)

**Best for:** Concepts, Documentation, Reports

```typ
#import "/.docgen/templates/concept/default.typ": concept

#let company = json("/data/company.json")
#let locale = json("/locale/de.json")

#show: concept.with(
  title: "My Concept",
  company: company,
  locale: locale,
)

= Introduction
Your content here...
```

**Compilation:**
```bash
docgen compile documents/concepts/2026/project.typ
```

**Process:**
1. Auto-updates `.docgen/templates/` if needed
2. User's .typ file imports template via `/.docgen/templates/concept/default.typ`
3. Typst compiles with access to project root (`--root .`)
4. Outputs PDF to `output/`

## Template Lifecycle

### Initialization

```bash
docgen init my-project
# or in existing project:
docgen template init
```

**What happens:**
1. Creates `.docgen/templates/` directory
2. Extracts embedded templates from docgen binary
3. Adds `.docgen/` to `.gitignore`

### Auto-Update

**Triggered by:**
- `docgen compile <file>`
- `docgen build <directory>`

**Logic:**
```rust
fn ensure_local_templates_updated() -> Result<()> {
    let templates_dir = get_local_templates_dir(); // .docgen/templates/
    
    // Extract embedded templates from binary
    for template_name in ["concept", "credentials", "documentation", "invoice", "offer"] {
        let dest = templates_dir.join(template_name);
        if dest.exists() {
            fs::remove_dir_all(&dest)?; // Remove old version
        }
        extract_embedded_template(template_name, &dest)?; // Write new version
    }
    Ok(())
}
```

**Benefits:**
- Templates always match docgen version
- No manual `docgen template update` needed
- Breaking changes controlled by docgen version

### Customization (Fork)

```bash
docgen template fork concept --name branded-concept
```

**Process:**
1. Copies `.docgen/templates/concept/` → `templates/branded-concept/`
2. User edits `templates/branded-concept/default.typ`
3. Commits to Git
4. Uses in .typ files: `#import "/templates/branded-concept/default.typ": concept`

**Key Point:** Custom templates are **never auto-updated**. They belong to your project.

## Template Implementation

### Embedding Templates (Build Time)

**cli/Cargo.toml:**
```toml
[dependencies]
include_dir = "0.7"
```

**cli/src/local_templates.rs:**
```rust
use include_dir::{include_dir, Dir};

// Embed all templates at compile time
static TEMPLATES_DIR: Dir = include_dir!("$CARGO_MANIFEST_DIR/../templates");

pub fn extract_embedded_dir(embedded_dir: &Dir, dest: &Path) -> Result<()> {
    for entry in embedded_dir.entries() {
        match entry {
            DirEntry::Dir(dir) => {
                let dir_dest = dest.join(dir.path());
                fs::create_dir_all(&dir_dest)?;
                extract_embedded_dir(dir, &dir_dest)?;
            }
            DirEntry::File(file) => {
                let file_dest = dest.join(file.path());
                fs::write(file_dest, file.contents())?;
            }
        }
    }
    Ok(())
}
```

**Why `include_dir`?**
- Templates embedded in binary at **build time**
- No runtime file system access needed
- Single binary deployment
- Templates extracted to `.docgen/templates/` at runtime

### Template Discovery (Runtime)

**cli/src/main.rs:**
```rust
fn compile_document(file_path: &Path) -> Result<()> {
    // Auto-update templates before compilation
    local_templates::ensure_local_templates_updated()?;
    
    let doc_type = detect_document_type(file_path)?;
    let template_path = format!(".docgen/templates/{}/default.typ", doc_type);
    
    // Invoke Typst
    let status = Command::new("typst")
        .arg("compile")
        .arg("--root").arg(".")
        .arg("--font-path").arg("fonts")
        .arg(&template_path)
        .arg(output_path)
        .arg("--input").arg(format!("data={}", file_path))
        .status()?;
    
    Ok(())
}
```

## Migration from v0.4.x (Package System)

### Old System (v0.4.x)

```typ
#import "@local/docgen-concept:0.4.12": concept
```

**Problems:**
1. Hard-coded version → no auto-updates
2. Global packages in `~/Library/Application Support/typst/packages/`
3. Not portable (missing on other machines)
4. Not in Git

### New System (v0.5.0+)

```typ
#import "/.docgen/templates/concept/default.typ": concept
```

**Benefits:**
1. Auto-updates with docgen version
2. Project-local → portable
3. Works on any machine with docgen installed
4. `.gitignore` handles exclusion

### Migration Steps

For existing projects:

```bash
# 1. Initialize new template system
docgen template init

# 2. Update .typ file imports
sed -i '' 's|@local/docgen-concept:[0-9.]*|/.docgen/templates/concept/default.typ|g' documents/**/*.typ
sed -i '' 's|@local/docgen-documentation:[0-9.]*|/.docgen/templates/documentation/default.typ|g' documents/**/*.typ

# 3. Remove old package installations (optional cleanup)
rm -rf ~/Library/Application\ Support/typst/packages/local/docgen-*

# 4. Test compilation
docgen build documents/
```

## Version Evolution

### v0.4.x - Global Package System

- Templates as Typst packages in `~/Library/Application Support/typst/packages/`
- `docgen template install <name>` to install
- Hard-coded versions in .typ files: `@local/docgen-concept:0.4.12`
- No auto-updates

### v0.5.0 - Project-Local Templates

- Templates in `.docgen/templates/`
- Embedded in binary with `include_dir` crate
- Auto-extracted and updated on compile
- Version-less imports: `/.docgen/templates/concept/default.typ`

### v0.5.1 - Fix Template Extraction

- Fixed: Templates not extracted (used wrong path variable)
- Added: Proper `include_dir` embedding

### v0.5.2 - Fix JSON Workflow

- Fixed: JSON documents using old `templates/` path
- Fixed: Offer template syntax error
- All workflows unified on `.docgen/templates/`

## Design Decisions

### Why Project-Local?

**Alternative:** Global packages (`~/Library/Application Support/typst/packages/`)

**Rejected because:**
- Not portable (missing on other machines)
- Not in Git (team collaboration issues)
- Requires manual installation
- Version conflicts between projects

### Why Auto-Update Standard Templates?

**Alternative:** User runs `docgen template update` manually

**Rejected because:**
- Users forget to update
- Version mismatch between docgen CLI and templates
- Breaking changes harder to manage

**Chosen approach:**
- Auto-update on every compile
- Breaking changes tied to docgen version
- User can freeze to older docgen version if needed

### Why Two Template Locations?

**Alternative:** Only `.docgen/templates/` with no customization

**Rejected because:**
- Users need branding control
- Some clients require specific layouts

**Chosen approach:**
- `.docgen/templates/` for standard (auto-updated)
- `templates/` for custom (stable, Git-committed)
- `docgen template fork` bridges the gap

### Why Embed Templates in Binary?

**Alternative:** Fetch from GitHub at runtime

**Rejected because:**
- Requires internet connection
- GitHub API rate limits
- Slower compilation
- Failure mode: network issues break builds

**Chosen approach:**
- `include_dir` embeds templates at **build time**
- Single binary, zero dependencies
- Offline-first
- Fast extraction to `.docgen/templates/`

## Future Considerations

### Template Marketplace (Not Planned)

Could allow third-party templates:

```bash
docgen template add https://github.com/user/custom-invoice
```

**Why not now:**
- Adds complexity (security, versioning, discovery)
- Fork mechanism sufficient for most cases
- Can be added later without breaking changes

### Template Versioning (Not Needed)

Could version custom templates:

```
templates/
  branded-invoice/
    v1.0/
    v1.1/
```

**Why not:**
- Git already provides versioning
- Users can use Git tags/branches
- Adds complexity without clear benefit

### Hot Reload (Future)

Could detect template changes and recompile:

```bash
docgen watch --templates
```

**Future enhancement:**
- Watch `.docgen/templates/` and `templates/`
- Auto-recompile on template changes
- Useful for template development

## Summary

The v0.5.0+ template architecture achieves:

✅ **Portability** - Everything in project directory  
✅ **Zero Config** - Auto-updates on compile  
✅ **Customization** - Fork when needed  
✅ **Git-Friendly** - Standard ignored, custom committed  
✅ **Fast** - Embedded in binary  
✅ **Offline** - No network dependencies  
✅ **Simple** - One command: `docgen compile`  

This design serves the primary use case (small businesses generating invoices/docs) while allowing advanced customization when needed.

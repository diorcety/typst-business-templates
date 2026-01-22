# Roadmap: Typst Business Templates

This roadmap defines the evolution from a template repository to a professional, installable CLI tool for small businesses.

## Vision

**Goal:** A single `docgen` command that small businesses install once and use forever - no subscriptions, no cloud dependency, full control over their documents.

```bash
# Install once
brew install casoon/tap/docgen

# Initialize anywhere
docgen init ~/Documents/my-business

# Create documents
cd ~/Documents/my-business
docgen
```

---

## Phase 1: Installation & Distribution (v0.3.0)

### 1.1 Homebrew Installation

**Current Problem:** Users must clone the repo and build from source.

**Solution:** Publish via Homebrew tap.

```bash
# Installation
brew tap casoon/tap
brew install docgen

# What gets installed:
# - docgen binary -> /usr/local/bin/docgen
# - Default templates -> /usr/local/share/docgen/templates/
# - JSON schemas -> /usr/local/share/docgen/schemas/
```

**Implementation:**

Create `homebrew-tap` repository with formula:

```ruby
class Docgen < Formula
  desc "Professional document generator for small businesses"
  homepage "https://github.com/casoon/typst-business-templates"
  url "https://github.com/casoon/typst-business-templates/archive/v0.3.0.tar.gz"
  sha256 "..."
  license "MIT"
  
  depends_on "rust" => :build
  depends_on "typst"
  
  def install
    cd "cli" do
      system "cargo", "build", "--release"
      bin.install "target/release/docgen"
    end
    
    # Install templates to share directory
    (share/"docgen/templates").install Dir["templates/*"]
    (share/"docgen/schemas").install Dir["schema/*"]
  end
  
  def caveats
    <<~EOS
      To get started, run:
        docgen init ~/Documents/my-business
        
      Templates are installed at:
        #{share}/docgen/templates/
    EOS
  end
end
```

**Tasks:**
- [ ] Create GitHub release workflow with pre-built binaries
- [ ] Create `homebrew-tap` repository
- [ ] Write Homebrew formula
- [ ] Test installation on fresh macOS
- [ ] Add Linux support (linuxbrew / direct download)
- [ ] Add Windows support (scoop / winget / direct download)

### 1.2 Template Resolution Strategy

**Priority order for finding templates:**

```
1. ./templates/               (Project-local, user customizations)
2. ~/.config/docgen/templates/ (User-global customizations)
3. /usr/local/share/docgen/templates/ (Homebrew-installed defaults)
```

**Implementation in Rust:**

```rust
fn find_template(template_type: &str, template_name: &str) -> PathBuf {
    let candidates = [
        // Project-local (highest priority)
        PathBuf::from("./templates").join(template_type).join(format!("{}.typ", template_name)),
        // User-global
        dirs::config_dir().unwrap().join("docgen/templates").join(template_type).join(format!("{}.typ", template_name)),
        // System-installed (Homebrew)
        PathBuf::from("/usr/local/share/docgen/templates").join(template_type).join(format!("{}.typ", template_name)),
    ];
    
    candidates.into_iter()
        .find(|p| p.exists())
        .expect("Template not found")
}
```

**Benefits:**
- Users can override any template by placing it in their project
- Global customizations persist across projects
- System templates always available as fallback

---

## Phase 2: Project Structure Convention (v0.3.1)

### 2.1 Standard Project Layout

**`docgen init` creates:**

```
my-business/
├── .docgen/                      # Hidden config (like .git)
│   └── config.toml               # Project settings
│
├── data/
│   └── company.json              # Company data
│
├── logo.png                      # Company logo (or logo.svg)
│
├── clients/                      # Client database (JSON files)
│   ├── K-001.json
│   └── K-002.json
│
├── projects/                     # Project database
│   └── P-001-01.json
│
├── documents/                    # Document source files (JSON)
│   ├── invoices/
│   │   └── 2025/
│   │       └── RE-2025-001.json
│   ├── offers/
│   │   └── 2025/
│   ├── credentials/
│   │   └── 2025/
│   └── concepts/
│       └── 2025/
│
├── output/                       # Generated PDFs (in Git!)
│   ├── invoices/
│   │   └── RE-2025-001.pdf
│   ├── offers/
│   ├── credentials/
│   └── concepts/
│
├── templates/                    # Custom templates (optional)
│   └── invoice/
│       └── default.typ           # Overrides system template
│
└── docgen.db                     # SQLite database
```

**Why output/ is in Git:**
- PDFs are the final deliverable - they should be versioned
- Easy access without recompilation
- Serves as documentation of what was actually sent
- Enables PDF diffing for audits

**Key decisions:**

| Aspect | Decision | Rationale |
|--------|----------|-----------|
| `company.json` location | `data/` folder | Consistent with current structure |
| Logo location | Project root | Easy to find and replace |
| Hidden config | `.docgen/` folder | Keeps root clean |
| Year subfolders | `documents/{type}/YYYY/` | Professional organization |
| Output in Git | Yes | PDFs are deliverables, should be versioned |
| Client/Project files | Separate folders | Clear separation, Git-friendly |

### 2.2 Project Configuration

**`.docgen/config.toml`:**

```toml
[project]
name = "My Business Documents"
version = "1.0"

[paths]
# Relative to project root
company = "company.json"
logo = "logo.png"
output = "documents"
clients = "clients"
projects = "projects"

[templates]
# Which template set to use
invoice = "default"      # Uses templates/invoice/default.typ
offer = "default"
credentials = "default"
concept = "default"

[numbering]
# Starting counters (useful for migration)
invoice_start = 1
offer_start = 1
client_start = 1

[defaults]
# Default values for new documents
payment_terms_days = 14
offer_validity_days = 30
vat_rate = 19
```

### 2.3 Company JSON with Logo and Branding Support

**`data/company.json`:**

```json
{
  "name": "Mustermann IT-Services",
  "logo": "logo.png",
  "logo_width": "3cm",
  "branding": {
    "accent_color": "#E94B3C",
    "primary_color": "#2c3e50"
  },
  "address": {
    "street": "Beispielstraße",
    "house_number": "123",
    "postal_code": "12345",
    "city": "Musterstadt",
    "country": "Deutschland"
  },
  "contact": {
    "phone": "+49 123 456789",
    "mobile": "+49 170 1234567",
    "email": "info@example.com",
    "website": "www.example.com"
  },
  "tax_id": "123/456/78901",
  "vat_id": "DE123456789",
  "business_owner": "Max Mustermann",
  "bank_account": {
    "bank_name": "Musterbank",
    "account_holder": "Mustermann IT-Services",
    "iban": "DE89 3704 0044 0532 0130 00",
    "bic": "COBADEFFXXX"
  },
  "default_offer_terms": {
    "hourly_rate": "95,00",
    "standard_terms": [
      "Preise zzgl. gesetzlicher MwSt. (19%)",
      "Zahlbar innerhalb von 14 Tagen",
      "..."
    ]
  }
}
```

**Branding options:**
- `accent_color`: Used for highlights, buttons, important elements
- `primary_color`: Used for headings, text emphasis

**Logo handling in templates:**

```typst
// templates/common/header.typ
#let company = json("../../company.json")

#let company-header() = {
  grid(
    columns: (auto, 1fr),
    gutter: 1em,
    // Logo (if exists)
    if "logo" in company and company.logo != none {
      let logo-width = if "logo_width" in company { 
        eval(company.logo_width) 
      } else { 
        3cm 
      }
      image("../../" + company.logo, width: logo-width)
    },
    // Company info
    align(right)[
      #text(weight: "bold", size: 14pt)[#company.name]
      #linebreak()
      #company.address.street #company.address.house_number
      #linebreak()
      #company.address.postal_code #company.address.city
    ]
  )
}
```

---

## Phase 3: Complete CRUD & UX (v0.4.0)

### 3.1 Client/Project Management

```bash
# Full CRUD for clients
docgen client list
docgen client add                    # Interactive
docgen client show K-001
docgen client edit K-001             # Opens $EDITOR or interactive
docgen client delete K-001           # With confirmation
docgen client export                 # Export all to JSON

# Full CRUD for projects
docgen project list
docgen project list --client K-001
docgen project add K-001 "Website Relaunch"
docgen project edit P-001-01
docgen project delete P-001-01
docgen project archive P-001-01      # Soft-delete

# Search across everything
docgen search "Müller"
docgen search --type client "Hamburg"
docgen search --type invoice "2025"
```

### 3.2 Document Status Tracking

```bash
# Update document status
docgen status RE-2025-001 sent
docgen status RE-2025-001 paid
docgen status RE-2025-001 overdue

# List by status
docgen list invoices --status unpaid
docgen list invoices --status overdue
docgen list offers --status pending

# Dashboard
docgen dashboard
# Shows:
# - Open invoices: 3 (€12,450.00)
# - Overdue: 1 (€2,500.00)
# - Pending offers: 2 (€8,900.00)
# - This month revenue: €15,200.00
```

### 3.3 Improved Compile Command

```bash
# Compile with auto-detection
docgen compile RE-2025-001              # Finds JSON, outputs PDF

# Compile all pending
docgen compile --all
docgen compile --type invoice --year 2025

# Watch mode with live preview
docgen watch documents/invoices/
docgen watch RE-2025-001                # Single file watch
```

---

## Phase 4: Template System (v0.4.1)

### 4.1 Template Customization Command

```bash
# Copy system template to project for customization
docgen template customize invoice
# -> Copies /usr/local/share/docgen/templates/invoice/default.typ
#    to ./templates/invoice/default.typ

# List available templates
docgen template list
# invoice/default (system)
# invoice/simple (system)
# offer/default (system)
# offer/detailed (project) ← customized

# Show template location
docgen template which invoice/default
# /usr/local/share/docgen/templates/invoice/default.typ

# Validate template
docgen template validate ./templates/invoice/custom.typ
```

### 4.2 Template Variables

Templates receive these variables automatically:

```typst
// Available in all templates:
#let company = json(sys.inputs.company)     // Company data
#let data = json(sys.inputs.data)           // Document data
#let config = json(sys.inputs.config)       // Project config
#let logo-path = sys.inputs.logo            // Path to logo file

// Usage
#if logo-path != none {
  image(logo-path, width: company.logo_width)
}
```

### 4.3 Template Inheritance (Future)

```typst
// templates/invoice/my-custom.typ
#import "@docgen/invoice:default" as base

// Override just the header
#let header() = {
  // Custom header with different layout
}

// Use everything else from base
#base.invoice(header: header)
```

---

## Phase 5: Data Validation & Safety (v0.5.0)

### 5.1 JSON Schema Validation

```bash
# Validate before compile
docgen validate RE-2025-001.json
# ✓ Valid invoice document

docgen validate broken.json
# ✗ Validation errors:
#   Line 12: "items" must have at least 1 element
#   Line 25: "due_date" format invalid (expected: DD.MM.YYYY)
```

### 5.2 Backup & Restore

```bash
# Manual backup
docgen backup
# Created: backups/backup-2025-01-22-143052.zip
# Contains: docgen.db, company.json, clients/, projects/

# Automatic backup before destructive operations
docgen client delete K-001
# ⚠ Creating backup before deletion...
# Backup created: backups/pre-delete-2025-01-22.zip
# Delete client K-001 "Max Müller"? [y/N]

# Restore from backup
docgen restore backups/backup-2025-01-22.zip
```

### 5.3 Data Export

```bash
# Export for spreadsheet analysis
docgen export invoices --format csv > invoices.csv
docgen export clients --format json > clients.json

# Full data export (for migration)
docgen export all --format zip > full-export.zip
```

---

## Phase 6: Testing & Quality (v0.5.1)

### 6.1 Test Infrastructure

```
cli/
├── src/
├── tests/
│   ├── integration/
│   │   ├── init_test.rs
│   │   ├── compile_test.rs
│   │   ├── client_crud_test.rs
│   │   └── workflow_test.rs
│   └── fixtures/
│       ├── valid/
│       │   ├── invoice-minimal.json
│       │   └── invoice-full.json
│       └── invalid/
│           └── invoice-missing-items.json
```

### 6.2 CI/CD Pipeline

```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
      - run: cargo test --manifest-path cli/Cargo.toml
      
  release:
    if: startsWith(github.ref, 'refs/tags/v')
    needs: test
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            target: x86_64-unknown-linux-gnu
          - os: macos-latest
            target: x86_64-apple-darwin
          - os: macos-latest
            target: aarch64-apple-darwin
          - os: windows-latest
            target: x86_64-pc-windows-msvc
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
      - run: cargo build --release --target ${{ matrix.target }}
      - uses: softprops/action-gh-release@v1
        with:
          files: target/${{ matrix.target }}/release/docgen*
```

---

## Phase 7: Advanced Features (v1.0.0)

### 7.1 Time Tracking

```bash
# Track time
docgen time start P-001-01 "Frontend development"
docgen time stop
docgen time add P-001-01 --hours 4 --desc "Code review"

# Generate invoice from time entries
docgen invoice from-time P-001-01 --month 2025-01
```

### 7.2 Recurring Documents

```bash
# Set up recurring invoice
docgen recurring add --type invoice --client K-001 --monthly
# Creates: RE-2025-001 on 1st of each month

# List recurring
docgen recurring list

# Generate all due
docgen recurring run
```

### 7.3 Email Integration

```bash
# Send document directly
docgen send RE-2025-001
# Sends to client email with PDF attached

# Configure SMTP
docgen config set smtp.host "smtp.gmail.com"
docgen config set smtp.user "your@email.com"
docgen config set smtp.password # prompts securely
```

### 7.4 E-Invoice Support (ZUGFeRD/XRechnung)

```bash
# Generate with embedded XML
docgen compile RE-2025-001 --zugferd
# Creates PDF/A-3 with embedded ZUGFeRD XML

# Validate e-invoice
docgen validate RE-2025-001.pdf --zugferd
```

---

## Implementation Timeline

| Phase | Version | Focus | Priority |
|-------|---------|-------|----------|
| 1 | v0.3.0 | Homebrew installation, template resolution | HIGH |
| 2 | v0.3.1 | Project structure, logo support | HIGH |
| 3 | v0.4.0 | Complete CRUD, status tracking | HIGH |
| 4 | v0.4.1 | Template customization system | MEDIUM |
| 5 | v0.5.0 | Validation, backup, export | MEDIUM |
| 6 | v0.5.1 | Testing, CI/CD | MEDIUM |
| 7 | v1.0.0 | Time tracking, recurring, email | LOW |

---

## Migration Guide

### From Repository Clone to Homebrew Installation

```bash
# 1. Install via Homebrew
brew install casoon/tap/docgen

# 2. Initialize new project structure
docgen init ~/Documents/my-business

# 3. Copy your existing data
cp old-project/data/company.json ~/Documents/my-business/company.json
cp old-project/logo.png ~/Documents/my-business/

# 4. Import existing clients (if any)
docgen import clients old-project/data/clients/

# 5. Your custom templates (if any)
cp -r old-project/templates/ ~/Documents/my-business/templates/
```

### Keeping Templates Updated

```bash
# Check for template updates
docgen template check
# invoice/default: system v1.2.0, local v1.0.0 (update available)

# Update system templates
brew upgrade docgen

# Re-customize if needed
docgen template diff invoice/default
# Shows differences between system and local template
```

---

## Success Metrics

| Metric | Current | v0.5.0 Target | v1.0.0 Target |
|--------|---------|---------------|---------------|
| Installation time | 5-10 min (build) | < 1 min (brew) | < 1 min |
| Test coverage | 0% | > 60% | > 80% |
| Supported platforms | 1 (source) | 3 (mac/linux/win) | 3 |
| Template customization | Manual copy | CLI command | CLI + inheritance |
| Document types | 4 | 4 | 6+ |

---

## Contributing

### Good First Issues

- Add a single unit test for client creation
- Improve error message for missing company.json
- Add `--version` flag to CLI
- Create example logo.svg for demo

### Larger Contributions

- Implement `docgen template customize` command
- Set up GitHub Actions release workflow
- Create Homebrew formula and tap repository
- Add Windows installer (MSI or Scoop)

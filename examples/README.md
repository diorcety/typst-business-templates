# Examples

This directory contains example projects and template references.

## Example Projects

Complete, self-contained example projects for different business types. Each project has its own `data/`, `documents/`, `templates/`, `locale/`, and `output/` directories - just like a real project created with `docgen init`.

| Directory | Business Type | Documents |
|-----------|--------------|-----------|
| [digitalagentur/](digitalagentur/) | Web Agency (Cologne) | 5 documents (Invoice, Offer, Credentials, Concept, Documentation) |
| [freelance-designer/](freelance-designer/) | Graphic Designer, Kleinunternehmer (Hamburg) | 3 documents (Invoice, Offer, Credentials) |
| [it-consultant/](it-consultant/) | IT Consulting (Berlin) | 3 documents (Invoice, Offer, Credentials) |

Each project is **fully functional** and can be used as a template for your own projects.

### Usage

Each example project is self-contained with its own `templates/` directory, just like a real project created with `docgen init`.

**Compile all documents:**
```bash
cd examples/digitalagentur
docgen build
```

**Compile specific documents:**
```bash
# JSON-based documents
docgen compile documents/invoices/2025/invoice.json
docgen compile documents/offers/2025/offer.json
docgen compile documents/credentials/2025/credentials.json

# .typ documents (digitalagentur only)
docgen compile documents/concepts/2025/concept.typ
docgen compile documents/documentation/2025/documentation.typ
```

**Note:** The digitalagentur example includes .typ documents (concept, documentation) that use the template package system. For these documents, the templates must be installed as packages first:

```bash
docgen template install concept
docgen template install documentation
```

### PDF Encryption

Generate password-protected PDFs using the `--encrypt` flag:

```bash
docgen compile examples/digitalagentur/data/invoice.json --encrypt
```

You will be prompted for:
- **Password** (with confirmation)
- **Allow printing** (default: yes)
- **Allow copying text/images** (default: no)
- **Allow modifications** (default: no)

**Example file:** [digitalagentur/output/credentials-encrypted.pdf](digitalagentur/output/credentials-encrypted.pdf) (Password: `test123`)

**Generate your own:**
```bash
docgen compile examples/digitalagentur/data/credentials.json -o examples/digitalagentur/output/credentials-encrypted.pdf --encrypt
```

> Requires `qpdf` installed: `brew install qpdf` (macOS) or `apt install qpdf` (Linux)

## Direct .typ Documents (Template Package System)

The digitalagentur example project demonstrates writing documents directly in Typst syntax using the template package system - perfect for concept documents and documentation.

### How It Works

1. **Install template packages (one-time):**
```bash
docgen template install concept
docgen template install documentation
```

2. **Write .typ documents with package imports:**
```typ
#import "@local/docgen-concept:0.4.2": concept

// Load company and locale from project root (absolute paths)
#let company = json("/data/company.json")
#let locale = json("/locale/de.json")

#show: concept.with(
  title: "E-Commerce Shop für Biobauernhof",
  document_number: "KO-2025-001",
  client_name: "Hofbauer's Biohof",
  project_name: "Onlineshop Entwicklung",
  version: "1.0",
  status: "final",
  company: company,
  locale: locale,
  // Optional: Pass logo as image for package imports
  // logo: image("/data/logo.png", width: 150pt),
)

= Projektziel

Entwicklung eines professionellen E-Commerce Shops...
```

3. **Compile:**
```bash
cd examples/digitalagentur
docgen compile documents/concepts/2025/concept.typ
```

See the [digitalagentur example](digitalagentur/) for complete working examples of concept and documentation .typ files.

### Benefits of .typ Documents

| Feature | JSON + content_file | Direct .typ |
|---------|-------------------|-------------|
| **File count** | 2 files (JSON + .typ) | 1 file |
| **Typst features** | Limited | Full (math, references, custom layouts) |
| **Version control** | Split across files | Single file |
| **Best for** | Invoices, offers, credentials | Concepts, documentation, reports |

### Template Package Commands

```bash
# List all available templates
docgen template list

# Install specific templates
docgen template install concept
docgen template install documentation
docgen template install invoice

# Update all templates
docgen template update

# Remove a template version
docgen template remove concept 0.4.2
```

### Package Locations

Installed packages are stored in your system's Typst package directory:

| OS | Location |
|----|----------|
| **macOS** | `~/Library/Application Support/typst/packages/local/docgen-*/` |
| **Linux** | `~/.local/share/typst/packages/local/docgen-*/` |
| **Windows** | `%APPDATA%/typst/packages/local/docgen-*/` |

## Learn More

For detailed information about each example project, see their respective README files:

- [digitalagentur/README.md](digitalagentur/README.md) - Web agency with full workflow demonstration
- [freelance-designer/README.md](freelance-designer/README.md) - Kleinunternehmer setup without VAT
- [it-consultant/README.md](it-consultant/README.md) - Regular business with 19% VAT

For template customization and usage instructions, see the [main README](../README.md).

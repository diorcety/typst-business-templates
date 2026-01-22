# Typst Business Templates

**Professional document generation for small businesses without expensive software.**

Stop paying for bloated invoice and document software. This open-source solution combines:
- **[Typst](https://typst.app/)** - Modern markup language for beautiful PDFs
- **JSON Templates** - Simple, human-readable data format
- **AI-Powered Creation** - Use Claude or other LLMs to generate document content
- **Interactive CLI** - Manage clients, projects, and documents from your terminal

Perfect for freelancers, agencies, and small businesses who want full control over their documents.

## Why This Approach?

| Traditional Software | This Solution |
|---------------------|---------------|
| Monthly subscriptions | Free & open source |
| Vendor lock-in | Your data in plain JSON |
| Limited customization | Full template control |
| Cloud dependency | Works offline |
| Complex interfaces | Simple CLI + AI |

### docgen vs. raw Typst

While templates are built with [Typst](https://typst.app/), the `docgen` CLI simplifies everything:

```bash
# With docgen - just point to your JSON
docgen compile invoice.json

# With raw typst - you handle all the paths
typst compile --root . --font-path fonts templates/invoice/default.typ output/invoice.pdf \
  --input data=/path/to/invoice.json --input company=/path/to/company.json
```

`docgen` auto-detects document type, finds templates, loads fonts, and places output correctly.

### The AI Workflow

Instead of clicking through forms, describe what you need:

```
"Create an invoice for client Acme Corp for 40 hours of web development 
at 85 EUR/hour, project was the new landing page, payment due in 14 days"
```

An AI assistant (we recommend [Claude](https://claude.ai)) generates the JSON, you review it, and compile to PDF. Fast, flexible, and you stay in control.

## Features

- **Invoice Template** - Professional German invoices with VAT calculation
- **Offer Template** - Quotes and proposals with item breakdowns
- **Credentials Template** - Secure access documentation for clients
- **Concept Template** - Project concepts and proposals
- **Documentation Template** - Technical documentation, API docs, project docs
- **Interactive CLI** - Manage clients, projects, and create documents
- **SQLite Database** - Automatic numbering, client/project management
- **Watch Mode** - Auto-rebuild on file changes
- **10 Font Presets** - Bundled Google Fonts (Inter, Roboto, Montserrat, etc.)
- **Customizable Branding** - Colors, fonts, logo via company.json

## Quick Start

### Prerequisites

Install [Typst](https://github.com/typst/typst#installation) (required for PDF generation)

### Installation

#### Option 1: Homebrew (macOS/Linux)

```bash
# Add the tap
brew tap casoon/tap

# Install docgen
brew install docgen
```

#### Option 2: Install Script (macOS/Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/casoon/typst-business-templates/main/install.sh | bash
```

#### Option 3: Download Binary

Download the latest release for your platform from [GitHub Releases](https://github.com/casoon/typst-business-templates/releases).

| Platform | Download |
|----------|----------|
| macOS (Apple Silicon) | `docgen-aarch64-apple-darwin.tar.gz` |
| macOS (Intel) | `docgen-x86_64-apple-darwin.tar.gz` |
| Linux (x64) | `docgen-x86_64-unknown-linux-gnu.tar.gz` |
| Linux (ARM64) | `docgen-aarch64-unknown-linux-gnu.tar.gz` |
| Windows (x64) | `docgen-x86_64-pc-windows-msvc.zip` |

#### Option 4: Build from Source

```bash
# Clone repository
git clone https://github.com/casoon/typst-business-templates.git
cd typst-business-templates

# Build CLI
cd cli
cargo build --release

# Add to PATH (optional)
export PATH="$PATH:$(pwd)/target/release"
```

### First Steps

```bash
# Initialize new project
docgen init my-business
cd my-business

# Edit your company data
nano data/company.json

# Start interactive mode
docgen
```

## Workflow Options

### Option 1: Interactive CLI

Run `docgen` for a full-featured terminal UI:

```
╔═══════════════════════════════════════════════════════╗
║  DOCGEN - Document Management                         ║
╚═══════════════════════════════════════════════════════╝

Clients (3)

┌───┬────────┬──────────────────────┬────────────┬─────────────────┐
│ # │ Nr.    │ Name                 │ City       │ Email           │
├───┼────────┼──────────────────────┼────────────┼─────────────────┤
│ 1 │ K-001  │ Acme Corp            │ Hamburg    │ info@acme.de    │
│ 2 │ K-002  │ Max Müller           │ Berlin     │ max@example.de  │
└───┴────────┴──────────────────────┴────────────┴─────────────────┘

> Selection: 1
```

Select a client to create invoices, offers, credentials, or concepts.

### Option 2: AI-Assisted Creation

1. **Describe your document** to an AI assistant:
   ```
   Create a JSON invoice for:
   - Client: K-001 (Acme Corp)
   - 3 items: 
     - 40h Development @ 85 EUR
     - 8h Code Review @ 85 EUR  
     - 500 EUR fixed for deployment
   - Due in 14 days
   ```

2. **AI generates the JSON** following the schema in `cli/templates/invoice.json`

3. **Save and compile**:
   ```bash
   docgen compile documents/invoices/RE-2025-001.json
   ```

4. **PDF ready** in `output/RE-2025-001.pdf`

### Option 3: Direct JSON Editing

For power users - copy a template, edit the JSON directly:

```bash
cp cli/templates/invoice.json documents/invoices/RE-2025-001.json
nano documents/invoices/RE-2025-001.json
docgen compile documents/invoices/RE-2025-001.json
```

## CLI Commands

| Command | Description |
|---------|-------------|
| `docgen` | Interactive mode |
| `docgen init <name>` | Create new project |
| `docgen compile <file>` | Compile JSON to PDF |
| `docgen build` | Build all documents |
| `docgen watch` | Watch and auto-rebuild |
| `docgen client list` | List all clients |
| `docgen client add` | Add new client |
| `docgen client show <id>` | Show client details |
| `docgen project list <client>` | List projects |
| `docgen project add <client> <name>` | Add project |

## Project Structure

```
my-business/
├── data/
│   ├── docgen.db          # SQLite database (auto-created)
│   └── company.json       # Your company data
├── documents/
│   ├── invoices/          # Invoice JSON files
│   ├── offers/            # Offer JSON files
│   ├── credentials/       # Credentials JSON files
│   └── concepts/          # Concept JSON files
├── templates/             # Typst templates
└── output/                # Generated PDFs
```

## Document Numbering

Automatic, consistent numbering managed by SQLite:

| Type | Format | Example |
|------|--------|---------|
| Client | K-XXX | K-001 |
| Project | P-KKK-NN | P-001-01 |
| Invoice | RE-YYYY-NNN | RE-2025-001 |
| Offer | AN-YYYY-NNN | AN-2025-001 |
| Credentials | ZD-YYYY-NNN | ZD-2025-001 |
| Concept | KO-YYYY-NNN | KO-2025-001 |

## Examples

The `examples/` directory contains complete, ready-to-use example projects for different types of businesses. Each project includes company data, sample documents, and pre-generated PDFs.

### Example Projects

#### 1. Digitalagentur (Web Agency)
**Pixelwerk Digitalagentur** - Full-service web agency from Cologne

| Document | Description | PDF |
|----------|-------------|-----|
| [Invoice](examples/digitalagentur/data/invoice.json) | Website relaunch for a carpentry shop (12,066.60 EUR) | [PDF](examples/digitalagentur/output/invoice.pdf) |
| [Offer](examples/digitalagentur/data/offer.json) | E-commerce shop for organic farm (9,791.32 EUR) | [PDF](examples/digitalagentur/output/offer.pdf) |

#### 2. Freelance Designer
**Lisa Chen Design** - Freelance graphic designer from Hamburg (Kleinunternehmer)

| Document | Description | PDF |
|----------|-------------|-----|
| [Invoice](examples/freelance-designer/data/invoice.json) | Corporate design for startup (4,700 EUR, no VAT) | [PDF](examples/freelance-designer/output/invoice.pdf) |
| [Offer](examples/freelance-designer/data/offer.json) | Packaging design for tea brand (4,490 EUR) | [PDF](examples/freelance-designer/output/offer.pdf) |

#### 3. IT Consultant
**TechVision Consulting** - IT consulting firm from Berlin

| Document | Description | PDF |
|----------|-------------|-----|
| [Invoice](examples/it-consultant/data/invoice.json) | AWS cloud migration project (47,481 EUR) | [PDF](examples/it-consultant/output/invoice.pdf) |
| [Offer](examples/it-consultant/data/offer.json) | IT security audit for law firm (26,763.10 EUR) | [PDF](examples/it-consultant/output/offer.pdf) |

### Try It Yourself

```bash
# Compile an example (with bundled fonts)
typst compile --root . --font-path fonts templates/invoice/default.typ output/my-invoice.pdf \
  --input data=/examples/digitalagentur/data/invoice.json \
  --input company=/examples/digitalagentur/data/company.json

# Or use the CLI
docgen compile examples/digitalagentur/data/invoice.json
```

### Basic Examples

The `examples/data/` directory also contains basic template examples:

| Document | JSON Data |
|----------|-----------|
| Invoice | [`examples/data/invoice-example.json`](examples/data/invoice-example.json) |
| Offer | [`examples/data/offer-example.json`](examples/data/offer-example.json) |
| Credentials | [`examples/data/credentials-example.json`](examples/data/credentials-example.json) |
| Concept | [`examples/data/concept-example.json`](examples/data/concept-example.json) |
| Documentation | [`examples/data/documentation-example.json`](examples/data/documentation-example.json) |

## Template Customization

Templates are written in [Typst](https://typst.app/docs), a modern alternative to LaTeX:

- Edit colors in `templates/common/styles.typ`
- Modify layouts in `templates/<type>/default.typ`
- Add your logo to `data/company.json`

### Branding Configuration

Customize colors, fonts, and language in `data/company.json`:

```json
{
  "language": "en",
  "branding": {
    "accent_color": "#E94B3C",
    "primary_color": "#2c3e50",
    "font_preset": "inter"
  }
}
```

### Multi-Language Support

Both the CLI and document templates support 7 languages:

| Code | Language |
|------|----------|
| `de` | Deutsch (German) |
| `en` | English |
| `fr` | Français (French) |
| `es` | Español (Spanish) |
| `it` | Italiano (Italian) |
| `nl` | Nederlands (Dutch) |
| `pt` | Português (Portuguese) |

Set the `language` field in `company.json` to change all labels, headings, and CLI output.

### Font Presets

10 professional Google Font combinations are available:

| Preset | Body/Heading | Mono | Style |
|--------|--------------|------|-------|
| `inter` | Inter | JetBrains Mono | Modern, clean |
| `roboto` | Roboto | Roboto Mono | Google's signature |
| `open-sans` | Open Sans | Source Code Pro | Friendly |
| `lato` | Lato | Fira Code | Elegant |
| `montserrat` | Montserrat | Fira Code | Geometric |
| `source-sans` | Source Sans 3 | Source Code Pro | Professional |
| `poppins` | Poppins | JetBrains Mono | Playful |
| `raleway` | Raleway | Fira Code | Sophisticated |
| `nunito` | Nunito | JetBrains Mono | Rounded |
| `work-sans` | Work Sans | Fira Code | Neutral |
| `default` | Helvetica | Courier New | System fallback |

All fonts are included in the `fonts/` directory. Use `--font-path fonts` when compiling:

```bash
typst compile --root . --font-path fonts templates/invoice/default.typ output/invoice.pdf \
  --input data=/path/to/invoice.json
```

## AI Integration Tips

When using Claude or other AI assistants:

1. **Share the JSON schema** from `cli/templates/` so the AI knows the structure
2. **Provide client context** - the AI can look up client data from your database exports
3. **Review before compiling** - always check the generated JSON for accuracy
4. **Use watch mode** during iteration: `docgen watch documents/`

Example prompt for Claude:
```
I'm using typst-business-templates. Here's my invoice schema: [paste schema]
Create an invoice JSON for client "Acme Corp" (K-001) for the following work:
- 40 hours frontend development at 95 EUR/hour
- Project: Website Redesign (P-001-02)
- Invoice date: today
- Payment terms: 14 days
```

## Documentation

- [Project Overview](docs/PROJECT.md) - Current state and ideas
- [Database Concept](docs/DATABASE.md) - SQLite schema and usage
- [Roadmap](docs/ROADMAP.md) - Detailed plan for upcoming improvements

## Requirements

- [Typst](https://typst.app/) >= 0.11
- [Rust](https://rustup.rs/) >= 1.70 (for building CLI)

## Roadmap

- [ ] Edit/delete clients and projects
- [ ] Document status tracking (sent, paid, overdue)
- [ ] Time tracking integration
- [ ] Email sending from CLI
- [ ] E-invoice support (ZUGFeRD/XRechnung)
- [ ] Web UI for non-technical users

## License

MIT License - see [LICENSE](LICENSE)

## Contributing

Contributions welcome! Areas where help is needed:
- Additional document templates (delivery notes, credit notes, reminders)
- Internationalization (currently German-focused)
- Test coverage
- Binary releases for different platforms

Please feel free to submit a Pull Request.

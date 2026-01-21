# Typst Business Templates

Professional business document templates for [Typst](https://typst.app/) with an interactive CLI for managing clients, projects, and documents.

## Features

- **Invoice Template** - Professional German invoices
- **Offer Template** - Quotes and proposals
- **Credentials Template** - Secure access documentation
- **Concept Template** - Project concepts and proposals
- **Interactive CLI** - Manage clients, projects, and create documents
- **SQLite Database** - Automatic numbering, client/project management
- **Watch Mode** - Auto-rebuild on file changes

## Quick Start

### Prerequisites

1. Install [Typst](https://github.com/typst/typst#installation)
2. Install [Rust](https://rustup.rs/) (for CLI)

### Installation

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

### Usage

```bash
# Initialize new project
docgen init my-documents
cd my-documents

# Edit company data
nano data/company.json

# Start interactive mode
docgen
```

## Interactive Mode

Run `docgen` without arguments for a full-featured terminal UI:

```
╔═══════════════════════════════════════════════════════╗
║  DOCGEN - Dokumentenverwaltung                        ║
╚═══════════════════════════════════════════════════════╝

Kunden (3)

┌───┬────────┬──────────────────────┬────────────┬─────────────────┐
│ # │ Nr.    │ Name                 │ Ort        │ E-Mail          │
├───┼────────┼──────────────────────┼────────────┼─────────────────┤
│ 1 │ K-001  │ Kunde GmbH           │ Hamburg    │ info@kunde.de   │
│ 2 │ K-002  │ Max Müller           │ Berlin     │ max@example.de  │
└───┴────────┴──────────────────────┴────────────┴─────────────────┘

> Auswahl: 1
```

Select a client to:
- Create invoices, offers, credentials, concepts
- Manage projects
- View recent documents

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
my-documents/
├── data/
│   ├── docgen.db          # SQLite database (auto-created)
│   └── company.json       # Your company data
├── documents/
│   ├── invoices/          # Invoice JSON files
│   ├── offers/
│   ├── credentials/
│   └── concepts/
├── templates/             # Typst templates (copy from repo)
└── output/                # Generated PDFs
```

## Document Numbering

Automatic, consistent numbering:

| Type | Format | Example |
|------|--------|---------|
| Client | K-XXX | K-001 |
| Project | P-KKK-NN | P-001-01 |
| Invoice | RE-YYYY-NNN | RE-2025-001 |
| Offer | AN-YYYY-NNN | AN-2025-001 |
| Credentials | ZD-YYYY-NNN | ZD-2025-001 |
| Concept | KO-YYYY-NNN | KO-2025-001 |

## Documentation

- [Project Overview](docs/PROJECT.md) - Current state, roadmap, ideas
- [Database Concept](docs/DATABASE.md) - SQLite schema and usage

## Requirements

- [Typst](https://typst.app/) >= 0.11
- [Rust](https://rustup.rs/) >= 1.70 (for building CLI)

## License

MIT License - see [LICENSE](LICENSE)

## Contributing

Contributions welcome! Please feel free to submit a Pull Request.

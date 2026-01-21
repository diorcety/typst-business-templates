# Typst Business Templates

Professional business document templates for [Typst](https://typst.app/) - a modern markup-based typesetting system.

Generate invoices, offers, credentials documentation, and concepts from JSON data files.

## Features

- **Invoice Template** - Professional German invoices with automatic calculations
- **Offer Template** - Quotes and proposals with itemized pricing
- **Credentials Template** - Secure documentation for access data and passwords
- **Concept Template** - Project concepts and proposals
- **Rust CLI** - Command-line tool for easy document generation
- **JSON Schema Validation** - Validate your data before compilation
- **Watch Mode** - Auto-rebuild on file changes

## Quick Start

### Prerequisites

1. Install [Typst](https://github.com/typst/typst#installation)
2. Clone this repository

### Manual Usage (without CLI)

```bash
# Clone the repository
git clone https://github.com/casoon/typst-business-templates.git
cd typst-business-templates

# Edit company data
cp data/company.json data/company.json.backup
nano data/company.json

# Compile an invoice
typst compile --root . templates/invoice/default.typ \
  --input data=/examples/data/invoice-example.json \
  output/invoice.pdf
```

### Using the CLI

```bash
# Build the CLI
cd cli
cargo build --release

# Add to PATH (optional)
export PATH="$PATH:$(pwd)/target/release"

# Initialize a new project
docgen init my-documents
cd my-documents

# Create a new invoice
docgen new invoice RE-2025-001

# Edit the JSON file
nano invoices/RE-2025-001.json

# Compile to PDF
docgen compile invoices/RE-2025-001.json

# Build all documents
docgen build

# Watch for changes
docgen watch
```

## Project Structure

```
typst-business-templates/
├── templates/
│   ├── common/
│   │   └── styles.typ       # Shared styles and colors
│   ├── invoice/
│   │   └── default.typ      # Invoice template
│   ├── offer/
│   │   └── default.typ      # Offer/quote template
│   ├── credentials/
│   │   └── default.typ      # Credentials template
│   └── concept/
│       └── default.typ      # Concept template
├── schema/
│   ├── invoice.schema.json
│   └── credentials.schema.json
├── examples/
│   └── data/
│       ├── invoice-example.json
│       └── credentials-example.json
├── data/
│   └── company.json         # Your company data
├── cli/
│   └── src/
│       └── main.rs          # Rust CLI source
└── README.md
```

## Templates

### Invoice (Rechnung)

Create professional German invoices with:
- Company header and footer
- Recipient address block
- Itemized positions with quantities and prices
- Automatic tax calculation display
- Payment information with bank details

**JSON Structure:**
```json
{
  "metadata": {
    "invoice_number": "RE-2025-001",
    "invoice_date": "15.01.2025",
    "due_date": "29.01.2025"
  },
  "recipient": {
    "name": "Customer Name",
    "address": { ... }
  },
  "items": [
    {
      "description": "Service description",
      "quantity": 10,
      "unit": "hours",
      "unit_price": "95,00 EUR",
      "total_price": "950,00 EUR"
    }
  ],
  "totals": {
    "subtotal": "950,00 EUR",
    "tax_rate": "19%",
    "tax_amount": "180,50 EUR",
    "total": "1.130,50 EUR"
  }
}
```

### Credentials (Zugangsdaten)

Secure documentation for client credentials:
- Confidential marking
- Service-based organization
- Technical settings (servers, ports)
- Login credentials with 2FA support
- Security notices

### Offer (Angebot)

Professional quotes and proposals:
- Itemized pricing with descriptions
- Discount support
- Terms and conditions
- Validity period

### Concept (Konzept)

Project concepts and documentation:
- Table of contents (optional)
- Version and status tracking
- Tag support
- Numbered headings

## Customization

### Company Data

Edit `data/company.json` with your company information:

```json
{
  "name": "Your Company",
  "address": {
    "street": "Street",
    "house_number": "123",
    "postal_code": "12345",
    "city": "City"
  },
  "contact": {
    "phone": "+49 123 456789",
    "email": "info@example.com"
  },
  "bank_account": {
    "bank_name": "Your Bank",
    "iban": "DE89...",
    "bic": "COBADEFFXXX"
  }
}
```

### Styling

Modify `templates/common/styles.typ` to customize:
- Colors (`color-accent`, `color-primary`)
- Fonts (`font-body`, `font-heading`)
- Spacing and borders

### Adding a Logo

Replace the logo placeholder in templates with your logo:

```typst
#image("path/to/your/logo.png", width: 150pt)
```

## CLI Commands

| Command | Description |
|---------|-------------|
| `docgen init <name>` | Create new document project |
| `docgen new <type> <id>` | Create document from template |
| `docgen compile <file>` | Compile JSON to PDF |
| `docgen build [path]` | Build all documents |
| `docgen watch [path]` | Watch and auto-rebuild |
| `docgen validate <file>` | Validate JSON structure |

## Requirements

- [Typst](https://typst.app/) >= 0.11
- [Rust](https://rustup.rs/) (for CLI, optional)

## License

MIT License - see [LICENSE](LICENSE)

## Contributing

Contributions welcome! Please feel free to submit a Pull Request.

## Related Projects

- [Typst](https://typst.app/) - The typesetting system
- [Typst Templates](https://typst.app/universe) - Official template gallery

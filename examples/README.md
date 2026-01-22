# Examples

This directory contains example projects and template references.

## Example Projects

Complete example setups for different business types, each with company data, sample documents, and pre-generated PDFs.

| Directory | Business Type | Documents |
|-----------|--------------|-----------|
| [digitalagentur/](digitalagentur/) | Web Agency (Cologne) | Invoice, Offer, Credentials, Concept, Documentation |
| [freelance-designer/](freelance-designer/) | Graphic Designer, Kleinunternehmer (Hamburg) | Invoice, Offer, Credentials, Concept, Documentation |
| [it-consultant/](it-consultant/) | IT Consulting (Berlin) | Invoice, Offer, Credentials, Concept, Documentation |

Each project contains all 5 document types with realistic, industry-specific content and pre-generated PDFs.

### Usage

**With docgen (recommended):**
```bash
docgen compile examples/digitalagentur/data/invoice.json
```

**With typst directly:**
```bash
typst compile --root . --font-path fonts templates/invoice/default.typ output/invoice.pdf \
  --input data=/examples/digitalagentur/data/invoice.json \
  --input company=/examples/digitalagentur/data/company.json
```

> `docgen` handles paths, fonts, and template selection automatically. The raw typst command requires specifying all paths manually.

## Template References

The `data/` directory contains basic reference examples for all document types.

| Template | JSON | Content File |
|----------|------|--------------|
| Invoice | [invoice-example.json](data/invoice-example.json) | - |
| Offer | [offer-example.json](data/offer-example.json) | - |
| Credentials | [credentials-example.json](data/credentials-example.json) | - |
| Concept | [concept-example.json](data/concept-example.json) | [concept-content.typ](data/concept-content.typ) |
| Documentation | [documentation-example.json](data/documentation-example.json) | [documentation-content.typ](data/documentation-content.typ) |

### Compile Template References

```bash
# From project root
cd /path/to/typst-business-templates

# Invoice
typst compile --root . --font-path fonts templates/invoice/default.typ output/invoice.pdf \
  --input data=/examples/data/invoice-example.json \
  --input company=/examples/data/company.json

# Offer
typst compile --root . --font-path fonts templates/offer/default.typ output/offer.pdf \
  --input data=/examples/data/offer-example.json \
  --input company=/examples/data/company.json

# Credentials
typst compile --root . --font-path fonts templates/credentials/default.typ output/credentials.pdf \
  --input data=/examples/data/credentials-example.json \
  --input company=/examples/data/company.json

# Concept
typst compile --root . --font-path fonts templates/concept/default.typ output/concept.pdf \
  --input data=/examples/data/concept-example.json \
  --input company=/examples/data/company.json

# Documentation
typst compile --root . --font-path fonts templates/documentation/default.typ output/documentation.pdf \
  --input data=/examples/data/documentation-example.json \
  --input company=/examples/data/company.json
```

## Company Data

Each example project has its own `company.json` with different branding. The `data/company.json` is a generic template:

```json
{
  "language": "de",
  "name": "Company Name",
  "branding": {
    "accent_color": "#E94B3C",
    "primary_color": "#2c3e50",
    "font_preset": "inter"
  },
  ...
}
```

See [company.json](data/company.json) for the full structure.

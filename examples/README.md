# Examples

This directory contains example projects and template references.

## Example Projects

Complete example setups for different business types, each with company data, sample documents, and pre-generated PDFs.

| Directory | Business Type | Documents |
|-----------|--------------|-----------|
| [digitalagentur/](digitalagentur/) | Web Agency (Cologne) | Invoice, Offer |
| [freelance-designer/](freelance-designer/) | Graphic Designer, Kleinunternehmer (Hamburg) | Invoice, Offer |
| [it-consultant/](it-consultant/) | IT Consulting (Berlin) | Invoice, Offer |

### Usage

```bash
# Compile an example
typst compile --root .. --font-path ../fonts ../templates/invoice/default.typ \
  digitalagentur/output/invoice.pdf \
  --input data=/examples/digitalagentur/data/invoice.json \
  --input company=/examples/digitalagentur/data/company.json

# Or from project root
docgen compile examples/digitalagentur/data/invoice.json
```

## Template References

The `data/` directory contains reference examples for all document types, including templates not covered by the example projects.

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

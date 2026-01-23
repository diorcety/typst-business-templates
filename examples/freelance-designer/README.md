# Freelance Designer - Example Project

This is a complete, self-contained example project for **Lisa Chen Design**, a freelance graphic designer from Hamburg, Germany.

## Project Structure

This project follows the standard structure created by `docgen init`:

```
freelance-designer/
├── data/
│   └── company.json          # Company information & branding
├── documents/
│   ├── invoices/2025/        # Invoices (JSON format)
│   ├── offers/2025/          # Offers (JSON format)
│   └── credentials/2025/     # Access credentials (JSON format)
├── locale/                   # Localization files (de, en, es, fr, it, nl, pt)
├── templates/                # Typst templates for all document types
└── output/                   # Generated PDFs
```

## Company Profile

**Lisa Chen Design**
- Location: Hamburg, Germany (Schanzenviertel)
- Services: Brand identity, logo design, packaging, social media design
- Tax status: Kleinunternehmer (§19 UStG - no VAT)
- Branding: Purple accent color (#6C63FF), modern font (Poppins)
- Contact: hello@lisachen.design

## Example Documents

### 1. Invoice (JSON-based)
**File:** `documents/invoices/2025/invoice.json`

Professional invoice for "BrewBuddy GmbH" corporate design project:
- Total: 4,700.00 EUR (no VAT - Kleinunternehmer)
- Services: Logo design, business stationery, brand guidelines, social media templates
- Client: Maximilian Brauer / BrewBuddy GmbH
- Payment terms: 14 days net

**Compile:**
```bash
docgen compile documents/invoices/2025/invoice.json
```

### 2. Offer (JSON-based)
**File:** `documents/offers/2025/offer.json`

Quote for "Bergmann Teemanufaktur" tea packaging design:
- Total: 4,490.00 EUR (no VAT - Kleinunternehmer)
- Services: Packaging concept, 6 tea varieties design, gift box, print supervision
- Client: Anna Bergmann / Bergmann Teemanufaktur
- Validity: 30 days
- Timeline: 4-5 weeks

**Compile:**
```bash
docgen compile documents/offers/2025/offer.json
```

### 3. Access Credentials (JSON-based)
**File:** `documents/credentials/2025/credentials.json`

Secure access document for client website:
- WordPress admin access
- FTP credentials
- Design file locations (Figma, Adobe Creative Cloud)

**Compile:**
```bash
docgen compile documents/credentials/2025/credentials.json
```

## Quick Start

### Compile All Documents

```bash
cd examples/freelance-designer

# Compile all documents at once
docgen build
```

This will generate:
- `output/invoice.pdf` - Client invoice
- `output/offer.pdf` - Project quote
- `output/credentials.pdf` - Access credentials

### Customize for Your Business

1. **Edit company data:**
   ```bash
   nano data/company.json
   ```
   Change name, address, branding colors, tax status, etc.

2. **Add your logo:**
   - Place logo file in `data/` directory (e.g., `logo.png`)
   - Add to `company.json`:
     ```json
     {
       "logo": "logo.png",
       "logo_width": "3cm"
     }
     ```

3. **Create new documents:**
   ```bash
   # Copy and modify existing examples
   cp documents/invoices/2025/invoice.json documents/invoices/2025/RE-2025-004.json
   
   # Edit the new file
   nano documents/invoices/2025/RE-2025-004.json
   ```

## Kleinunternehmer (Small Business) Setup

This example demonstrates a **Kleinunternehmer** setup according to German §19 UStG:

- **No VAT charged** on invoices and offers
- All items have `"vat_rate": { "code": "Kleinunternehmer", "percentage": "0" }`
- `vat_breakdown` array is empty: `[]`
- Legal notice included: "Gemäß §19 UStG wird keine Umsatzsteuer berechnet."

**In `company.json`:**
```json
{
  "default_terms": {
    "vat_rate": 0,
    "vat_exempt": true,
    "vat_note": "Gemäß §19 UStG wird keine Umsatzsteuer berechnet."
  }
}
```

**In invoices/offers:**
```json
{
  "totals": {
    "subtotal": { "amount": "4700", "currency": "EUR" },
    "vat_breakdown": [],
    "vat_total": { "amount": "0", "currency": "EUR" },
    "total": { "amount": "4700", "currency": "EUR" }
  }
}
```

## Document Workflow

This example uses the **JSON workflow** for all documents:

### 📊 JSON Workflow (Structured Data)
**Best for:** Invoices, Offers, Credentials

- Data in JSON format
- Content from templates
- Easy to generate programmatically
- Machine-readable

**Structure:**
```json
{
  "metadata": {
    "invoice_number": "RE-2025-003",
    "invoice_date": { "date": "2025-01-18" }
  },
  "recipient": {
    "name": "Client Name",
    "company": "Client Company"
  },
  "items": [
    {
      "description": "Logo Design",
      "quantity": "1",
      "unit_price": { "amount": "1800" }
    }
  ]
}
```

## Features Demonstrated

- ✅ Professional German business documents
- ✅ Kleinunternehmer setup (no VAT)
- ✅ Custom branding (purple accent, Poppins font)
- ✅ Multi-language support (7 languages available)
- ✅ JSON workflow for structured documents
- ✅ Organized by year structure
- ✅ Logo placeholder when no logo configured
- ✅ Graceful handling of empty VAT breakdown

## Learn More

- [Main README](../../README.md) - Full project documentation
- [Examples Overview](../README.md) - All example projects
- [Typst Documentation](https://typst.app/docs) - Typst syntax reference

# IT Consultant - Example Project

This is a complete, self-contained example project for **TechVision Consulting**, an IT security and cloud consulting firm from Berlin, Germany.

## Project Structure

This project follows the standard structure created by `docgen init`:

```
it-consultant/
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

**TechVision Consulting GmbH**
- Location: Berlin, Germany (Friedrichstraße)
- Services: IT security audits, cloud migration, DevOps consulting
- Owner: Dr. Michael Hoffmann
- Branding: Green accent color (#00B894), professional font (Source Sans)
- Contact: info@techvision-consulting.de
- Rates: 1,400 EUR/day, 175 EUR/hour

## Example Documents

### 1. Invoice (JSON-based)
**File:** `documents/invoices/2025/invoice.json`

Professional invoice for "Richter & Partner Rechtsanwälte" IT security project:
- Total: 21,098.50 EUR (incl. 19% VAT)
- Services: Security assessment, penetration testing, GDPR compliance, hardening
- Client: Thomas Richter / Rechtsanwaltskanzlei
- Payment terms: 30 days net
- Includes detailed daily breakdown

**Compile:**
```bash
docgen compile documents/invoices/2025/invoice.json
```

### 2. Offer (JSON-based)
**File:** `documents/offers/2025/offer.json`

Comprehensive quote for law firm IT security audit:
- Total: 26,763.10 EUR (incl. 19% VAT)
- Services: 
  - Security assessment (3 days)
  - Penetration testing (4 days)
  - GDPR compliance check (2 days)
  - Security hardening (5 days)
  - Awareness training (1 workshop)
  - Documentation & final report
- Client: Thomas Richter / Richter & Partner Rechtsanwälte
- Validity: Until February 28, 2025
- Timeline: 4-6 weeks

**Compile:**
```bash
docgen compile documents/offers/2025/offer.json
```

### 3. Access Credentials (JSON-based)
**File:** `documents/credentials/2025/credentials.json`

Secure access document for client infrastructure:
- AWS Console access
- SSH keys for servers
- Database credentials
- Monitoring dashboard access

**Compile:**
```bash
docgen compile documents/credentials/2025/credentials.json
```

## Quick Start

### Compile All Documents

```bash
cd examples/it-consultant

# Compile all documents at once
docgen build
```

This will generate:
- `output/invoice.pdf` - Client invoice
- `output/offer.pdf` - Project quote
- `output/credentials.pdf` - Infrastructure access

### Customize for Your Business

1. **Edit company data:**
   ```bash
   nano data/company.json
   ```
   Change name, address, branding colors, rates, etc.

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
   cp documents/invoices/2025/invoice.json documents/invoices/2025/RE-2025-016.json
   
   # Edit the new file
   nano documents/invoices/2025/RE-2025-016.json
   ```

## VAT Setup (Regular Business)

This example demonstrates a **regular business** with VAT according to German tax law:

- **19% VAT charged** on all services
- All items have `"vat_rate": { "code": "Standard", "percentage": "19" }`
- `vat_breakdown` contains detailed VAT calculation
- VAT ID included in company data

**In `company.json`:**
```json
{
  "vat_id": "DE345678901",
  "default_terms": {
    "vat_rate": 19,
    "standard_terms": [
      "Alle Preise verstehen sich zzgl. der gesetzlichen MwSt. (19%).",
      "Zahlbar innerhalb von 30 Tagen netto."
    ]
  }
}
```

**In invoices/offers:**
```json
{
  "totals": {
    "subtotal": { "amount": "22490", "currency": "EUR" },
    "vat_breakdown": [
      {
        "rate": { "code": "Standard", "percentage": "19" },
        "base": { "amount": "22490", "currency": "EUR" },
        "amount": { "amount": "4273.10", "currency": "EUR" }
      }
    ],
    "vat_total": { "amount": "4273.10", "currency": "EUR" },
    "total": { "amount": "26763.10", "currency": "EUR" }
  }
}
```

## Professional Services Pricing

This example shows typical IT consulting pricing structures:

**Daily Rate:**
- Standard: 1,400 EUR/day (as configured in `company.json`)
- Used for: assessments, penetration tests, implementation work

**Hourly Rate:**
- Standard: 175 EUR/hour
- Used for: short tasks, support, minor adjustments

**Fixed Price:**
- Used for: workshops, documentation, standard deliverables

**Travel Costs:**
- Billed separately as per agreement

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
    "invoice_number": "RE-2025-015",
    "invoice_date": { "date": "2025-01-20" }
  },
  "recipient": {
    "name": "Client Name",
    "company": "Client Company"
  },
  "items": [
    {
      "title": "Security Assessment",
      "quantity": "3",
      "unit": "Tage",
      "unit_price": { "amount": "1400" }
    }
  ]
}
```

## Features Demonstrated

- ✅ Professional German business documents
- ✅ Regular VAT setup (19%)
- ✅ Day-based and hourly pricing
- ✅ Custom branding (green accent, Source Sans font)
- ✅ Multi-language support (7 languages available)
- ✅ JSON workflow for structured documents
- ✅ Organized by year structure
- ✅ Logo placeholder when no logo configured
- ✅ Detailed service breakdowns with sub-items
- ✅ Professional terms and conditions

## Typical Use Cases

This example project covers common IT consulting scenarios:

1. **Security Audits** - Comprehensive infrastructure analysis
2. **Penetration Testing** - Simulated attacks to find vulnerabilities
3. **GDPR Compliance** - Data protection assessment for German businesses
4. **Infrastructure Hardening** - Implementation of security improvements
5. **Training & Workshops** - Employee awareness programs
6. **Documentation** - Technical reports and management summaries

## Learn More

- [Main README](../../README.md) - Full project documentation
- [Examples Overview](../README.md) - All example projects
- [Typst Documentation](https://typst.app/docs) - Typst syntax reference

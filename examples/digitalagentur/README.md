# Digitalagentur - Example Project

This is a complete, self-contained example project for **Pixelwerk Digitalagentur**, a web agency from Cologne, Germany.

## Project Structure

This project follows the standard structure created by `docgen init`:

```
digitalagentur/
├── data/
│   └── company.json          # Company information & branding
├── documents/
│   ├── invoices/2025/        # Invoices (JSON format)
│   ├── offers/2025/          # Offers (JSON format)
│   ├── credentials/2025/     # Access credentials (JSON format)
│   ├── concepts/2025/        # Concepts (.typ format with packages)
│   └── documentation/2025/   # Documentation (.typ format with packages)
├── locale/                   # Localization files (de, en, es, fr, it, nl, pt)
├── templates/                # Typst templates for all document types
└── output/                   # Generated PDFs
```

## Company Profile

**Pixelwerk Digitalagentur**
- Location: Cologne, Germany
- Services: Web design, development, e-commerce solutions
- Branding: Orange accent color (#FF6B35), modern font (Inter)

## Example Documents

### 1. Invoice (JSON-based)
**File:** `documents/invoices/2025/invoice.json`

Professional invoice for "Zimmermann Schreinerei" website relaunch project:
- Total: 12,066.60 EUR (incl. 19% VAT)
- Services: Design, development, content creation
- Payment terms: 14 days net

**Compile:**
```bash
docgen compile documents/invoices/2025/invoice.json
```

### 2. Offer (JSON-based)
**File:** `documents/offers/2025/offer.json`

Quote for "Hofbauer's Biohof" e-commerce shop:
- Total: 9,791.32 EUR (incl. 19% VAT)
- Services: Shopware 6 setup, photography, training
- Validity: 30 days

**Compile:**
```bash
docgen compile documents/offers/2025/offer.json
```

### 3. Access Credentials (JSON-based)
**File:** `documents/credentials/2025/credentials.json`

Secure access document for client website:
- WordPress admin access
- FTP credentials
- Database access
- Email settings

**Compile:**
```bash
docgen compile documents/credentials/2025/credentials.json
```

### 4. Concept Document (.typ with local templates)
**File:** `documents/concepts/2025/concept.typ`

E-commerce concept for "Hofbauer's Biohof" organic farm shop:
- Shopware 6 platform recommendation
- Subscription box system
- Timeline & cost breakdown
- Uses `/.docgen/templates/concept/default.typ` import

**Compile:**
```bash
# First initialize templates (one-time)
docgen template init

# Then compile
docgen compile documents/concepts/2025/concept.typ
```

### 5. Documentation (.typ with local templates)
**File:** `documents/documentation/2025/documentation.typ`

WordPress user manual for "Zimmermann Schreinerei":
- Dashboard overview
- Page editing guide
- Image upload instructions
- WooCommerce basics
- Uses `/.docgen/templates/documentation/default.typ` import

**Compile:**
```bash
# Templates auto-update on compile
docgen compile documents/documentation/2025/documentation.typ
```

## Quick Start

### Compile All Documents

```bash
cd examples/digitalagentur

# Compile all documents at once
docgen build documents/
```

### Customize for Your Business

1. **Edit company data:**
   ```bash
   nano data/company.json
   ```
   Change name, address, branding colors, etc.

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
   cp documents/invoices/2025/invoice.json documents/invoices/2025/RE-2025-002.json
   
   # Or create new .typ documents
   cp documents/concepts/2025/concept.typ documents/concepts/2025/my-concept.typ
   ```

## Two Document Workflows

This example demonstrates **both workflows** supported by docgen:

### 📊 JSON Workflow (Structured Data)
**Best for:** Invoices, Offers, Credentials

- Data in JSON format
- Content from templates
- Easy to generate programmatically
- Machine-readable

**Example:**
```json
{
  "metadata": {
    "document_number": "RE-2025-001",
    "client_name": "Acme Corp"
  },
  "items": [
    {"description": "Web Design", "quantity": 40, "unit_price": 95.00}
  ]
}
```

### 📝 .typ Workflow (Direct Writing)
**Best for:** Concepts, Documentation, Reports

- Everything in one `.typ` file
- Full Typst syntax (tables, math, references)
- Uses project-local templates (`/.docgen/templates/`)
- Better version control

**Example:**
```typ
#import "/.docgen/templates/concept/default.typ": concept

// Load company and locale from project root (absolute paths)
#let company = json("/data/company.json")
#let locale = json("/locale/de.json")

#show: concept.with(
  title: "My Project Concept",
  client_name: "Client Name",
  company: company,
  locale: locale,
)

= Introduction
Your content here...
```

## Features Demonstrated

- ✅ Professional German business documents
- ✅ VAT calculation (19%)
- ✅ Custom branding (colors, fonts)
- ✅ Multi-language support (7 languages available)
- ✅ Both JSON and .typ workflows
- ✅ Project-local template system
- ✅ Organized by year structure
- ✅ Auto-updating standard templates

## Learn More

- [Main README](../../README.md) - Full project documentation
- [Examples Overview](../README.md) - All example projects
- [Typst Documentation](https://typst.app/docs) - Typst syntax reference

// Common Typst Styles
// This file contains reusable style definitions for all templates
// Based on casoon-documents styling

// Load company data for branding colors (if available)
#let company-data = json("../../data/company.json")

// Color Palette (with company branding override)
#let color-primary = if "branding" in company-data and "primary_color" in company-data.branding {
  rgb(company-data.branding.primary_color)
} else {
  rgb("#2c3e50")
}

#let color-accent = if "branding" in company-data and "accent_color" in company-data.branding {
  rgb(company-data.branding.accent_color)
} else {
  rgb("#E94B3C")
}

#let color-secondary = rgb("#34495e")
#let color-text = rgb("#2c3e50")
#let color-text-light = rgb("#7f8c8d")
#let color-border = rgb("#bdc3c7")
#let color-background = rgb("#f5f5f5")
#let color-white = rgb("#ffffff")
#let color-warning = rgb("#fff8e1")

// Typography
#let font-body = "Helvetica"
#let font-heading = "Helvetica"
#let font-mono = "Courier New"

#let size-xs = 7pt
#let size-small = 8pt
#let size-normal = 9pt
#let size-medium = 10pt
#let size-large = 11pt
#let size-xlarge = 13pt
#let size-xxlarge = 16pt
#let size-title = 22pt

// Text Styles (as dictionaries for use with set text(..style))
#let text-body = (
  font: font-body,
  size: size-medium,
  fill: color-text,
)

#let text-small = (
  font: font-body,
  size: size-small,
  fill: color-text-light,
)

#let text-heading = (
  font: font-heading,
  size: size-large,
  fill: color-primary,
  weight: "bold",
)

#let text-title = (
  font: font-heading,
  size: size-xxlarge,
  fill: color-primary,
  weight: "bold",
)

#let text-mono = (
  font: font-mono,
  size: size-small,
)

// Layout Spacing
#let spacing-xs = 0.2em
#let spacing-small = 0.3em
#let spacing-normal = 0.5em
#let spacing-medium = 1em
#let spacing-large = 1.5em
#let spacing-xlarge = 2em

// Border Styles
#let border-thin = 0.5pt
#let border-normal = 1pt
#let border-thick = 2pt

// UTILITY: Currency format
#let format-currency(amount, currency: "EUR") = [#amount #currency]

// UTILITY: Pill/tag component
#let pill(content, stroke-color: color-text-light) = box(
  stroke: 0.75pt + stroke-color,
  radius: 10pt,
  inset: (x: 10pt, y: 5pt),
  text(size: size-small, fill: stroke-color)[#content]
)

// UTILITY: Info box
#let info-box(content, fill: color-background) = block(
  fill: fill,
  inset: spacing-medium,
  radius: 4pt,
  width: 100%,
  content
)

// UTILITY: Warning box
#let warning-box(content, accent: color-accent) = block(
  stroke: 1.5pt + accent,
  radius: 6pt,
  inset: spacing-medium,
  width: 100%,
  content
)

// UTILITY: Resolve placeholder in footer line
// Replaces {field} and {field.subfield} with values from company data
#let resolve-placeholder(template, company) = {
  let result = template
  
  // Simple field replacements
  if result.contains("{name}") and "name" in company {
    result = result.replace("{name}", company.name)
  }
  if result.contains("{business_owner}") and "business_owner" in company and company.business_owner != none {
    result = result.replace("{business_owner}", company.business_owner)
  }
  if result.contains("{tax_id}") and "tax_id" in company and company.tax_id != none {
    result = result.replace("{tax_id}", company.tax_id)
  }
  if result.contains("{vat_id}") and "vat_id" in company and company.vat_id != none {
    result = result.replace("{vat_id}", company.vat_id)
  }
  
  // Address fields
  if result.contains("{address.street}") and "address" in company and "street" in company.address {
    result = result.replace("{address.street}", company.address.street)
  }
  if result.contains("{address.house_number}") and "address" in company and "house_number" in company.address {
    result = result.replace("{address.house_number}", company.address.house_number)
  }
  if result.contains("{address.postal_code}") and "address" in company and "postal_code" in company.address {
    result = result.replace("{address.postal_code}", company.address.postal_code)
  }
  if result.contains("{address.city}") and "address" in company and "city" in company.address {
    result = result.replace("{address.city}", company.address.city)
  }
  if result.contains("{address.country}") and "address" in company and "country" in company.address {
    result = result.replace("{address.country}", company.address.country)
  }
  
  // Contact fields
  if result.contains("{contact.phone}") and "contact" in company and "phone" in company.contact {
    result = result.replace("{contact.phone}", company.contact.phone)
  }
  if result.contains("{contact.email}") and "contact" in company and "email" in company.contact {
    result = result.replace("{contact.email}", company.contact.email)
  }
  if result.contains("{contact.website}") and "contact" in company and "website" in company.contact {
    result = result.replace("{contact.website}", company.contact.website)
  }
  
  // Bank account fields
  if result.contains("{bank_account.bank_name}") and "bank_account" in company and "bank_name" in company.bank_account {
    result = result.replace("{bank_account.bank_name}", company.bank_account.bank_name)
  }
  if result.contains("{bank_account.iban}") and "bank_account" in company and "iban" in company.bank_account {
    result = result.replace("{bank_account.iban}", company.bank_account.iban)
  }
  if result.contains("{bank_account.bic}") and "bank_account" in company and "bic" in company.bank_account {
    result = result.replace("{bank_account.bic}", company.bank_account.bic)
  }
  if result.contains("{bank_account.account_holder}") and "bank_account" in company and "account_holder" in company.bank_account {
    result = result.replace("{bank_account.account_holder}", company.bank_account.account_holder)
  }
  
  result
}

// UTILITY: Dynamic footer from company.json
// Automatically adjusts column count (1-4) based on footer configuration
#let company-footer(company, show-line: true) = {
  if "footer" not in company or "columns" not in company.footer {
    return []
  }
  
  let footer-columns = company.footer.columns
  let col-count = footer-columns.len()
  
  if col-count == 0 {
    return []
  }
  
  // Build column content
  let col-content = ()
  for col in footer-columns {
    let lines = ()
    
    // Add title if present
    if "title" in col and col.title != none {
      lines.push(strong[#col.title])
    }
    
    // Add lines with placeholder resolution
    if "lines" in col {
      for line in col.lines {
        let resolved = resolve-placeholder(line, company)
        // Skip lines that still contain unresolved placeholders
        if not resolved.contains("{") {
          lines.push(resolved)
        }
      }
    }
    
    // Join lines with linebreaks
    col-content.push(lines.join(linebreak()))
  }
  
  // Calculate column widths (equal distribution)
  let col-width = 100% / col-count
  let col-widths = range(col-count).map(_ => col-width)
  
  [
    #if show-line [
      #line(length: 100%, stroke: border-thin)
      #v(5pt)
    ]
    #set text(size: size-xs)
    #grid(
      columns: col-widths,
      column-gutter: 8pt,
      ..col-content
    )
  ]
}

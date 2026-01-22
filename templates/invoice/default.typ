// Invoice Template (Rechnung)
// German-formatted invoice template for professional business use
// Based on casoon-documents structure

#import "../common/styles.typ": *

// Load data from JSON input
#let data = json(sys.inputs.data)

// Load company data
#let company = json("../../data/company.json")

// Page setup
#set page(
  paper: "a4",
  margin: (left: 2.5cm, right: 2cm, top: 2cm, bottom: 2cm),
  header: context {
    if counter(page).get().first() > 1 [
      #set text(..text-small)
      #grid(
        columns: (1fr, 1fr),
        align: (left, right),
        [#company.name],
        [Seite #counter(page).display()]
      )
      #v(0.3em)
      #line(length: 100%, stroke: border-thin + color-border)
    ]
  },
  footer: [
    #line(length: 100%, stroke: border-thin + color-border)
    #v(0.3em)
    #set text(size: size-xs)
    #grid(
      columns: (1fr, 1fr, 1fr),
      align: (left, center, right),
      [
        #company.name #linebreak()
        #company.address.street #company.address.house_number #linebreak()
        #company.address.postal_code #company.address.city
      ],
      [
        Tel: #company.contact.phone #linebreak()
        E-Mail: #company.contact.email #linebreak()
        #if "website" in company.contact [Web: #company.contact.website]
      ],
      [
        #if "tax_id" in company and company.tax_id != none [Steuernr: #company.tax_id #linebreak()]
        #if "vat_id" in company and company.vat_id != none [USt-IdNr: #company.vat_id]
      ]
    )
  ]
)

// Document settings
#set text(..text-body)
#set par(justify: true, leading: 0.65em)

// Sender address (small, above recipient)
#set text(..text-small)
[#company.name · #company.address.street #company.address.house_number · #company.address.postal_code #company.address.city]

#v(spacing-medium)

// Recipient address block
#set text(..text-body)
#block(width: 8.5cm)[
  #if "company" in data.recipient and data.recipient.company != none [
    #data.recipient.company #linebreak()
  ]
  #data.recipient.name #linebreak()
  #data.recipient.address.street #data.recipient.address.house_number #linebreak()
  #data.recipient.address.postal_code #data.recipient.address.city
  #if "country" in data.recipient.address and data.recipient.address.country != "Deutschland" [
    #linebreak()
    #data.recipient.address.country
  ]
]

#v(spacing-xlarge)

// Invoice details grid (right aligned)
#align(right)[
  #grid(
    columns: (auto, auto),
    column-gutter: spacing-medium,
    row-gutter: spacing-small,
    align: (right, left),
    [*Rechnungsnummer:*], [#data.metadata.invoice_number],
    [*Rechnungsdatum:*], [#data.metadata.invoice_date.date],
    [*Fälligkeitsdatum:*], [#data.metadata.due_date.date],
    ..if "customer_number" in data.metadata and data.metadata.customer_number != none {
      ([*Kundennummer:*], [#data.metadata.customer_number])
    } else { () },
    ..if "project_reference" in data.metadata and data.metadata.project_reference != none {
      ([*Projekt:*], [#data.metadata.project_reference])
    } else { () },
    ..if "performance_period" in data.metadata and data.metadata.performance_period != none {
      ([*Leistungszeitraum:*], [#data.metadata.performance_period])
    } else { () },
  )
]

#v(spacing-xlarge)

// Invoice title
#set text(..text-title)
[*Rechnung*]

#v(spacing-large)

// Items table
#set text(..text-body)
#table(
  columns: (1fr, auto, auto, auto, auto),
  align: (left, right, right, right, right),
  stroke: (x, y) => if y == 0 {
    (bottom: border-normal + color-primary)
  } else {
    (bottom: border-thin + color-border)
  },
  inset: (x: spacing-normal, y: spacing-small),

  // Header row
  table.cell(fill: color-white)[*Position*],
  table.cell(fill: color-white)[*Menge*],
  table.cell(fill: color-white)[*Einheit*],
  table.cell(fill: color-white)[*Einzelpreis*],
  table.cell(fill: color-white)[*Gesamtpreis*],

  // Item rows
  ..for item in data.items {
    (
      [
        #item.description
        #if "sub_items" in item and item.sub_items.len() > 0 [
          #for sub in item.sub_items [
            #linebreak()
            #text(size: size-small, fill: color-text-light)[– #sub]
          ]
        ]
      ],
      [#item.quantity],
      [#item.unit],
      [#item.unit_price.amount #item.unit_price.currency],
      [#item.total.amount #item.total.currency],
    )
  }
)

#v(spacing-medium)

// Totals section (right aligned)
#align(right)[
  #grid(
    columns: (auto, auto),
    column-gutter: spacing-large,
    row-gutter: spacing-small,
    align: (right, right),

    [Zwischensumme:], [#data.totals.subtotal.amount #data.totals.subtotal.currency],
    
    // VAT breakdown
    ..if "vat_breakdown" in data.totals {
      for vat in data.totals.vat_breakdown {
        ([MwSt. (#vat.rate.percentage%):], [#vat.amount.amount #vat.amount.currency])
      }
    } else if "vat_total" in data.totals and data.totals.vat_total != none {
      ([MwSt.:], [#data.totals.vat_total.amount #data.totals.vat_total.currency])
    } else { () },
    
    [], [],
    grid.cell(stroke: (top: border-normal + color-primary))[*Gesamtbetrag:*],
    grid.cell(stroke: (top: border-normal + color-primary))[*#data.totals.total.amount #data.totals.total.currency*],
  )
]

#v(spacing-xlarge)

// Payment information
#if "payment" in data and data.payment != none [
  #block(
    fill: color-background,
    inset: spacing-medium,
    radius: 3pt,
    width: 100%,
  )[
    *Zahlungsinformationen*

    #v(spacing-small)

    #grid(
      columns: (auto, 1fr),
      column-gutter: spacing-medium,
      row-gutter: spacing-small,

      [Bank:], [#data.payment.bank_account.bank_name],
      [IBAN:], [#data.payment.bank_account.iban],
      [BIC:], [#data.payment.bank_account.bic],
      [Verwendungszweck:], [Rechnung #data.metadata.invoice_number],
    )
  ]

  #v(spacing-large)
]

// Notes section
#if "notes" in data and data.notes != none [
  *Hinweise*

  #v(spacing-small)

  #data.notes

  #v(spacing-medium)
]

// Terms and conditions
#if "terms" in data and data.terms != none [
  #set text(..text-small)

  #data.terms
] else if "payment" in data and "payment_terms" in data.payment [
  #set text(..text-small)

  #data.payment.payment_terms
]

#v(spacing-xlarge)

// Closing
[
  Vielen Dank für Ihr Vertrauen!

  #v(spacing-medium)

  Mit freundlichen Grüßen

  #v(spacing-large)

  #company.name
]

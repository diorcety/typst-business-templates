// Invoice Template (Rechnung)
// Professional German invoice template

#import "../common/styles.typ": *

// Load data from JSON input
#let data = json(sys.inputs.data)

// Load company data
#let company = json(read("../../data/company.json", encoding: none))

#set page(
  paper: "a4",
  margin: (left: 2.5cm, right: 2cm, top: 2cm, bottom: 2.5cm),
  header: context {
    if counter(page).get().first() > 1 [
      #set text(size: size-small, fill: color-text-light)
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
        #company.name \
        #company.address.street #company.address.house_number \
        #company.address.postal_code #company.address.city
      ],
      [
        Tel: #company.contact.phone \
        E-Mail: #company.contact.email
      ],
      [
        #if "tax_id" in company [Steuernr: #company.tax_id \]
        #if "vat_id" in company [USt-IdNr: #company.vat_id]
      ]
    )
  ]
)

#set text(font: font-body, size: size-medium, lang: "de")
#set par(justify: true, leading: 0.65em)

// Sender line (small)
#set text(size: size-small, fill: color-text-light)
[#company.name · #company.address.street #company.address.house_number · #company.address.postal_code #company.address.city]

#v(spacing-medium)

// Recipient address
#set text(size: size-medium, fill: color-text)
#block(width: 8.5cm)[
  #data.recipient.name \
  #if "company" in data.recipient and data.recipient.company != none [#data.recipient.company \]
  #data.recipient.address.street #data.recipient.address.house_number \
  #data.recipient.address.postal_code #data.recipient.address.city
]

#v(spacing-xlarge)

// Invoice details (right aligned)
#align(right)[
  #grid(
    columns: (auto, auto),
    column-gutter: spacing-medium,
    row-gutter: spacing-small,
    align: (right, left),
    [*Rechnungsnummer:*], [#data.metadata.invoice_number],
    [*Rechnungsdatum:*], [#data.metadata.invoice_date],
    [*Fälligkeitsdatum:*], [#data.metadata.due_date],
    ..if "customer_number" in data.metadata and data.metadata.customer_number != none {
      ([*Kundennummer:*], [#data.metadata.customer_number])
    } else { () }
  )
]

#v(spacing-xlarge)

// Title
#text(size: size-xxlarge, weight: "bold", fill: color-primary)[Rechnung]

#v(spacing-large)

// Items table
#table(
  columns: (1fr, auto, auto, auto, auto),
  align: (left, right, right, right, right),
  stroke: (x, y) => if y == 0 { (bottom: border-normal + color-accent) } else if y > 0 { (bottom: border-thin + color-border) } else { none },
  inset: (x: spacing-normal, y: spacing-small),
  
  table.cell(fill: color-white)[*Position*],
  table.cell(fill: color-white)[*Menge*],
  table.cell(fill: color-white)[*Einheit*],
  table.cell(fill: color-white)[*Einzelpreis*],
  table.cell(fill: color-white)[*Gesamtpreis*],
  
  ..for item in data.items {
    (
      [#item.description],
      [#item.quantity],
      [#item.unit],
      [#item.unit_price],
      [#item.total_price],
    )
  }
)

#v(spacing-medium)

// Totals
#align(right)[
  #grid(
    columns: (auto, auto),
    column-gutter: spacing-large,
    row-gutter: spacing-small,
    align: (right, right),
    [Zwischensumme:], [#data.totals.subtotal],
    [MwSt. (#data.totals.tax_rate):], [#data.totals.tax_amount],
    [], [],
    table.cell(stroke: (top: border-normal + color-accent))[*Gesamtbetrag:*],
    table.cell(stroke: (top: border-normal + color-accent))[*#data.totals.total*],
  )
]

#v(spacing-xlarge)

// Payment information
#info-box[
  *Zahlungsinformationen*
  #v(spacing-small)
  #grid(
    columns: (auto, 1fr),
    column-gutter: spacing-medium,
    row-gutter: spacing-small,
    [Bank:], [#company.bank_account.bank_name],
    [IBAN:], [#company.bank_account.iban],
    [BIC:], [#company.bank_account.bic],
    [Verwendungszweck:], [Rechnung #data.metadata.invoice_number],
  )
]

#v(spacing-large)

// Notes
#if "notes" in data and data.notes != none [
  *Hinweise*
  #v(spacing-small)
  #data.notes
  #v(spacing-medium)
]

// Payment terms
#set text(size: size-small)
#if "terms" in data and data.terms != none [
  *Zahlungsbedingungen*
  #v(spacing-small)
  #data.terms
] else [
  Der Rechnungsbetrag ist innerhalb von 14 Tagen nach Rechnungsdatum ohne Abzug zur Zahlung fällig.
]

#v(spacing-xlarge)

// Closing
#set text(size: size-medium)
[
  Vielen Dank für Ihr Vertrauen!
  
  #v(spacing-medium)
  Mit freundlichen Grüßen
  #v(spacing-large)
  #company.name
]

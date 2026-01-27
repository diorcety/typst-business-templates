// Order Confirmation Template (Auftragsbestätigung) - CASOON Layout
// Confirmation of received orders

// Load data from JSON input
#import "../common/footers.typ": accounting-footer
#import "../common/formatting.typ": format_german_date, format_money
#import "../common/din5008-address.typ": din5008-address-block
#import "../common/accounting-header.typ": accounting-header, order-confirmation-metadata
#let data = json(sys.inputs.data)

// Load company data
#let company = json("/data/company.json")

#set page(
  paper: "a4",
  margin: (left: 50pt, right: 45pt, top: 50pt, bottom: 80pt),

  footer: accounting-footer(company: company)
)

#set text(font: "Helvetica", size: 10pt, lang: "de")

// Logo and metadata
#accounting-header(
  company: company,
  metadata_content: order-confirmation-metadata(
    confirmation_number: data.metadata.confirmation_number,
    confirmation_date: data.metadata.confirmation_date,
    order_number: data.metadata.order_number,
    expected_delivery: if "expected_delivery" in data.metadata { data.metadata.expected_delivery } else { none },
  )
)

// Recipient address - DIN 5008
#din5008-address-block(
  company: company,
  recipient: data.recipient,
)

// Title and intro
#block[
  #set text(size: 10pt, font: "Helvetica")

  #text(weight: "bold", size: 12pt)[Auftragsbestätigung]

  #v(8pt)

  #if "salutation" in data and data.salutation != none [
    #data.salutation.greeting\
    #v(3pt)
    #if "introduction" in data.salutation [
      #data.salutation.introduction
    ]
  ] else [
    Sehr geehrte Damen und Herren,\
    #v(3pt)
    vielen Dank für Ihre Bestellung. Hiermit bestätigen wir den Auftrag wie folgt:
  ]

  #v(8pt)
]

// Items table
#block[
  #set text(size: 8pt, font: "Helvetica")

  #grid(
    columns: (35pt, 200pt, 50pt, 50pt, 80pt, 90pt),
    align: (center, left, center, center, right, right),
    row-gutter: 8pt,

    text(weight: "bold")[Pos.],
    text(weight: "bold")[Artikel / Beschreibung],
    text(weight: "bold")[Menge],
    text(weight: "bold")[Einh.],
    text(weight: "bold")[Einzelpreis],
    text(weight: "bold")[Summe],
  )

  #v(5pt)
  #line(length: 100%, stroke: 0.5pt)
  #v(5pt)
]

#for item in data.items [
  #block[
    #set text(size: 8pt, font: "Helvetica")

    #grid(
      columns: (35pt, 200pt, 50pt, 50pt, 80pt, 90pt),
      align: (center, left, center, center, right, right),
      row-gutter: 5pt,

      [#item.position],
      [
        #if "article_number" in item and item.article_number != none [
          #text(weight: "bold")[Art.-Nr.: #item.article_number]\
        ]
        #item.description
      ],
      [#item.quantity],
      {
        if item.unit == "stueck" [Stk.]
        else if item.unit == "stunde" [Std.]
        else if item.unit == "tag" [Tag]
        else [#item.unit]
      },
      [#format_money(item.unit_price.amount) EUR],
      [#text(weight: "bold")[#format_money(item.total.amount) EUR]],
    )

    #v(5pt)
  ]
]

#v(5pt)
#line(length: 100%, stroke: 0.5pt)
#v(5pt)

// Totals
#align(right)[
  #set text(size: 10pt, font: "Helvetica")

  #if data.totals.vat_breakdown.len() > 0 [
    #grid(
      columns: (100pt, 80pt),
      align: (right, right),
      row-gutter: 10pt,

      [Nettobetrag:], [#format_money(data.totals.subtotal.amount) EUR],
      [MwSt. (#data.totals.vat_breakdown.at(0).rate.percentage%):], [#format_money(data.totals.vat_breakdown.at(0).amount.amount) EUR],
      [#text(weight: "bold", size: 11pt)[Gesamtbetrag:]], [#text(weight: "bold", size: 11pt)[#format_money(data.totals.total.amount) EUR]],
    )
  ]
]

#v(10pt)

// Terms and closing
#block[
  #set text(size: 10pt, font: "Helvetica")
  #set par(justify: true)

  #if "payment_terms" in data.terms and data.terms.payment_terms != none [
    *Zahlungsbedingungen:* #data.terms.payment_terms

    #v(8pt)
  ]

  #if "delivery_terms" in data.terms and data.terms.delivery_terms != none [
    *Lieferbedingungen:* #data.terms.delivery_terms

    #v(8pt)
  ]

  #if "custom_text" in data and data.custom_text != none [
    #data.custom_text

    #v(8pt)
  ]

  Mit freundlichen Grüßen

  #v(20pt)

  #if "business_owner" in company and company.business_owner != none [
    #company.business_owner
  ] else [
    #company.name
  ]
]

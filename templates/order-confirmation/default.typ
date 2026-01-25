// Order Confirmation Template (Auftragsbestätigung) - CASOON Layout
// Confirmation of received orders

// Load data from JSON input
#import "../common/footers.typ": accounting-footer
#let data = json(sys.inputs.data)

// Load company data
#let company = json("/data/company.json")

// Helper function to format date as DD.MM.YY
#let format_german_date(date_obj) = {
  let date_str = date_obj.date
  let parts = date_str.split("-")
  if parts.len() == 3 {
    let year = parts.at(0).slice(2, 4)
    let month = parts.at(1)
    let day = parts.at(2)
    day + "." + month + "." + year
  } else {
    date_str
  }
}

// Helper function to format money
#let format_money(amount) = {
  let str_amount = str(amount)
  if str_amount.contains(".") {
    let parts = str_amount.split(".")
    let integer_part = parts.at(0)
    let decimal_part = parts.at(1)
    if decimal_part.len() == 1 {
      integer_part + "," + decimal_part + "0"
    } else if decimal_part.len() >= 2 {
      integer_part + "," + decimal_part.slice(0, 2)
    } else {
      integer_part + ",00"
    }
  } else {
    str_amount + ",00"
  }
}

#set page(
  paper: "a4",
  margin: (left: 50pt, right: 45pt, top: 50pt, bottom: 80pt),

  footer: accounting-footer(company: company)
    )
  ]
)

#set text(font: "Helvetica", size: 10pt, lang: "de")

// Logo
#place(
  right + top,
  dx: 0pt,
  dy: 0pt,
  if "logo" in company and company.logo != none [
    #image("/" + company.logo, width: 150pt)
  ]
)

// Metadata
#place(
  right + top,
  dx: 0pt,
  dy: 80pt,
  block(width: 195pt)[
    #set text(size: 8pt)
    #set par(leading: 0.5em)

    #text(weight: "bold")[Rückfragen an:]\
    #company.name\
    #if "phone" in company.contact and company.contact.phone != none [
      #company.contact.phone\
    ]
    #if "email" in company.contact and company.contact.email != none [
      #company.contact.email
    ]

    #v(5pt)

    #set text(size: 10pt)
    *AB-Nr.:* #data.metadata.confirmation_number\
    #if "order_reference" in data.metadata and data.metadata.order_reference != none [
      *Ihre Bestellung:* #data.metadata.order_reference\
    ]
    *Datum:* #format_german_date(data.metadata.date)\
    #if "delivery_date" in data.metadata and data.metadata.delivery_date != none [
      *Liefertermin:* #format_german_date(data.metadata.delivery_date)\
    ]
  ]
)

// Recipient address - DIN 5008
#v(77.5pt)

#block(height: 20pt)[
  #set text(size: 8pt, font: "Helvetica")
  #if "business_owner" in company and company.business_owner != none [
    #company.business_owner · #company.address.street #company.address.house_number · #company.address.postal_code #company.address.city
  ] else [
    #company.name · #company.address.street #company.address.house_number · #company.address.postal_code #company.address.city
  ]
]

#block(height: 120pt)[
  #set text(size: 12pt, font: "Helvetica")

  #if "company" in data.recipient and data.recipient.company != none [
    #data.recipient.company\
  ]
  #data.recipient.name\
  #data.recipient.address.street #data.recipient.address.house_number\
  #data.recipient.address.postal_code #data.recipient.address.city
]

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

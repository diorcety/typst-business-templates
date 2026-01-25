// Delivery Note Template (Lieferschein) - CASOON Layout
// Document for tracking goods delivery

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
    *Lieferschein-Nr.:* #data.metadata.delivery_note_number\
    #if "order_reference" in data.metadata and data.metadata.order_reference != none [
      *Bestell-Nr.:* #data.metadata.order_reference\
    ]
    *Lieferdatum:* #format_german_date(data.metadata.delivery_date)\
    #if "delivery_time" in data.metadata and data.metadata.delivery_time != none [
      *Lieferzeit:* #data.metadata.delivery_time\
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

// Delivery address (can be different from billing address)
#block(height: 120pt)[
  #set text(size: 12pt, font: "Helvetica")

  #if "delivery_address" in data and data.delivery_address != none [
    #if "company" in data.delivery_address and data.delivery_address.company != none [
      #data.delivery_address.company\
    ]
    #if "name" in data.delivery_address [
      #data.delivery_address.name\
    ]
    #data.delivery_address.address.street #data.delivery_address.address.house_number\
    #data.delivery_address.address.postal_code #data.delivery_address.address.city
  ] else [
    #data.recipient.name\
    #if "company" in data.recipient and data.recipient.company != none [
      #data.recipient.company\
    ]
    #data.recipient.address.street #data.recipient.address.house_number\
    #data.recipient.address.postal_code #data.recipient.address.city
  ]
]

// Title
#block[
  #set text(size: 10pt, font: "Helvetica")

  #text(weight: "bold", size: 12pt)[Lieferschein]

  #v(8pt)
]

// Items table
#block[
  #set text(size: 8pt, font: "Helvetica")

  #grid(
    columns: (35pt, 250pt, 60pt, 60pt, 80pt),
    align: (center, left, center, center, left),
    row-gutter: 8pt,

    text(weight: "bold")[Pos.],
    text(weight: "bold")[Artikel / Beschreibung],
    text(weight: "bold")[Menge],
    text(weight: "bold")[Einheit],
    text(weight: "bold")[Bemerkung],
  )

  #v(5pt)
  #line(length: 100%, stroke: 0.5pt)
  #v(5pt)
]

#for item in data.items [
  #block[
    #set text(size: 8pt, font: "Helvetica")

    #grid(
      columns: (35pt, 250pt, 60pt, 60pt, 80pt),
      align: (center, left, center, center, left),
      row-gutter: 5pt,

      [#item.position],
      [
        #if "article_number" in item and item.article_number != none [
          Art.-Nr.: #item.article_number\
        ]
        #item.description
      ],
      [#item.quantity],
      {
        if item.unit == "stueck" [Stk.]
        else if item.unit == "karton" [Ktn.]
        else if item.unit == "palette" [Pal.]
        else if item.unit == "kg" [kg]
        else if item.unit == "meter" [m]
        else [#item.unit]
      },
      [#if "notes" in item and item.notes != none [#item.notes]],
    )

    #v(5pt)
  ]
]

#v(5pt)
#line(length: 100%, stroke: 0.5pt)
#v(10pt)

// Signature section
#block[
  #set text(size: 9pt, font: "Helvetica")

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 20pt,
    row-gutter: 50pt,

    [
      #box(
        width: 100%,
        stroke: (top: 0.5pt),
        inset: (top: 5pt),
      )[
        #align(center)[Ort, Datum, Unterschrift Lieferant]
      ]
    ],

    [
      #box(
        width: 100%,
        stroke: (top: 0.5pt),
        inset: (top: 5pt),
      )[
        #align(center)[Ort, Datum, Unterschrift Empfänger]
      ]
    ],
  )
]

#v(10pt)

// Special notes
#if "special_notes" in data and data.special_notes != none [
  #block[
    #set text(size: 9pt, font: "Helvetica")
    
    #text(weight: "bold")[Hinweise:]\
    #data.special_notes
  ]
]

// Shipping info
#if "shipping_method" in data.metadata and data.metadata.shipping_method != none [
  #v(8pt)
  #block[
    #set text(size: 9pt, font: "Helvetica")
    
    *Versandart:* #data.metadata.shipping_method
    
    #if "tracking_number" in data.metadata and data.metadata.tracking_number != none [
      \ *Sendungsnummer:* #data.metadata.tracking_number
    ]
  ]
]

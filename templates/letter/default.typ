// Letter Template (Geschäftsbrief) - CASOON Layout
// Based on invoice template layout with DIN 5008 compliance
// Supports both JSON input and direct .typ content files

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
    let year = parts.at(0).slice(2, 4)  // Get last 2 digits of year
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

#set text(
  font: "Helvetica",
  size: 10pt,
  lang: "de"
)

// ============================================================================
// HEADER SECTION
// ============================================================================

// Logo (right side at x=350, y=50)
#place(
  right + top,
  dx: 0pt,
  dy: 0pt,
  if "logo" in company and company.logo != none [
    #image("/" + company.logo, width: 150pt)
  ] else [
    #box(
      width: 150pt,
      height: 50pt,
      stroke: 1pt + luma(200),
      inset: 10pt,
      radius: 4pt,
    )[
      #align(center + horizon)[
        #text(size: 8pt, fill: luma(150))[Logo hinzufügen in\ company.json]
      ]
    ]
  ]
)

// Letter metadata (right side, below logo at x=350)
#place(
  right + top,
  dx: 0pt,
  dy: 80pt,
  block(width: 195pt)[
    #set text(size: 8pt)
    #set par(leading: 0.5em)
    #set align(left)

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
    #set par(leading: 0.6em)
    #if "reference_number" in data.metadata and data.metadata.reference_number != none [
      *Unser Zeichen:* #data.metadata.reference_number\
    ]
    #if "your_reference" in data.metadata and data.metadata.your_reference != none [
      *Ihr Zeichen:* #data.metadata.your_reference\
    ]
    *Datum:* #format_german_date(data.metadata.date)\
  ]
)

// ============================================================================
// RECIPIENT ADDRESS (DIN 5008 position at y=160)
// ============================================================================

// DIN 5008: Recipient address at y=127.5pt (45mm from top)
// Sender line 20pt above recipient address
#v(77.5pt)

// Sender line (small, above recipient) - DIN 5008
#block(height: 20pt)[
  #set text(size: 8pt, font: "Helvetica")
  #if "business_owner" in company and company.business_owner != none [
    #company.business_owner · #company.address.street #company.address.house_number · #company.address.postal_code #company.address.city
  ] else [
    #company.name · #company.address.street #company.address.house_number · #company.address.postal_code #company.address.city
  ]
]

// Recipient address - DIN 5008
#block(height: 120pt)[
  #set text(size: 12pt, font: "Helvetica")

  #data.recipient.name\
  #if "company" in data.recipient and data.recipient.company != none and data.recipient.company != data.recipient.name [
    #data.recipient.company\
  ]
  #data.recipient.address.street #data.recipient.address.house_number\
  #data.recipient.address.postal_code #data.recipient.address.city
]

// ============================================================================
// SALUTATION AND CONTENT
// ============================================================================

#block[
  #set text(size: 10pt, font: "Helvetica")
  #set par(justify: true, leading: 0.65em)

  #if "subject" in data.metadata and data.metadata.subject != none [
    #text(weight: "bold", size: 11pt)[#data.metadata.subject]
    #v(8pt)
  ]

  #if "salutation" in data and data.salutation != none [
    #data.salutation\
    #v(8pt)
  ]

  // Main content body
  #if "content" in data [
    #data.content
  ]

  #v(12pt)

  // Closing
  #if "closing" in data and data.closing != none [
    #data.closing

    #v(20pt)

    #if "signature_name" in data and data.signature_name != none [
      #data.signature_name
    ] else if "business_owner" in company and company.business_owner != none [
      #company.business_owner
    ] else [
      #company.name
    ]
  ] else [
    Mit freundlichen Grüßen

    #v(20pt)

    #if "business_owner" in company and company.business_owner != none [
      #company.business_owner
    ] else [
      #company.name
    ]
  ]
]

// Attachments section
#if "attachments" in data and data.attachments != none and data.attachments.len() > 0 [
  #v(15pt)
  #text(weight: "bold")[Anlagen:]
  #v(3pt)
  #for attachment in data.attachments [
    - #attachment
  ]
]

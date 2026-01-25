// Reminder Template (Zahlungserinnerung/Mahnung) - CASOON Layout
// Multi-level payment reminder system

// Load data from JSON input
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

  footer: context [
    #set text(size: 7pt, font: "Helvetica")

    #place(
      left + bottom,
      dx: 0pt,
      dy: -10pt,
      block(width: 500pt)[
        #grid(
          columns: (125pt, 125pt, 125pt, 125pt),
          column-gutter: 0pt,
          align: (top, top, top, top),

          [
            #text(weight: "bold")[#company.name]\
            #if "business_owner" in company and company.business_owner != none [
              #company.business_owner\
            ]
            #company.address.street #company.address.house_number\
            #company.address.postal_code #company.address.city
          ],

          [
            #if "phone" in company.contact and company.contact.phone != none [
              Tel.: #company.contact.phone\
            ]
            #if "email" in company.contact and company.contact.email != none [
              Email: #company.contact.email\
            ]
            #if "website" in company.contact and company.contact.website != none [
              Web: #company.contact.website
            ]
          ],

          [
            Geschäftsinhaber:\
            #if "business_owner" in company and company.business_owner != none [
              #company.business_owner\
            ]
            USt-IdNr.:\
            #if "vat_id" in company and company.vat_id != none [
              #company.vat_id
            ]
          ],

          [
            #if "bank_account" in company and company.bank_account != none [
              Bank: #company.bank_account.bank_name\
              Kontoinhaber: #company.bank_account.account_holder\
              IBAN: #company.bank_account.iban\
              BIC/SWIFT-Code: #company.bank_account.bic
            ]
          ],
        )
      ]
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
    *Mahnungs-Nr.:* #data.metadata.reminder_number\
    *Mahnstufe:* #data.metadata.reminder_level\
    *Datum:* #format_german_date(data.metadata.date)\
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

  #data.recipient.name\
  #if "company" in data.recipient and data.recipient.company != none [
    #data.recipient.company\
  ]
  #data.recipient.address.street #data.recipient.address.house_number\
  #data.recipient.address.postal_code #data.recipient.address.city
]

// Title
#block[
  #set text(size: 10pt, font: "Helvetica")

  #text(weight: "bold", size: 12pt)[
    #if data.metadata.reminder_level == "1" [
      Zahlungserinnerung
    ] else [
      #data.metadata.reminder_level. Mahnung
    ]
  ]

  #v(8pt)

  #if "salutation" in data and data.salutation != none [
    #data.salutation\
  ] else [
    Sehr geehrte Damen und Herren,
  ]

  #v(8pt)

  #if "introduction" in data and data.introduction != none [
    #data.introduction
  ] else [
    trotz Fälligkeit haben wir bisher keinen Zahlungseingang feststellen können. Wir bitten Sie höflich, den folgenden offenen Betrag zu begleichen:
  ]

  #v(8pt)
]

// Outstanding invoices table
#block[
  #set text(size: 9pt, font: "Helvetica")

  #table(
    columns: (80pt, 80pt, 80pt, 80pt, 80pt),
    align: (left, left, left, right, right),
    stroke: 0.5pt,
    inset: 8pt,

    [*Rechnung*], [*Datum*], [*Fällig am*], [*Betrag*], [*Offen*],

    ..data.outstanding_invoices.map(inv => (
      [#inv.invoice_number],
      [#format_german_date(inv.invoice_date)],
      [#format_german_date(inv.due_date)],
      [#format_money(inv.amount.amount) EUR],
      [#format_money(inv.outstanding.amount) EUR],
    )).flatten()
  )
]

#v(10pt)

// Total outstanding
#align(right)[
  #set text(size: 11pt, font: "Helvetica")
  
  #grid(
    columns: (120pt, 100pt),
    align: (right, right),
    row-gutter: 8pt,

    [#text(weight: "bold")[Offener Gesamtbetrag:]], 
    [#text(weight: "bold")[#format_money(data.totals.total_outstanding.amount) EUR]],

    ..if "reminder_fee" in data.totals and data.totals.reminder_fee.amount > 0 {
      (
        [Mahngebühr:],
        [#format_money(data.totals.reminder_fee.amount) EUR],
        [#text(weight: "bold")[Zahlbetrag gesamt:]],
        [#text(weight: "bold")[#format_money(data.totals.total_due.amount) EUR]]
      )
    } else { () }
  )
]

#v(10pt)

// Payment instructions
#block[
  #set text(size: 10pt, font: "Helvetica")
  #set par(justify: true)

  #if "payment_deadline" in data.metadata [
    Wir bitten Sie, den offenen Betrag bis zum *#format_german_date(data.metadata.payment_deadline)* auf unser Konto zu überweisen.

    #v(8pt)
  ]

  #if "custom_text" in data and data.custom_text != none [
    #data.custom_text

    #v(8pt)
  ]

  Falls Sie bereits gezahlt haben, betrachten Sie dieses Schreiben bitte als gegenstandslos.

  #v(12pt)

  Mit freundlichen Grüßen

  #v(20pt)

  #if "business_owner" in company and company.business_owner != none [
    #company.business_owner
  ] else [
    #company.name
  ]
]

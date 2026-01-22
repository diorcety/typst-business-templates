// Offer/Quote Template (Angebot)
// German-formatted offer template for professional business use
// Based on casoon-documents structure

#import "../common/styles.typ": *

// Load data from JSON input
#let data = json(sys.inputs.data)

// Load company data
#let company = json("../../data/company.json")

#set page(
  paper: "a4",
  margin: (left: 2.5cm, right: 2cm, top: 2cm, bottom: 2cm),
  footer: [
    #company-footer(company)
  ]
)

#set text(font: font-body, size: size-medium, lang: "de")
#set par(justify: true)

// Header
#align(center)[
  #text(size: size-xlarge, weight: "bold")[#company.name] #linebreak()
  #company.address.street #company.address.house_number #linebreak()
  #company.address.postal_code #company.address.city
]

#v(2cm)

// Recipient
#block[
  #if "company" in data.recipient and data.recipient.company != none [
    #data.recipient.company #linebreak()
  ]
  #data.recipient.name #linebreak()
  #data.recipient.address.street #data.recipient.address.house_number #linebreak()
  #data.recipient.address.postal_code #data.recipient.address.city
]

#v(1.5cm)

// Offer details
#align(right)[
  #grid(
    columns: (auto, auto),
    column-gutter: 1cm,
    row-gutter: 0.5em,
    align: (right, left),
    [*Angebotsnummer:*], [#data.metadata.offer_number],
    [*Angebotsdatum:*], [#data.metadata.offer_date.date],
    [*Gültig bis:*], [#data.metadata.valid_until.date],
    ..if "version" in data.metadata { ([*Version:*], [#data.metadata.version]) } else { () },
    ..if "project_reference" in data.metadata and data.metadata.project_reference != none { 
      ([*Projekt:*], [#data.metadata.project_reference]) 
    } else { () },
  )
]

#v(1cm)

// Title
#text(size: size-xxlarge, weight: "bold", fill: color-primary)[Angebot]

#v(0.5cm)

// Introduction
[Sehr geehrte Damen und Herren,

vielen Dank für Ihr Interesse an unseren Leistungen. Gerne unterbreiten wir Ihnen folgendes Angebot:]

#v(1cm)

// Items table
#table(
  columns: (auto, 1fr, auto, auto, auto),
  align: (center, left, right, right, right),
  stroke: (x, y) => if y == 0 { (bottom: border-normal + color-accent) } else { none },
  inset: 8pt,

  [*Pos.*], [*Beschreibung*], [*Menge*], [*Einzelpreis*], [*Gesamt*],

  ..for item in data.items {
    (
      [#item.position],
      [
        *#item.title*

        #if "description" in item and item.description != none [
          #item.description
        ]

        #if "sub_items" in item and item.sub_items.len() > 0 [
          #for sub in item.sub_items [
            #linebreak() #sub
          ]
        ]
      ],
      [#item.quantity #item.unit],
      [#item.unit_price.amount #item.unit_price.currency],
      [#item.total.amount #item.total.currency],
    )
  }
)

#v(1cm)

// Totals
#align(right)[
  #let has_discount = "discount_total" in data.totals and data.totals.discount_total != none

  #grid(
    columns: (auto, auto),
    column-gutter: 1.5cm,
    row-gutter: 0.4em,
    align: (right, right),

    [Zwischensumme:], [#data.totals.subtotal.amount #data.totals.subtotal.currency],
    ..if has_discount {
      ([Rabatt:], [-#data.totals.discount_total.amount #data.totals.discount_total.currency])
    } else {
      ()
    },
    [], [],
    [*Gesamtbetrag:*], [*#data.totals.total.amount #data.totals.total.currency*],
  )
]

#v(1.5cm)

// Terms
#if "terms" in data and data.terms != none [
  #block(
    fill: color-background,
    inset: 1em,
    radius: 3pt,
    width: 100%,
  )[
    *Konditionen*

    #v(0.5em)

    *Gültigkeit:* #data.terms.validity

    #if "payment_terms" in data.terms and data.terms.payment_terms != none [

      *Zahlungsbedingungen:* #data.terms.payment_terms
    ]

    #if "delivery_terms" in data.terms and data.terms.delivery_terms != none [

      *Lieferbedingungen:* #data.terms.delivery_terms
    ]
  ]
]

#v(1cm)

// Notes
#if "notes" in data and data.notes != none [
  #data.notes

  #v(1cm)
]

// Closing
[
Wir freuen uns auf Ihre Rückmeldung und stehen für Rückfragen gerne zur Verfügung.

#v(1cm)

Mit freundlichen Grüßen

#v(1.5cm)

#company.name
]

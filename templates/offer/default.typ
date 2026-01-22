// Offer/Quote Template (Angebot)
// Professional offer template for business use
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

#set text(font: font-body, size: size-medium, lang: lang)
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
    [*#t("offer", "offer_number"):*], [#data.metadata.offer_number],
    [*#t("offer", "offer_date"):*], [#data.metadata.offer_date.date],
    [*#t("offer", "valid_until"):*], [#data.metadata.valid_until.date],
    ..if "version" in data.metadata { ([*#t("common", "version"):*], [#data.metadata.version]) } else { () },
    ..if "project_reference" in data.metadata and data.metadata.project_reference != none { 
      ([*#t("common", "project"):*], [#data.metadata.project_reference]) 
    } else { () },
  )
]

#v(1cm)

// Title
#text(size: size-xxlarge, weight: "bold", fill: color-primary)[#t("offer", "title")]

#v(0.5cm)

// Introduction
[#t("offer", "greeting")

#t("offer", "intro")]

#v(1cm)

// Items table
#table(
  columns: (auto, 1fr, auto, auto, auto),
  align: (center, left, right, right, right),
  stroke: (x, y) => if y == 0 { (bottom: border-normal + color-accent) } else { none },
  inset: 8pt,

  [*#t("offer", "position")*], [*#t("offer", "description")*], [*#t("offer", "quantity")*], [*#t("offer", "unit_price")*], [*#t("offer", "total")*],

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

    [#t("offer", "subtotal"):], [#data.totals.subtotal.amount #data.totals.subtotal.currency],
    ..if has_discount {
      ([Rabatt:], [-#data.totals.discount_total.amount #data.totals.discount_total.currency])
    } else {
      ()
    },
    [], [],
    [*#t("offer", "grand_total"):*], [*#data.totals.total.amount #data.totals.total.currency*],
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
    *#t("offer", "conditions")*

    #v(0.5em)

    *#t("offer", "validity"):* #data.terms.validity

    #if "payment_terms" in data.terms and data.terms.payment_terms != none [

      *#t("offer", "payment_terms"):* #data.terms.payment_terms
    ]

    #if "delivery_terms" in data.terms and data.terms.delivery_terms != none [

      *#t("offer", "delivery_terms"):* #data.terms.delivery_terms
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
#t("offer", "closing")

#v(1cm)

#t("offer", "regards")

#v(1.5cm)

#company.name
]

// Accounts/Credentials Document Template (Zugangsdaten)
// Based on casoon-documents structure

#import "../common/styles.typ": *

// Load data from JSON input
#let data = json(sys.inputs.data)

// Load company data
#let company = json("../../data/company.json")

// Localization
#let lang = if "language" in company { company.language } else { "de" }
#let locale = json("../../locale/" + lang + ".json")

#set page(
  paper: "a4",
  margin: (left: 2.5cm, right: 2cm, top: 2.5cm, bottom: 2.5cm),
  header: context {
    if counter(page).get().first() > 1 [
      #set text(size: size-small)
      #grid(
        columns: (1fr, 1fr),
        align: (left, right),
        [#text(fill: color-accent, weight: "bold")[#upper(locale.credentials.confidential)]],
        [#data.metadata.document_number]
      )
      #v(0.2em)
      #line(length: 100%, stroke: border-thin + color-accent)
    ]
  },
  footer: context {
    if counter(page).get().first() > 1 [
      #line(length: 100%, stroke: border-thin)
      #v(0.2em)
      #set text(size: size-small)
      #grid(
        columns: (1fr, auto, 1fr),
        align: (left, center, right),
        [#data.metadata.client_name],
        [#locale.common.page #counter(page).display()],
        [#data.metadata.created_at.date]
      )
    ]
  }
)

#set text(font: font-body, size: size-medium, lang: "de")
#set par(justify: true, leading: 0.65em)

// Heading styles
#show heading.where(level: 1): it => {
  v(25pt)
  block(sticky: true, width: 100%)[
    #text(size: size-xxlarge, weight: "bold", fill: color-accent)[#it.body]
  ]
  v(12pt)
}

#show heading.where(level: 2): it => {
  v(18pt)
  block(sticky: true, width: 100%)[
    #text(size: size-xlarge, weight: "bold")[#it.body]
  ]
  v(8pt)
}

// ============================================================================
// TITLE PAGE
// ============================================================================

#v(50pt)

// Logo placeholder
#align(center)[
  #if "logo" in company and company.logo != none [
    #let logo-width = if "logo_width" in company { eval(company.logo_width) } else { 150pt }
    #image("../../" + company.logo, width: logo-width)
  ] else [
    #box(
      stroke: 1pt + color-border,
      inset: 1em,
      radius: 4pt,
    )[
      #text(size: size-xlarge, fill: color-text-light)[LOGO]
    ]
  ]
]

#v(30pt)

// Document title
#align(center)[
  #text(size: size-title, weight: "bold")[#data.metadata.title]
]

#v(20pt)

// Document type and number
#align(center)[
  #text(size: size-xlarge, fill: color-accent, weight: "bold")[#upper(locale.credentials.title)]
  #text(size: size-xlarge, fill: color-text-light)[
    · #data.metadata.document_number
  ]
]

#v(30pt)

// Metadata
#align(center)[
  #grid(
    columns: (auto, auto),
    row-gutter: 14pt,
    column-gutter: 20pt,
    align: (right, left),
    [*#locale.common.project:*], [#data.metadata.project_name],
    [*#locale.common.client:*], [#data.metadata.client_name],
    [*#locale.common.date:*], [#data.metadata.created_at.date],
  )
]

#v(1fr)

// Security warning
#align(center)[
  #box(
    stroke: 1.5pt + color-accent,
    radius: 6pt,
    inset: 1em,
    width: 70%,
  )[
    #align(center)[
      #text(size: size-medium, fill: color-accent, weight: "bold")[
        #upper(locale.credentials.confidential)
      ]
      #v(0.3em)
      #text(size: size-small)[
        #locale.credentials.confidential_notice
      ]
    ]
  ]
]

#v(30pt)

// Tags as outlined pills
#if "tags" in data.metadata and data.metadata.tags.len() > 0 [
  #align(center)[
    #for tag in data.metadata.tags [
      #pill(tag)
      #h(8pt)
    ]
  ]
  #v(30pt)
]

// Email
#align(center)[
  #set text(size: size-small, fill: color-text-light)
  #company.contact.email
]

#v(40pt)

#pagebreak()

// ============================================================================
// CONTENT
// ============================================================================

// Services and credentials
#for (index, service) in data.services.enumerate() [
  #if index > 0 [
    #v(2em)
    #line(length: 100%, stroke: border-thin + color-border)
  ]

  = #service.name

  #if "description" in service and service.description != none [
    #service.description
    #v(0.5em)
  ]

  #if "url" in service and service.url != none [
    *URL:* #link(service.url)[#service.url]
    #v(0.5em)
  ]

  // Technical settings
  #if "technical" in service and service.technical.len() > 0 [
    == #locale.credentials.technical_settings

    #block(
      fill: color-background,
      inset: 1em,
      radius: 4pt,
      width: 100%,
    )[
      #table(
        columns: (auto, 1fr),
        stroke: none,
        inset: 0.4em,
        ..service.technical.map(setting => (
          [*#setting.key:*],
          [#raw(str(setting.value))]
        )).flatten()
      )
    ]
    #v(0.5em)
  ]

  // Ports
  #if "ports" in service and service.ports.len() > 0 [
    == #locale.credentials.ports_protocols

    #table(
      columns: (auto, auto, auto),
      inset: 0.6em,
      stroke: border-thin + color-border,
      fill: (x, y) => if y == 0 { color-background } else { none },
      [*#locale.credentials.port*], [*#locale.credentials.protocol*], [*#locale.credentials.description*],
      ..service.ports.map(port => (
        [#port.port],
        [#port.protocol],
        [#if "description" in port [#port.description] else [-]]
      )).flatten()
    )
    #v(0.5em)
  ]

  // Credentials
  #if "credentials" in service and service.credentials.len() > 0 [
    == #locale.credentials.title

    #for cred in service.credentials [
      #block(
        stroke: border-normal + color-border,
        inset: 1em,
        radius: 4pt,
        width: 100%,
      )[
        #if "description" in cred and cred.description != none [
          #text(weight: "bold", size: size-medium)[#cred.description]
          #v(0.5em)
        ]

        #table(
          columns: (auto, 1fr),
          stroke: none,
          inset: 0.3em,

          [*#locale.credentials.username:*], [#raw(cred.username)],
          [*#locale.credentials.password:*], [#raw(cred.password)],

          ..if "credential_type" in cred and cred.credential_type != none {
            ([*#locale.credentials.type:*], [#cred.credential_type])
          } else {
            ()
          },
        )
      ]
      #v(0.8em)
    ]
  ]

  // Notes
  #if "notes" in service and service.notes != none [
    == #locale.credentials.notes
    #service.notes
  ]
]

// ============================================================================
// SECURITY NOTICE
// ============================================================================

#v(2em)
#line(length: 100%, stroke: border-thin + color-border)
#v(1em)

#align(center)[
  #box(
    stroke: border-normal + color-accent,
    radius: 6pt,
    inset: 1.2em,
    width: 90%,
  )[
    #text(size: size-normal, weight: "bold", fill: color-accent)[#locale.credentials.security_notices]
    #v(0.5em)
    #set text(size: size-small)
    #align(left)[
      - #locale.credentials.security_hint_1
      - #locale.credentials.security_hint_2
      - #locale.credentials.security_hint_3
      - #locale.credentials.security_hint_4
      - #locale.credentials.security_hint_5
    ]
  ]
]

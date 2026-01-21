// Credentials Document Template (Zugangsdaten)
// Secure credentials documentation for clients

#import "../common/styles.typ": *

// Load data from JSON input
#let data = json(sys.inputs.data)

// Load company data
#let company = json(read("../../data/company.json", encoding: none))

#set page(
  paper: "a4",
  margin: (left: 2.5cm, right: 2cm, top: 2.5cm, bottom: 2.5cm),
  header: context {
    if counter(page).get().first() > 1 [
      #set text(size: size-small)
      #grid(
        columns: (1fr, 1fr),
        align: (left, right),
        [#text(fill: color-accent, weight: "bold")[VERTRAULICH]],
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
        [Seite #counter(page).display()],
        [#data.metadata.created_at]
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
    #text(size: size-large, weight: "bold")[#it.body]
  ]
  v(8pt)
}

// TITLE PAGE
#v(50pt)

// Logo placeholder (replace with your logo)
#align(center)[
  #box(
    stroke: 1pt + color-border,
    inset: 1em,
    radius: 4pt,
  )[
    #text(size: size-xlarge, fill: color-text-light)[LOGO]
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
  #text(size: size-xlarge, fill: color-accent, weight: "bold")[ZUGANGSDATEN]
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
    [*Projekt:*], [#data.metadata.project_name],
    [*Kunde:*], [#data.metadata.client_name],
    [*Datum:*], [#data.metadata.created_at],
  )
]

#v(1fr)

// Security warning
#align(center)[
  #warning-box(accent: color-accent)[
    #align(center)[
      #text(size: size-medium, fill: color-accent, weight: "bold")[VERTRAULICH]
      #v(0.3em)
      #text(size: size-small)[
        Dieses Dokument enthält vertrauliche Zugangsdaten.\
        Bitte sicher aufbewahren und nicht an Dritte weitergeben.
      ]
    ]
  ]
]

#v(30pt)

// Tags
#if "tags" in data.metadata and data.metadata.tags.len() > 0 [
  #align(center)[
    #for tag in data.metadata.tags [
      #pill(tag)
      #h(8pt)
    ]
  ]
  #v(30pt)
]

// Contact
#align(center)[
  #set text(size: size-small, fill: color-text-light)
  #company.contact.email
]

#v(40pt)

#pagebreak()

// CONTENT: Services and credentials
#for (index, service) in data.services.enumerate() [
  #if index > 0 [
    #v(2em)
    #line(length: 100%, stroke: border-thin + color-border)
  ]

  = #service.name

  #if "provider" in service and service.provider != none [
    *Anbieter:* #service.provider
    #v(0.5em)
  ]

  #if "description" in service and service.description != none [
    #service.description
    #v(0.5em)
  ]

  // Technical settings
  #if "technical" in service and service.technical.len() > 0 [
    == Technische Einstellungen

    #info-box[
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
    == Ports & Protokolle

    #table(
      columns: (auto, auto, auto),
      inset: 0.6em,
      stroke: border-thin + color-border,
      fill: (x, y) => if y == 0 { color-background } else { none },
      [*Protokoll*], [*Port*], [*SSL-Port*],
      ..service.ports.map(port => (
        [#port.protocol],
        [#port.port],
        [#if "ssl_port" in port and port.ssl_port != none [#port.ssl_port] else [-]]
      )).flatten()
    )
    #v(0.5em)
  ]

  // Credentials
  #if "credentials" in service and service.credentials.len() > 0 [
    == Zugangsdaten

    #for cred in service.credentials [
      #block(
        stroke: border-normal + color-border,
        inset: 1em,
        radius: 4pt,
        width: 100%,
      )[
        #if "name" in cred and cred.name != none [
          #text(weight: "bold", size: size-medium)[#cred.name]
          #v(0.5em)
        ]

        #table(
          columns: (auto, 1fr),
          stroke: none,
          inset: 0.3em,
          [*Benutzername:*], [#raw(cred.username)],
          [*Passwort:*], [#raw(cred.password)],
          ..if "email" in cred and cred.email != none { ([*E-Mail:*], [#cred.email]) } else { () },
          ..if "role" in cred and cred.role != none { ([*Rolle:*], [#cred.role]) } else { () },
        )

        #if "two_factor" in cred and cred.two_factor != none [
          #v(0.3em)
          #box(fill: color-warning, inset: 0.5em, radius: 3pt)[
            *2FA:* #cred.two_factor.method
            #if "secret" in cred.two_factor and cred.two_factor.secret != none [
              #h(1em) Secret: #raw(cred.two_factor.secret)
            ]
          ]
        ]

        #if "notes" in cred and cred.notes != none [
          #v(0.5em)
          #text(size: size-small, style: "italic", fill: color-text-light)[#cred.notes]
        ]
      ]
      #v(0.8em)
    ]
  ]

  // Service notes
  #if "notes" in service and service.notes != none [
    == Hinweise
    #service.notes
  ]
]

// SECURITY NOTICE
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
    #text(size: size-normal, weight: "bold", fill: color-accent)[Sicherheitshinweise]
    #v(0.5em)
    #set text(size: size-small)
    #align(left)[
      - Bewahren Sie dieses Dokument sicher auf
      - Geben Sie Zugangsdaten nicht an Dritte weiter
      - Ändern Sie Passwörter regelmäßig
      - Verwenden Sie 2-Faktor-Authentifizierung wo möglich
      - Melden Sie verdächtige Aktivitäten sofort
    ]
  ]
]

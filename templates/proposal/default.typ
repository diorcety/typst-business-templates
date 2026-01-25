// Proposal Template (Projektvorschlag) - Document Layout
// Creative project proposals and pitch documents
// Based on concept structure with enhanced visual elements

#import "../common/styles.typ": *
#import "../common/footers.typ": document-footer

// Document function
#let proposal(
  title: none,
  document_number: none,
  client_name: none,
  project_name: none,
  budget: none,
  timeline: none,
  version: "1.0",
  status: "Angebot",
  tags: (),
  created_at: none,
  valid_until: none,
  authors: (),
  show_toc: true,
  company: none,
  locale: none,
  logo: none,
  body
) = {
  let company = if company != none { company } else { (:) }
  let locale = if locale != none { locale } else { (common: (:), proposal: (:)) }
  
  let accent-color = get-accent-color(company)
  let primary-color = get-primary-color(company)
  let fonts = get-font-preset(company)

  set page(
    paper: "a4",
    margin: (left: 50pt, right: 45pt, top: 50pt, bottom: 80pt),

    header: context [
      #if counter(page).get().first() > 1 [
        #set text(size: size-small)
        #grid(
          columns: (1fr, auto, 1fr),
          align: (left, center, right),
          [#document_number],
          [#title],
          [#if valid_until != none [Gültig bis: #valid_until]]
        )
        #v(5pt)
        #line(length: 100%, stroke: border-thin)
      ]
    ],

    footer: document-footer(
      company: company,
      locale: locale,
      document_number: document_number,
      created_at: created_at,
      status: status,
    )
      )
    ]
  )

  set text(font: fonts.body, size: size-medium, lang: "de")
  set par(justify: true, leading: 0.65em)
  set heading(numbering: "1.1")

  show heading.where(level: 1): it => {
    v(25pt)
    text(size: size-xxlarge, weight: "bold", fill: accent-color)[#it]
    v(12pt)
  }

  show heading.where(level: 2): it => {
    v(18pt)
    text(size: size-xlarge, weight: "bold")[#it]
    v(8pt)
  }

  show heading.where(level: 3): it => {
    v(12pt)
    text(size: size-large, weight: "bold")[#it]
    v(6pt)
  }

  // Links
  show link: it => text(fill: rgb("#0066cc"), it)

  // Tables
  set table(
    stroke: border-thin + color-border,
    fill: (x, y) => if y == 0 { color-background }
  )

  // ============================================================================
  // TITLE PAGE
  // ============================================================================

  page(
    margin: (left: 50pt, right: 45pt, top: 50pt, bottom: 50pt),
    header: none,
    footer: none,
  )[
    #align(center)[
      #v(50pt)

      // Logo
      #if logo != none [
        #logo
        #v(30pt)
      ] else if "_logo_image" in company [
        #company._logo_image
        #v(30pt)
      ]

      // Title
      #text(size: 28pt, weight: "bold")[#title]

      #v(20pt)

      // Proposal type
      #text(size: size-xlarge, fill: accent-color, weight: "bold")[PROJEKTVORSCHLAG]
      #text(size: size-xlarge, fill: color-text-light)[ · #document_number]

      #v(40pt)

      // Key information box
      #box(
        width: 85%,
        stroke: border-normal + accent-color,
        radius: 6pt,
        inset: 1.5em,
        fill: color-background,
      )[
        #align(left)[
          #grid(
            columns: (auto, auto),
            column-gutter: 30pt,
            row-gutter: 14pt,
            align: (right, left),

            [*Projekt:*], [#text(size: size-large, weight: "bold")[#project_name]],
            [*Auftraggeber:*], [#client_name],
            ..if budget != none {
              ([*Budget:*], [#text(fill: accent-color, weight: "bold")[#budget]])
            } else { () },
            ..if timeline != none {
              ([*Zeitrahmen:*], [#timeline])
            } else { () },
            [*Version:*], [#version],
            [*Status:*], [#text(fill: accent-color, weight: "bold")[#upper(status)]],
            ..if created_at != none {
              ([*Datum:*], [#created_at])
            } else { () },
            ..if valid_until != none {
              ([*Gültig bis:*], [#valid_until])
            } else { () },
          )
        ]
      ]

      #v(1fr)

      // Tags
      #if tags.len() > 0 [
        #for tag in tags [
          #pill(tag)
          #h(8pt)
        ]
        #v(30pt)
      ]

      // Authors
      #if authors.len() > 0 [
        #text(size: size-small, fill: color-text-light)[
          Erstellt von: #authors.join(", ")
        ]
        #v(30pt)
      ]
    ]
  ]

  // ============================================================================
  // TABLE OF CONTENTS
  // ============================================================================

  if show_toc {
    [
      #outline(
        title: [
          #set text(size: size-xxlarge, weight: "bold")
          Inhalt
        ],
        indent: 1em,
        depth: 3,
      )

      #pagebreak()
    ]
  }

  // ============================================================================
  // MAIN CONTENT
  // ============================================================================

  body

  // ============================================================================
  // NEXT STEPS / CALL TO ACTION
  // ============================================================================

  pagebreak()

  v(50pt)

  align(center)[
    #text(size: size-xxlarge, weight: "bold", fill: accent-color)[
      Nächste Schritte
    ]

    #v(30pt)

    #box(
      width: 80%,
      stroke: border-normal + accent-color,
      radius: 6pt,
      inset: 1.5em,
    )[
      #align(left)[
        #set text(size: size-normal)
        
        Wir freuen uns darauf, dieses Projekt mit Ihnen umzusetzen.

        #v(15pt)

        *Kontakt:*\
        #if "contact" in company [
          #if "email" in company.contact [
            Email: #link("mailto:" + company.contact.email)[#company.contact.email]\
          ]
          #if "phone" in company.contact [
            Telefon: #company.contact.phone
          ]
        ]

        #v(15pt)

        #if valid_until != none [
          *Gültigkeit:* Dieses Angebot ist gültig bis #valid_until
        ]
      ]
    ]
  ]

  v(1fr)
}

// JSON workflow
#let data = if "data" in sys.inputs {
  json(sys.inputs.data)
} else {
  none
}

#let _company = if data != none and "company" in sys.inputs {
  let c = json(sys.inputs.company)
  if "logo" in c and c.logo != none {
    let logo-width = if "logo_width" in c { eval(c.logo_width) } else { 150pt }
    c.insert("_logo_image", image("/" + c.logo, width: logo-width))
  }
  c
} else {
  none
}

#let _locale = if data != none and "locale" in sys.inputs {
  json(sys.inputs.locale)
} else {
  none
}

#if data != none {
  let created-date = if "created_at" in data.metadata {
    if type(data.metadata.created_at) == dictionary and "date" in data.metadata.created_at {
      data.metadata.created_at.date
    } else {
      data.metadata.created_at
    }
  } else {
    none
  }

  let valid-until-date = if "valid_until" in data.metadata {
    if type(data.metadata.valid_until) == dictionary and "date" in data.metadata.valid_until {
      data.metadata.valid_until.date
    } else {
      data.metadata.valid_until
    }
  } else {
    none
  }
  
  let content-body = if "content_file" in data {
    include(data.content_file)
  } else if "content" in data {
    eval(data.content, mode: "markup")
  } else {
    []
  }
  
  proposal(
    title: data.metadata.title,
    document_number: data.metadata.document_number,
    client_name: if "client_name" in data.metadata { data.metadata.client_name } else { none },
    project_name: if "project_name" in data.metadata { data.metadata.project_name } else { none },
    budget: if "budget" in data.metadata { data.metadata.budget } else { none },
    timeline: if "timeline" in data.metadata { data.metadata.timeline } else { none },
    version: if "version" in data.metadata { data.metadata.version } else { "1.0" },
    status: if "status" in data.metadata { data.metadata.status } else { "Angebot" },
    tags: if "tags" in data.metadata { data.metadata.tags } else { () },
    created_at: created-date,
    valid_until: valid-until-date,
    authors: if "authors" in data.metadata { data.metadata.authors } else { () },
    show_toc: if "show_toc" in data.metadata { data.metadata.show_toc } else { true },
    company: _company,
    locale: _locale,
    content-body
  )
}

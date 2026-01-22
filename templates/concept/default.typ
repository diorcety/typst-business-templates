// Concept/Design Document Template (Konzept)
// Based on casoon-documents structure
// Supports both JSON input and direct .typ content files

#import "../common/styles.typ": *

// Load company data
#let company = json("../../data/company.json")

// Document function for flexible use
#let concept(
  title: none,
  document_number: none,
  client_name: none,
  project_name: none,
  version: "1.0",
  status: "Entwurf",
  tags: (),
  created_at: none,
  authors: (),
  show_toc: true,
  body
) = {

  set page(
    paper: "a4",
    margin: (left: 50pt, right: 45pt, top: 50pt, bottom: 100pt),

    header: context [
      #if counter(page).get().first() > 1 [
        #set text(size: size-small)
        #grid(
          columns: (1fr, auto, 1fr),
          align: (left, center, right),
          [#document_number],
          [#title],
          [Version #version]
        )
        #v(5pt)
        #line(length: 100%, stroke: border-thin)
      ]
    ],

    footer: context [
      #line(length: 100%, stroke: border-thin)
      #v(5pt)
      #set text(size: size-xs)
      #grid(
        columns: (125pt, 125pt, 125pt, 125pt),
        column-gutter: 0pt,

        // Column 1: Company Info
        [
          #strong[#company.name] #linebreak()
          #company.address.street #company.address.house_number #linebreak()
          #company.address.postal_code #company.address.city
        ],

        // Column 2: Contact
        [
          Tel.: #company.contact.phone #linebreak()
          Email: #company.contact.email #linebreak()
          #if "website" in company.contact [Web: #company.contact.website]
        ],

        // Column 3: Document Info
        [
          #strong[Dokument:] #linebreak()
          #document_number #linebreak()
          Seite #counter(page).display()
        ],

        // Column 4: Date
        [
          #strong[Erstellt:] #linebreak()
          #if created_at != none [#created_at] #linebreak()
          Status: #status
        ],
      )
    ]
  )

  set text(font: font-body, size: size-medium, lang: "de")
  set par(justify: true, leading: 0.65em)
  set heading(numbering: "1.1")

  // Heading styles
  show heading.where(level: 1): it => {
    v(20pt)
    text(size: size-xxlarge, weight: "bold", fill: color-accent)[#it]
    v(10pt)
  }

  show heading.where(level: 2): it => {
    v(15pt)
    text(size: size-xlarge, weight: "bold")[#it]
    v(8pt)
  }

  show heading.where(level: 3): it => {
    v(10pt)
    text(size: size-large, weight: "bold")[#it]
    v(5pt)
  }

  // ============================================================================
  // TITLE PAGE
  // ============================================================================

  page(
    margin: (left: 50pt, right: 45pt, top: 50pt, bottom: 50pt),
    header: none,
    footer: none,
  )[
    // Logo (right side, top)
    #place(
      right + top,
      dx: 0pt,
      dy: 0pt,
    )[
      #if "logo" in company and company.logo != none [
        #let logo-width = if "logo_width" in company { eval(company.logo_width) } else { 150pt }
        #image("../../" + company.logo, width: logo-width)
      ]
    ]

    #v(120pt)

    // Document type
    #align(left)[
      #set text(size: size-xlarge, fill: color-text-light)
      KONZEPT
    ]

    #v(10pt)

    // Title
    #align(left)[
      #set text(size: size-title, weight: "bold")
      #title
    ]

    #v(30pt)

    // Project and Client
    #align(left)[
      #set text(size: size-large)
      #set par(leading: 0.8em)

      #strong[Projekt:] #project_name #linebreak()
      #strong[Kunde:] #client_name
    ]

    #v(60pt)

    // Metadata table
    #align(left)[
      #set text(size: size-medium)
      #table(
        columns: (110pt, 1fr),
        stroke: none,
        inset: (x: 0pt, y: 6pt),
        align: (left, left),

        [Dokumentnummer:], [#document_number],
        [Version:], [#version],
        [Datum:], [#if created_at != none [#created_at]],
        [Status:], [#status],

        ..if authors.len() > 0 {
          ([Erstellt von:], [#authors.join(", ")])
        } else {
          ()
        },
      )
    ]

    #v(1fr)

    // Tags
    #if tags.len() > 0 [
      #for tag in tags [
        #pill(tag)
        #h(8pt)
      ]
      #v(20pt)
    ]

    // Company footer
    #align(center)[
      #set text(size: size-small, fill: color-text-light)
      #company.name #if "business_owner" in company and company.business_owner != none [ · #company.business_owner] · #company.address.street #company.address.house_number · #company.address.postal_code #company.address.city #linebreak()
      Tel.: #company.contact.phone · Email: #company.contact.email #if "website" in company.contact [ · Web: #company.contact.website]
    ]
  ]

  // ============================================================================
  // TABLE OF CONTENTS
  // ============================================================================

  if show_toc [
    #outline(
      title: [
        #set text(size: size-xxlarge, weight: "bold")
        Inhaltsverzeichnis
      ],
      indent: 1em,
      depth: 3,
    )

    #pagebreak()
  ]

  // ============================================================================
  // MAIN CONTENT
  // ============================================================================

  body
}

// For JSON-based usage
#let data = if "data" in sys.inputs {
  json(sys.inputs.data)
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
  
  let content-body = if "content_file" in data {
    include(data.content_file)
  } else if "content" in data {
    eval(data.content, mode: "markup")
  } else {
    []
  }
  
  concept(
    title: data.metadata.title,
    document_number: data.metadata.document_number,
    client_name: data.metadata.client_name,
    project_name: data.metadata.project_name,
    version: if "version" in data.metadata { data.metadata.version } else { "1.0" },
    status: if "status" in data.metadata { data.metadata.status } else { "Entwurf" },
    tags: if "tags" in data.metadata { data.metadata.tags } else { () },
    created_at: created-date,
    authors: if "authors" in data.metadata { data.metadata.authors } else { () },
    show_toc: if "show_toc" in data.metadata { data.metadata.show_toc } else { true },
    content-body
  )
}

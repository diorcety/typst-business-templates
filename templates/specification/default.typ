// Specification Template (Spezifikation/Pflichtenheft) - Document Layout
// Technical and functional requirements documentation
// Based on documentation structure with enhanced code support

#import "../common/styles.typ": *

// Document function
#let specification(
  title: none,
  document_number: none,
  subject: none,
  client_name: none,
  project_name: none,
  version: "1.0",
  status: "Entwurf",
  tags: (),
  authors: (),
  created_at: none,
  last_updated: none,
  show_toc: true,
  company: none,
  locale: none,
  logo: none,
  body
) = {
  let company = if company != none { company } else { (:) }
  let locale = if locale != none { locale } else { (common: (:), specification: (:)) }
  
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
          [#if subject != none [#subject] else [#title]],
          [Version #version]
        )
        #v(5pt)
        #line(length: 100%, stroke: border-thin)
      ]
    ],

    footer: context [
      #let l-document = if "common" in locale and "document" in locale.common { locale.common.document } else { "Document" }
      #let l-page = if "common" in locale and "page" in locale.common { locale.common.page } else { "Page" }
      #let l-status = if "common" in locale and "status" in locale.common { locale.common.status } else { "Status" }
      
      #line(length: 100%, stroke: border-thin)
      #v(5pt)
      #set text(size: size-xs)
      #grid(
        columns: (125pt, 125pt, 125pt, 125pt),
        column-gutter: 0pt,

        [
          #if "name" in company [#strong[#company.name] #linebreak()]
          #if "address" in company [
            #if "street" in company.address [#company.address.street ]
            #if "house_number" in company.address [#company.address.house_number]
            #linebreak()
            #if "postal_code" in company.address [#company.address.postal_code ]
            #if "city" in company.address [#company.address.city]
          ]
        ],

        [
          #if "contact" in company [
            #if "phone" in company.contact [Tel.: #company.contact.phone #linebreak()]
            #if "email" in company.contact [Email: #company.contact.email #linebreak()]
            #if "website" in company.contact [Web: #company.contact.website]
          ]
        ],

        [
          #strong[#l-document:] #linebreak()
          #document_number #linebreak()
          #l-page #counter(page).display()
        ],

        [
          #strong[Version:] #version #linebreak()
          #l-status: #status #linebreak()
          #if last_updated != none [Aktualisiert: #last_updated]
        ],
      )
    ]
  )

  set text(font: fonts.body, size: size-medium, lang: "de")
  set par(justify: true, leading: 0.65em)
  set heading(numbering: "1.1")

  // Enhanced code block styling
  show raw.where(block: true): it => {
    set text(size: size-small, font: fonts.mono)
    block(
      fill: color-background,
      inset: 1em,
      radius: 3pt,
      width: 100%,
      stroke: border-thin + color-border,
      it
    )
  }

  // Inline code styling
  show raw.where(block: false): it => {
    box(
      fill: color-background,
      inset: (x: 3pt, y: 0pt),
      radius: 2pt,
      text(size: size-small, font: fonts.mono, it)
    )
  }

  // Heading styles
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

  // Requirements boxes (can be used via custom markup)
  // Example: #requirement[REQ-001][High][User login must support OAuth2]
  let requirement(id, priority, content) = {
    block(
      fill: if priority == "High" { rgb("#fff3cd") } else if priority == "Medium" { rgb("#d1ecf1") } else { rgb("#f8f9fa") },
      stroke: border-normal + if priority == "High" { rgb("#ffc107") } else if priority == "Medium" { rgb("#17a2b8") } else { color-border },
      radius: 4pt,
      inset: 1em,
      width: 100%,
    )[
      #grid(
        columns: (80pt, 60pt, 1fr),
        align: (left, left, left),
        column-gutter: 10pt,
        [#text(weight: "bold", font: fonts.mono)[#id]],
        [#text(weight: "bold", fill: if priority == "High" { rgb("#856404") } else if priority == "Medium" { rgb("#0c5460") } else { color-text })[#priority]],
        [#content]
      )
    ]
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
      #text(size: 24pt, weight: "bold")[#title]

      #v(20pt)

      // Document type
      #text(size: size-xlarge, fill: accent-color, weight: "bold")[SPEZIFIKATION]
      #text(size: size-xlarge, fill: color-text-light)[ · #document_number]

      #v(30pt)

      // Metadata grid
      #grid(
        columns: (auto, auto),
        column-gutter: 20pt,
        row-gutter: 14pt,
        align: (right, left),

        ..if project_name != none {
          ([*Projekt:*], [#project_name])
        } else { () },
        ..if client_name != none {
          ([*Auftraggeber:*], [#client_name])
        } else { () },
        [*Version:*], [#version],
        [*Status:*], [#text(fill: accent-color, weight: "bold")[#upper(status)]],
        ..if created_at != none {
          ([*Erstellt:*], [#created_at])
        } else { () },
        ..if last_updated != none {
          ([*Aktualisiert:*], [#last_updated])
        } else { () },
        ..if authors.len() > 0 {
          ([*Autoren:*], [#authors.join(", ")])
        } else { () },
      )

      #v(1fr)

      // Tags
      #if tags.len() > 0 [
        #for tag in tags [
          #pill(tag)
          #h(8pt)
        ]
        #v(40pt)
      ]
    ]
  ]

  // ============================================================================
  // REVISION HISTORY (optional)
  // ============================================================================

  // Can be added via content

  // ============================================================================
  // TABLE OF CONTENTS
  // ============================================================================

  if show_toc {
    [
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
  }

  // ============================================================================
  // MAIN CONTENT
  // ============================================================================

  body
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

  let updated-date = if "last_updated" in data.metadata {
    if type(data.metadata.last_updated) == dictionary and "date" in data.metadata.last_updated {
      data.metadata.last_updated.date
    } else {
      data.metadata.last_updated
    }
  } else {
    none
  }
  
  let content-body = if "content_file" in data {
    include(data.content_file)
  } else if "content" in data and "markdown" in data.content {
    eval(data.content.markdown, mode: "markup")
  } else {
    []
  }
  
  specification(
    title: data.metadata.title,
    document_number: data.metadata.document_number,
    subject: if "subject" in data.metadata { data.metadata.subject } else { none },
    client_name: if "client_name" in data.metadata { data.metadata.client_name } else { none },
    project_name: if "project_name" in data.metadata { data.metadata.project_name } else { none },
    version: if "version" in data.metadata { data.metadata.version } else { "1.0" },
    status: if "status" in data.metadata { data.metadata.status } else { "Entwurf" },
    tags: if "tags" in data.metadata { data.metadata.tags } else { () },
    created_at: created-date,
    last_updated: updated-date,
    authors: if "authors" in data.metadata { data.metadata.authors } else { () },
    show_toc: if "show_toc" in data.metadata { data.metadata.show_toc } else { true },
    company: _company,
    locale: _locale,
    content-body
  )
}

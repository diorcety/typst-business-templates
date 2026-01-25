// Concept/Design Document Template (Konzept)
// Based on casoon-documents structure
// Supports both JSON input and direct .typ content files
//
// USAGE (Package Import):
//   #import "@local/docgen-concept:0.4.2": concept
//   #let company = json("/data/company.json")
//   #let locale = json("/locale/de.json")
//   #show: concept.with(
//     title: "My Concept",
//     company: company,
//     locale: locale,
//     logo: image("/data/logo.png"),  // Logo as image, not path
//   )

#import "../common/styles.typ": *

// Load data from JSON input (only if available for JSON workflow)
#let data = if "data" in sys.inputs {
  json(sys.inputs.data)
} else {
  none
}

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
  company: none,
  locale: none,
  logo: none,
  body
) = {
  // Use passed company/locale or empty defaults
  let company = if company != none { 
    // Pre-load logo image if logo path is specified (for package-import mode)
    if "logo" in company and company.logo != none and "_logo_image" not in company {
      let logo-width = if "logo_width" in company { eval(company.logo_width) } else { 150pt }
      company.insert("_logo_image", image("/" + company.logo, width: logo-width))
    }
    company
  } else { 
    (:) 
  }
  let locale = if locale != none { locale } else { (common: (:), concept: (:)) }
  
  // Get branding from company data
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
          [Version #version]
        )
        #v(5pt)
        #line(length: 100%, stroke: border-thin)
      ]
    ],

    footer: context {
      if counter(page).get().first() > 1 [
        #line(length: 100%, stroke: border-thin)
        #v(0.2em)
        #set text(size: size-small)
        #let l-page = if "common" in locale and "page" in locale.common { locale.common.page } else { "Page" }
        #grid(
          columns: (1fr, auto, 1fr),
          align: (left, center, right),
          [#client_name],
          [#l-page #counter(page).display()],
          [#created_at]
        )
      ]
    }
  )

  set text(font: fonts.body, size: size-medium, lang: "de")
  set par(justify: true, leading: 0.65em)
  set heading(numbering: "1.1")

  // Heading styles
  show heading.where(level: 1): it => {
    v(20pt)
    text(size: size-xxlarge, weight: "bold", fill: accent-color)[#it]
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
  // TITLE PAGE (centered layout like casoon-documents)
  // ============================================================================

  page(
    margin: (left: 50pt, right: 45pt, top: 50pt, bottom: 50pt),
    header: none,
    footer: none,
  )[
    #align(center)[
      #v(50pt)

      // Locale labels with fallbacks
      #let l-concept = if "concept" in locale and "title" in locale.concept { locale.concept.title } else { "Concept" }
      #let l-project = if "common" in locale and "project" in locale.common { locale.common.project } else { "Project" }
      #let l-client = if "common" in locale and "client" in locale.common { locale.common.client } else { "Client" }
      #let l-version = if "common" in locale and "version" in locale.common { locale.common.version } else { "Version" }
      #let l-status = if "common" in locale and "status" in locale.common { locale.common.status } else { "Status" }
      #let l-created = if "common" in locale and "created" in locale.common { locale.common.created } else { "Created" }
      #let l-authors = if "common" in locale and "authors" in locale.common { locale.common.authors } else { "Authors" }

      // Logo (use passed logo parameter or pre-loaded _logo_image)
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

      // Document type and number
      #text(size: size-xlarge, fill: accent-color, weight: "bold")[#upper(l-concept)]
      #text(size: size-xlarge, fill: color-text-light)[ · #document_number]

      #v(30pt)

      // Metadata grid
      #grid(
        columns: (auto, auto),
        column-gutter: 20pt,
        row-gutter: 14pt,
        align: (right, left),

        [*#l-project:*], [#project_name],
        [*#l-client:*], [#client_name],
        [*#l-version:*], [#version],
        [*#l-status:*], [#text(fill: accent-color, weight: "bold")[#upper(status)]],
        ..if created_at != none {
          ([*#l-created:*], [#created_at])
        } else { () },
        ..if authors.len() > 0 {
          ([*#l-authors:*], [#authors.join(", ")])
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
  // TABLE OF CONTENTS
  // ============================================================================

  if show_toc {
    let l-toc = if "common" in locale and "table_of_contents" in locale.common { locale.common.table_of_contents } else { "Table of Contents" }
    [
      #outline(
        title: [
          #set text(size: size-xxlarge, weight: "bold")
          #l-toc
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

// For JSON-based usage (via docgen CLI)
// Only load from sys.inputs when "data" is present (JSON workflow)
#let data = if "data" in sys.inputs {
  json(sys.inputs.data)
} else {
  none
}

// Only load company/locale when in JSON workflow (data != none)
#let _company = if data != none and "company" in sys.inputs {
  let c = json(sys.inputs.company)
  // Load logo image if logo path is specified
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
    company: _company,
    locale: _locale,
    content-body
  )
}

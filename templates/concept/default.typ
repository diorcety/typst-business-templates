// Concept/Proposal Document Template (Konzept)
// Professional concept and proposal documentation

#import "../common/styles.typ": *

// Document function for flexible use
#let concept(
  title: none,
  document_number: none,
  client_name: none,
  project_name: none,
  version: "1.0",
  status: "draft",
  tags: (),
  created_at: none,
  show_toc: false,
  body
) = {
  // Load company data
  let company = json("../../data/company.json")

  set page(
    paper: "a4",
    margin: (left: 50pt, right: 50pt, top: 70pt, bottom: 70pt),
    header: context {
      if counter(page).get().first() > 1 [
        #set text(size: size-small, fill: color-text-light)
        #grid(
          columns: (1fr, 1fr),
          align: (left, right),
          [#document_number],
          [#title]
        )
        #line(length: 100%, stroke: border-thin + color-text-light)
      ]
    },
    footer: context {
      if counter(page).get().first() > 1 [
        #set text(size: size-small, fill: color-text-light)
        #line(length: 100%, stroke: border-thin + color-text-light)
        #v(5pt)
        #grid(
          columns: (1fr, 1fr, 1fr),
          align: (left, center, right),
          [#company.name],
          [Seite #counter(page).display("1 / 1", both: true)],
          [#if created_at != none { created_at } else { datetime.today().display("[day].[month].[year]") }]
        )
      ]
    }
  )

  set text(font: font-body, size: size-medium, lang: "de")
  set par(leading: 0.65em, justify: true)

  // Headings
  set heading(numbering: "1.1")

  show heading.where(level: 1): it => {
    v(30pt)
    block(sticky: true, width: 100%)[
      #text(size: size-xxlarge, weight: "bold", fill: color-accent)[#it]
    ]
    v(15pt)
  }

  show heading.where(level: 2): it => {
    v(15pt)
    block(sticky: true, width: 100%)[
      #text(size: size-xlarge, weight: "bold")[#it]
    ]
    v(10pt)
  }

  show heading.where(level: 3): it => {
    v(12pt)
    block(sticky: true, width: 100%)[
      #text(size: size-large, weight: "bold")[#it]
    ]
    v(8pt)
  }

  // Links
  show link: it => text(fill: rgb("#3498db"), it)

  // Code blocks
  show raw.where(block: true): it => {
    set text(size: size-small)
    block(fill: color-background, inset: 10pt, radius: 3pt, width: 100%, it)
  }

  // Tables
  set table(
    stroke: border-thin + color-text-light,
    fill: (x, y) => if y == 0 { rgb("#f0f0f0") }
  )

  // TITLE PAGE
  [
    #align(center)[
      #v(50pt)

      // Logo placeholder
      #box(
        stroke: 1pt + color-border,
        inset: 1em,
        radius: 4pt,
      )[
        #text(size: size-xlarge, fill: color-text-light)[LOGO]
      ]

      #v(30pt)

      #text(size: size-title, weight: "bold")[#title]

      #v(20pt)

      #text(size: size-xlarge, fill: color-accent, weight: "bold")[KONZEPT]
      #text(size: size-xlarge, fill: color-text-light)[· #document_number]

      #v(30pt)

      #grid(
        columns: (auto, auto),
        column-gutter: 20pt,
        row-gutter: 14pt,
        align: (right, left),
        [*Projekt:*], [#project_name],
        [*Kunde:*], [#client_name],
        [*Version:*], [#version],
        [*Status:*], [#text(fill: color-accent, weight: "bold")[#upper(status)]],
        ..if created_at != none { ([*Erstellt:*], [#created_at]) } else { () },
      )

      #v(1fr)

      #if tags.len() > 0 [
        #tags.map(tag => pill(tag)).join(h(8pt))
      ]

      #v(40pt)
    ]

    #pagebreak()

    #if show_toc [
      #outline(title: "Inhaltsverzeichnis", indent: auto)
      #pagebreak()
    ]

    #body
  ]
}

// For JSON-based usage
#let data = if "data" in sys.inputs {
  json(sys.inputs.data)
} else {
  none
}

#if data != none {
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
    status: if "status" in data.metadata { data.metadata.status } else { "draft" },
    tags: if "tags" in data.metadata { data.metadata.tags } else { () },
    created_at: if "created_at" in data.metadata { data.metadata.created_at } else { none },
    show_toc: if "show_toc" in data.metadata { data.metadata.show_toc } else { false },
    content-body
  )
}

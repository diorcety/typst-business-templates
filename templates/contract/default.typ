// Contract Template (Vertrag) - Document Layout
// Based on concept/documentation structure
// Supports both JSON input and direct .typ content files

#import "../common/styles.typ": *
#import "../common/footers.typ": document-footer
#import "../common/title-page.typ": parties-title-page

// Document function
#let contract(
  title: none,
  document_number: none,
  contract_type: "Dienstleistungsvertrag",
  parties: (),
  effective_date: none,
  termination_date: none,
  created_at: none,
  show_toc: true,
  company: none,
  locale: none,
  logo: none,
  show-title-page: true,
  show-footer: true,
  status: "Draft",
  lang: "de",
  body
) = {
  let company = if company != none { company } else { (:) }
  let locale = if locale != none { locale } else { (common: (:), contract: (:)) }

  let accent-color = get-accent-color(company)
  let primary-color = get-primary-color(company)
  let fonts = get-font-preset(company)

  // Locale labels with fallbacks
  let l-contractor = if "contract" in locale and "contractor" in locale.contract { locale.contract.contractor } else { "Contractor" }
  let l-client = if "contract" in locale and "client" in locale.contract { locale.contract.client } else { "Client" }
  let l-valid-from = if "contract" in locale and "valid_from" in locale.contract { locale.contract.valid_from } else { "Valid from" }
  let l-term-until = if "contract" in locale and "term_until" in locale.contract { locale.contract.term_until } else { "Term until" }
  let l-created-on = if "contract" in locale and "created_on" in locale.contract { locale.contract.created_on } else { "Created on" }
  let l-signatures = if "contract" in locale and "signatures" in locale.contract { locale.contract.signatures } else { "Signatures" }
  let l-place-date-signature = if "contract" in locale and "place_date_signature" in locale.contract { locale.contract.place_date_signature } else { "Place, date, signature" }

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
          [#if effective_date != none [#l-valid-from: #effective_date]]
        )
        #v(5pt)
        #line(length: 100%, stroke: border-thin)
      ]
    ],

    footer: if show-footer { document-footer(
      company: company,
      locale: locale,
      document_number: document_number,
      created_at: created_at,
      status: status,
    ) } else { none }
  )

  set text(font: fonts.body, size: size-medium, lang: lang)
  set par(justify: true, leading: 0.65em)
  set heading(numbering: "1.1")

  show heading.where(level: 1): it => {
    v(20pt)
    text(size: size-xlarge, weight: "bold", fill: accent-color)[#it]
    v(10pt)
  }

  show heading.where(level: 2): it => {
    v(15pt)
    text(size: size-large, weight: "bold")[#it]
    v(8pt)
  }

  // ============================================================================
  // TITLE PAGE
  // ============================================================================

  if show-title-page {
    page(
      margin: (left: 50pt, right: 45pt, top: 50pt, bottom: 50pt),
      header: none,
      footer: none,
    )[
      #parties-title-page(
        company: company,
        logo: logo,
        title: title,
        document-type: contract_type,
        document-number: document_number,
        accent-color: accent-color,
        party1-label: l-contractor,
        party1-name: if parties.len() > 0 and "company" in parties.at(0) and parties.at(0).company != none { parties.at(0).company } else if parties.len() > 0 and "name" in parties.at(0) { parties.at(0).name } else { none },
        party1-address: if parties.len() > 0 and "address" in parties.at(0) { parties.at(0).address } else { none },
        party2-label: l-client,
        party2-name: if parties.len() > 1 and "company" in parties.at(1) and parties.at(1).company != none { parties.at(1).company } else if parties.len() > 1 and "name" in parties.at(1) { parties.at(1).name } else { none },
        party2-address: if parties.len() > 1 and "address" in parties.at(1) { parties.at(1).address } else { none },
        metadata: {
          let meta = (:)
          if effective_date != none {
            meta.insert(l-valid-from, effective_date)
          }
          if termination_date != none {
            meta.insert(l-term-until, termination_date)
          }
          if created_at != none {
            meta.insert(l-created-on, created_at)
          }
          meta
        },
      )
    ]

    pagebreak()
  }

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

  // ============================================================================
  // SIGNATURE PAGE
  // ============================================================================

  pagebreak()

  v(1fr)

  text(size: size-large, weight: "bold")[#l-signatures]

  v(30pt)

  grid(
    columns: (1fr, 1fr),
    column-gutter: 30pt,
    row-gutter: 80pt,

    ..parties.map(party =>
      box(
        width: 100%,
        stroke: (top: 0.5pt),
        inset: (top: 8pt),
      )[
        #align(left)[
          #if "company" in party and party.company != none [
            #party.company\
          ]
          #if "name" in party [
            #party.name\
          ]
          #v(0.3em)
          #text(size: size-small)[#l-place-date-signature]
        ]
      ]
    ).flatten()
  )

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

  let content-body = if "content_file" in data {
    include(data.content_file)
  } else if "content" in data {
    eval(data.content, mode: "markup")
  } else {
    []
  }

  contract(
    title: data.metadata.title,
    document_number: data.metadata.document_number,
    contract_type: if "contract_type" in data.metadata { data.metadata.contract_type } else { "Dienstleistungsvertrag" },
    parties: if "parties" in data.metadata { data.metadata.parties } else { () },
    effective_date: if "effective_date" in data.metadata { data.metadata.effective_date } else { none },
    termination_date: if "termination_date" in data.metadata { data.metadata.termination_date } else { none },
    created_at: created-date,
    show_toc: if "show_toc" in data.metadata { data.metadata.show_toc } else { true },
    company: _company,
    locale: _locale,
    content-body
  )
}

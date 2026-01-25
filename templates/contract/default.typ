// Contract Template (Vertrag) - Document Layout
// Based on concept/documentation structure
// Supports both JSON input and direct .typ content files

#import "../common/styles.typ": *

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
  body
) = {
  let company = if company != none { company } else { (:) }
  let locale = if locale != none { locale } else { (common: (:), contract: (:)) }
  
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
          [#if effective_date != none [Gültig ab: #effective_date]]
        )
        #v(5pt)
        #line(length: 100%, stroke: border-thin)
      ]
    ],

    footer: context [
      #let l-document = if "common" in locale and "document" in locale.common { locale.common.document } else { "Document" }
      #let l-page = if "common" in locale and "page" in locale.common { locale.common.page } else { "Page" }
      
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
          #strong[Erstellt:] #linebreak()
          #if created_at != none [#created_at]
        ],
      )
    ]
  )

  set text(font: fonts.body, size: size-medium, lang: "de")
  set par(justify: true, leading: 0.65em)
  set heading(numbering: "§1.")

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

      // Contract type
      #text(size: size-xlarge, fill: accent-color, weight: "bold")[#upper(contract_type)]
      #text(size: size-xlarge, fill: color-text-light)[ · #document_number]

      #v(40pt)

      // Parties
      #text(size: size-large, weight: "bold")[Vertragsparteien]
      
      #v(15pt)

      #for (index, party) in parties.enumerate() [
        #box(
          width: 80%,
          stroke: border-normal + color-border,
          radius: 4pt,
          inset: 1em,
        )[
          #align(left)[
            #text(weight: "bold", fill: accent-color)[#if index == 0 [Auftragnehmer] else if index == 1 [Auftraggeber] else [Partei #(index + 1)]]\
            #v(0.3em)
            #if "company" in party and party.company != none [
              #party.company\
            ]
            #if "name" in party [
              #party.name\
            ]
            #if "address" in party [
              #party.address.street #party.address.house_number\
              #party.address.postal_code #party.address.city
            ]
          ]
        ]
        #v(15pt)
      ]

      #v(1fr)

      // Dates
      #grid(
        columns: (auto, auto),
        column-gutter: 20pt,
        row-gutter: 14pt,
        align: (right, left),

        ..if effective_date != none {
          ([*Gültig ab:*], [#effective_date])
        } else { () },
        ..if termination_date != none {
          ([*Laufzeit bis:*], [#termination_date])
        } else { () },
        ..if created_at != none {
          ([*Erstellt am:*], [#created_at])
        } else { () },
      )

      #v(30pt)
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

  // ============================================================================
  // SIGNATURE PAGE
  // ============================================================================

  pagebreak()

  v(1fr)

  text(size: size-large, weight: "bold")[Unterschriften]

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
          #text(size: size-small)[Ort, Datum, Unterschrift]
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

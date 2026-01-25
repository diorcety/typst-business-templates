// SLA Template (Service Level Agreement) - Document Layout
// Service level agreements and support contracts
// Based on contract structure with metrics focus

#import "../common/styles.typ": *

// Document function
#let sla(
  title: none,
  document_number: none,
  service_provider: none,
  customer: none,
  effective_date: none,
  termination_date: none,
  review_period: none,
  version: "1.0",
  status: "Aktiv",
  created_at: none,
  show_toc: true,
  company: none,
  locale: none,
  logo: none,
  body
) = {
  let company = if company != none { company } else { (:) }
  let locale = if locale != none { locale } else { (common: (:), sla: (:)) }
  
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
          #strong[Version:] #version #linebreak()
          #strong[Status:] #status #linebreak()
          #if effective_date != none [Gültig ab: #effective_date]
        ],
      )
    ]
  )

  set text(font: fonts.body, size: size-medium, lang: "de")
  set par(justify: true, leading: 0.65em)
  set heading(numbering: "1.1")

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

  // Tables for SLA metrics
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

      // SLA type
      #text(size: size-xlarge, fill: accent-color, weight: "bold")[SERVICE LEVEL AGREEMENT]
      #text(size: size-xlarge, fill: color-text-light)[ · #document_number]

      #v(40pt)

      // Parties
      #text(size: size-large, weight: "bold")[Vertragsparteien]
      
      #v(15pt)

      #grid(
        columns: (1fr, 1fr),
        column-gutter: 30pt,
        row-gutter: 15pt,

        [
          #box(
            width: 100%,
            stroke: border-normal + color-border,
            radius: 4pt,
            inset: 1em,
          )[
            #align(left)[
              #text(weight: "bold", fill: accent-color)[Service Provider]\
              #v(0.3em)
              #if service_provider != none [
                #if type(service_provider) == dictionary [
                  #if "company" in service_provider [#service_provider.company\]
                  #if "name" in service_provider [#service_provider.name\]
                  #if "address" in service_provider [
                    #service_provider.address.street #service_provider.address.house_number\
                    #service_provider.address.postal_code #service_provider.address.city
                  ]
                ] else [
                  #service_provider
                ]
              ]
            ]
          ]
        ],

        [
          #box(
            width: 100%,
            stroke: border-normal + color-border,
            radius: 4pt,
            inset: 1em,
          )[
            #align(left)[
              #text(weight: "bold", fill: accent-color)[Kunde]\
              #v(0.3em)
              #if customer != none [
                #if type(customer) == dictionary [
                  #if "company" in customer [#customer.company\]
                  #if "name" in customer [#customer.name\]
                  #if "address" in customer [
                    #customer.address.street #customer.address.house_number\
                    #customer.address.postal_code #customer.address.city
                  ]
                ] else [
                  #customer
                ]
              ]
            ]
          ]
        ],
      )

      #v(1fr)

      // Dates and status
      #grid(
        columns: (auto, auto),
        column-gutter: 20pt,
        row-gutter: 14pt,
        align: (right, left),

        [*Version:*], [#version],
        [*Status:*], [#text(fill: accent-color, weight: "bold")[#upper(status)]],
        ..if effective_date != none {
          ([*Gültig ab:*], [#effective_date])
        } else { () },
        ..if termination_date != none {
          ([*Laufzeit bis:*], [#termination_date])
        } else { () },
        ..if review_period != none {
          ([*Review-Zyklus:*], [#review_period])
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

    box(
      width: 100%,
      stroke: (top: 0.5pt),
      inset: (top: 8pt),
    )[
      #align(left)[
        Service Provider\
        #v(0.3em)
        #text(size: size-small)[Ort, Datum, Unterschrift]
      ]
    ],

    box(
      width: 100%,
      stroke: (top: 0.5pt),
      inset: (top: 8pt),
    )[
      #align(left)[
        Kunde\
        #v(0.3em)
        #text(size: size-small)[Ort, Datum, Unterschrift]
      ]
    ],
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
  
  sla(
    title: data.metadata.title,
    document_number: data.metadata.document_number,
    service_provider: if "service_provider" in data.metadata { data.metadata.service_provider } else { none },
    customer: if "customer" in data.metadata { data.metadata.customer } else { none },
    effective_date: if "effective_date" in data.metadata { data.metadata.effective_date } else { none },
    termination_date: if "termination_date" in data.metadata { data.metadata.termination_date } else { none },
    review_period: if "review_period" in data.metadata { data.metadata.review_period } else { none },
    version: if "version" in data.metadata { data.metadata.version } else { "1.0" },
    status: if "status" in data.metadata { data.metadata.status } else { "Aktiv" },
    created_at: created-date,
    show_toc: if "show_toc" in data.metadata { data.metadata.show_toc } else { true },
    company: _company,
    locale: _locale,
    content-body
  )
}

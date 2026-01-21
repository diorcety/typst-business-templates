// Typst Business Templates
// Use: #import "@preview/business-templates:0.1.0": invoice, offer, credentials, concept

#import "templates/common/styles.typ": *
#import "templates/invoice/default.typ": invoice
#import "templates/offer/default.typ": offer
#import "templates/credentials/default.typ": credentials
#import "templates/concept/default.typ": concept

// Re-export utilities
#let format-currency = currency
#let tag = pill
#let box-info = info-box
#let box-warning = warning-box

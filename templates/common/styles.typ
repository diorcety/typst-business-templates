// Common Typst Styles
// This file contains reusable style definitions for all templates
// Based on casoon-documents styling

// Load company data for branding colors (if available)
#let company-data = json("../../data/company.json")

// Color Palette (with company branding override)
#let color-primary = if "branding" in company-data and "primary_color" in company-data.branding {
  rgb(company-data.branding.primary_color)
} else {
  rgb("#2c3e50")
}

#let color-accent = if "branding" in company-data and "accent_color" in company-data.branding {
  rgb(company-data.branding.accent_color)
} else {
  rgb("#E94B3C")
}

#let color-secondary = rgb("#34495e")
#let color-text = rgb("#2c3e50")
#let color-text-light = rgb("#7f8c8d")
#let color-border = rgb("#bdc3c7")
#let color-background = rgb("#f5f5f5")
#let color-white = rgb("#ffffff")
#let color-warning = rgb("#fff8e1")

// Typography
#let font-body = "Helvetica"
#let font-heading = "Helvetica"
#let font-mono = "Courier New"

#let size-xs = 7pt
#let size-small = 8pt
#let size-normal = 9pt
#let size-medium = 10pt
#let size-large = 11pt
#let size-xlarge = 13pt
#let size-xxlarge = 16pt
#let size-title = 22pt

// Text Styles (as dictionaries for use with set text(..style))
#let text-body = (
  font: font-body,
  size: size-medium,
  fill: color-text,
)

#let text-small = (
  font: font-body,
  size: size-small,
  fill: color-text-light,
)

#let text-heading = (
  font: font-heading,
  size: size-large,
  fill: color-primary,
  weight: "bold",
)

#let text-title = (
  font: font-heading,
  size: size-xxlarge,
  fill: color-primary,
  weight: "bold",
)

#let text-mono = (
  font: font-mono,
  size: size-small,
)

// Layout Spacing
#let spacing-xs = 0.2em
#let spacing-small = 0.3em
#let spacing-normal = 0.5em
#let spacing-medium = 1em
#let spacing-large = 1.5em
#let spacing-xlarge = 2em

// Border Styles
#let border-thin = 0.5pt
#let border-normal = 1pt
#let border-thick = 2pt

// UTILITY: Currency format
#let format-currency(amount, currency: "EUR") = [#amount #currency]

// UTILITY: Pill/tag component
#let pill(content, stroke-color: color-text-light) = box(
  stroke: 0.75pt + stroke-color,
  radius: 10pt,
  inset: (x: 10pt, y: 5pt),
  text(size: size-small, fill: stroke-color)[#content]
)

// UTILITY: Info box
#let info-box(content, fill: color-background) = block(
  fill: fill,
  inset: spacing-medium,
  radius: 4pt,
  width: 100%,
  content
)

// UTILITY: Warning box
#let warning-box(content, accent: color-accent) = block(
  stroke: 1.5pt + accent,
  radius: 6pt,
  inset: spacing-medium,
  width: 100%,
  content
)

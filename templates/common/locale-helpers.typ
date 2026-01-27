// Locale Helpers
// Reusable locale string resolution with fallbacks

/// Gets a localized string with fallback
///
/// Parameters:
/// - locale: Locale dictionary
/// - category: Category key (e.g., "common", "invoice")
/// - key: String key (e.g., "page", "client")
/// - fallback: Default value if key not found
///
/// Returns:
/// - Localized string or fallback value
///
/// Example:
/// ```typst
/// #get-locale-string(locale, "common", "page", "Page")
/// // Returns locale.common.page if exists, otherwise "Page"
/// ```
#let get-locale-string(locale, category, key, fallback) = {
  if locale != none and category in locale and key in locale.at(category) {
    locale.at(category).at(key)
  } else {
    fallback
  }
}

/// Gets common locale strings (frequently used across templates)
///
/// Parameters:
/// - locale: Locale dictionary
///
/// Returns:
/// - Dictionary with common locale strings
///
/// Available keys:
/// - page, project, client, date, version, status, created, authors
/// - table_of_contents, description, quantity, unit, price, total
///
/// Example:
/// ```typst
/// #let l = get-common-locale-strings(locale)
/// #l.page  // "Page" or localized equivalent
/// ```
#let get-common-locale-strings(locale) = {
  (
    // Document metadata
    page: get-locale-string(locale, "common", "page", "Page"),
    project: get-locale-string(locale, "common", "project", "Project"),
    client: get-locale-string(locale, "common", "client", "Client"),
    date: get-locale-string(locale, "common", "date", "Date"),
    version: get-locale-string(locale, "common", "version", "Version"),
    status: get-locale-string(locale, "common", "status", "Status"),
    created: get-locale-string(locale, "common", "created", "Created"),
    authors: get-locale-string(locale, "common", "authors", "Authors"),
    
    // Content
    table_of_contents: get-locale-string(locale, "common", "table_of_contents", "Table of Contents"),
    description: get-locale-string(locale, "common", "description", "Description"),
    quantity: get-locale-string(locale, "common", "quantity", "Quantity"),
    unit: get-locale-string(locale, "common", "unit", "Unit"),
    price: get-locale-string(locale, "common", "price", "Price"),
    total: get-locale-string(locale, "common", "total", "Total"),
  )
}

/// Gets accounting locale strings (for invoices, offers, etc.)
///
/// Parameters:
/// - locale: Locale dictionary
///
/// Returns:
/// - Dictionary with accounting locale strings
///
/// Example:
/// ```typst
/// #let l = get-accounting-locale-strings(locale)
/// #l.position  // "Pos." or localized equivalent
/// ```
#let get-accounting-locale-strings(locale) = {
  (
    // Table headers
    position: get-locale-string(locale, "common", "position", "Pos."),
    description: get-locale-string(locale, "common", "description", "Bezeichnung"),
    quantity: get-locale-string(locale, "common", "quantity", "Menge"),
    unit: get-locale-string(locale, "common", "unit", "Einh."),
    unit_price: get-locale-string(locale, "common", "unit_price", "Einzelpreis"),
    vat_rate: get-locale-string(locale, "common", "vat_rate", "MwSt."),
    total: get-locale-string(locale, "common", "total", "Summe"),
    
    // Totals section
    subtotal: get-locale-string(locale, "common", "subtotal", "Nettobetrag"),
    vat: get-locale-string(locale, "common", "vat", "MwSt."),
    total_amount: get-locale-string(locale, "common", "total_amount", "Gesamtbetrag"),
    
    // Payment
    payment_method: get-locale-string(locale, "common", "payment_method", "Zahlungsart"),
    payment_terms: get-locale-string(locale, "common", "payment_terms", "Zahlungsbedingungen"),
    due_date: get-locale-string(locale, "common", "due_date", "Fällig am"),
  )
}

/// Gets document-style locale strings (for concepts, documentation, etc.)
///
/// Parameters:
/// - locale: Locale dictionary
/// - doc_type: Document type category (e.g., "concept", "documentation")
///
/// Returns:
/// - Dictionary with document-style locale strings
///
/// Example:
/// ```typst
/// #let l = get-document-locale-strings(locale, "concept")
/// #l.title  // "Concept" or localized equivalent
/// ```
#let get-document-locale-strings(locale, doc_type) = {
  let common = get-common-locale-strings(locale)
  
  // Add document-specific title
  common.insert(
    "title",
    get-locale-string(locale, doc_type, "title", upper(doc_type))
  )
  
  common
}

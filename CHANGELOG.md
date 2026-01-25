# Changelog

All notable changes to this project will be documented in this file.

## [0.4.6] - 2025-01-25

### Added
- **12 neue Template-Typen** für verschiedene Geschäftsdokumente:
  - `letter` - Geschäftsbrief (DIN 5008 konform)
  - `credit-note` - Gutschrift für Rückerstattungen
  - `reminder` - Zahlungserinnerung/Mahnung (Multi-Level)
  - `delivery-note` - Lieferschein mit Unterschriftsfeldern
  - `order-confirmation` - Auftragsbestätigung
  - `time-sheet` - Stundenzettel für Arbeitszeiterfassung
  - `contract` - Vertrag mit Unterschriftsseite
  - `protocol` - Besprechungsprotokoll/Meeting Notes
  - `specification` - Spezifikation/Pflichtenheft mit Code-Blocks
  - `proposal` - Projektvorschlag für Agenturen/Beratung
  - `sla` - Service Level Agreement
  - `quotation-request` - Angebotsanfrage an Lieferanten

### Fixed
- **Footer-Position** in `concept` und `documentation` Templates von 100pt auf 80pt korrigiert
- **Logo-Pfade** konsistent in allen Templates (`"/" + company.logo` oder `company._logo_image`)

### Changed
- Alle Templates verwenden jetzt konsistente Margins und Footer-Position (80pt)
- Templates folgen durchgängig Accounting-Layout oder Document-Layout Standards

### Documentation
- Neue Datei `DOCUMENT-TYPES.md` mit vollständiger Übersicht aller Templates
- Umfangreiche Examples für IT-Consultant Szenario hinzugefügt:
  - 12 vollständige JSON-Beispieldateien
  - README mit Verwendungsbeispielen und Szenarien
  - Realistische Projekt-Workflows (API-Migration, Cloud-Migration)

## [0.4.5] - 2025-01-24

### Fixed
- Invoice footer positioning corrected (bottom margin 122pt → 80pt)
- Logo path consistency across all templates
- Consistent use of `image("/" + company.logo)` pattern

## [0.4.4] - 2025-01-23

### Fixed
- Invoice footer positioning issue (bottom margin reduced from 122pt to 71pt)

## [0.4.3] - 2025-01-23

### Added
- Initial templates for invoice, offer, concept, documentation, credentials

## [0.4.2] - 2025-01-20

### Added
- Basic CLI functionality
- Template generation support
- JSON-based document workflow

## [0.4.1] - 2025-01-18

### Added
- Initial release
- Core template system
- Typst integration

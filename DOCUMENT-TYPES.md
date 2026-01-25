# Dokumenttypen Übersicht

## Layout-Kategorien

### 📄 Accounting-Layout
Footer mit 4-Spalten Firmendetails, DIN 5008 Briefkopf, bottom margin: 80pt

### 📋 Document-Layout
Zentrierte Titelseite, Inhaltsverzeichnis, bottom margin: 80pt

---

## Verfügbare Templates

### ✅ Implementiert

#### Accounting-Layout (Rechnungswesen)

| Template | Beschreibung | Verwendung |
|----------|--------------|------------|
| **invoice** | Rechnung | Rechnungsstellung an Kunden |
| **offer** | Angebot | Angebote für Dienstleistungen/Produkte |
| **credit-note** | Gutschrift | Rückerstattungen, Stornierungen |
| **reminder** | Mahnung/Zahlungserinnerung | 1.-3. Mahnstufe, Zahlungserinnerungen |
| **delivery-note** | Lieferschein | Warenlieferungen dokumentieren |
| **order-confirmation** | Auftragsbestätigung | Bestätigung von Kundenbestellungen |
| **letter** | Geschäftsbrief | Formelle Korrespondenz, DIN 5008 |
| **time-sheet** | Stundenzettel | Arbeitszeiterfassung, Abrechnung |

#### Document-Layout (Dokumente)

| Template | Beschreibung | Verwendung |
|----------|--------------|------------|
| **concept** | Konzept | Design-Konzepte, Projektideen |
| **documentation** | Dokumentation | Technische Dokumentation, Handbücher |
| **contract** | Vertrag | Dienstleistungs-, Werk-, Kaufverträge |
| **protocol** | Protokoll | Meeting Notes, Besprechungsprotokolle |
| **specification** | Spezifikation/Pflichtenheft | Technische/fachliche Anforderungen |

#### Speziallayout

| Template | Beschreibung | Verwendung |
|----------|--------------|------------|
| **credentials** | Zugangsdaten | Sichere Dokumentation von Credentials |

---

## Template-Details

### invoice (Rechnung)
- **Layout**: Accounting
- **Features**: 
  - 7-Spalten Tabelle (Pos., Bezeichnung, Menge, Einh., MwSt., Einzelpreis, Summe)
  - Sub-items Support
  - MwSt.-Aufschlüsselung
  - Zahlungsfrist
- **Branchen**: Alle

### offer (Angebot)
- **Layout**: Accounting
- **Features**:
  - 6-Spalten Tabelle
  - Gültigkeit
  - Zahlungs-/Lieferbedingungen
  - Optional: AGB auf zweiter Seite
- **Branchen**: Alle

### credit-note (Gutschrift)
- **Layout**: Accounting
- **Features**:
  - Referenz zur Original-Rechnung
  - Grund für Gutschrift
  - Identisch zu Invoice-Layout
- **Branchen**: Alle

### reminder (Mahnung)
- **Layout**: Accounting
- **Features**:
  - Mahnstufen (1-3)
  - Tabelle mit offenen Rechnungen
  - Mahngebühren
  - Zahlungsfrist
- **Branchen**: Alle

### delivery-note (Lieferschein)
- **Layout**: Accounting
- **Features**:
  - Artikelliste mit Mengen
  - Unterschriftsfelder (Lieferant/Empfänger)
  - Versandart/Tracking
  - Lieferadresse (kann von Rechnungsadresse abweichen)
- **Branchen**: Handel, E-Commerce, Produktion

### order-confirmation (Auftragsbestätigung)
- **Layout**: Accounting
- **Features**:
  - Bestelldetails
  - Liefertermin
  - Zahlungs-/Lieferbedingungen
  - Referenz zur Kundenbestellung
- **Branchen**: Alle

### letter (Geschäftsbrief)
- **Layout**: Accounting
- **Features**:
  - DIN 5008 konform
  - Betreffzeile
  - Anlagen-Liste
  - Ihr/Unser Zeichen
- **Branchen**: Alle

### time-sheet (Stundenzettel)
- **Layout**: Accounting
- **Features**:
  - Tägliche Zeiterfassung
  - Von/Bis Zeiten
  - Gesamtstunden
  - Abrechenbare/Nicht-abrechenbare Stunden
  - Unterschriftsfelder
- **Branchen**: Freelancer, IT-Consulting, Handwerk

### concept (Konzept)
- **Layout**: Document
- **Features**:
  - Zentrierte Titelseite
  - Project/Client Metadaten
  - Version/Status
  - Tags
  - Optional: Inhaltsverzeichnis
- **Branchen**: Design, Marketing, IT

### documentation (Dokumentation)
- **Layout**: Document
- **Features**:
  - Code-Block Styling
  - Inline-Code Support
  - Nummerierte Headings
  - Inhaltsverzeichnis
  - Version/Status
- **Branchen**: IT, Software-Entwicklung, Engineering

### contract (Vertrag)
- **Layout**: Document
- **Features**:
  - Vertragsparteien (Auftragnehmer/Auftraggeber)
  - Paragraphen-Nummerierung (§1, §2, ...)
  - Unterschriftsseite
  - Laufzeit/Gültigkeit
  - Inhaltsverzeichnis
- **Branchen**: Alle

### protocol (Protokoll)
- **Layout**: Document
- **Features**:
  - Teilnehmerliste
  - Entschuldigte Personen
  - Moderation/Protokollant
  - Datum/Uhrzeit/Ort
  - Tagesordnung
  - Action Items
- **Branchen**: Alle

### specification (Spezifikation)
- **Layout**: Document
- **Features**:
  - Enhanced Code-Block Styling
  - Requirements Boxes (High/Medium/Low Priority)
  - Version History Support
  - Aktualisierungsdatum
  - Autoren
- **Branchen**: IT, Software-Entwicklung, Engineering

### credentials (Zugangsdaten)
- **Layout**: Speziell
- **Features**:
  - Vertraulichkeits-Warnung
  - Services/Credentials Tabelle
  - Technische Einstellungen
  - Ports & Protokolle
  - Sicherheitshinweise
- **Branchen**: IT, Hosting, DevOps

---

## Weitere mögliche Templates (noch nicht implementiert)

### Phase 2 - Business Documents
- **quotation-request** - Angebotsanfrage an Lieferanten
- **expense-report** - Reisekostenabrechnung

### Phase 3 - Spezialisiert
- **proposal** - Projektvorschlag (für Agenturen)
- **sla** - Service Level Agreement (für IT)
- **certificate** - Zertifikat/Bescheinigung (für Trainings)
- **assessment** - Gutachten (für Beratung)
- **case-study** - Fallstudie (für Marketing)
- **incident-report** - Störungsbericht (für IT/DevOps)
- **change-request** - Änderungsantrag (für Software-Entwicklung)
- **inspection-report** - Prüfbericht (für Handwerk/Bau)
- **warranty** - Garantiebescheinigung
- **reference** - Arbeitszeugnis/Referenz
- **brief** - Creative Brief (für Design/Marketing)
- **style-guide** - Styleguide (für Branding)

---

## Nutzung

### Mit docgen CLI (JSON-basiert)
```bash
docgen generate invoice data/invoices/2025/invoice-001.json
docgen generate letter data/letters/2025/letter-001.json
```

### Als Typst Package (direkt)
```typst
#import "@local/docgen-invoice:0.4.5": invoice
#let company = json("/data/company.json")
#let locale = json("/locale/de.json")

#show: invoice.with(
  company: company,
  locale: locale,
  logo: image("/data/logo.png", width: 150pt),
)
```

---

## Konsistenz-Standards

### Alle Templates verwenden:
- ✅ **Footer Position**: `bottom: 80pt` (außer Credentials: 50pt)
- ✅ **Logo-Pfad**: `image("/" + company.logo)` oder `company._logo_image`
- ✅ **Font**: Helvetica (Accounting) / configurable (Document)
- ✅ **Margins**: left: 50pt, right: 45pt, top: 50pt
- ✅ **DIN 5008**: Empfängeradresse bei y=127.5pt (45mm von oben)

### Layout-Kategorien:
- **Accounting-Layout**: invoice, offer, credit-note, reminder, delivery-note, order-confirmation, letter, time-sheet
- **Document-Layout**: concept, documentation, contract, protocol, specification
- **Special-Layout**: credentials

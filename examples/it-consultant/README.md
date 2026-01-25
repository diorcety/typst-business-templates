# IT-Consultant Examples

Dieses Verzeichnis enthält vollständige Beispiele für alle verfügbaren Dokumenttypen.

## Überblick

Alle Beispiele basieren auf einem realistischen IT-Beratungs-Szenario mit folgenden Projekten:

### Hauptprojekt: API Migration für DataFlow Analytics AG
- **Client**: DataFlow Analytics AG (Dr. Sarah Schmidt, CTO)
- **Projekt**: Migration einer Legacy-API zu modernem REST-API Design
- **Umfang**: User Management, Data Processing, Reporting Endpoints
- **Timeline**: Q1 2025 (14 Wochen)

### Nebenprojekt: Cloud Migration für TechVision GmbH
- **Client**: TechVision GmbH (Thomas Weber, CTO)
- **Projekt**: Migration On-Premise Infrastruktur zu AWS
- **Umfang**: 15 VMs, Datenbanken, File Storage
- **Timeline**: Q1-Q2 2025 (14 Wochen)

## Verfügbare Dokumenttypen

### 📄 Accounting-Layout (Rechnungswesen)

| Typ | Datei | Beschreibung |
|-----|-------|--------------|
| **Invoice** | `invoices/2025/invoice-*.json` | Rechnungen für erbrachte Leistungen |
| **Offer** | `offers/2025/offer-*.json` | Angebote für IT-Dienstleistungen |
| **Letter** | `letters/2025/letter-001.json` | Geschäftsbrief (Projektanfrage) |
| **Credit Note** | `credit-notes/2025/credit-note-001.json` | Gutschrift für stornierte Leistungen |
| **Reminder** | `reminders/2025/reminder-001.json` | 1. Mahnung für überfällige Rechnung |
| **Delivery Note** | `delivery-notes/2025/delivery-note-001.json` | Lieferschein für Hardware |
| **Order Confirmation** | `order-confirmations/2025/order-confirmation-001.json` | Auftragsbestätigung API-Projekt |
| **Time Sheet** | `time-sheets/2025/timesheet-001.json` | Stundenzettel mit 71.5h über 2 Wochen |

### 📋 Document-Layout (Projektdokumentation)

| Typ | Datei | Beschreibung |
|-----|-------|--------------|
| **Concept** | `concepts/2025/concept-*.typ` | Projektkonzepte |
| **Documentation** | `documentation/2025/documentation-*.typ` | Technische Dokumentation |
| **Contract** | `contracts/2025/contract-001.json` | Dienstleistungsvertrag (6 Monate) |
| **Protocol** | `protocols/2025/protocol-001.json` | Kick-off Meeting Protokoll |
| **Specification** | `specifications/2025/specification-001.json` | API Spezifikation mit OpenAPI |
| **Proposal** | `proposals/2025/proposal-001.json` | Cloud Migration Projektvorschlag |
| **SLA** | `slas/2025/sla-001.json` | Service Level Agreement (12 Monate) |
| **Quotation Request** | `quotation-requests/2025/quotation-request-001.json` | Angebotsanfrage für Tools |

### 🔒 Special-Layout

| Typ | Datei | Beschreibung |
|-----|-------|--------------|
| **Credentials** | `credentials/2024/credentials-*.json` | Zugangsdaten für Systeme |

## Verwendung

### Mit docgen CLI

```bash
# Aus dem Projekt-Root
cd examples/it-consultant

# Einzelnes Dokument generieren
docgen generate letter documents/letters/2025/letter-001.json

# Alle Dokumente eines Typs generieren
docgen generate contract documents/contracts/2025/*.json

# Output anzeigen
open output/letters/2025/letter-001.pdf
```

### Als Typst Package

Die JSON-Dateien enthalten vollständige Metadaten und können direkt mit den Templates verwendet werden:

```bash
typst compile \\
  --input data=documents/letters/2025/letter-001.json \\
  --input company=data/company.json \\
  --input locale=locale/de.json \\
  ../../templates/letter/default.typ \\
  output/letter-001.pdf
```

## Dateien-Struktur

```
it-consultant/
├── data/
│   ├── company.json              # Firmendaten
│   ├── concept-content.typ       # Content für Konzept-Dokumente
│   └── documentation-content.typ # Content für Dokumentation
├── locale/
│   └── de.json                   # Deutsche Übersetzungen
├── documents/                    # Alle JSON-Dateien für Dokumente
│   ├── letters/2025/
│   ├── credit-notes/2025/
│   ├── reminders/2025/
│   ├── time-sheets/2025/
│   ├── delivery-notes/2025/
│   ├── order-confirmations/2025/
│   ├── contracts/2025/
│   ├── protocols/2025/
│   ├── specifications/2025/
│   ├── proposals/2025/
│   ├── slas/2025/
│   └── quotation-requests/2025/
├── templates/                    # Branding-spezifische Templates
└── output/                       # Generierte PDFs

```

## Realistische Szenarien

### Szenario 1: Komplettes Projekt-Lifecycle

1. **Proposal** (`proposals/2025/proposal-001.json`) - Projektvorschlag Cloud Migration
2. **Contract** (`contracts/2025/contract-001.json`) - Unterschriebener Vertrag
3. **Protocol** (`protocols/2025/protocol-001.json`) - Kick-off Meeting
4. **Specification** (`specifications/2025/specification-001.json`) - API-Spezifikation
5. **Time Sheet** (`time-sheets/2025/timesheet-001.json`) - Wöchentliche Zeiterfassung
6. **Order Confirmation** (`order-confirmations/2025/order-confirmation-001.json`) - Auftragsbestätigung
7. **Invoice** (`invoices/2025/invoice-*.json`) - Monatliche Abrechnung
8. **SLA** (`slas/2025/sla-001.json`) - Ongoing Support nach Projekt

### Szenario 2: Zahlungs-Workflow

1. **Invoice** - Rechnung versandt
2. **Reminder** (`reminders/2025/reminder-001.json`) - 1. Mahnung nach Zahlungsverzug
3. **Credit Note** (`credit-notes/2025/credit-note-001.json`) - Teilstorno bei Reduzierung

### Szenario 3: Beschaffung

1. **Quotation Request** (`quotation-requests/2025/quotation-request-001.json`) - Anfrage an Supplier
2. **Order Confirmation** - Bestätigung vom Supplier
3. **Delivery Note** (`delivery-notes/2025/delivery-note-001.json`) - Warenlieferung

## Anpassung

Um diese Examples für Ihr Unternehmen anzupassen:

1. **Firmendaten ändern**: `data/company.json` editieren
2. **Logo austauschen**: `data/logo.png` ersetzen
3. **Texte anpassen**: JSON-Dateien in `documents/` editieren
4. **Neue Beispiele**: JSON-Dateien kopieren und anpassen

## Tipps

- Alle Beträge sind in EUR (netto)
- Datumsformat: YYYY-MM-DD in JSON
- MwSt.-Satz: 19% (Standard in Deutschland)
- Zahlungsziel: Standard 14 Tage

## Nächste Schritte

1. Generieren Sie alle Beispiele: `docgen generate-all`
2. Schauen Sie sich die PDFs im `output/` Verzeichnis an
3. Passen Sie die JSON-Dateien an Ihre Bedürfnisse an
4. Erstellen Sie eigene Dokumente basierend auf den Beispielen

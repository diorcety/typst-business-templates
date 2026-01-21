# Typst Business Templates - Projektdefinition

## Was es ist

Ein Open-Source-Framework zur Erstellung professioneller Geschäftsdokumente mit Typst. Kombiniert die Einfachheit von JSON-Daten mit der Layoutqualität von Typst.

**Kernidee:** Daten (JSON) + Template (Typst) = PDF

## Aktueller Stand (v0.2.0)

### Templates

| Template | Beschreibung | Status |
|----------|--------------|--------|
| Invoice | Rechnungen mit deutscher Formatierung | ✅ Fertig |
| Offer | Angebote mit Positionsliste | ✅ Fertig |
| Credentials | Zugangsdaten-Dokumentation | ✅ Fertig |
| Concept | Konzepte und Proposals | ✅ Fertig |

### CLI (Rust)

| Befehl | Beschreibung | Status |
|--------|--------------|--------|
| `docgen` (ohne Argument) | **Interaktiver Modus** | ✅ Neu |
| `docgen init` | Projekt initialisieren | ✅ Fertig |
| `docgen compile` | JSON → PDF | ✅ Fertig |
| `docgen build` | Alle Dokumente bauen | ✅ Fertig |
| `docgen watch` | Auto-Rebuild | ✅ Fertig |
| `docgen client list` | Kunden auflisten | ✅ Neu |
| `docgen client add` | Kunde anlegen | ✅ Neu |
| `docgen client show` | Kundendetails | ✅ Neu |
| `docgen project list` | Projekte auflisten | ✅ Neu |
| `docgen project add` | Projekt anlegen | ✅ Neu |

### Infrastruktur

- **SQLite-Datenbank** für Kunden, Projekte, Dokument-Index
- Automatische fortlaufende Nummerierung
- JSON Schemas für Validierung
- Beispieldateien
- Typst Package Struktur (`typst.toml`)
- MIT Lizenz

## Interaktiver Modus

Starte `docgen` ohne Argumente für eine übersichtliche Terminal-UI:

```
╔═══════════════════════════════════════════════════════╗
║  DOCGEN - Dokumentenverwaltung                        ║
╚═══════════════════════════════════════════════════════╝

Kunden (3)

┌───┬────────┬──────────────────────┬────────────┬─────────────────┐
│ # │ Nr.    │ Name                 │ Ort        │ E-Mail          │
├───┼────────┼──────────────────────┼────────────┼─────────────────┤
│ 1 │ K-001  │ Kunde GmbH           │ Hamburg    │ info@kunde.de   │
│ 2 │ K-002  │ Max Müller           │ Berlin     │ max@example.de  │
│ 3 │ K-003  │ Stadtwerke Rostock   │ Rostock    │ sw@rostock.de   │
└───┴────────┴──────────────────────┴────────────┴─────────────────┘

> Auswahl: [1-3] Kunde wählen, + Neuer Kunde, q Beenden
```

Nach Kundenauswahl:

```
╔═══════════════════════════════════════════════════════╗
║  Kunde GmbH                                    K-001  ║
║  Musterstraße 42, 12345 Hamburg                       ║
║  info@kunde.de                                        ║
╚═══════════════════════════════════════════════════════╝

Projekte (2)
┌──────────────┬──────────────────────┬────────┐
│ Nr.          │ Name                 │ Status │
├──────────────┼──────────────────────┼────────┤
│ P-001-01     │ Website Relaunch     │ active │
│ P-001-02     │ App Entwicklung      │ active │
└──────────────┴──────────────────────┴────────┘

Dokumente (letzte 10)
┌─────────────┬───────────┬────────────┬───────────┬─────────┐
│ Nummer      │ Typ       │ Datum      │ Betrag    │ Status  │
├─────────────┼───────────┼────────────┼───────────┼─────────┤
│ RE-2025-012 │ Rechnung  │ 2025-01-15 │ 1.250 €   │ offen   │
│ AN-2025-003 │ Angebot   │ 2025-01-10 │ 3.500 €   │ gesendet│
└─────────────┴───────────┴────────────┴───────────┴─────────┘

> Aktion: [r] Rechnung  [a] Angebot  [z] Zugangsdaten  [k] Konzept
          [p] Projekt   [←] Zurück
```

## Datenbank

SQLite (`data/docgen.db`) für konsistente Datenhaltung:

### Tabellen

**clients** - Kundenstammdaten
- Automatische Nummerierung (K-001, K-002, ...)
- Adresse, Kontakt, Notizen

**projects** - Projekte pro Kunde
- Nummerierung pro Kunde (P-001-01, P-001-02, ...)
- Stundensatz, Status

**documents** - Dokument-Index
- Fortlaufende Nummern pro Typ (RE-2025-001, AN-2025-002, ...)
- Verknüpfung zu Kunde und Projekt
- Status-Tracking (Entwurf, Gesendet, Bezahlt, ...)

**counters** - Nummernkreise
- Atomare Operationen für sichere Nummerierung

## Was fehlt

### Priorität 1: Erweiterungen Kunden/Projekte

- [ ] `docgen client edit` - Kunde bearbeiten
- [ ] `docgen client delete` - Kunde löschen (mit Sicherheitsabfrage)
- [ ] `docgen project edit/delete`
- [ ] Suche in Kunden/Projekten

### Priorität 2: Dokumenten-Features

- [ ] `docgen invoice status RE-2025-001 paid` - Status ändern
- [ ] `docgen stats` - Umsatzübersicht
- [ ] `docgen unpaid` - Offene Rechnungen
- [ ] Automatische Mahnungen

### Priorität 3: Weitere Templates

- [ ] Lieferschein (Delivery Note)
- [ ] Gutschrift (Credit Note)  
- [ ] Mahnung (Payment Reminder)
- [ ] Zeiterfassung (Timesheet)

### Priorität 4: Integration

- [ ] Typst Universe Package veröffentlichen
- [ ] Homebrew Formula
- [ ] E-Rechnung Export (ZUGFeRD/XRechnung)

## Ideen

### Zeiterfassung

```bash
docgen time add --project P-001-01 --hours 4 --desc "Frontend"
docgen time list --project P-001-01
docgen invoice from-time --project P-001-01 --month 01
```

### Recurring

```bash
docgen recurring add --type invoice --client K-001 --monthly
docgen recurring run  # Erstellt alle fälligen Dokumente
```

### Reports

```bash
docgen report revenue --year 2025
docgen report client K-001
```

## Technische Architektur

```
docgen (Rust CLI)
    │
    ├── Interaktiver Modus (dialoguer, comfy-table)
    │
    ├── SQLite Datenbank (rusqlite)
    │   └── data/docgen.db
    │
    ├── JSON Dokument-Daten
    │   └── documents/{type}/{number}.json
    │
    └── Typst Kompilierung
        └── typst compile --root . ...
```

### Warum diese Entscheidungen?

**SQLite statt JSON für Stammdaten:**
- Atomare Nummerierung (keine Race Conditions)
- Relationen (Projekt → Kunde)
- Queries (alle Rechnungen für Kunde X)
- Transaktionen garantieren Konsistenz

**JSON für Dokument-Inhalte:**
- Git-trackbar (Diff sichtbar)
- Einfach zu bearbeiten
- Template-unabhängig

**Rust:**
- Single Binary
- Schnell
- Cross-Platform
- Gutes Ökosystem

## Mitwirken

Contributions willkommen! 

- Issues: https://github.com/casoon/typst-business-templates/issues
- Pull Requests gerne gesehen

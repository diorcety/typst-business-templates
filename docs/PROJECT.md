# Typst Business Templates - Projektdefinition

## Was es ist

Ein Open-Source-Framework zur Erstellung professioneller Geschäftsdokumente mit Typst. Kombiniert die Einfachheit von JSON-Daten mit der Layoutqualität von Typst.

**Kernidee:** Daten (JSON) + Template (Typst) = PDF

## Aktueller Stand (v0.1.0)

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
| `docgen init` | Projekt initialisieren | ✅ Fertig |
| `docgen new` | Dokument aus Vorlage | ✅ Fertig |
| `docgen compile` | JSON → PDF | ✅ Fertig |
| `docgen build` | Alle Dokumente bauen | ✅ Fertig |
| `docgen watch` | Auto-Rebuild | ✅ Fertig |
| `docgen validate` | JSON validieren | ✅ Basis |

### Infrastruktur

- JSON Schemas für Validierung
- Beispieldateien
- Typst Package Struktur (`typst.toml`)
- MIT Lizenz

## Was fehlt

### Priorität 1: Kunden- und Projektverwaltung

Aktuell muss man Kundendaten in jeder JSON-Datei wiederholen. Besser wäre:

```
data/
├── company.json      # Eigene Firmendaten
├── clients/
│   ├── kunde-a.json
│   └── kunde-b.json
└── projects/
    ├── projekt-1.json  # Referenziert Client
    └── projekt-2.json
```

**Geplante CLI-Befehle:**
- `docgen client add "Kunde GmbH"`
- `docgen client list`
- `docgen project add "Website Relaunch" --client kunde-a`

### Priorität 2: Weitere Templates

- [ ] Lieferschein (Delivery Note)
- [ ] Gutschrift (Credit Note)
- [ ] Mahnung (Payment Reminder)
- [ ] Protokoll (Meeting Minutes)
- [ ] Zeiterfassung (Timesheet)

### Priorität 3: Erweiterte Features

- [ ] Template-Varianten (minimal, detailed, modern)
- [ ] Mehrsprachigkeit (DE/EN)
- [ ] Logo-Integration vereinfachen
- [ ] PDF-Metadaten (Autor, Titel)
- [ ] Automatische Nummernvergabe

### Priorität 4: Integration

- [ ] Typst Universe Package veröffentlichen
- [ ] Homebrew Formula für CLI
- [ ] GitHub Actions für CI/CD
- [ ] VS Code Extension

## Ideen

### Dokumenten-Workflow

```
docgen new invoice --client kunde-a --project projekt-1
# → Erstellt invoices/RE-2025-001.json mit vorausgefüllten Daten
```

### Recurring Documents

```json
{
  "type": "recurring",
  "template": "invoice",
  "schedule": "monthly",
  "client": "kunde-a",
  "items": [...]
}
```

### Export-Formate

- PDF (aktuell)
- E-Rechnung (ZUGFeRD/XRechnung)
- HTML Preview

### Verknüpfung mit Zeiterfassung

```
docgen timesheet add --project projekt-1 --hours 8 --description "Frontend"
docgen invoice generate --from-timesheet --project projekt-1
```

## Technische Entscheidungen

### Warum JSON?

- Einfach zu lesen und schreiben
- Validierbar mit JSON Schema
- Überall unterstützt
- Git-freundlich (diffbar)

### Warum Rust CLI?

- Single Binary (keine Runtime)
- Schnell
- Cross-Platform
- Gute Ecosystem (clap, serde, notify)

### Warum Typst?

- Modernes LaTeX-Alternative
- Schnelle Kompilierung
- Einfache Syntax
- Aktive Entwicklung

## Datenbank-Optionen für Kunden/Projekte

Für eine lokale, dokumentenbasierte Lösung gibt es mehrere Optionen:

### Option A: SQLite (Empfohlen)

```
data/docgen.db
```

- Einzelne Datei, keine Installation
- SQL-Queries, Relations
- Rust: `rusqlite` crate
- Backup = Datei kopieren

### Option B: JSON-Dateien (Aktuell)

```
data/clients/*.json
data/projects/*.json
```

- Maximal einfach
- Git-freundlich
- Keine echten Relations
- Bei vielen Einträgen unübersichtlich

### Option C: SurrealDB (Modern)

```
data/surreal.db
```

- Document + Graph + SQL
- Embedded oder Server
- Rust-native
- Relationen möglich

### Empfehlung

**SQLite** für Kunden/Projekte, **JSON** für Dokumente.

Gründe:
- Clients/Projects haben Relationen (Projekt gehört zu Kunde)
- Queries nötig (alle Rechnungen für Kunde X)
- Dokument-JSONs bleiben Git-trackbar
- SQLite ist überall verfügbar

## Mitwirken

Contributions willkommen! Siehe [CONTRIBUTING.md](CONTRIBUTING.md) (TODO).

Kontakt: GitHub Issues oder joern.seidel@casoon.de

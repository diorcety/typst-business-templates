# Datenbank-Konzept für Kunden- und Projektverwaltung

## Problemstellung

Aktuell werden Kundendaten in jeder Dokumenten-JSON wiederholt:

```json
// invoices/RE-2025-001.json
{
  "recipient": {
    "name": "Max Mustermann",
    "company": "Kunde GmbH",
    "address": { ... }
  }
}

// invoices/RE-2025-002.json  
{
  "recipient": {
    "name": "Max Mustermann",  // Dupliziert!
    "company": "Kunde GmbH",
    "address": { ... }
  }
}
```

**Probleme:**
- Daten-Duplikation
- Inkonsistenzen bei Änderungen
- Keine Übersicht über alle Kunden/Projekte
- Keine Verknüpfungen (Welche Rechnungen für Kunde X?)

## Lösungsansatz: Hybrid (SQLite + JSON)

### Architektur

```
project/
├── data/
│   ├── docgen.db          # SQLite: Clients, Projects, Document-Index
│   └── company.json       # Eigene Firmendaten (bleibt JSON)
├── documents/
│   ├── invoices/
│   │   └── RE-2025-001.json   # Dokument-Daten (nur Items, Totals)
│   ├── offers/
│   └── ...
└── output/
    └── *.pdf
```

### SQLite Schema

```sql
-- Kunden
CREATE TABLE clients (
    id TEXT PRIMARY KEY,           -- z.B. "kunde-gmbh"
    name TEXT NOT NULL,
    company TEXT,
    street TEXT,
    house_number TEXT,
    postal_code TEXT,
    city TEXT,
    country TEXT DEFAULT 'Deutschland',
    email TEXT,
    phone TEXT,
    tax_id TEXT,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Projekte
CREATE TABLE projects (
    id TEXT PRIMARY KEY,           -- z.B. "website-relaunch"
    client_id TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'active',  -- active, completed, archived
    hourly_rate DECIMAL(10,2),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(id)
);

-- Dokument-Index (Metadaten, nicht der Inhalt)
CREATE TABLE documents (
    id TEXT PRIMARY KEY,           -- z.B. "RE-2025-001"
    type TEXT NOT NULL,            -- invoice, offer, credentials, concept
    client_id TEXT,
    project_id TEXT,
    file_path TEXT NOT NULL,       -- Pfad zur JSON-Datei
    status TEXT DEFAULT 'draft',   -- draft, sent, paid, cancelled
    total_amount DECIMAL(10,2),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    due_date DATE,
    paid_date DATE,
    FOREIGN KEY (client_id) REFERENCES clients(id),
    FOREIGN KEY (project_id) REFERENCES projects(id)
);

-- Zeiterfassung (optional)
CREATE TABLE time_entries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id TEXT NOT NULL,
    date DATE NOT NULL,
    hours DECIMAL(4,2) NOT NULL,
    description TEXT,
    invoiced BOOLEAN DEFAULT FALSE,
    invoice_id TEXT,
    FOREIGN KEY (project_id) REFERENCES projects(id),
    FOREIGN KEY (invoice_id) REFERENCES documents(id)
);
```

### Workflow

**Neuen Kunden anlegen:**
```bash
docgen client add
# Interaktiv oder:
docgen client add --name "Kunde GmbH" --email "info@kunde.de"
```

**Neues Projekt:**
```bash
docgen project add "Website Relaunch" --client kunde-gmbh --rate 95
```

**Rechnung erstellen:**
```bash
docgen new invoice RE-2025-003 --client kunde-gmbh --project website-relaunch
# → Erstellt JSON mit vorausgefüllten Kundendaten
# → Trägt in documents-Tabelle ein
```

**Abfragen:**
```bash
docgen client list
docgen invoices --client kunde-gmbh
docgen invoices --unpaid
docgen stats --year 2025
```

### JSON-Format (vereinfacht)

Mit der Datenbank werden Dokument-JSONs schlanker:

```json
// Vorher (ohne DB)
{
  "metadata": { ... },
  "recipient": {
    "name": "Max Mustermann",
    "company": "Kunde GmbH",
    "address": { "street": "...", ... }
  },
  "items": [ ... ],
  "totals": { ... }
}

// Nachher (mit DB)
{
  "metadata": {
    "invoice_number": "RE-2025-003",
    "invoice_date": "21.01.2025",
    "due_date": "04.02.2025"
  },
  "client_id": "kunde-gmbh",      // Referenz!
  "project_id": "website-relaunch",
  "items": [ ... ],
  "totals": { ... }
}
```

Beim Kompilieren löst das CLI die Referenzen auf:
```bash
docgen compile invoices/RE-2025-003.json
# → Lädt Kundendaten aus DB
# → Merged mit JSON
# → Kompiliert Template
```

## Alternative: Reine JSON-Lösung

Falls SQLite zu komplex erscheint:

```
data/
├── company.json
├── clients.json        # Array aller Kunden
└── projects.json       # Array aller Projekte
```

```json
// clients.json
[
  {
    "id": "kunde-gmbh",
    "name": "Kunde GmbH",
    "address": { ... }
  }
]
```

**Vorteile:**
- Alles in Git trackbar
- Einfach zu verstehen
- Kein DB-Setup

**Nachteile:**
- Keine echten Queries
- Merge-Konflikte bei paralleler Bearbeitung
- Wird bei vielen Einträgen unübersichtlich

## Empfehlung

**Phase 1 (jetzt):** JSON-Dateien für Clients/Projects
- Schnell implementierbar
- Gut für kleine Nutzerbasis

**Phase 2 (später):** SQLite Migration
- Wenn Queries wichtig werden
- Wenn Zeiterfassung dazukommt
- Migration-Script bereitstellen

## CLI-Erweiterungen

```rust
// Neue Befehle
Commands::Client { action: ClientAction },
Commands::Project { action: ProjectAction },
Commands::Stats { year: Option<i32> },

enum ClientAction {
    Add { name: String, ... },
    List,
    Show { id: String },
    Edit { id: String },
    Delete { id: String },
}
```

## Datei-Format Empfehlung

Für die reine JSON-Variante empfehle ich **YAML** als Alternative zu JSON:

```yaml
# clients/kunde-gmbh.yaml
id: kunde-gmbh
name: Kunde GmbH
contact:
  name: Max Mustermann
  email: max@kunde.de
address:
  street: Kundenstraße
  number: "42"
  postal_code: "12345"
  city: Kundenstadt
```

**Vorteile von YAML:**
- Besser lesbar
- Kommentare möglich
- Weniger Klammern/Anführungszeichen
- Multiline Strings einfach

**Rust:** `serde_yaml` crate

Aber: JSON ist universeller und die Schemas existieren bereits. Entscheidung nach Präferenz.

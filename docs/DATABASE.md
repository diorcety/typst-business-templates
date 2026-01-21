# Datenbank-Konzept

## Übersicht

docgen verwendet SQLite für die Verwaltung von Kunden, Projekten und Dokument-Metadaten.

**Datei:** `data/docgen.db`

## Warum SQLite?

| Anforderung | JSON-Datei | SQLite |
|-------------|------------|--------|
| Atomare Nummerierung | ❌ Race Conditions möglich | ✅ Transaktionen |
| Relationen | ❌ Manuell verwalten | ✅ Foreign Keys |
| Abfragen | ❌ Alle Dateien laden | ✅ SQL Queries |
| Konsistenz | ❌ Datei kann korrupt werden | ✅ ACID |
| Setup | ✅ Keine | ✅ Automatisch |
| Portabilität | ✅ Eine Datei | ✅ Eine Datei |

## Schema

### clients

```sql
CREATE TABLE clients (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    number INTEGER UNIQUE NOT NULL,        -- K-001, K-002, ...
    name TEXT NOT NULL,                    -- Ansprechpartner
    company TEXT,                          -- Firmenname
    street TEXT,
    house_number TEXT,
    postal_code TEXT,
    city TEXT,
    country TEXT DEFAULT 'Deutschland',
    email TEXT,
    phone TEXT,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
```

### projects

```sql
CREATE TABLE projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    number INTEGER NOT NULL,               -- Pro Kunde: 1, 2, 3, ...
    client_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    hourly_rate REAL,
    status TEXT DEFAULT 'active',          -- active, completed, archived
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(id),
    UNIQUE(client_id, number)              -- P-001-01, P-001-02, ...
);
```

### documents

```sql
CREATE TABLE documents (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    doc_type TEXT NOT NULL,                -- invoice, offer, credentials, concept
    doc_number TEXT UNIQUE NOT NULL,       -- RE-2025-001, AN-2025-002, ...
    client_id INTEGER,
    project_id INTEGER,
    file_path TEXT NOT NULL,               -- documents/invoices/RE-2025-001.json
    amount REAL,                           -- Betrag (für Rechnungen/Angebote)
    status TEXT DEFAULT 'draft',           -- draft, sent, paid, overdue, ...
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    due_date TEXT,
    FOREIGN KEY (client_id) REFERENCES clients(id),
    FOREIGN KEY (project_id) REFERENCES projects(id)
);
```

### counters

```sql
CREATE TABLE counters (
    name TEXT PRIMARY KEY,                 -- client, invoice, offer, ...
    value INTEGER NOT NULL DEFAULT 0
);
```

## Nummernformate

| Typ | Format | Beispiel |
|-----|--------|----------|
| Kunde | K-XXX | K-001, K-042 |
| Projekt | P-KKK-PP | P-001-01, P-042-03 |
| Rechnung | RE-YYYY-NNN | RE-2025-001 |
| Angebot | AN-YYYY-NNN | AN-2025-015 |
| Zugangsdaten | ZD-YYYY-NNN | ZD-2025-003 |
| Konzept | KO-YYYY-NNN | KO-2025-008 |

## Verwendung im CLI

### Datenbank automatisch erstellt

```bash
docgen  # Erstellt data/docgen.db falls nicht vorhanden
```

### Kunden

```bash
# Auflisten
docgen client list

# Hinzufügen (interaktiv)
docgen client add

# Hinzufügen (direkt)
docgen client add --name "Max Mustermann"

# Details anzeigen
docgen client show 1       # Nach ID
docgen client show K-001   # Nach Nummer
```

### Projekte

```bash
# Auflisten für Kunde
docgen project list K-001

# Hinzufügen
docgen project add K-001 "Website Relaunch"
```

### Dokumente

Im interaktiven Modus:
1. Kunde auswählen
2. Aktion wählen (Rechnung, Angebot, ...)
3. Optional: Projekt wählen
4. → JSON wird erstellt mit Kundendaten vorausgefüllt
5. → Nummer wird automatisch vergeben

## Datei-Struktur

```
project/
├── data/
│   ├── docgen.db          # SQLite Datenbank
│   └── company.json       # Eigene Firmendaten
├── documents/
│   ├── invoices/
│   │   └── RE-2025-001.json
│   ├── offers/
│   │   └── AN-2025-001.json
│   ├── credentials/
│   └── concepts/
└── output/
    └── *.pdf
```

## Backup

```bash
# Einfach die Datei kopieren
cp data/docgen.db data/docgen.db.backup

# Oder mit SQLite
sqlite3 data/docgen.db ".backup data/backup.db"
```

## Migration

Falls du von der alten JSON-Struktur migrieren willst:

```bash
# Kommt in einer späteren Version
docgen migrate --from-json
```

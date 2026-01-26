# Simplification Plan: Unix-Tool Philosophy

## Vision

**docgen = PDF-Generator, nicht mehr, nicht weniger**

Analogie zu anderen Unix-Tools:
- `pandoc` - Document converter (keine Datenbank, keine UI)
- `imagemagick` - Image processor (keine Verwaltung, nur Transformation)
- `ffmpeg` - Video processor (kein Tracking, nur Conversion)

docgen sollte sein:
- `docgen compile invoice.json → PDF` ✅
- Kein Client-Management ❌
- Keine Projektverwaltung ❌
- Keine Status-Datenbank ❌

---

## Current State Analysis

### Was macht SQLite aktuell?

**1. Client Management (clients table)**
```sql
CREATE TABLE clients (
  id, number, name, company, street, house_number,
  postal_code, city, country, email, phone, notes
)
```
**Genutzt von:**
- `docgen client list/add/show`
- Interactive UI (Mandanten-Auswahl)
- Nummerierung (K-001, K-002, ...)

**2. Project Management (projects table)**
```sql
CREATE TABLE projects (
  id, number, client_id, name, description,
  hourly_rate, status
)
```
**Genutzt von:**
- `docgen project list/add`
- Interactive UI (Projekt-Auswahl)
- Nummerierung (P-001-01, P-001-02, ...)

**3. Document Tracking (documents table)**
```sql
CREATE TABLE documents (
  id, doc_type, doc_number, client_id, project_id,
  file_path, amount, status, due_date
)
```
**Genutzt von:**
- NIE! Wird nur befüllt, aber nicht abgefragt
- Interactive UI zeigt nur "last 10 documents" aus Dateisystem

**4. Counters (counters table)**
```sql
CREATE TABLE counters (
  name, value  -- client, invoice, offer, credentials, concept
)
```
**Genutzt von:**
- Auto-Increment für Client-Nummern
- Auto-Increment für Dokument-Nummern (RE-2026-001)

---

## Problems with Current Database

1. **Dual Source of Truth**
   - Clients in `data/docgen.db` UND in `documents/invoices/*/invoice.json`
   - Wenn JSON Client-Name ändert → DB veraltet
   - Keine Synchronisation

2. **Database = Optional Feature**
   - User kann `docgen compile` ohne DB nutzen
   - DB nur für `docgen client` Commands gebraucht
   - 80% der User nutzen es nie

3. **Interactive UI Complexity**
   - 696 Zeilen Code nur für Terminal-UI
   - Abhängig von DB
   - Keine Tests

4. **Migration Issues**
   - User wechselt Rechner → DB fehlt
   - Git kann SQLite-Binaries schlecht tracken
   - Merge-Konflikte bei DB nicht lösbar

---

## Simplification Strategy

### Phase 1: Database → JSON Files (v0.6.0)

**Replace SQLite with simple JSON files:**

```
data/
├── clients.json          # All clients (replaces clients table)
├── projects.json         # All projects (replaces projects table)
└── counters.json         # Auto-increment counters
```

**Benefits:**
- ✅ Git-friendly (diffable, mergeable)
- ✅ Human-readable
- ✅ No schema migrations
- ✅ Works across machines
- ✅ Easy backup (just copy files)

**Implementation:**

```rust
// data/clients.json
[
  {
    "id": 1,
    "number": 1,
    "name": "Max Mustermann",
    "company": "Mustermann GmbH",
    "address": {
      "street": "Hauptstraße",
      "house_number": "1",
      "postal_code": "12345",
      "city": "Berlin",
      "country": "Deutschland"
    },
    "contact": {
      "email": "max@example.com",
      "phone": "+49 30 12345678"
    },
    "notes": "Stammkunde seit 2020",
    "created_at": "2025-01-15T10:30:00Z"
  }
]
```

```rust
// data/counters.json
{
  "client": 5,
  "invoice": 12,
  "offer": 8,
  "credentials": 3,
  "concept": 4
}
```

**Migration Path:**
```bash
# Export existing DB to JSON
docgen migrate db-to-json

# Creates:
# - data/clients.json (from clients table)
# - data/projects.json (from projects table)
# - data/counters.json (from counters table)
# - Deletes data/docgen.db

# User can commit to Git
git add data/*.json
git commit -m "Migrate from SQLite to JSON"
```

---

### Phase 2: Make Client/Project Management Optional (v0.6.0)

**Current:** Client commands are core features

**Simplified:** Client commands are OPTIONAL helpers

```bash
# Core workflow (NO database needed):
docgen compile invoice.json  → PDF

# Optional helper commands:
docgen client list           # Read from data/clients.json
docgen client add            # Append to data/clients.json
docgen project list K-001    # Read from data/projects.json
```

**If data/clients.json missing:**
```bash
docgen client list
→ Error: No clients found. Create data/clients.json manually or run:
  docgen client add
```

**Key principle:** Commands are convenience, NOT required for PDF generation

---

### Phase 3: Remove Interactive UI (v0.7.0)

**Current:** Interactive mode = 696 lines of UI code

**Simplified:** Remove completely or make optional feature

**Option A: Remove entirely**
```bash
# OLD:
docgen              # Interactive mode
→ [Terminal UI]

# NEW:
docgen              # Show help
→ Usage: docgen <command>
  compile <file>    Compile document to PDF
  build <dir>       Build all documents
  client list       List clients
  ...
```

**Option B: Make optional feature flag**
```toml
# Cargo.toml
[features]
default = []
interactive = ["dialoguer", "console", "comfy-table"]

# Build without interactive:
cargo build --release

# Build with interactive:
cargo build --release --features interactive
```

**Recommendation:** Option A (remove) - simplifies codebase, reduces dependencies

---

### Phase 4: Simplified Architecture (v0.7.0)

**Current structure:**
```
cli/src/
├── main.rs (1,384 lines) - Everything
├── db/ - SQLite abstraction
├── ui/ - Interactive mode
├── local_templates.rs
├── packages.rs (DEAD CODE)
├── encrypt.rs
├── locale.rs
└── embedded.rs
```

**Simplified structure:**
```
cli/src/
├── main.rs (150 lines) - Entry point
├── cli.rs (100 lines) - Clap definitions
├── commands/
│   ├── compile.rs (200 lines)
│   ├── build.rs (100 lines)
│   ├── watch.rs (150 lines)
│   ├── client.rs (150 lines) - OPTIONAL
│   ├── template.rs (100 lines)
│   └── init.rs (100 lines)
├── core/
│   ├── compiler.rs (150 lines) - Typst invocation
│   ├── templates.rs (200 lines) - Template management
│   ├── document.rs (150 lines) - Type detection
│   ├── config.rs (100 lines) - Config loading
│   ├── data.rs (150 lines) - JSON data management
│   └── counter.rs (100 lines) - Auto-increment
├── error.rs (150 lines) - Custom errors
└── tests/
    ├── integration/
    └── fixtures/
```

**Removed:**
- ❌ `db/` (304 lines) - Replaced by `core/data.rs`
- ❌ `ui/` (696 lines) - Interactive mode removed
- ❌ `packages.rs` (304 lines) - Already dead code

**Added:**
- ✅ `tests/` - Integration tests
- ✅ `core/` - Business logic separated

**Total reduction:** ~2,000 → ~1,300 lines (-35%)

---

## Implementation Roadmap

### v0.6.0 - "Database Removal" (2-3 weeks)

**Week 1: JSON Data Layer**
```
[x] Create core/data.rs
    - ClientStore (read/write data/clients.json)
    - ProjectStore (read/write data/projects.json)
    - CounterStore (read/write data/counters.json)
[x] Create core/counter.rs
    - next_number(type) → increment & return
[x] Write migration tool
    - docgen migrate db-to-json
    - Exports SQLite → JSON files
[x] Update client commands
    - Use ClientStore instead of Database
[x] Update project commands
    - Use ProjectStore instead of Database
```

**Week 2: Remove SQLite**
```
[x] Remove db/ directory
[x] Remove rusqlite dependency
[x] Update main.rs to use new stores
[x] Add JSON validation
[x] Test migration with examples/
```

**Week 3: Testing & Documentation**
```
[x] Add integration tests
[x] Update README (no more database)
[x] Update AI guide
[x] Migration guide for users
```

**Release:** v0.6.0 - "JSON-based, no SQLite"

---

### v0.7.0 - "Interactive UI Removal" (1-2 weeks)

**Week 1: Remove UI**
```
[x] Remove ui/ directory
[x] Remove dialoguer, console, comfy-table dependencies
[x] docgen without args → show help (not UI)
[x] Update README
```

**Week 2: Refactoring**
```
[x] Split main.rs into modules
[x] commands/ directory structure
[x] core/ business logic
[x] Add 40+ integration tests
```

**Release:** v0.7.0 - "CLI-only, modular"

---

### v0.8.0 - "Production Quality" (2-3 weeks)

**Focus: Code Quality**
```
[x] Remove packages.rs dead code
[x] Custom error types (no anyhow)
[x] Config validation
[x] Document validation
[x] 60%+ test coverage
```

**Release:** v0.8.0 - "Stable, tested, simple"

---

## JSON Data Format Specification

### data/clients.json

```json
[
  {
    "id": 1,
    "number": 1,
    "name": "Max Mustermann",
    "company": "Mustermann GmbH",
    "address": {
      "street": "Hauptstraße",
      "house_number": "1",
      "postal_code": "12345",
      "city": "Berlin",
      "country": "Deutschland"
    },
    "contact": {
      "email": "max@example.com",
      "phone": "+49 30 12345678"
    },
    "notes": "Stammkunde seit 2020",
    "created_at": "2025-01-15T10:30:00Z"
  }
]
```

### data/projects.json

```json
[
  {
    "id": 1,
    "number": 1,
    "client_id": 1,
    "client_number": 1,
    "name": "Website Relaunch",
    "description": "Kompletter Relaunch der Firmenwebsite",
    "hourly_rate": 95.00,
    "status": "active",
    "created_at": "2025-01-20T14:00:00Z"
  }
]
```

### data/counters.json

```json
{
  "client": 5,
  "invoice": 12,
  "offer": 8,
  "credentials": 3,
  "concept": 4,
  "documentation": 2
}
```

**Atomicity:** Use file locking (flock) for concurrent writes

---

## Benefits of Simplification

### Developer Benefits
- ✅ **1,300 lines** instead of 2,000 (-35%)
- ✅ **No SQLite migrations** - just JSON
- ✅ **Easier testing** - mock JSON files
- ✅ **Clearer separation** - core/ vs commands/
- ✅ **Fewer dependencies** - no rusqlite, dialoguer, console, comfy-table

### User Benefits
- ✅ **Git-friendly** - diff/merge clients.json
- ✅ **Portable** - copy data/ folder
- ✅ **Readable** - inspect clients.json directly
- ✅ **Simple backup** - just JSON files
- ✅ **No DB corruption** - JSON always recoverable

### Unix Philosophy
- ✅ **Do one thing well** - PDF generation
- ✅ **Plain text** - JSON instead of binary DB
- ✅ **Composable** - works with jq, grep, etc.
- ✅ **Simple** - no hidden state

---

## Migration Guide for Users

### Automatic Migration (v0.6.0)

```bash
# Update to v0.6.0
brew upgrade docgen

# Run migration (one-time)
cd my-project
docgen migrate db-to-json

→ Migrating database to JSON...
  ✓ Exported 5 clients to data/clients.json
  ✓ Exported 12 projects to data/projects.json
  ✓ Exported counters to data/counters.json
  ✓ Backed up data/docgen.db → data/docgen.db.backup
  
→ Migration complete! 
  - Review JSON files: ls -la data/
  - Commit to Git: git add data/*.json
  - Old DB backed up at: data/docgen.db.backup
```

### Manual Migration

If automatic migration fails:

```bash
# 1. Export from old version
docgen-0.5.2 client list > clients.txt

# 2. Create JSON manually
cat > data/clients.json << 'EOF'
[
  {
    "id": 1,
    "number": 1,
    "name": "Client Name",
    ...
  }
]
EOF

# 3. Initialize counters
cat > data/counters.json << 'EOF'
{
  "client": 5,
  "invoice": 12,
  "offer": 8
}
EOF
```

---

## API Changes (Breaking)

### v0.5.x → v0.6.0

**Removed:**
- `data/docgen.db` (SQLite file)
- Interactive mode UI (696 lines)

**Added:**
- `data/clients.json`
- `data/projects.json`
- `data/counters.json`

**Commands unchanged:**
```bash
docgen client list       # Still works, reads JSON
docgen project list      # Still works, reads JSON
docgen compile file.json # Unchanged
```

**Migration required:** One-time `docgen migrate db-to-json`

---

## Testing Strategy

### Unit Tests

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_client_store_read_write() {
        let store = ClientStore::new("tests/fixtures/clients.json");
        let clients = store.list().unwrap();
        assert_eq!(clients.len(), 3);
    }

    #[test]
    fn test_counter_increment() {
        let mut counter = CounterStore::new("tests/fixtures/counters.json");
        assert_eq!(counter.next("invoice").unwrap(), 1);
        assert_eq!(counter.next("invoice").unwrap(), 2);
    }
}
```

### Integration Tests

```rust
#[test]
fn test_client_add_and_list() {
    let tmp = setup_test_project();
    
    run_docgen(&["client", "add"])
        .input("Test Client\ntest@example.com\n...");
    
    let output = run_docgen(&["client", "list"]);
    assert!(output.contains("Test Client"));
}
```

---

## Open Questions

1. **Concurrent writes:** Use file locking (flock)? Or atomic rename?
2. **Large datasets:** 1000+ clients - still JSON or warn user?
3. **Backward compat:** Keep docgen.db reader for one version?
4. **Interactive mode:** Remove immediately or deprecate first?

---

## Decision Log

| Decision | Rationale |
|----------|-----------|
| JSON instead of SQLite | Git-friendly, human-readable, portable |
| Remove interactive UI | Simplifies, reduces deps, Unix-style |
| Keep client commands | Convenience helpers, optional |
| File locking for writes | Prevent race conditions |
| Atomic counters | File lock + read-modify-write |

---

**Next Steps:**
1. Get approval on this plan
2. Create v0.6.0 milestone
3. Implement JSON data layer
4. Write migration tool
5. Add tests
6. Release v0.6.0

**Estimated Effort:** 2-3 weeks full-time

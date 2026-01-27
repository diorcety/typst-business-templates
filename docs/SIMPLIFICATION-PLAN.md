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

### Phase 1: Database → JSON Files ✅ COMPLETED (v0.6.0)

**Replaced SQLite with simple JSON files:**

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

**Implementation Status:**
- ✅ Created `cli/src/data/mod.rs` - ClientStore, ProjectStore, CounterStore (400 lines)
- ✅ Created `cli/src/data/models.rs` - Data models (120 lines)
- ✅ Removed `cli/src/db/` - SQLite wrapper (497 lines removed)
- ✅ Removed rusqlite dependency
- ✅ Updated all commands to use JSON stores
- ✅ Integration tests: 11 test cases passing

**Migration:** No migration tool needed - v0.6.0 had no production users.

---

### Phase 2: Remove Interactive UI ✅ COMPLETED (v0.6.0)

**Old Behavior:**
```bash
docgen  # → Opens interactive terminal UI (696 lines of code)
```

**New Behavior:**
```bash
docgen  # → Shows help text
docgen client add  # → Error: --name required
docgen client add --name "Acme Corp"  # → ✓ K-001 angelegt
```

**Implementation Status:**
- ✅ Removed `cli/src/ui/` - Interactive TUI (696 lines removed)
- ✅ Removed dialoguer, console, comfy-table dependencies (3 deps)
- ✅ Changed `docgen` with no args to show help
- ✅ All commands require explicit parameters
- ✅ Simpler, script-friendly CLI

---

### Phase 3: Remove Dead Code ✅ COMPLETED (v0.6.0)

**Found and removed:**
- ✅ `cli/src/packages.rs` - Global package management (304 lines removed, never called)
- ✅ lopdf dependency (never used, 2 deps removed)
- ✅ Simplified `cli/src/embedded.rs` (removed unused template constants)
- ✅ Simplified `cli/src/encrypt.rs` (removed dialoguer dependency)

**Total reduction:**
- Code: -1,497 lines
- Dependencies: 15 → 10 (5 removed)
- Binary size: ~20% smaller

---

Client/project commands are kept as OPTIONAL helpers:
- Core workflow: `docgen compile invoice.json` (no data files needed)
- Helper commands: `docgen client add/list/show` (uses data/clients.json)
- Helper commands: `docgen project add/list` (uses data/projects.json)

**Key principle:** Commands are convenience, NOT required for PDF generation.

---

### Phase 5: Future Architecture Improvements (v0.7.0+)

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

**Week 2: Remove SQLite** ✅ COMPLETED
```
✅ Remove db/ directory (497 lines)
✅ Remove rusqlite dependency
✅ Update main.rs to use new stores
✅ Created ClientStore, ProjectStore, CounterStore
```

**Week 3: Remove UI & Dead Code** ✅ COMPLETED
```
✅ Remove ui/ directory (696 lines)
✅ Remove packages.rs (304 lines)
✅ Remove dialoguer, console, comfy-table dependencies (3 deps)
✅ Remove lopdf dependency (never used, 2 deps)
✅ docgen without args → show help
✅ All commands require explicit parameters
```

**Week 4: Testing & Documentation** ✅ COMPLETED
```
✅ Add integration tests (11 tests passing)
✅ Update README (no more database)
✅ Update CHANGELOG for v0.6.0
✅ Update SIMPLIFICATION-PLAN.md
```

**Release:** v0.6.0 - "JSON-based, Unix philosophy" ✅ COMPLETED

**Total Impact:**
- Removed: 1,497 lines of code
- Removed: 5 dependencies (15 → 10)
- Binary size: ~20% smaller
- Git-friendly: JSON instead of SQLite
- Script-friendly: No interactive prompts
- Test coverage: 11 integration tests

---

### v0.7.0 - "Future Improvements" (PLANNED)

**Focus: Code Quality & Architecture**
```
[ ] Split main.rs into modules (currently 1,000+ lines)
[ ] commands/ directory structure
[ ] core/ business logic separation
[ ] More integration tests (target: 30+ tests)
[ ] Better error messages
[ ] Edit/delete commands for clients/projects
```

**Optional Features to Consider:**
```
[ ] E-invoice support (ZUGFeRD/XRechnung)
[ ] Multi-language templates (EN, FR, ES)
[ ] Document status tracking (as optional JSON file)
[ ] Simple web UI (as separate binary, optional)
```

**Release:** v0.7.0 - "Mature, stable"

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

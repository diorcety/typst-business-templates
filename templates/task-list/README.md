# Task List / Aufgabenliste Template

Professionelles Template für Aufgabenlisten, Todo-Listen und Projektplanung.

## Features

- ✅ **Checklisten** mit Status-Tracking (Todo, In Progress, Done, Blocked)
- 📅 **Datum-basierte Aufgaben** mit Deadlines
- 🎯 **Prioritäten** (Hoch, Mittel, Niedrig)
- 📋 **Kategorien & Strukturierung** für bessere Organisation
- 🔗 **Abhängigkeiten** ("Abhängig von..." / "Wenn-Dann-Logik")
- 👤 **Zuweisungen** (Assignees)
- 🏷️ **Tags** für flexible Filterung
- 📝 **Subtasks** mit hierarchischer Struktur
- 📄 **Notizen-Bereich** für zusätzliche Informationen

## Verwendung

### Option 1: Typst File (.typ)

```typst
#import ".docgen/templates/task-list/default.typ": task-list

#task-list(
  title: "Meine Aufgabenliste",
  subtitle: "Sprint Planning Q1 2026",
  project: "Website Redesign",
  
  categories: (
    (
      name: "🎯 Hochpriorität",
      tasks: (
        (
          title: "User Authentication implementieren",
          description: "OAuth 2.0 Integration",
          status: "in-progress",
          priority: "high",
          due: "31.01.2026",
          assignee: "Max Mustermann",
          tags: ("backend", "security"),
          subtasks: (
            (title: "OAuth Provider konfigurieren", status: "done"),
            (title: "Login-Flow testen", status: "todo"),
          )
        ),
      )
    ),
  ),
  
  notes: [
    *Wichtige Hinweise:*
    - Alle High-Priority Tasks bis Ende Januar
    - Wöchentliches Standup jeden Montag
  ]
)[]
```

### Option 2: JSON Format

```bash
docgen compile task-list.json
```

**task-list.json:**
```json
{
  "title": "Projekt Aufgabenliste",
  "subtitle": "Sprint Planning Q1 2026",
  "project": "Website Redesign",
  "categories": [
    {
      "name": "🎯 Hochpriorität",
      "tasks": [
        {
          "title": "User Authentication implementieren",
          "description": "OAuth 2.0 Integration",
          "status": "in-progress",
          "priority": "high",
          "due": "31.01.2026",
          "assignee": "Max Mustermann",
          "tags": ["backend", "security"],
          "subtasks": [
            {"title": "OAuth Provider konfigurieren", "status": "done"},
            {"title": "Login-Flow testen", "status": "todo"}
          ]
        }
      ]
    }
  ]
}
```

## Task-Felder

| Feld | Typ | Beschreibung | Beispiel |
|------|-----|--------------|----------|
| `title` | String | Aufgabentitel (Pflicht) | `"API implementieren"` |
| `description` | String | Detaillierte Beschreibung | `"REST API mit OAuth 2.0"` |
| `status` | String | Status der Aufgabe | `"todo"`, `"in-progress"`, `"done"`, `"blocked"` |
| `priority` | String | Priorität | `"high"`, `"medium"`, `"low"` |
| `due` | String | Fälligkeitsdatum | `"31.01.2026"` |
| `assignee` | String | Verantwortliche Person | `"Max Mustermann"` |
| `tags` | Array | Tags für Kategorisierung | `["backend", "security"]` |
| `depends-on` | String | Abhängigkeit | `"OAuth Provider Setup"` |
| `condition` | String | Wenn-Dann-Bedingung | `"Budget freigegeben"` |
| `subtasks` | Array | Unteraufgaben | Siehe Beispiel oben |

## Status-Werte

| Status | Icon | Farbe | Bedeutung |
|--------|------|-------|-----------|
| `todo` | ☐ | Grau | Noch nicht begonnen |
| `in-progress` | ◐ | Orange | In Bearbeitung |
| `done` | ✓ | Grün | Abgeschlossen |
| `blocked` | ⊘ | Rot | Blockiert/Wartend |

## Prioritäten

| Priorität | Badge-Farbe | Verwendung |
|-----------|-------------|------------|
| `high` / `hoch` | Rot | Kritische, dringende Aufgaben |
| `medium` / `mittel` | Orange | Normale Aufgaben |
| `low` / `niedrig` | Grün | Niedrige Priorität |

## Kategorien

Kategorien helfen bei der Strukturierung großer Aufgabenlisten:

```typst
categories: (
  (
    name: "🏠 Privat",
    description: "Private Aufgaben und Termine",
    tasks: (...)
  ),
  (
    name: "💼 Arbeit",
    tasks: (...)
  ),
)
```

## Abhängigkeiten & Bedingungen

**Abhängigkeiten** (`depends-on`):
```json
{
  "title": "Unit Tests schreiben",
  "depends-on": "API Implementation fertig"
}
```

**Wenn-Dann-Bedingungen** (`condition`):
```json
{
  "title": "Website deployen",
  "condition": "Alle Tests müssen grün sein"
}
```

## Notizen-Bereich

Zusätzliche Informationen am Ende der Liste:

```typst
notes: [
  = Wichtige Hinweise
  
  *Sprint Termine:*
  - Sprint Review: 14.02.2026
  - Retrospektive: 15.02.2026
  
  *Abhängigkeiten:*
  - Database Migration blockiert Backend-Tasks
]
```

## Beispiele

Siehe:
- `example.typ` - Einfaches Typst-Beispiel
- `cli/templates/task-list.json` - Umfangreiches JSON-Beispiel

## Anwendungsfälle

- 📋 **Projektplanung** - Sprint Planning, Roadmaps
- ✅ **Persönliche Todos** - Tägliche/Wöchentliche Aufgaben
- 🎯 **Team-Tasks** - Aufgabenverteilung im Team
- 📊 **Meeting Action Items** - Follow-ups nach Meetings
- 🚀 **Release Checklists** - Deployment-Schritte
- 📝 **Onboarding-Prozesse** - Schritt-für-Schritt Anleitungen

## Tipps

1. **Emojis nutzen** für visuelle Kategorisierung (🎯 🏠 💼 📝 etc.)
2. **Subtasks** für komplexe Aufgaben in kleinere Schritte aufteilen
3. **Tags** konsistent verwenden für einfaches Filtern
4. **Prioritäten** sparsam einsetzen (nicht alles ist "high")
5. **Deadlines** realistisch setzen
6. **Abhängigkeiten** dokumentieren für bessere Planung

## Customization

Template forken und anpassen:

```bash
docgen template fork task-list --name my-task-list
```

Dann in `templates/my-task-list/default.typ` anpassen:
- Farben ändern
- Eigene Icons/Symbole
- Layout anpassen
- Zusätzliche Felder

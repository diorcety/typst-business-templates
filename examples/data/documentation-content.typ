= Übersicht

Diese Dokumentation beschreibt die REST API der Mustermann Platform Version 1.0. Die API ermöglicht die Integration externer Systeme und bietet Zugriff auf alle Kernfunktionen.

*Basis-URL:* `https://api.example.com/v1`

*Formate:* JSON (Content-Type: application/json)

= Authentifizierung

Alle API-Anfragen erfordern einen gültigen API-Schlüssel. Dieser wird im Header `X-API-Key` übergeben:

```bash
curl -H "X-API-Key: your-api-key" https://api.example.com/v1/projects
```

== API-Schlüssel anfordern

API-Schlüssel können über das Dashboard unter _Einstellungen → API_ erstellt werden. Jeder Schlüssel hat ein konfigurierbares Berechtigungsprofil.

#table(
  columns: (auto, 1fr),
  align: (left, left),
  [*Schlüsseltyp*], [*Beschreibung*],
  [Read-Only], [Nur lesender Zugriff auf alle Ressourcen],
  [Standard], [Lesen und Schreiben von Projekten und Dokumenten],
  [Admin], [Vollzugriff inkl. Benutzerverwaltung],
)

= Endpunkte

== Projekte

=== GET /v1/projects

Listet alle Projekte auf.

*Parameter:*
- `status` (optional): Filter nach Status (`active`, `archived`, `draft`)
- `page` (optional): Seitennummer (Standard: 1)
- `limit` (optional): Anzahl Ergebnisse pro Seite (Standard: 50, Max: 100)

*Beispiel-Anfrage:*
```bash
curl -H "X-API-Key: your-api-key" \
  "https://api.example.com/v1/projects?status=active&limit=10"
```

*Antwort:*
```json
{
  "data": [
    {
      "id": "proj_123",
      "name": "Website Relaunch",
      "status": "active",
      "created_at": "2025-01-15T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 42
  }
}
```

=== POST /v1/projects

Erstellt ein neues Projekt.

*Request Body:*
```json
{
  "name": "Neues Projekt",
  "description": "Projektbeschreibung",
  "client_id": "client_456",
  "status": "draft"
}
```

*Antwort (201 Created):*
```json
{
  "id": "proj_789",
  "name": "Neues Projekt",
  "status": "draft",
  "created_at": "2025-01-22T14:30:00Z"
}
```

=== GET /v1/projects/{id}

Ruft ein einzelnes Projekt ab.

*Antwort:*
```json
{
  "id": "proj_123",
  "name": "Website Relaunch",
  "description": "Kompletter Relaunch der Unternehmenswebsite",
  "status": "active",
  "client": {
    "id": "client_456",
    "name": "Beispiel GmbH"
  },
  "created_at": "2025-01-15T10:00:00Z",
  "updated_at": "2025-01-20T16:45:00Z"
}
```

== Dokumente

=== GET /v1/documents

Listet alle Dokumente auf.

*Parameter:*
- `project_id` (optional): Filter nach Projekt
- `type` (optional): Filter nach Typ (`invoice`, `offer`, `concept`, `documentation`)
- `from_date` (optional): Von-Datum (ISO 8601)
- `to_date` (optional): Bis-Datum (ISO 8601)

=== POST /v1/documents

Erstellt ein neues Dokument.

*Request Body:*
```json
{
  "project_id": "proj_123",
  "type": "invoice",
  "title": "Rechnung Januar 2025",
  "data": {
    "items": [...],
    "totals": {...}
  }
}
```

= Fehlerbehandlung

Die API verwendet Standard-HTTP-Statuscodes:

#table(
  columns: (auto, 1fr),
  align: (left, left),
  [*Code*], [*Bedeutung*],
  [200 OK], [Erfolgreiche Anfrage],
  [201 Created], [Ressource erfolgreich erstellt],
  [400 Bad Request], [Ungültige Anfrage (z.B. fehlende Pflichtfelder)],
  [401 Unauthorized], [Fehlende oder ungültige Authentifizierung],
  [403 Forbidden], [Keine Berechtigung für diese Ressource],
  [404 Not Found], [Ressource nicht gefunden],
  [422 Unprocessable Entity], [Validierungsfehler],
  [429 Too Many Requests], [Rate Limit überschritten],
  [500 Internal Server Error], [Serverfehler],
)

*Fehlerantwort-Format:*
```json
{
  "error": {
    "code": "validation_error",
    "message": "Das Feld 'name' ist erforderlich",
    "details": [
      {
        "field": "name",
        "reason": "required",
        "message": "Dieses Feld ist erforderlich"
      }
    ]
  }
}
```

= Rate Limiting

Die API ist auf *1000 Anfragen pro Stunde* begrenzt. Der aktuelle Status wird in den Response-Headern zurückgegeben:

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 847
X-RateLimit-Reset: 1642694400
```

Bei Überschreitung des Limits wird ein `429 Too Many Requests` zurückgegeben. Die Antwort enthält einen `Retry-After` Header mit der Wartezeit in Sekunden.

= Webhooks

Die API unterstützt Webhooks für Echtzeit-Benachrichtigungen bei Änderungen.

== Webhook einrichten

```bash
curl -X POST \
  -H "X-API-Key: your-api-key" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://your-server.com/webhook",
    "events": ["project.created", "document.updated"],
    "secret": "your-webhook-secret"
  }' \
  https://api.example.com/v1/webhooks
```

== Verfügbare Events

- `project.created` - Neues Projekt erstellt
- `project.updated` - Projekt aktualisiert
- `project.deleted` - Projekt gelöscht
- `document.created` - Neues Dokument erstellt
- `document.updated` - Dokument aktualisiert
- `document.deleted` - Dokument gelöscht

== Webhook-Payload

```json
{
  "event": "project.created",
  "timestamp": "2025-01-22T14:30:00Z",
  "data": {
    "id": "proj_789",
    "name": "Neues Projekt",
    "status": "draft"
  }
}
```

= Changelog

== Version 1.0 (22.01.2025)
- Initiale API-Version
- Projekte: CRUD-Operationen
- Dokumente: CRUD-Operationen
- Authentifizierung via API-Key
- Rate Limiting (1000 req/h)
- Webhook-Support

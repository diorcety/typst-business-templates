# Bug: Inkonsistente Logo-Pfad-Behandlung in Templates

## Problem

Die Templates behandeln den Logo-Pfad aus `company.json` unterschiedlich:

- **Invoice/Offer**: Fügt `/data/` vor den Pfad hinzu
  ```typ
  #image("/data/" + company.logo, width: 150pt)
  ```

- **Credentials**: Verwendet den Pfad direkt mit `/`
  ```typ
  image("/" + c.logo, width: logo-width)
  ```

Das führt dazu, dass kein einheitlicher Logo-Pfad in `company.json` funktioniert.

## Betroffene Version

- docgen 0.4.4

## Reproduzieren

Mit `company.json`:
```json
{
  "logo": "logo.png"
}
```

- Invoice: Sucht `/data/logo.png` ✓
- Credentials: Sucht `/logo.png` ✗

Mit `company.json`:
```json
{
  "logo": "data/logo.png"
}
```

- Invoice: Sucht `/data/data/logo.png` ✗
- Credentials: Sucht `/data/logo.png` ✓

## Erwartetes Verhalten

Alle Templates sollten den Logo-Pfad einheitlich behandeln. Empfehlung:

1. Logo-Pfad relativ zum Projekt-Root (ohne `/data/` Prefix im Template)
2. `company.json` enthält: `"logo": "data/logo.png"`
3. Template verwendet: `image("/" + company.logo)`

## Betroffene Dateien

- `templates/invoice/default.typ`
- `templates/offer/default.typ`
- `templates/credentials/default.typ`
- Evtl. weitere Templates

# Bug: Invoice Footer zu hoch positioniert

## Problem

Der Footer in Rechnungen (invoice template) ist zu hoch positioniert und lässt zu viel Abstand zum unteren Seitenrand.

## Betroffene Version

- docgen 0.4.3
- Template: `templates/invoice/default.typ`

## Reproduzieren

```bash
docgen compile documents/invoices/2026/RE260002.json
```

## Erwartetes Verhalten

Der Footer sollte näher am unteren Seitenrand positioniert sein, ähnlich wie bei professionellen Geschäftsdokumenten üblich.

## Aktuelles Verhalten

Der Footer erscheint mit zu großem Abstand zum unteren Seitenrand.

## Technischer Hinweis

Das Problem liegt vermutlich in der Footer-Definition im Invoice-Template. Die bottom-Margin oder die Footer-Höhe sollte angepasst werden.

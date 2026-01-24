# Bug: Invoice Footer zu hoch positioniert

## Problem

Der Footer in Rechnungen (invoice template) ist zu hoch positioniert im Vergleich zu anderen Dokumenttypen (z.B. credentials).

## Ursache

Unterschiedliche bottom-Margins in den Templates:

- **Invoice**: bottom: 122pt (ca. 4.3cm)
- **Credentials**: bottom: 2.5cm (ca. 71pt)

Der Invoice-Footer hat einen 70% groesseren Abstand zum Seitenrand.

## Betroffene Version

- docgen 0.4.4
- Template: templates/invoice/default.typ

## Loesung

Den bottom-Margin im Invoice-Template reduzieren (z.B. auf 80pt) und den dy-Offset im Footer anpassen.

## Betroffene Dateien

- templates/invoice/default.typ
- templates/offer/default.typ (vermutlich gleicher Issue)

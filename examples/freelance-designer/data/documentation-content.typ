= Einleitung

Diese Brand Guidelines definieren die visuelle Identität von BrewBuddy. Sie dienen als verbindliche Grundlage für alle Kommunikationsmaßnahmen und stellen sicher, dass die Marke konsistent und wiedererkennbar auftritt.

== Über BrewBuddy

BrewBuddy ist eine Craft-Beer-App, die Bierliebhaber mit lokalen Brauereien verbindet. Die Marke steht für:

- *Gemeinschaft:* Bier verbindet Menschen
- *Entdeckung:* Neue Geschmackserlebnisse finden
- *Handwerk:* Wertschätzung für Craft Beer
- *Spaß:* Bier trinken soll Freude machen

= Logo

== Primäres Logo

Das BrewBuddy-Logo besteht aus einer Wortmarke mit integriertem Icon. Das Bierglas-Icon ersetzt den Buchstaben "u" im Wort "Buddy".

#block(
  fill: luma(95),
  inset: 20pt,
  radius: 8pt,
  width: 100%,
  align(center)[
    #text(size: 24pt, weight: "bold", fill: rgb("#2D3436"))[Brew#text(fill: rgb("#6C63FF"))[🍺]ddy]
  ]
)

== Schutzzone

Um das Logo herum muss ein Mindestabstand eingehalten werden. Die Schutzzone entspricht der Höhe des Buchstabens "B".

```
    ┌──────────────────────────┐
    │     ↕ Schutzzone         │
    │   ┌──────────────┐       │
    │ ← │  BrewBuddy   │ →     │
    │   └──────────────┘       │
    │     ↕ Schutzzone         │
    └──────────────────────────┘
```

== Mindestgrößen

- *Digital:* Mindestbreite 120 px
- *Print:* Mindestbreite 30 mm

== Don'ts

- Logo nicht strecken oder stauchen
- Farben nicht verändern
- Keine Effekte (Schatten, Glow) hinzufügen
- Logo nicht auf unruhigen Hintergründen platzieren
- Elemente nicht neu anordnen

= Farben

== Primärfarben

#table(
  columns: (1fr, 1fr, 1fr, 1fr),
  align: center,
  [*Farbe*], [*HEX*], [*RGB*], [*Verwendung*],
  [Purple], [\#6C63FF], [108, 99, 255], [Akzentfarbe, CTAs],
  [Dark], [\#2D3436], [45, 52, 54], [Text, Hintergründe],
  [White], [\#FFFFFF], [255, 255, 255], [Hintergründe, Text auf Dark],
)

== Sekundärfarben

#table(
  columns: (1fr, 1fr, 1fr, 1fr),
  align: center,
  [*Farbe*], [*HEX*], [*RGB*], [*Verwendung*],
  [Light Purple], [\#A29BFE], [162, 155, 254], [Hover-States, Icons],
  [Gray], [\#636E72], [99, 110, 114], [Sekundärer Text],
  [Light Gray], [\#F5F5F5], [245, 245, 245], [Hintergründe],
  [Success], [\#00B894], [0, 184, 148], [Erfolg, Bestätigung],
  [Warning], [\#FDCB6E], [253, 203, 110], [Warnungen],
  [Error], [\#E17055], [225, 112, 85], [Fehler],
)

== Farbverhältnisse

- *60%* Weiß/Light Gray (Hintergrund)
- *30%* Dark (Text, UI-Elemente)
- *10%* Purple (Akzente, CTAs)

= Typografie

== Schriftfamilie

*Poppins* ist die primäre Schriftart für alle Anwendungen.

#table(
  columns: (1fr, 1fr, 2fr),
  [*Schnitt*], [*Gewicht*], [*Verwendung*],
  [Bold], [700], [Headlines, CTAs],
  [SemiBold], [600], [Subheadlines, Navigation],
  [Medium], [500], [Buttons, Labels],
  [Regular], [400], [Fließtext, Body],
)

== Schriftgrößen (Digital)

#table(
  columns: (1fr, 1fr, 1fr),
  [*Element*], [*Größe*], [*Zeilenhöhe*],
  [H1], [32px], [40px],
  [H2], [24px], [32px],
  [H3], [20px], [28px],
  [Body], [16px], [24px],
  [Small], [14px], [20px],
  [Caption], [12px], [16px],
)

= Bildsprache

== Fotostil

- Authentisch, nicht gestellt
- Warme, einladende Atmosphäre
- Menschen in geselligen Situationen
- Nahaufnahmen von Craft Beer
- Natürliches Licht bevorzugen

== Dont's

- Keine übermäßig betrunkenen Personen
- Kein aggressiver Alkoholkonsum
- Keine Stock-Fotos mit gestellten Situationen
- Keine kalten, sterilen Umgebungen

= Anwendungsbeispiele

== Visitenkarte

- Format: 85 × 55 mm
- Vorderseite: Logo zentriert auf Dark-Hintergrund
- Rückseite: Kontaktdaten auf Weiß, Purple-Akzentlinie

== E-Mail-Signatur

```
Max Brauer
CEO & Co-Founder

BrewBuddy GmbH
Speicherstadt 12 | 20457 Hamburg
max\@brewbuddy.de | +49 40 123456
```

== Social Media

- Profilbild: Logo-Icon auf Purple-Hintergrund
- Header: Stimmungsbild mit Logo-Overlay
- Posts: Einheitlicher Rahmen mit Purple-Akzent

= Dateien & Ressourcen

Alle Design-Dateien sind verfügbar unter:

- *Figma:* figma.com/files/project/brewbuddy-cd
- *Google Drive:* Link in Zugangsdaten-Dokument

== Enthaltene Dateien

- Logo (SVG, PNG, EPS)
- Farbpalette (ASE, Sketch, Figma)
- Schriften (Google Fonts Link)
- Vorlagen (Visitenkarte, Briefpapier, Signatur)
- Social Media Templates

= Kontakt

Bei Fragen zur Anwendung der Brand Guidelines:

*Lisa Chen Design*\
hello\@lisachen.design\
+49 170 9876543

#block(
  fill: luma(240),
  inset: 10pt,
  radius: 4pt,
  [Diese Guidelines sind ein lebendes Dokument. Änderungen und Erweiterungen werden versioniert und kommuniziert.]
)

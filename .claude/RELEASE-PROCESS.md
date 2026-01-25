# Release Process für typst-business-templates

## Übersicht

Dieses Projekt wird über Homebrew verteilt. Es gibt zwei Repositories:
1. **Haupt-Repo**: `casoon/typst-business-templates` - Code und Templates
2. **Homebrew Tap**: `casoon/homebrew-tap` - Homebrew Formula

## Release-Schritte

### 1. Version vorbereiten

**Dateien aktualisieren:**
```bash
# cli/Cargo.toml
version = "0.4.x"

# CHANGELOG.md erstellen/aktualisieren
# Alle Änderungen dokumentieren
```

### 2. Code committen und taggen

```bash
cd /Users/jseidel/GitHub/typst-business-templates

# Alle Änderungen stagen
git add -A

# Commit mit ausführlicher Message
git commit -m "Release v0.4.x: [Beschreibung]

- Feature 1
- Feature 2
- Fix 1"

# Tag erstellen
git tag -a v0.4.x -m "Release v0.4.x: [Kurzbeschreibung]

Features:
- Feature 1
- Feature 2"

# Zu GitHub pushen
git push origin main
git push origin v0.4.x
```

### 3. Binary bauen

```bash
cd cli
cargo build --release

# Binary vorbereiten
cd ..
mkdir -p releases/v0.4.x
cp cli/target/release/docgen releases/v0.4.x/

# Tarball für macOS ARM64 erstellen
cd releases/v0.4.x
tar -czf docgen-aarch64-apple-darwin.tar.gz docgen

# Checksum berechnen
shasum -a 256 docgen-aarch64-apple-darwin.tar.gz
# Output kopieren für Formula!
```

### 4. GitHub Release erstellen

```bash
cd /Users/jseidel/GitHub/typst-business-templates

gh release create v0.4.x \
  --title "v0.4.x - [Titel]" \
  --notes "## What's New
  
[Release Notes hier einfügen]

### Installation
\`\`\`bash
brew tap casoon/tap
brew install docgen
\`\`\`" \
  releases/v0.4.x/docgen-aarch64-apple-darwin.tar.gz
```

### 5. Homebrew Formula aktualisieren

**WICHTIG: Es gibt zwei Formula-Dateien:**
- `Formula/docgen.rb` (im Haupt-Repo, nur zur Dokumentation)
- `/opt/homebrew/Library/Taps/casoon/homebrew-tap/Formula/docgen.rb` (die aktive Formula)

**Aktualisierung:**

```bash
# 1. Haupt-Repo Formula aktualisieren (optional, für Dokumentation)
vim Formula/docgen.rb

# Ändern:
version "0.4.x"

# macOS ARM64 checksum (vom tar-Schritt oben)
on_arm do
  url "https://github.com/casoon/typst-business-templates/releases/download/v#{version}/docgen-aarch64-apple-darwin.tar.gz"
  sha256 "[CHECKSUM_HIER]"
end

# Andere Plattformen auf Platzhalter setzen (wenn nicht gebaut)
sha256 "0000000000000000000000000000000000000000000000000000000000000000"

# 2. Committen im Haupt-Repo
git add Formula/docgen.rb
git commit -m "Update Formula checksums for v0.4.x"
git push origin main

# 3. WICHTIG: Formula ins homebrew-tap kopieren
cp Formula/docgen.rb /opt/homebrew/Library/Taps/casoon/homebrew-tap/Formula/docgen.rb

# 4. Im homebrew-tap committen und pushen
cd /opt/homebrew/Library/Taps/casoon/homebrew-tap
git add Formula/docgen.rb
git commit -m "Release v0.4.x: [Beschreibung]"
git push origin main
```

### 6. Installation testen

```bash
# Homebrew aktualisieren
brew update

# Installieren oder upgraden
brew install docgen
# oder
brew upgrade docgen

# Version prüfen
docgen --version
# Sollte zeigen: docgen 0.4.x

# Funktionalität testen
docgen --help
```

## Checkliste vor Release

- [ ] Version in `cli/Cargo.toml` aktualisiert
- [ ] `CHANGELOG.md` geschrieben
- [ ] Alle Tests laufen durch
- [ ] Code committed und getagged
- [ ] Binary gebaut und Checksum berechnet
- [ ] GitHub Release erstellt mit Binary
- [ ] Formula im Haupt-Repo aktualisiert
- [ ] Formula ins homebrew-tap kopiert
- [ ] homebrew-tap gepusht
- [ ] Installation über brew getestet
- [ ] Funktionalität getestet

## Troubleshooting

### "Warning: docgen X.X.X already installed"
```bash
brew uninstall docgen
brew install docgen
```

### "Tap remote mismatch"
Das Tap zeigt auf `casoon/homebrew-tap`, nicht auf `typst-business-templates`.
Das ist korrekt! Immer ins homebrew-tap pushen.

### Checksum stimmt nicht
```bash
# Neu berechnen
cd releases/v0.4.x
shasum -a 256 docgen-aarch64-apple-darwin.tar.gz
```

### Formula wird nicht aktualisiert
```bash
# Tap-Cache löschen
rm -rf $(brew --cache)/downloads/*docgen*

# Tap neu laden
brew untap casoon/tap
brew tap casoon/tap
```

## Repository-Struktur

```
typst-business-templates/
├── cli/                    # Rust CLI Code
├── templates/              # Typst Templates
├── Formula/docgen.rb       # Formula (Doku-Kopie)
└── releases/               # Build-Artefakte (nicht committen)

homebrew-tap/
└── Formula/docgen.rb       # Aktive Formula (hierhin pushen!)
```

## Wichtige Links

- Haupt-Repo: https://github.com/casoon/typst-business-templates
- Homebrew-Tap: https://github.com/casoon/homebrew-tap
- Releases: https://github.com/casoon/typst-business-templates/releases

## Versionsnummern

Format: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking Changes
- **MINOR**: Neue Features (backwards compatible)
- **PATCH**: Bug Fixes

Beispiele:
- 0.4.5 → 0.4.6: Neue Templates (Minor)
- 0.4.6 → 0.4.7: Bug Fixes (Patch)
- 0.4.7 → 0.5.0: Breaking Changes (Minor für 0.x)

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
cd /Users/jseidel/GitHub/typst-business-templates

# Binary bauen
cd cli
cargo build --release
cd ..

# Tarball erstellen (für alle macOS - funktioniert auf ARM und Intel via Rosetta)
tar -czf docgen-0.4.x-x86_64-apple-darwin.tar.gz -C cli/target/release docgen

# Checksum berechnen
shasum -a 256 docgen-0.4.x-x86_64-apple-darwin.tar.gz
# Output kopieren für Formula!

# WICHTIG: Auch tarball ohne Version erstellen für Homebrew
cp docgen-0.4.x-x86_64-apple-darwin.tar.gz docgen-x86_64-apple-darwin.tar.gz
```

### 4. GitHub Release erstellen

```bash
cd /Users/jseidel/GitHub/typst-business-templates

# Commits pushen
git push origin main

# GitHub Release mit BEIDEN Tarballs erstellen
gh release create v0.4.x \
  --title "v0.4.x - [Titel]" \
  --notes "## What's New
  
[Release Notes hier einfügen]

### Installation
\`\`\`bash
brew tap casoon/tap
brew install docgen
\`\`\`

**Full Changelog**: https://github.com/casoon/typst-business-templates/compare/v0.4.[x-1]...v0.4.x" \
  docgen-0.4.x-x86_64-apple-darwin.tar.gz

# WICHTIG: Auch tarball ohne Version hochladen (für Homebrew Formula)
gh release upload v0.4.x docgen-x86_64-apple-darwin.tar.gz
```

### 5. Homebrew Formula aktualisieren

**WICHTIG: Es gibt zwei Formula-Dateien:**
- `Formula/docgen.rb` (im Haupt-Repo, nur zur Dokumentation)
- `/opt/homebrew/Library/Taps/casoon/homebrew-tap/Formula/docgen.rb` (die aktive Formula)

**Aktualisierung:**

```bash
cd /Users/jseidel/GitHub/typst-business-templates

# 1. Haupt-Repo Formula aktualisieren
# Ändern in Formula/docgen.rb:
# - version "0.4.x"
# - sha256 "[CHECKSUM_VON_OBEN]" (in der on_macos Sektion)

# Beispiel:
# version "0.4.8"
# on_macos do
#   url "https://github.com/casoon/typst-business-templates/releases/download/v#{version}/docgen-x86_64-apple-darwin.tar.gz"
#   sha256 "5beb03e78e1f286c17d83f72bbba6d80cd18f6a9d7753540c61eefc958159e1a"
# end

# 2. Committen im Haupt-Repo
git add Formula/docgen.rb
git commit -m "Update Formula checksums for v0.4.x"
git push origin main

# 3. WICHTIG: Formula ins homebrew-tap kopieren
cp Formula/docgen.rb /opt/homebrew/Library/Taps/casoon/homebrew-tap/Formula/docgen.rb

# 4. Im homebrew-tap committen und pushen
cd /opt/homebrew/Library/Taps/casoon/homebrew-tap
git add Formula/docgen.rb
git commit -m "Update docgen to v0.4.x

- [Änderung 1]
- [Änderung 2]
"
git push origin main
```

### 6. Installation testen

```bash
# WICHTIG: Asset braucht ~30 Sekunden bis es verfügbar ist
# Bei 404-Fehlern kurz warten und nochmal versuchen

# Homebrew aktualisieren
brew update

# Upgraden
brew upgrade docgen

# Version prüfen
docgen --version
# Sollte zeigen: docgen 0.4.x

# Funktionalität testen
docgen --help

# Template-Kompilierung testen
cd examples/it-consultant/documents
docgen compile protocols/2025/protocol-001.json
docgen compile specifications/2025/specification-001.json
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

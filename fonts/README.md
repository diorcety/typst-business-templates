# Bundled Fonts

This directory contains font files for use with the Typst templates. All fonts are open source and freely distributable.

## Font Licenses

| Font | License | Copyright |
|------|---------|-----------|
| Inter | SIL Open Font License 1.1 | Copyright 2020 The Inter Project Authors |
| Roboto | Apache License 2.0 | Copyright 2011 Google Inc. |
| Roboto Mono | Apache License 2.0 | Copyright 2015 Google Inc. |
| Open Sans | SIL Open Font License 1.1 | Copyright 2020 The Open Sans Project Authors |
| Lato | SIL Open Font License 1.1 | Copyright 2010-2014 Lukasz Dziedzic |
| Montserrat | SIL Open Font License 1.1 | Copyright 2011 The Montserrat Project Authors |
| Source Sans 3 | SIL Open Font License 1.1 | Copyright 2010-2020 Adobe |
| Source Code Pro | SIL Open Font License 1.1 | Copyright 2010-2020 Adobe |
| Poppins | SIL Open Font License 1.1 | Copyright 2014-2019 Indian Type Foundry |
| Raleway | SIL Open Font License 1.1 | Copyright 2010 The Raleway Project Authors |
| Nunito | SIL Open Font License 1.1 | Copyright 2014 The Nunito Project Authors |
| Work Sans | SIL Open Font License 1.1 | Copyright 2015 The Work Sans Project Authors |
| JetBrains Mono | SIL Open Font License 1.1 | Copyright 2020 The JetBrains Mono Project Authors |
| Fira Code | SIL Open Font License 1.1 | Copyright 2014-2020 The Fira Code Project Authors |

## License Details

Each font directory contains a `LICENSE.txt` file with the full license text.

### SIL Open Font License 1.1 (OFL)

Most fonts use the SIL Open Font License, which permits:
- Free use in any project (personal and commercial)
- Modification and redistribution
- Bundling with software

Restrictions:
- Cannot sell the fonts by themselves
- Modified versions must use a different name
- Must include the license when redistributing

### Apache License 2.0

Roboto and Roboto Mono use the Apache License 2.0, which permits:
- Free use, modification, and distribution
- Commercial use
- Patent grant from contributors

## Usage

Use `--font-path fonts` when compiling with Typst:

```bash
typst compile --root . --font-path fonts template.typ output.pdf
```

## Sources

All fonts were downloaded from their official repositories:

- Inter: https://github.com/rsms/inter
- Roboto: https://github.com/googlefonts/roboto
- Roboto Mono: https://github.com/googlefonts/RobotoMono
- Open Sans: https://github.com/googlefonts/opensans
- Lato: https://github.com/googlefonts/latofonts
- Montserrat: https://github.com/JulietaUla/Montserrat
- Source Sans 3: https://github.com/adobe-fonts/source-sans
- Source Code Pro: https://github.com/adobe-fonts/source-code-pro
- Poppins: https://github.com/itfoundry/Poppins
- Raleway: https://github.com/googlefonts/raleway
- Nunito: https://github.com/googlefonts/nunito
- Work Sans: https://github.com/weiweihuanghuang/Work-Sans
- JetBrains Mono: https://github.com/JetBrains/JetBrainsMono
- Fira Code: https://github.com/tonsky/FiraCode

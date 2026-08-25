# Money Creation in the Modern Economy

A 40-minute briefing for policymakers and parliamentarians on how money creation actually works in the UK economy.

## 🎯 [View the Presentation](https://vg2000.github.io/money-presentation/money-creation-uk.html)

## Overview

This presentation explains:

1. **What money actually is** — 97% of UK money is commercial bank deposits, not physical cash
2. **How commercial banks create money** — through lending, not by intermediating deposits (debunking the "money multiplier" myth)
3. **How government spending works** — the Consolidated Fund mechanism and why spending is operationally money creation
4. **What taxation and debt issuance actually do** — taxation destroys money; debt issuance is a policy choice
5. **Real vs perceived constraints** — inflation and resources matter; "affordability" doesn't

## Key Sources

### Primary Academic Sources

- **Bank of England (2014)** — "[Money creation in the modern economy](https://www.bankofengland.co.uk/quarterly-bulletin/2014/q1/money-creation-in-the-modern-economy)", *Quarterly Bulletin Q1 2014*

- **Berkeley, Andrew and Ryan-Collins, Josh and Voldsgaard, Asker and Tye, Richard and Wilson, Neil (2024)** — "The Self-Financing State: An Institutional Analysis of Government Expenditure, Revenue Collection and Debt Issuance Operations in the United Kingdom", *Journal of Economic Issues*, 59(3), 852-880. Available at SSRN: https://ssrn.com/abstract=4890683 or http://dx.doi.org/10.2139/ssrn.4890683

### Key UK Legislation

- Exchequer and Audit Departments Act 1866
- Finance Act 1954, Section 34(3)
- National Loans Act 1968
- Bank of England Act 1998

## Running Locally

There is no build step and nothing to install. The deck is a single HTML file;
reveal.js and the Flourish charts load from CDN, so an internet connection is
needed the first time you open it.

### Option 1 — open the file directly

```bash
open money-creation-uk.html          # macOS
xdg-open money-creation-uk.html      # Linux
```

### Option 2 — serve over HTTP (recommended)

Some browsers restrict `file://` pages, which can block the embedded Flourish
charts and the system-map image. Serving the folder avoids this:

```bash
python3 -m http.server 8000
```

Then visit <http://localhost:8000/money-creation-uk.html>.

Any static server works equally well, for example `npx serve .` or
`php -S localhost:8000`.

## Using the Presentation

### Navigation

| Key | Action |
|-----|--------|
| `→` `↓` `Space` | Next slide |
| `←` `↑` | Previous slide |
| `S` | Speaker view (notes + timer) |
| `O` | Overview mode |
| `F` | Fullscreen |
| `Esc` | Exit fullscreen/overview |

### Speaker Notes

Press `S` to open the speaker view in a new window. This shows:
- Current slide
- Next slide preview
- Speaker notes
- Timer

### Export to PDF

Run the export script from the repository root:

```bash
./make-pdf.sh                              # writes money-creation-uk.pdf
./make-pdf.sh input.html output.pdf        # explicit input/output
```

This drives headless Google Chrome to produce a clean 16:9, one-slide-per-page
PDF with slide backgrounds intact. It requires Google Chrome and Node.js 18+.

To export by hand instead:

1. Open the presentation
2. Add `?print-pdf` to the URL (e.g., `money-creation-uk.html?print-pdf`)
3. Press `Ctrl/Cmd + P` to print
4. Select "Save as PDF"

## Repository Structure

```
money-presentation/
├── README.md                    # This file
├── LICENSE                      # MIT License
├── money-creation-uk.html       # The presentation
├── make-pdf.sh                  # Headless-Chrome PDF export
├── spending-accounting.md       # Table 1: Government spending transactions
├── taxation-accounting.md       # Table 2: Taxation transactions
├── glossary.md                  # Key terms and definitions
├── bibliography.md              # Full reference list
├── image/
│   └── system_map.png           # UK government financial architecture
└── government-borrowing-and-debt-since-1700-3125x1842.jpg
```

## Technical Details

Built with [reveal.js](https://revealjs.com/) — a modern HTML presentation framework.

- **No build step required** — just open the HTML file
- **No dependencies to install** — libraries load from CDN
- **Works offline** — after first load, browsers cache the CDN resources
- **Mobile-friendly** — supports touch gestures

## Contributing

Corrections, improvements, and translations welcome. Please open an issue or pull request.

## License

Content is provided under the [MIT License](LICENSE). Academic sources retain their original copyright.

## Acknowledgements

This presentation synthesises research from the Bank of England and academic economists studying UK public finance operations. Special thanks to the authors of "The Self-Financing State" for their detailed institutional analysis.

---

*"The Government's banking arrangements... ensure that all expenditure authorized by Parliament can be settled."*
— HM Treasury, FOI response 2020

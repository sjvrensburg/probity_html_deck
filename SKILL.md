---
name: probity-html-template
description: "Create branded Probity Data Analytics HTML (Reveal.js) slide decks with Quarto. Use this skill whenever the user wants to build, draft, or restyle a slide deck as an HTML presentation for Probity: client decks, internal reviews, conference talks, methodology walkthroughs, or any slide output carrying the Probity name. Triggers even when the user only says 'make a Probity HTML deck', 'turn this into web slides', 'use our Reveal.js template', or attaches notes to convert to slides. The skill wraps a Quarto format extension that renders Markdown to a navy/gold Probity-branded Reveal.js HTML deck."
---

# Probity Data Analytics Quarto HTML Slide Deck Template

This skill builds branded HTML (Reveal.js) decks for Probity Data Analytics
from a Quarto Markdown source. Branding (navy/gold palette, Calibri, logo
chrome, card patterns) lives in a Quarto extension at
`_extensions/probity-html/`. Write content in a `.qmd` file; Quarto renders a
styled HTML presentation.

This template is the HTML companion to `probity-pptx-template`. Use this one
when the output must run in a browser; use the PowerPoint template when the
client expects a `.pptx` file. Palette, voice, and content conventions are
identical between the two.

---

## When this skill triggers

Any HTML slide deck leaving the studio under the Probity name: client decks,
internal review decks, conference talks, methodology walkthroughs, board
updates. Triggers on "web slides", "HTML deck", "Reveal.js", "interactive
slides", "turn this into slides", or any request for Probity-branded slides
where the output format is not explicitly `.pptx`.

For PowerPoint output use `probity-pptx-template`. For Word, PDF, or memos use
the broader `probity-style` skill.

---

## Agent workflow

Follow these steps in order every time this skill fires.

### Step 1 — check installation

```bash
ls _extensions/probity-html/_extension.yml 2>/dev/null \
  && echo "installed" || echo "not installed"
```

If not installed, run from the `probity_html_deck` repo root:

```bash
bash /path/to/probity_html_deck/install.sh /path/to/working-project
```

If the deck will live in a **subdirectory** of the project (not beside
`_extensions/`), pass that subdirectory so the extension is placed next to it —
otherwise the render fails with `Unable to read the extension`:

```bash
bash /path/to/probity_html_deck/install.sh /path/to/working-project pipeline/docs
```

See **Subdirectory decks** under Common pitfalls for why.

Verify after installing:

```bash
ls _extensions/probity-html/
# must contain: _extension.yml  custom.scss  footer.html
#               logo_navy_small.png  logo_white.png  probity.lua
```

If `_quarto.yml` is absent the install script creates one. Do not add
`post-render` hooks — the HTML template needs none.

### Step 2 — plan slide structure

Before writing any source, map the incoming content to slide types (see
**Pattern decision guide** below). A typical 20-minute deck has 12–18 slides.
Plan the structure:

1. Title (from YAML front matter — not a slide you write)
2. One or more `#` section dividers, each grouping 2–5 content slides
3. `##` content slides — one clear claim per slide
4. Closing `# Thank you` or `# Questions` (heading-only, no body)

### Step 3 — write the QMD

Create `deck.qmd` (or a more descriptive name) at the project root. Minimum
front matter:

```yaml
---
title: "Deck title"
subtitle: "A short, factual subtitle"
author: "Author Name, Role"
date: today
date-format: "D MMMM YYYY"
format: probity-html-revealjs
---
```

The format key is `probity-html-revealjs` — extension name `probity-html`,
base format `revealjs`. Do not set `theme`, `logo`, or `background-color` at
the document level; the extension sets all of these.

### Step 4 — render

```bash
quarto render deck.qmd
```

Output: `deck.html` plus a `deck_files/` directory. The HTML file references
assets in that directory; distribute both together. For a single portable file
add `embed-resources: true` to the format block (see **Output options**).

### Step 5 — structural verification

Agents cannot open a browser. Run these checks against the rendered HTML:

```bash
# File was created
ls -lh deck.html

# At least one navy background (title slide is always present)
grep -c 'data-background-color="#0A325A"' deck.html

# No un-processed [[marker]] survived into the output
python3 -c "
import sys
html = open('deck.html').read()
bad = html.count('[[statcards]]') + html.count('[[cards]]')
print('unprocessed markers:', bad)
sys.exit(1 if bad else 0)
"

# Stat-card content is not empty (only needed if [[statcards]] was used)
grep 'statcard-value' deck.html | grep -v 'statcard-value"></div>'

# Three-card content is not empty (only if [[cards]] was used)
grep 'card-body' deck.html | grep -v 'card-body"></div>'

# Count slide sections (rough sanity check on slide count)
grep -c '^<section ' deck.html
```

If `unprocessed markers` is non-zero, see **Common pitfalls — card markers**.

### Step 6 — voice pass

Grep the **source** `.qmd` for violations before declaring done:

```bash
# em dashes
grep -n '—' deck.qmd

# US spellings
grep -in '\b\(color\|analyze\|behavior\|defence\|organization\|programme\)\b' deck.qmd

# Banned constructions
grep -in '\b\(leverage\|delve\|utilise\|robust\|seamless\|holistic\)\b' deck.qmd
grep -in 'in order to\|prior to' deck.qmd
```

Fix every hit before delivering.

---

## Pattern decision guide

Use this table to decide which slide pattern fits the content.

| Content type | Use this pattern |
|---|---|
| A claim with supporting evidence | `##` content slide with bullets |
| Two things to compare (before/after, claim/evidence) | Two-column slide |
| Structured data with row/column categories, 3–8 rows | Table |
| 2–4 key numbers that must stand out visually | `[[statcards]]` |
| 2–4 sequential steps, principles, or categories | `[[cards]]` |
| Trend, distribution, or multi-series comparison | Native R/Python chart |
| A topic break between logical groups of slides | `#` section divider |
| Final acknowledgement or handover | `# Thank you` (heading only) |

**Gold card rule.** Use `*` prefix on at most one card per `[[statcards]]` row —
the single most important figure. Using it on every card defeats the emphasis.

**Card vs bullet.** Bullets are the default. Use cards only when the items are
genuinely parallel and benefit from visual separation. Do not use cards just
because the content looks sparse.

---

## Converting input content to slides

When given prose, notes, a Word document, or a brief:

1. Identify the logical arguments or phases → each becomes a `#` divider.
2. Identify the key claim in each argument → each becomes a `##` slide title.
   Titles lead with the answer, not the topic. "Loss rates rose 40%" beats
   "Loss rate analysis".
3. Strip connecting prose. Slides use short bullets, not paragraphs. One
   qualifier clause per bullet is acceptable; more than that belongs in
   speaker notes.
4. Identify key numbers (2–4 per deck) → `[[statcards]]`.
5. Identify process steps or principles → `[[cards]]`.
6. Identify data that belongs in a table vs a chart: tables for exact values
   and cross-tabulations; charts for trends and distributions.
7. Everything that does not fit a slide but must be said → `::: {.notes}`
   block on the relevant slide (see **Speaker notes** below).

**Slide density.** 4–6 bullets per slide is the upper bound. If content
overflows, split the slide. Never shrink font size to fit more content — the
extension does not expose a font-size override and shrinking would break the
visual hierarchy.

---

## Slide patterns (full reference)

### Content slide

```markdown
## Lead with the answer

- Short bullets, sentence case, no terminal full stops on fragments
- One idea per slide
- State sample sizes and limitations openly
```

### Two columns

Use for claim/evidence or before/after pairs. Unequal widths are fine.

```markdown
## Two columns

::: {.columns}
::: {.column width="50%"}
**Left lead-in.** Body text.
:::
::: {.column width="50%"}
**Right lead-in.** Body text.
:::
:::
```

### Table

```markdown
| Variable       | Lag   | Correlation |
|----------------|-------|-------------|
| GDP growth     | lag-1 | -0.93       |
| Unemployment   | lag-1 | -0.41       |

: Loss-rate drivers, FY 2019/20 to FY 2023/24 {tbl-colwidths="[40,20,40]"}
```

The `tbl-colwidths` attribute is optional but strongly recommended. Column
widths are integer percentages summing to 100.

### Stat callout row

Fields: `label :: number :: description`. Two to four cards per row.

```markdown
## Headline numbers

[[statcards]]

- Sample :: 6 :: Fiscal-year observations the model is fitted on
- Fit :: 0.86 :: R-squared on lag-1 GDP
- *Multiplier :: R 14.9M :: Applied forward-looking provision uplift
```

`*` prefix → gold emphasis card (navy fill, gold label, white number). Use at
most once per row.

### Three-card row

Fields: `label :: body`. Two to four cards per row.

```markdown
## Three steps

[[cards]]

- Estimate :: Fit the univariate model on the six observations and record the sign against theory.
- Stress :: Drop the FY 2020/21 anomaly and refit. Report how far the fit moves.
- Apply :: Scale every cell of the provision matrix by the single multiplier.
```

### Native chart (R)

```r
#| echo: false
#| fig-cap: "Provision multiplier by fiscal year"
library(ggplot2)
ggplot(df, aes(year, value)) +
  geom_col(fill = "#0A325A", width = 0.6) +
  theme_minimal(base_family = "sans") +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor   = element_blank(),
    panel.grid.major.y = element_line(colour = "#D5DEE9", linewidth = 0.3),
    axis.text          = element_text(colour = "#6B7280")
  )
```

Keep `fig-height` at or below 4.2 in (the extension default). Taller figures
overlap the slide title.

### Native chart (Python)

```python
#| echo: false
#| fig-cap: "Caption"
import matplotlib.pyplot as plt
import matplotlib as mpl

mpl.rcParams['font.family'] = 'sans-serif'
fig, ax = plt.subplots(figsize=(9, 4))
ax.bar(years, values, color='#0A325A', width=0.6)
ax.set_facecolor('white')
ax.spines[['top','right','left']].set_visible(False)
ax.yaxis.grid(True, color='#D5DEE9', linewidth=0.4)
ax.tick_params(colors='#6B7280')
plt.tight_layout()
```

### Speaker notes

Use `::: {.notes}` to add off-slide content visible in presenter view.
Notes do not appear in the rendered slides themselves.

```markdown
## A content slide

- Key point one
- Key point two

::: {.notes}
Remind the audience that this analysis excludes the FY 2020/21 anomaly. The
sensitivity test is on the following slide.
:::
```

### Incremental bullet reveal

Bullets appear one at a time when the presenter advances.

```markdown
## Three findings

::: {.incremental}
- Finding one
- Finding two
- Finding three
:::
```

Or enable for the whole deck via front matter:

```yaml
format:
  probity-html-revealjs:
    incremental: true
```

### Section divider (heading-only)

```markdown
# Section title
```

No body text under a `#` heading. The Lua filter adds a navy background
automatically. Adding body text produces a stray extra slide in the output.

---

## Output options

Safe additions to the `format` block that do not break branding:

```yaml
format:
  probity-html-revealjs:
    embed-resources: true   # single portable .html file; no _files/ directory needed
    slide-number: "c/t"     # current / total in bottom-right; "true" for current only
    incremental: true        # all bullet lists reveal incrementally
    toc: true                # auto table-of-contents slide after title
    toc-depth: 1             # show only section titles in TOC
    chalkboard: true         # enables drawing on slides during presentation
```

**`embed-resources: true` is recommended** when the deck will be emailed or
shared as a file attachment, because the default output references a sibling
`deck_files/` directory. Without `embed-resources`, the HTML file alone is
broken — the directory must travel with it.

Options that **must not** be set (they override the extension and break branding):

- `theme` — overrides the Probity SCSS
- `logo` — overrides the logo file path
- `background-color` at the document level — use `data-background-color` on
  individual section headers if needed, but the Lua filter handles all standard
  cases automatically

---

## Error diagnosis

| Symptom | Cause | Fix |
|---|---|---|
| `ERROR: Extension 'probity-html' not found` | Extension not installed | Run `install.sh` and verify `_extensions/probity-html/_extension.yml` exists |
| `ERROR: Unknown format: probity-html-revealjs` | Same as above | Same fix |
| `ERROR: Unable to read the extension 'probity-html'` (deck in a subdirectory) | Quarto walks up only to the project root; `_extensions/` is not on the path from the deck to its root — no root `_quarto.yml`, or an intermediate `_quarto.yml` re-anchors the root below `_extensions/` | Co-locate the extension with the deck: `bash install.sh <project> <deck-subdir>`. See **Subdirectory decks** below |
| Card content empty in output | `[[marker]]` not on its own paragraph or blank line between marker and list | See **Common pitfalls — card markers** |
| `[[statcards]]` appears as literal text in slide | Same parsing issue | Same fix |
| Logo shows as broken image | Logo files absent from `_extensions/probity-html/` | Re-run `install.sh`; or copy `logo_navy_small.png` and `logo_white.png` manually |
| White logo on content slides / navy logo on dark slides (swapped) | JS did not run (e.g. opened as `file://` without a server, or JS blocked) | Serve with `quarto preview` or a local server instead of opening directly |
| `Warning: package 'ggplot2' is not available` | R package not installed | `Rscript -e 'install.packages("ggplot2")'` |
| Figures overlap the slide title | `fig-height` too large | Set `#| fig-height: 3.5` on the offending chunk |
| All slides have white background (no navy dividers) | Lua filter not loaded | Check `_extension.yml` contains `filters: [probity.lua]`; ensure `probity.lua` is in `_extensions/probity-html/` |

---

## Brand reference

| Element | Value |
|---|---|
| Primary navy | `#0A325A` |
| Deep navy | `#062340` |
| Mid blue | `#4A7BA8` |
| Light blue | `#8BABCB` |
| Pale blue tint | `#E8EEF5` |
| Off-background | `#F7F9FC` |
| Gold accent | `#C8881F` |
| Body text | `#1F2937` |
| Muted text | `#6B7280` |
| Rule / hairline | `#D5DEE9` |
| Font | Calibri → Gill Sans MT → Trebuchet MS → Arial |
| Mono / code | Consolas → Courier New |

**Palette discipline.** Navy dominates (about 70%): titles, table headers,
chart bars, hairlines, card borders. Gold is the accent only: the left stripe
on divider/title slides, the subtitle on dark slides, the single most important
number in a stat group. Never use gold for body text or chart fills.

**Number format.** Money: `R 14,903,239` in tables, `R 14.9M` in prose.
Percentages: `12.5%` (no space). Fiscal years: `FY 2024/25`. Dates:
`2024-06-30` in tables, "30 June 2024" in prose.

**AI-slop tells to avoid.** No accent lines under titles, no cream backgrounds,
no generic blue gradients, no emoji, no decorative full-width bars. The small
logo plus a hairline rule is the only chrome a content slide needs.

---

## Common pitfalls

**`#` vs `##`.** Level-1 is a navy divider, level-2 is a white content slide.
Mixing these up is the most common error. A `#` with body text produces a stray
extra slide and breaks the navy layout.

**Card markers must be on their own paragraph with no blank line before the
list.** Correct:

```markdown
[[statcards]]

- Label :: Value :: Description
```

Wrong (blank line between marker and list — the filter sees them as separate
blocks):

```markdown
[[statcards]]


- Label :: Value :: Description
```

Wrong (extra text on the marker line):

```markdown
[[statcards]] three cards below
```

**`::` is the field separator.** Use exactly two colons. If a value itself
contains `::` (e.g. a ratio like `1::2`), write it as `1:2` instead.

**`*` gold prefix must be the first character of the bullet text** with no
leading space. `- *Label :: ...` is correct. `- * Label :: ...` (space after
asterisk) will not be recognised and the `*` is treated as a literal character
in the card label.

**Do not set `theme` in your front matter.** Even `theme: [probity-html/custom.scss]`
will override the extension's theme merge and lose defaults. The extension
handles the theme; you only need `format: probity-html-revealjs`.

**Tall figures overlap the title.** The slide content area starts below the
title. With the default `fig-height: 4.2`, a figure plus its caption fits the
content area on a standard content slide. Set `#| fig-height: 3.5` on any
chart that sits alongside a long title.

**`embed-resources` and the `_files/` directory.** Without `embed-resources:
true`, the rendered `deck.html` depends on `deck_files/` being in the same
directory. Sending only the `.html` by email will produce a broken presentation.
Always set `embed-resources: true` before distributing a deck outside the
project directory.

**Subdirectory decks — `Unable to read the extension`.** Quarto discovers
`_extensions/` by walking **up** from the `.qmd` only as far as the project root
(the nearest ancestor with a `_quarto.yml`), checking each directory for
`_extensions/`. A deck at the project root always resolves. A deck in a
subdirectory resolves only when the extension is on that upward path — which
fails in two common cases:

- **No `_quarto.yml` above the deck** (e.g. installed with `quarto add`, which
  does not create one): the deck's own directory becomes the project root and
  only `<deckdir>/_extensions/` is searched.
- **An intermediate `_quarto.yml`** between the deck and `_extensions/`: it
  re-anchors the project root below the extension, so the walk-up stops short.

Fixes, simplest first:

1. Keep the deck at the project root, beside `_extensions/` and `_quarto.yml`.
2. Ensure a `_quarto.yml` exists at the project root and that no subdirectory
   between the deck and the root has its own `_quarto.yml`.
3. Co-locate the extension with the deck — re-run the installer with the deck
   subdirectory: `bash install.sh <project> pipeline/docs`. (It copies by
   default, which is portable and works on Windows; `--link` symlinks instead on
   Unix.) Putting only a `_quarto.yml` in the deck's directory does **not** help
   on its own — the extension itself must be co-located.

---

## What the template gives you

- **Title slide**: full navy background, gold left stripe (8 px), white logo
  top-left, white left-aligned title, gold subtitle, gold anchor rule at the
  bottom.
- **Section dividers (`#`)**: same as title slide but without subtitle/author;
  background set automatically by the Lua filter.
- **Content slides (`##`)**: white background, small navy logo top-left,
  hairline rule below the logo, navy left-aligned title, navy "Probity Data
  Analytics" footer wordmark (hidden on dark slides automatically via JS).
- **Tables**: navy header row, white bold header text, pale-blue alternating
  rows.
- **Stat cards / three-card rows**: rendered by the Lua filter — no post-render
  script needed.
- **Code**: inline code in Consolas on a pale-blue background; fenced blocks
  with a navy left border on an off-white background.
- **Two-column layout**: flex-based, gap-separated.
- **Logo swap**: JavaScript in `footer.html` switches between the white logo
  (dark slides) and the navy logo (light slides) on every slide change.
- **Slide size**: 1280 × 720 px (HD 16:9). Margin: 0 (full bleed).

---

## Extension file map

| File | Purpose |
|---|---|
| `_extension.yml` | Format manifest — revealjs options, logo path, title-slide navy bg |
| `custom.scss` | Full Reveal.js SCSS theme — palette, typography, all slide layouts, card styles |
| `probity.lua` | Lua filter — navy bg on `#` headers; `[[statcards]]`/`[[cards]]` → HTML |
| `footer.html` | Injected HTML — "Probity Data Analytics" wordmark + logo-swap JS |
| `logo_navy_small.png` | Small navy logo for white content slides |
| `logo_white.png` | White logo for navy title/divider slides |

---

## Differences from the PowerPoint template

| Aspect | PowerPoint (`probity-pptx`) | HTML (`probity-html`) |
|---|---|---|
| Card patterns | Python post-render script (`build/probity_cards.py`) | Lua filter — no extra step |
| Font post-processing | Python swaps Courier → Consolas | Consolas set directly in SCSS |
| Logo swap | Built into `reference.pptx` slide masters | JavaScript at runtime |
| `_quarto.yml` post-render hooks | Required for card slides | Not required |
| Portable single file | `.pptx` is always single-file | Add `embed-resources: true` |
| Font availability | Calibri/Consolas must be installed | Falls back to system equivalents |
| Navigation | Slide sorter / presenter view in PowerPoint | Keyboard (arrow keys), overview (Esc), presenter mode (S key) |

# probity_html_deck

Probity Data Analytics HTML Slide Deck Template — a Quarto Reveal.js extension
with full Probity branding: navy/gold palette, Calibri, logo chrome, stat
cards, and three-card rows.

The HTML companion to [`probity_ppt`](../probity_ppt). Both share the same
palette, voice rules, and `[[statcards]]` / `[[cards]]` syntax. Use this
template when the output must run in a browser; use `probity_ppt` when the
client expects a `.pptx` file.

---

## Quick start

### 1. Install

```bash
# From the probity_html_deck repo root:
bash install.sh /path/to/your-project

# Or via quarto add:
quarto add /path/to/probity_html_deck --no-prompt
```

### 2. Write

Create `deck.qmd` in your project:

```yaml
---
title: "Deck title"
subtitle: "A short, factual subtitle"
author: "Author Name, Role"
date: today
date-format: "D MMMM YYYY"
format: probity-html-revealjs
---

# Section one

## Content slide

- Lead with the answer, then the qualification
- Short bullets, sentence case, no terminal full stops on fragments
- UK spelling throughout

## Headline numbers

[[statcards]]

- Sample :: 6 :: Fiscal-year observations
- Fit :: 0.86 :: R-squared on lag-1 GDP
- *Multiplier :: R 14.9M :: Applied provision uplift
```

See `template.qmd` for a complete worked example covering all patterns.

### 3. Render

```bash
quarto render deck.qmd
```

Output: `deck.html` + `deck_files/`. To produce a single portable file:

```yaml
format:
  probity-html-revealjs:
    embed-resources: true
```

---

## Slide types

| Markdown | Slide | Background |
|---|---|---|
| YAML front matter | Title slide | Navy |
| `# Heading` | Section divider | Navy, gold left stripe |
| `## Heading` | Content slide | White, navy title, hairline |
| `## Heading` + `::: {.columns}` | Two-column slide | White |

**Rule:** `#` is a divider (heading only, no body text). `##` is a content
slide. Mixing them up is the most common error.

---

## Card patterns

Both patterns are handled by the Lua filter at render time — no post-render
script needed.

**Stat callout row** (`label :: number :: description`). Prefix one label with
`*` for the gold emphasis card.

```markdown
[[statcards]]

- Sample :: 6 :: Fiscal-year observations
- Fit :: 0.86 :: R-squared on lag-1 GDP
- *Multiplier :: R 14.9M :: Applied provision uplift
```

**Three-card row** (`label :: body`).

```markdown
[[cards]]

- Estimate :: Fit the model and record the sign against theory.
- Stress :: Drop the anomaly and refit. Report how far the fit moves.
- Apply :: Scale every matrix cell by the multiplier.
```

The `[[marker]]` must be on its own paragraph with no blank line separating it
from the bullet list.

---

## Repository structure

```
_extensions/probity-html/
  _extension.yml       Quarto format manifest
  custom.scss          Reveal.js SCSS theme
  probity.lua          Lua filter — dark backgrounds + card patterns
  footer.html          Footer wordmark + logo-swap JavaScript
  logo_navy_small.png  Navy logo (content slides)
  logo_white.png       White logo (dark slides)
assets/
  logo_navy_small.png
  logo_white.png
  logo.png
  logo_trim.png
template.qmd           Worked example (all patterns)
SKILL.md               Full documentation for agent and human use
install.sh             Copies extension + assets into another project
README.md              This file
```

---

## Palette

| Element | Hex |
|---|---|
| Primary navy | `#0A325A` |
| Gold accent | `#C8881F` |
| Body text | `#1F2937` |
| Muted text | `#6B7280` |
| Rule / hairline | `#D5DEE9` |
| Font | Calibri → Gill Sans MT → Arial |
| Mono | Consolas → Courier New |

Navy dominates. Gold is the accent only — the left stripe on dark slides and
the single most important number in a stat group.

---

## Companion template

[`probity_ppt`](../probity_ppt) produces `.pptx` output from the same
Markdown source and card syntax. The only difference is the format key:
`probity-pptx-pptx` vs `probity-html-revealjs`.

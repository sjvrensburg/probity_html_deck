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

> **Decks in a subdirectory?** Quarto only discovers `_extensions/` by walking up
> from the `.qmd` to the project root (the nearest ancestor with a `_quarto.yml`).
> If your deck lives in a subfolder, pass that subfolder as a second argument so the
> extension is placed next to it:
>
> ```bash
> bash install.sh /path/to/your-project pipeline/docs
> ```
>
> `quarto add` does **not** create a `_quarto.yml`; without one, a deck in a
> subdirectory will fail to find the extension. See
> [Project layout & extension discovery](#project-layout--extension-discovery).

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

# Section One

## Content Slide

- Lead with the answer, then the qualification
- Short bullets, sentence case, no terminal full stops on fragments
- UK spelling throughout

## Headline Numbers

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

## Project layout & extension discovery

Quarto finds the extension by walking **up** from the `.qmd` to the *project
root* — the nearest ancestor directory that contains a `_quarto.yml` — checking
each directory on the way for `_extensions/`. The extension must sit on that
path, or the render fails with:

```
ERROR: Unable to read the extension 'probity-html'.
```

This works out of the box for a deck at the project root. A deck in a
**subdirectory** resolves only when both of these hold:

- A `_quarto.yml` exists at (or above) the deck — it defines the project root.
  `install.sh` creates one; `quarto add` does **not**.
- No *intermediate* `_quarto.yml` sits between the deck and `_extensions/`. An
  inner `_quarto.yml` re-anchors the project root below the extension, so the
  walk-up stops before reaching it.

```
project/
  _quarto.yml          ← project root marker (required)
  _extensions/
    probity-html/
  decks/
    deck.qmd           ← resolves: walks up to the root and finds _extensions/
```

If you cannot guarantee that layout (no root `_quarto.yml`, or an unavoidable
intermediate one), place the extension **next to the deck**. `install.sh` does
this for you when you pass the deck subdirectory:

```bash
bash install.sh /path/to/project decks         # copies the extension into decks/ (portable)
bash install.sh --link /path/to/project decks   # symlink instead (Unix only; see note)
```

The default is a **copy** — self-contained and portable, so the deck still
renders after it is zipped, emailed, or moved to another machine, and it works on
Windows. `--link` makes a relative symlink instead (no duplication, theme stays
in sync), but symlinks need Administrator/Developer Mode on Windows and break when
the folder is zipped or copied off the filesystem; the script automatically falls
back to a copy if it cannot create a working symlink.

A `_quarto.yml` in the deck's own directory does **not** help on its own — the
extension must be co-located, not just the project marker.

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

**Heading case:** all slide titles and section dividers use title case
(`Headline Numbers`, `Loss Rates Rose 40%`), while bullets, captions, and body
text stay sentence case.

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

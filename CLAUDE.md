# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A Quarto extension (`probity-html`) that produces branded Probity Data Analytics
Reveal.js HTML slide decks. The repo is itself the canonical copy of the
extension; users install it into their own projects via `install.sh` or
`quarto add`.

## Render the template deck

```bash
quarto render template.qmd        # produces template.html + template_files/
quarto preview template.qmd       # live-reload in browser
```

`template.html` and `*_files/` directories are gitignored. `footer.html` inside
`_extensions/` is **not** ignored — `/*.html` (root only) is the gitignore rule.

## Verify after changes

Run the structural checks against the rendered output — these are the canonical
correctness tests for this repo:

```bash
quarto render template.qmd

# No un-processed [[markers]] in output
python3 -c "
import sys; html = open('template.html').read()
bad = html.count('[[statcards]]') + html.count('[[cards]]')
print('unprocessed markers:', bad); sys.exit(1 if bad else 0)
"

# Dark backgrounds applied to section slides
grep -c 'data-background-color="#0A325A"' template.html

# Stat-card content populated
grep 'statcard-value' template.html | grep -v 'statcard-value"></div>'

# Three-card content populated
grep 'card-body' template.html | grep -v 'card-body"></div>'
```

## Architecture

The extension is four files that work as a pipeline:

```
.qmd source
  → probity.lua          (Pandoc Lua filter, runs first)
      - Adds data-background-color="#0A325A" to every level-1 Header
      - Replaces [[statcards]] Para + BulletList → <div class="probity-statcards">
      - Replaces [[cards]] Para + BulletList   → <div class="probity-cards">
  → Quarto/Pandoc revealjs renderer
  → custom.scss           (Reveal.js SCSS theme, compiled by Quarto)
      - /*-- scss:defaults --*/  sets Sass variables (colours, fonts)
      - /*-- scss:rules --*/     all CSS: slide layouts, logo, table, code, cards
  → footer.html           (injected before </body>)
      - Adds .probity-footer wordmark div
      - JS polls for Reveal.ready, then swaps logo src and toggles footer
        visibility on every slidechanged event
```

`_extension.yml` wires these together and sets all revealjs defaults (size,
transitions, logo path, title-slide navy background).

## Key constraints

**Do not set `theme`, `logo`, or document-level `background-color`** in user
front matter — the extension sets all three. Overriding them silently drops
branding.

**`[[statcards]]` / `[[cards]]` parsing.** The Lua filter's `Blocks` function
walks the block list looking for a `Para` whose concatenated `Str` inlines equal
`[[statcards]]` or `[[cards]]`, immediately followed by a `BulletList`. Pandoc
parses bullet list items as `Plain` blocks (not `Para`), so `item_text()` in
`probity.lua` handles both. A blank line between the marker and the list
produces two separate block groups and the filter will not match — the marker
must be separated from the list by exactly one blank line in Markdown (standard
paragraph break), not two.

**Logo swap timing.** `footer.html` polls with `setTimeout` until
`Reveal` is defined, then registers `ready` and `slidechanged` listeners. The
white/navy logo src swap derives the white path by replacing
`logo_navy_small.png` with `logo_white.png` in the resolved URL — both files
must be present in `_extensions/probity-html/`.

**`embed-resources`.** Without it the rendered `.html` depends on a sibling
`*_files/` directory. Set `embed-resources: true` in the format block when
the deck will be distributed as a standalone file.

## Changing the theme

All visual changes go in `_extensions/probity-html/custom.scss`. The
`/*-- scss:defaults --*/` block sets Sass variables; the `/*-- scss:rules --*/`
block contains all CSS. There is no separate build step — Quarto compiles the
SCSS on every render.

Palette constants are defined once at the top of `custom.scss` as `$probity-*`
variables. Use them everywhere; do not hardcode hex values in the rules section.

## Installing into another project

```bash
bash install.sh /path/to/target-project
```

The script copies `_extensions/probity-html/` and `assets/` and creates
`_quarto.yml` if absent. No post-render hooks are needed in `_quarto.yml` —
the Lua filter handles everything at render time.

## Full usage documentation

`SKILL.md` contains the authoritative reference: all slide patterns with exact
syntax, the pattern decision guide, output options, error diagnosis table, voice
rules, and brand palette. Read it before making content or branding changes.

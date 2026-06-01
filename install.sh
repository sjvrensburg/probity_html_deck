#!/usr/bin/env bash
# install.sh — copy the Probity HTML Deck extension into another project
#
# Usage:
#   ./install.sh <project-dir>                 Install at the project root.
#   ./install.sh <project-dir> <deck-subdir>   Also make the extension resolvable
#                                              from a deck kept in a subdirectory
#                                              (copies the extension next to it).
#   ./install.sh --link <project-dir> <deck-subdir>
#                                              As above, but symlink instead of copy
#                                              (Unix filesystems only — see below).
#
# Why <deck-subdir> exists
#   Quarto discovers `_extensions/` by walking up from the .qmd only as far as the
#   project root — the nearest ancestor directory that contains a `_quarto.yml`. If
#   no `_quarto.yml` sits above the deck, or an intermediate `_quarto.yml` re-anchors
#   the project root below `_extensions/`, a deck in a subdirectory reports
#   "Unable to read the extension 'probity-html'". Passing <deck-subdir> places the
#   extension next to the deck so discovery succeeds regardless of project layout.
#
#   The default is a copy because it is self-contained and portable: it survives
#   zipping, emailing, and moving to another machine, and it works on Windows.
#   --link makes a relative symlink instead (one source of truth, no duplication),
#   but symlinks need Administrator/Developer Mode on Windows and do not survive
#   being zipped or copied off the filesystem; the script falls back to a copy if
#   the symlink cannot be created or resolved.

set -euo pipefail

LINK_MODE=0
ARGS=()
for arg in "$@"; do
  case "$arg" in
    --link) LINK_MODE=1 ;;
    -h|--help)
      sed -n '2,26p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) ARGS+=("$arg") ;;
  esac
done

TARGET="${ARGS[0]:-}"
DECK_SUBDIR="${ARGS[1]:-}"

if [[ -z "$TARGET" ]]; then
  echo "Usage: $0 [--link] <project-dir> [deck-subdir]" >&2
  exit 1
fi

if [[ ! -d "$TARGET" ]]; then
  echo "Error: '$TARGET' is not a directory." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$(cd "$TARGET" && pwd)"   # absolute, normalised

echo "Installing Probity HTML Deck extension into: $TARGET"

# Copy extension to the project root
mkdir -p "$TARGET/_extensions"
cp -r "$SCRIPT_DIR/_extensions/probity-html" "$TARGET/_extensions/"

# Copy assets
mkdir -p "$TARGET/assets"
for f in logo_navy_small.png logo_white.png logo.png logo_trim.png; do
  src="$SCRIPT_DIR/assets/$f"
  [[ -f "$src" ]] && cp "$src" "$TARGET/assets/"
done

# Create _quarto.yml if absent — this marks the project root so Quarto can walk up
# from a deck and discover the extension.
if [[ ! -f "$TARGET/_quarto.yml" ]]; then
  printf 'project:\n  type: default\n' > "$TARGET/_quarto.yml"
  echo "Created _quarto.yml (marks the project root for extension discovery)"
fi

# Optionally make the extension resolvable from a deck kept in a subdirectory.
if [[ -n "$DECK_SUBDIR" ]]; then
  DECK_DIR="$TARGET/$DECK_SUBDIR"
  mkdir -p "$DECK_DIR"
  DECK_DIR="$(cd "$DECK_DIR" && pwd)"
  DEST="$DECK_DIR/_extensions"

  if [[ "$DECK_DIR" == "$TARGET" ]]; then
    echo "Deck subdirectory is the project root; nothing extra to do."
  elif [[ -e "$DEST" && ! -L "$DEST" ]]; then
    echo "Note: '$DEST' already exists and is not a symlink — left untouched."
  else
    [[ -L "$DEST" ]] && rm -f "$DEST"
    linked=0
    if [[ "$LINK_MODE" -eq 1 ]]; then
      # Relative symlink so the project stays movable. Verify it actually resolves
      # (it will not on filesystems without symlink support, e.g. some Windows
      # setups) and fall back to a copy if not.
      if command -v python3 >/dev/null 2>&1; then
        REL="$(python3 -c 'import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' "$TARGET/_extensions" "$DECK_DIR")"
      else
        REL="$TARGET/_extensions"   # absolute fallback target
      fi
      if ln -s "$REL" "$DEST" 2>/dev/null && [[ -r "$DEST/probity-html/_extension.yml" ]]; then
        echo "Linked $DECK_SUBDIR/_extensions -> $REL"
        linked=1
      else
        rm -f "$DEST" 2>/dev/null || true
        echo "Note: could not create a working symlink here; copying instead."
      fi
    fi
    if [[ "$linked" -eq 0 ]]; then
      mkdir -p "$DEST"
      cp -r "$SCRIPT_DIR/_extensions/probity-html" "$DEST/"
      echo "Copied extension into $DECK_SUBDIR/_extensions/ (self-contained, portable)"
    fi
  fi
fi

echo ""
echo "Done. Create a .qmd with this front matter:"
echo ""
echo "  ---"
echo "  title: \"Deck title\""
echo "  subtitle: \"A short, factual subtitle\""
echo "  author: \"Author Name, Role\""
echo "  date: today"
echo "  date-format: \"D MMMM YYYY\""
echo "  format: probity-html-revealjs"
echo "  ---"
echo ""
echo "Then: quarto render deck.qmd"
echo ""
echo "Keep the deck at or below the directory holding _quarto.yml and _extensions/."
echo "If a deck in a subdirectory reports \"Unable to read the extension\", re-run"
echo "this script with the subdirectory as the second argument, e.g.:"
echo "  bash install.sh $TARGET pipeline/docs"

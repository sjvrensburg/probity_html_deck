#!/usr/bin/env bash
# install.sh — copy the Probity HTML Deck extension into another project
#
# Usage: ./install.sh /path/to/your-project

set -euo pipefail

TARGET="${1:-}"
if [[ -z "$TARGET" ]]; then
  echo "Usage: $0 /path/to/target-project" >&2
  exit 1
fi

if [[ ! -d "$TARGET" ]]; then
  echo "Error: '$TARGET' is not a directory." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Probity HTML Deck extension into: $TARGET"

# Copy extension
mkdir -p "$TARGET/_extensions"
cp -r "$SCRIPT_DIR/_extensions/probity-html" "$TARGET/_extensions/"

# Copy assets
mkdir -p "$TARGET/assets"
for f in logo_navy_small.png logo_white.png logo.png logo_trim.png; do
  src="$SCRIPT_DIR/assets/$f"
  [[ -f "$src" ]] && cp "$src" "$TARGET/assets/"
done

# Create _quarto.yml if absent
if [[ ! -f "$TARGET/_quarto.yml" ]]; then
  printf 'project:\n  type: default\n' > "$TARGET/_quarto.yml"
  echo "Created _quarto.yml"
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

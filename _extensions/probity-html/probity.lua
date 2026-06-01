-- probity.lua: Probity HTML Deck filter
-- Handles two responsibilities:
--   1. Adds data-background-color="#0A325A" to level-1 section-divider headers
--   2. Replaces [[statcards]] / [[cards]] + BulletList with branded HTML divs

-- ── Dark backgrounds on level-1 dividers ─────────────────────────────────────

function Header(h)
  if h.level == 1 then
    h.attributes["data-background-color"] = "#0A325A"
    return h
  end
end

-- ── Inline-to-text helper ─────────────────────────────────────────────────────

local function inlines_to_text(inlines)
  local parts = {}
  for _, el in ipairs(inlines) do
    if     el.t == "Str"       then parts[#parts + 1] = el.text
    elseif el.t == "Space"
        or el.t == "SoftBreak" then parts[#parts + 1] = " "
    elseif el.t == "Strong"
        or el.t == "Emph"      then parts[#parts + 1] = inlines_to_text(el.content)
    end
  end
  return table.concat(parts)
end

-- Return trimmed plain text of the first Para or Plain block in a BulletList item
local function item_text(item)
  if #item > 0 and (item[1].t == "Para" or item[1].t == "Plain") then
    local t = inlines_to_text(item[1].content)
    return t:match("^%s*(.-)%s*$") or t
  end
  return ""
end

-- Escape HTML entities so arbitrary text is safe to inline
local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- ── Stat cards ────────────────────────────────────────────────────────────────

local function make_statcards(list)
  local rows = {'<div class="probity-statcards">'}
  for _, item in ipairs(list.content) do
    local text = item_text(item)

    local gold = false
    if text:sub(1, 1) == "*" then
      gold  = true
      text  = (text:sub(2):match("^%s*(.-)%s*$") or text:sub(2))
    end

    local label, value, desc = text:match("^(.-)%s*::%s*(.-)%s*::%s*(.+)$")
    label = esc(label or text)
    value = esc(value or "")
    desc  = esc(desc  or "")

    local cls = "probity-statcard" .. (gold and " probity-statcard--gold" or "")
    rows[#rows + 1] = string.format(
      '<div class="%s">'
        .. '<div class="statcard-label">%s</div>'
        .. '<div class="statcard-value">%s</div>'
        .. '<div class="statcard-desc">%s</div>'
      .. '</div>',
      cls, label:upper(), value, desc
    )
  end
  rows[#rows + 1] = "</div>"
  return pandoc.RawBlock("html", table.concat(rows, "\n"))
end

-- ── Three-card rows ───────────────────────────────────────────────────────────

local function make_cards(list)
  local rows = {'<div class="probity-cards">'}
  for _, item in ipairs(list.content) do
    local text = item_text(item)
    local label, body = text:match("^(.-)%s*::%s*(.+)$")
    label = esc(label or text)
    body  = esc(body  or "")

    rows[#rows + 1] = string.format(
      '<div class="probity-card">'
        .. '<div class="card-label">%s</div>'
        .. '<div class="card-body">%s</div>'
      .. '</div>',
      label, body
    )
  end
  rows[#rows + 1] = "</div>"
  return pandoc.RawBlock("html", table.concat(rows, "\n"))
end

-- ── Check whether a block is a [[marker]] paragraph ──────────────────────────

local function is_marker(block, marker)
  if block.t ~= "Para" then return false end
  local t = inlines_to_text(block.content)
  return (t:match("^%s*(.-)%s*$") or t) == marker
end

-- ── Block-list processor ──────────────────────────────────────────────────────

function Blocks(blocks)
  local out = {}
  local i = 1
  while i <= #blocks do
    local b     = blocks[i]
    local b_next = blocks[i + 1]
    if is_marker(b, "[[statcards]]") and b_next and b_next.t == "BulletList" then
      out[#out + 1] = make_statcards(b_next)
      i = i + 2
    elseif is_marker(b, "[[cards]]") and b_next and b_next.t == "BulletList" then
      out[#out + 1] = make_cards(b_next)
      i = i + 2
    else
      out[#out + 1] = b
      i = i + 1
    end
  end
  return out
end

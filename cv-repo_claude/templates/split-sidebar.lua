-- 1) Pulls the leading contact paragraph + the "Training" / "Education" /
--    "Qualities" / "Strong Points" / "Hobbies" H2 sections out of the main
--    body into metadata variables ($sidebar-contact$, $sidebar-training$,
--    etc.) so a two-column template (LaTeX/HTML) can place them in the
--    left sidebar.
-- 2) Within the sections that stay in the main body (Data Science & ML,
--    Engineering Background), turns each "### Title | Company — Date"
--    subsection into a two-column (date | content) row: RawBlock latex
--    for the PDF, a flex <div> for HTML.
-- Not applied when building the docx (single-column) target, so
-- resume.md stays the single source of truth for every format.

local sidebar_titles = {
  ["training"] = "sidebar-training",
  ["education"] = "sidebar-education",
  ["qualities"] = "sidebar-qualities",
  ["strong points"] = "sidebar-strongpoints",
  ["hobbies"] = "sidebar-hobbies",
}

-- Split "Title | Company — Date" (Company optional) into title/company/date
local function split_heading(text)
  local date
  local rest = text
  local d1, d2 = rest:find("%s+—%s+[^—]+$")
  if d1 then
    date = rest:sub(d1):gsub("^%s*—%s*", "")
    rest = rest:sub(1, d1 - 1)
  end
  local title, company = rest, nil
  local p1 = rest:find("%s+|%s+")
  if p1 then
    title = rest:sub(1, p1 - 1)
    company = rest:sub(p1):gsub("^%s*|%s*", "")
  end
  return title, company, date
end

function Pandoc(doc)
  local blocks = doc.blocks
  local meta = doc.meta
  local fmt = FORMAT

  -- 1) Leading contact paragraph (first block, if it's a Para/Plain)
  local body_start = 1
  if blocks[1] and (blocks[1].t == "Para" or blocks[1].t == "Plain") then
    meta["sidebar-contact"] = pandoc.MetaBlocks({ blocks[1] })
    body_start = 2
  end

  -- 2) Walk remaining blocks: siphon sidebar H2 sections, transform H3 entries
  local body = {}
  local capturing_key = nil
  local captured = {}

  local function flush_sidebar()
    if capturing_key then
      meta[capturing_key] = pandoc.MetaBlocks(captured)
    end
    capturing_key = nil
    captured = {}
  end

  local pending_entry_blocks = nil
  local pending_date = nil

  local function flush_entry()
    if not pending_entry_blocks then return end
    if fmt == "latex" then
      table.insert(body, pandoc.RawBlock("latex",
        "\\begin{cventry}{" .. (pending_date or "") .. "}"))
      for _, b in ipairs(pending_entry_blocks) do table.insert(body, b) end
      table.insert(body, pandoc.RawBlock("latex", "\\end{cventry}"))
    elseif fmt == "html" then
      table.insert(body, pandoc.RawBlock("html",
        '<div class="entry"><div class="entry-date">' ..
        (pending_date or "") .. '</div><div class="entry-body">'))
      for _, b in ipairs(pending_entry_blocks) do table.insert(body, b) end
      table.insert(body, pandoc.RawBlock("html", "</div></div>"))
    else
      for _, b in ipairs(pending_entry_blocks) do table.insert(body, b) end
    end
    pending_entry_blocks = nil
    pending_date = nil
  end

  local function add_to_current(block)
    if pending_entry_blocks then
      table.insert(pending_entry_blocks, block)
    elseif capturing_key then
      table.insert(captured, block)
    else
      table.insert(body, block)
    end
  end

  for i = body_start, #blocks do
    local block = blocks[i]
    if block.t == "Header" and block.level == 2 then
      flush_entry()
      flush_sidebar()
      local text = pandoc.utils.stringify(block.content):lower()
      local key = sidebar_titles[text]
      if key then
        capturing_key = key
      else
        table.insert(body, block)
      end
    elseif block.t == "Header" and block.level == 3 then
      flush_entry()
      local text = pandoc.utils.stringify(block.content)
      local title, company, date = split_heading(text)
      local inlines = { pandoc.Strong({ pandoc.Str(title) }) }
      if company then
        table.insert(inlines, pandoc.Space())
        table.insert(inlines, pandoc.Emph({ pandoc.Str("- " .. company) }))
      end
      local titlepara = pandoc.Para(inlines)
      if (fmt == "latex" or fmt == "html") and date then
        pending_entry_blocks = { titlepara }
        pending_date = date
      else
        if date then
          table.insert(inlines, pandoc.Space())
          table.insert(inlines, pandoc.Emph({ pandoc.Str("(" .. date .. ")") }))
        end
        add_to_current(pandoc.Para(inlines))
      end
    else
      add_to_current(block)
    end
  end
  flush_entry()
  flush_sidebar()

  return pandoc.Pandoc(body, meta)
end

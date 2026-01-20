-- ~/.config/nvim/luasnippets/vimwiki.lua
-- Custom snippets for VimWiki files

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

-- Helper function to get the page name (filename without extension)
local function get_page_name()
	local filename = vim.fn.expand("%:t:r") -- Get filename without path and extension
	-- Replace underscores with spaces for display
	return filename:gsub("_", " ")
end

-- Helper function to find the nearest H2 heading above cursor and extract venue name
-- Parses format like "Feb-11: The Pageant - St. Louis, MO" → "the_pageant"
local function get_venue_from_h2()
	local current_line = vim.fn.line(".")

	-- Search backward for H2 heading
	for line_num = current_line - 1, 1, -1 do
		local line = vim.fn.getline(line_num)
		-- Match H2 heading (## at start)
		if line:match("^## ") then
			-- Try to extract venue name from format: "Date: Venue - Location"
			-- Pattern: after ": " and before " - " or end of line
			local venue = line:match("^## [^:]+:%s*([^-]+)")
			if venue then
				-- Trim whitespace and convert to snake_case
				venue = vim.trim(venue)
				venue = venue:lower():gsub("%s+", "_"):gsub("[^%w_]", "")
				return venue
			else
				-- Fallback: use everything after "## " converted to snake_case
				venue = line:gsub("^## ", "")
				venue = venue:lower():gsub("%s+", "_"):gsub("[^%w_]", "")
				return venue
			end
		end
	end

	return "venue" -- Default placeholder if no H2 found
end

return {
	-- ============================================================
	-- Show Advance Template (full page template)
	-- ============================================================
	s({
		trig = "advance",
		name = "Show Advance Template",
		dscr = "Create a show advance document template with TaskWiki progress tracking",
	}, {
		-- H2: Advance Progress with TaskWiki project
		t("## Advance Progress | project:"),
		i(1, "tour_name"),
		t("."),
		f(function()
			-- Get venue from filename (e.g., "021026_Folly-Theater_Kansas-City_MO" → "folly_theater")
			local filename = vim.fn.expand("%:t:r")
			-- Extract venue part (second segment after date, before city)
			-- Pattern: MMDDYY_Venue-Name_City-Name_ST
			local venue = filename:match("^%d+_([^_]+)")
			if venue then
				return venue:lower():gsub("%-", "_")
			end
			-- Fallback: use whole filename as snake_case
			return filename:lower():gsub("%-", "_"):gsub("%s+", "_")
		end, {}),
		t({ "", "", "" }),

		-- H2: Advance Information
		t({ "## Advance Information", "", "" }),

		-- Regular checkbox (not TaskWiki)
		t({ "- [ ] Tech Pack Received", "", "" }),

		-- Hospitality Table (2 columns)
		t({
			"| Hospitality       | Info |",
			"|-------------------|------|",
			"| Dinner:           |      |",
			"| Showers:          |      |",
			"| Wifi Password(s): |      |",
			"",
			"",
		}),

		-- Personnel Table (2 columns)
		t({
			"| Personnel    | Info |",
			"|--------------|------|",
			"| Runner:      |      |",
			"| Merch Seller:|      |",
			"",
			"",
		}),

		-- H2: Travel/Lodging
		t({ "## Travel/Lodging", "", "" }),

		-- H3: Bus Info
		t({ "### Bus Info:", "", "" }),
		i(2, ""),
		t({ "", "", "" }),

		-- H3: Accommodations
		t({ "### Accommodations:", "", "" }),
		i(3, ""),
		t({ "", "", "" }),

		-- H2: Schedule
		t({ "## Schedule", "", "" }),
		i(4, ""),
		t({ "", "", "" }),

		-- H2: Contacts
		t({ "## Contacts", "", "" }),
		i(0), -- Final cursor position
	}),

	-- ============================================================
	-- Logistics Section (H3 with TaskWiki project)
	-- ============================================================
	s({
		trig = "logistics",
		name = "Logistics Section",
		dscr = "H3 Logistics header with TaskWiki project and checklist",
	}, {
		t("### Logistics | project:"),
		i(1, "tour_name"),
		t("."),
		f(function()
			return get_venue_from_h2()
		end, {}),
		t({ ".logistics", "" }),
		t({ "- [ ] Clean Up Rooms", "" }),
		t({ "    - [ ] Book", "" }),
		t({ "    - [ ] Log MT", "" }),
		t({ "    - [ ] Log Drive", "" }),
		i(0),
	}),

	-- ============================================================
	-- Advance Section (H3 with TaskWiki project)
	-- ============================================================
	s({
		trig = "advancesec",
		name = "Advance Section",
		dscr = "H3 Advance header with TaskWiki project and checklist",
	}, {
		t("### Advance | project:"),
		i(1, "tour_name"),
		t("."),
		f(function()
			return get_venue_from_h2()
		end, {}),
		t({ ".advance", "" }),
		t({ "- [ ] Received Tech Pack", "" }),
		t({ "- [ ] Hospitality", "" }),
		t({ "    - [ ] Dinner", "" }),
		t({ "    - [ ] Showers", "" }),
		t({ "- [ ] Personnel", "" }),
		t({ "    - [ ] Runner", "" }),
		t({ "    - [ ] Merch Seller", "" }),
		t({ "- [ ] Bus Info", "" }),
		t({ "    - [ ] Parking Instructions", "" }),
		t({ "    - [ ] Shore Power/Generator Restrictions", "" }),
		t({ "- [ ] Schedule Confirmed", "" }),
		i(0),
	}),

	-- ============================================================
	-- Combined Logistics + Advance (both sections at once)
	-- ============================================================
	s({
		trig = "showsections",
		name = "Show Sections (Logistics + Advance)",
		dscr = "Both Logistics and Advance H3 sections with shared tour name",
	}, {
		-- Logistics
		t("### Logistics | project:"),
		i(1, "tour_name"),
		t("."),
		f(function()
			return get_venue_from_h2()
		end, {}),
		t({ ".logistics", "" }),
		t({ "- [ ] Clean Up Rooms", "" }),
		t({ "    - [ ] Book", "" }),
		t({ "    - [ ] Log MT", "" }),
		t({ "    - [ ] Log Drive", "" }),
		t({ "", "" }),

		-- Advance (reuse tour name from first input)
		t("### Advance | project:"),
		f(function(args)
			return args[1][1] -- Reference the tour_name from i(1)
		end, { 1 }),
		t("."),
		f(function()
			return get_venue_from_h2()
		end, {}),
		t({ ".advance", "" }),
		t({ "- [ ] Received Tech Pack", "" }),
		t({ "- [ ] Hospitality", "" }),
		t({ "    - [ ] Dinner", "" }),
		t({ "    - [ ] Showers", "" }),
		t({ "- [ ] Personnel", "" }),
		t({ "    - [ ] Runner", "" }),
		t({ "    - [ ] Merch Seller", "" }),
		t({ "- [ ] Bus Info", "" }),
		t({ "    - [ ] Parking Instructions", "" }),
		t({ "    - [ ] Shore Power/Generator Restrictions", "" }),
		t({ "- [ ] Schedule Confirmed", "" }),
		i(0),
	}),
}

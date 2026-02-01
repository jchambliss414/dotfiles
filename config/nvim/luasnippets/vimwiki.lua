-- ~/.config/nvim/luasnippets/vimwiki.lua
-- Tour Management Snippets for VimWiki
-- Updated: Based on finalized templates

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

-- =============================================================================
-- HELPER FUNCTIONS
-- =============================================================================

-- Convert venue name to ID (spaces -> underscores, lowercase)
local function venue_to_id(args)
	local venue = args[1][1] or ""
	return venue:lower():gsub("%s+", "_"):gsub("-", "_")
end

-- Get venue from filename (e.g., "2026_0210_Folly-Theater_Kansas-City_MO" → "folly_theater")
local function get_venue_from_filename()
	local filename = vim.fn.expand("%:t:r")
	-- Pattern: YYYY_MMDD_Venue-Name_City_ST
	local venue = filename:match("^%d+_%d+_([^_]+)")
	if venue then
		return venue:lower():gsub("%-", "_")
	end
	return filename:lower():gsub("%-", "_"):gsub("%s+", "_")
end

-- Find nearest H2 heading and extract venue name
-- Parses format like "Feb-11: The Pageant - St. Louis, MO" → "the_pageant"
local function get_venue_from_h2()
	local current_line = vim.fn.line(".")
	for line_num = current_line - 1, 1, -1 do
		local line = vim.fn.getline(line_num)
		if line:match("^## ") then
			local venue = line:match("^## [^:]+:%s*([^-]+)")
			if venue then
				venue = vim.trim(venue)
				venue = venue:lower():gsub("%s+", "_"):gsub("[^%w_]", "")
				return venue
			else
				venue = line:gsub("^## ", "")
				venue = venue:lower():gsub("%s+", "_"):gsub("[^%w_]", "")
				return venue
			end
		end
	end
	return "venue"
end

-- =============================================================================
-- SNIPPETS
-- =============================================================================

return {

	-- =========================================================================
	-- FULL SHOW ADVANCE DOCUMENT
	-- =========================================================================
	s({
		trig = "show",
		name = "Full Show Advance Document",
		dscr = "Complete show page with all sections",
	}, {
		t("# "),
		i(1, "YYYY_MMDD"),
		t(" "),
		i(2, "Venue-Name"),
		t(" "),
		i(3, "City-Name"),
		t(" "),
		i(4, "ST"),
		t({ "", "", "" }),

		-- Advance Progress viewport
		t("## Advance Progress | project:"),
		i(5, "tour_name"),
		t(" venue:"),
		f(venue_to_id, { 2 }),
		t(" category:advance"),
		t({ "", "", "" }),
		t("* [ ] Advance Sent"),
		t({ "", "" }),
		t("* [ ] Recieved Tech Pack"),
		t({ "", "" }),
		t("* [ ] Personnel"),
		t({ "", "" }),
		t("   * [ ] Runner"),
		t({ "", "" }),
		t("   * [ ] Merch Seller"),
		t({ "", "" }),
		t("* [ ] Hospitality"),
		t({ "", "" }),
		t("   * [ ] Showers"),
		t({ "", "" }),
		t("   * [ ] Dinner"),
		t({ "", "" }),
		t("* [ ] Bus Info"),
		t({ "", "" }),
		t("   * [ ] Shore Power/Generator Restrictions"),
		t({ "", "" }),
		t("   * [ ] Parking Instructions"),
		t({ "", "" }),
		t("* [ ] Schedule Confirmed"),
		t({ "", "", "" }),

		-- Lodging Progress viewport
		t("## Lodging Progress | project:"),
		i(6, "tour_name"),
		t(" venue:"),
		f(venue_to_id, { 2 }),
		t(" category:lodging"),
		t({ "", "", "" }),
		t("* [ ] Clean Up/Driver Rooms"),
		t({ "", "" }),
		t("   * [ ] Researched"),
		t({ "", "" }),
		t("   * [ ] Booked"),
		t({ "", "" }),
		t("   * [ ] Logged in Drive"),
		t({ "", "" }),
		t("   * [ ] Logged in MT"),
		t({ "", "", "" }),

		-- Advance Information section
		t("## Advance Information"),
		t({ "", "", "" }),
		t("- Tech Pack"),
		t({ "", "", "" }),

		-- Hospo Info
		t("### Hospo Info"),
		t({ "", "", "" }),
		t("| Hospitality | Info |"),
		t({ "", "" }),
		t("| ----------- | ---- |"),
		t({ "", "" }),
		t("| Dinner:     |      |"),
		t({ "", "" }),
		t("| Showers:    |      |"),
		t({ "", "", "" }),
		t("| Wifi Network | Password |"),
		t({ "", "" }),
		t("| ------------ | -------- |"),
		t({ "", "" }),
		t("|              |          |"),
		t({ "", "", "" }),
		t("#### Hospo Notes"),
		t({ "", "", "" }),
		t("- Local Food Options"),
		t({ "", "", "" }),

		-- Merch/Personnel Info
		t("### Merch/Personnel Info"),
		t({ "", "", "" }),
		t("| Personnel     | Info |"),
		t({ "", "" }),
		t("| ------------- | ---- |"),
		t({ "", "" }),
		t("| Runner:       |      |"),
		t({ "", "" }),
		t("| Merch Seller: |      |"),
		t({ "", "", "" }),
		t("#### Merch/Personnel Notes"),
		t({ "", "", "" }),
		t("-"),
		t({ "", "", "" }),

		-- Lodging/Logistics section
		t("## Lodging/Logistics"),
		t({ "", "", "" }),
		t("* [ ] Clean Up/Driver Rooms"),
		t({ "", "" }),
		t("   * [ ] Researched"),
		t({ "", "" }),
		t("   * [ ] Booked"),
		t({ "", "" }),
		t("   * [ ] Logged in Drive"),
		t({ "", "" }),
		t("   * [ ] Logged in MT"),
		t({ "", "", "" }),

		-- Bus Info
		t("### Bus Info"),
		t({ "", "", "" }),
		t("- Parking location"),
		t({ "", "" }),
		t("- Shore power info"),
		t({ "", "" }),
		t("- Additional info in tech pack"),
		t({ "", "", "" }),

		-- Accommodations
		t("### Accommodations"),
		t({ "", "", "" }),
		t("Hotel contact/info"),
		t({ "", "", "" }),

		-- Schedule
		t("## Schedule"),
		t({ "", "", "" }),
		t("| Time    | Event              |"),
		t({ "", "" }),
		t("| ------- | ------------------ |"),
		t({ "", "" }),
		t("| 8:00am  | Bus arrival & park |"),
		t({ "", "" }),
		t("| 12:00pm | Venue access       |"),
		t({ "", "" }),
		t("| 1:00pm  | Load in            |"),
		t({ "", "" }),
		t("| 4:00pm  | Act 1 Sound Check  |"),
		t({ "", "" }),
		t("| 5:00pm  | Act 2 Sound Check  |"),
		t({ "", "" }),
		t("| 6:00pm  | Dinner             |"),
		t({ "", "" }),
		t("| 7:00pm  | Doors              |"),
		t({ "", "" }),
		t("| 8:00pm  | Set 1 (60)         |"),
		t({ "", "" }),
		t("| 9:00pm  | Changeover (15)    |"),
		t({ "", "" }),
		t("| 9:15pm  | Set 2 (60)         |"),
		t({ "", "" }),
		t("| 11:45pm | Curfew             |"),
		t({ "", "" }),
		t("| 5:00am  | Parking Lot Curfew |"),
		t({ "", "", "" }),

		-- Contacts
		t("## Contacts"),
		t({ "", "", "" }),
		t("| Contact | Position | Email | Phone |"),
		t({ "", "" }),
		t("| ------- | -------- | ----- | ----- |"),
		t({ "", "" }),
		t("| Name    | DOS      | email | phone |"),
		t({ "", "" }),
		t("|         |          |       |       |"),
		t({ "", "" }),
	}),

	-- =========================================================================
	-- SHOW SECTION FOR TOUR INDEX
	-- =========================================================================
	s({
		trig = "showsec",
		name = "Show Section for Tour Index",
		dscr = "H2 header with link + Lodging/Advance viewports",
	}, {
		t("## ["),
		i(1, "Mon-DD"),
		t(": "),
		i(2, "Venue Name"),
		t(" - "),
		i(3, "City"),
		t(", "),
		i(4, "ST"),
		t("]("),
		i(5, "YYYY_MMDD_Venue-Name_City_ST.md"),
		t(")"),
		t({ "", "", "" }),

		-- Lodging viewport (comes first)
		t("### Lodging | project:"),
		i(6, "tour_name"),
		t(" venue:"),
		f(venue_to_id, { 2 }),
		t(" category:lodging"),
		t({ "", "", "" }),
		t("* [ ] Driver/Clean Up Rooms"),
		t({ "", "" }),
		t("   * [ ] Book"),
		t({ "", "" }),
		t("   * [ ] Log Drive"),
		t({ "", "" }),
		t("   * [ ] Log MT"),
		t({ "", "", "" }),

		-- Advance viewport
		t("### Advance | project:"),
		i(7, "tour_name"),
		t(" venue:"),
		f(venue_to_id, { 2 }),
		t(" category:advance"),
		t({ "", "", "" }),
		t("* [ ] Advance sent"),
		t({ "", "" }),
		t("* [ ] Recieved Tech Pack"),
		t({ "", "" }),
		t("* [ ] Bus Info"),
		t({ "", "" }),
		t("   * [ ] Parking Instructions"),
		t({ "", "" }),
		t("   * [ ] Shore Power/Generator Restrictions"),
		t({ "", "" }),
		t("* [ ] Personnel"),
		t({ "", "" }),
		t("   * [ ] Merch Seller"),
		t({ "", "" }),
		t("   * [ ] Runner"),
		t({ "", "" }),
		t("* [ ] Hospitality"),
		t({ "", "" }),
		t("   * [ ] Showers"),
		t({ "", "" }),
		t("   * [ ] Dinner"),
		t({ "", "" }),
		t("* [ ] Schedule Confirmed"),
		t({ "", "" }),
	}),

	-- =========================================================================
	-- ADVANCE VIEWPORT WITH TASKS
	-- =========================================================================
	s({
		trig = "adv",
		name = "Advance Viewport",
		dscr = "H3 Advance viewport with standard tasks",
	}, {
		t("### Advance | project:"),
		i(1, "tour_name"),
		t(" venue:"),
		i(2, "venue_id"),
		t(" category:advance"),
		t({ "", "", "" }),
		t("* [ ] Advance sent"),
		t({ "", "" }),
		t("* [ ] Recieved Tech Pack"),
		t({ "", "" }),
		t("* [ ] Bus Info"),
		t({ "", "" }),
		t("   * [ ] Parking Instructions"),
		t({ "", "" }),
		t("   * [ ] Shore Power/Generator Restrictions"),
		t({ "", "" }),
		t("* [ ] Personnel"),
		t({ "", "" }),
		t("   * [ ] Merch Seller"),
		t({ "", "" }),
		t("   * [ ] Runner"),
		t({ "", "" }),
		t("* [ ] Hospitality"),
		t({ "", "" }),
		t("   * [ ] Showers"),
		t({ "", "" }),
		t("   * [ ] Dinner"),
		t({ "", "" }),
		t("* [ ] Schedule Confirmed"),
		t({ "", "" }),
	}),

	-- =========================================================================
	-- LODGING VIEWPORT WITH TASKS
	-- =========================================================================
	s({
		trig = "lodging",
		name = "Lodging Viewport",
		dscr = "H3 Lodging viewport with standard tasks",
	}, {
		t("### Lodging | project:"),
		i(1, "tour_name"),
		t(" venue:"),
		i(2, "venue_id"),
		t(" category:lodging"),
		t({ "", "", "" }),
		t("* [ ] Driver/Clean Up Rooms"),
		t({ "", "" }),
		t("   * [ ] Book"),
		t({ "", "" }),
		t("   * [ ] Log Drive"),
		t({ "", "" }),
		t("   * [ ] Log MT"),
		t({ "", "" }),
	}),

	-- =========================================================================
	-- DAY-OF SCHEDULE TABLE
	-- =========================================================================
	s({
		trig = "sched",
		name = "Schedule Table",
		dscr = "Day-of schedule template",
	}, {
		t("## Schedule"),
		t({ "", "", "" }),
		t("| Time    | Event              |"),
		t({ "", "" }),
		t("| ------- | ------------------ |"),
		t({ "", "" }),
		t("| 8:00am  | Bus arrival & park |"),
		t({ "", "" }),
		t("| 12:00pm | Venue access       |"),
		t({ "", "" }),
		t("| 1:00pm  | Load in            |"),
		t({ "", "" }),
		t("| 4:00pm  | Act 1 Sound Check  |"),
		t({ "", "" }),
		t("| 5:00pm  | Act 2 Sound Check  |"),
		t({ "", "" }),
		t("| 6:00pm  | Dinner             |"),
		t({ "", "" }),
		t("| 7:00pm  | Doors              |"),
		t({ "", "" }),
		t("| 8:00pm  | Set 1 (60)         |"),
		t({ "", "" }),
		t("| 9:00pm  | Changeover (15)    |"),
		t({ "", "" }),
		t("| 9:15pm  | Set 2 (60)         |"),
		t({ "", "" }),
		t("| 11:45pm | Curfew             |"),
		t({ "", "" }),
		t("| 5:00am  | Parking Lot Curfew |"),
		t({ "", "" }),
	}),

	-- =========================================================================
	-- CONTACTS TABLE
	-- =========================================================================
	s({
		trig = "contacts",
		name = "Contacts Table",
		dscr = "Venue contacts template",
	}, {
		t("## Contacts"),
		t({ "", "", "" }),
		t("| Contact | Position | Email | Phone |"),
		t({ "", "" }),
		t("| ------- | -------- | ----- | ----- |"),
		t({ "", "" }),
		t("|         | DOS      |       |       |"),
		t({ "", "" }),
		t("|         |          |       |       |"),
		t({ "", "" }),
		t("|         |          |       |       |"),
		t({ "", "" }),
	}),

	-- =========================================================================
	-- HOSPITALITY INFO SECTION
	-- =========================================================================
	s({
		trig = "hospo",
		name = "Hospitality Section",
		dscr = "Hospitality/personnel info tables",
	}, {
		t("### Hospo Info"),
		t({ "", "", "" }),
		t("| Hospitality | Info |"),
		t({ "", "" }),
		t("| ----------- | ---- |"),
		t({ "", "" }),
		t("| Dinner:     |      |"),
		t({ "", "" }),
		t("| Showers:    |      |"),
		t({ "", "", "" }),
		t("| Wifi Network | Password |"),
		t({ "", "" }),
		t("| ------------ | -------- |"),
		t({ "", "" }),
		t("|              |          |"),
		t({ "", "", "" }),
		t("- Local Food Options"),
		t({ "", "", "" }),
		t("| Personnel     | Info |"),
		t({ "", "" }),
		t("| ------------- | ---- |"),
		t({ "", "" }),
		t("| Runner:       |      |"),
		t({ "", "" }),
		t("| Merch Seller: |      |"),
		t({ "", "" }),
	}),

	-- =========================================================================
	-- BUS INFO SUBSECTION
	-- =========================================================================
	s({
		trig = "businfo",
		name = "Bus Info Section",
		dscr = "Bus parking and power details",
	}, {
		t("### Bus Info"),
		t({ "", "", "" }),
		t("- Parking:"),
		t({ "", "" }),
		t("- Shore Power:"),
		t({ "", "" }),
		t("- Additional info in tech pack"),
		t({ "", "" }),
	}),

	-- =========================================================================
	-- ADVANCE INFORMATION TABLES
	-- =========================================================================
	s({
		trig = "advinfo",
		name = "Advance Information",
		dscr = "Advance info with hospitality tables",
	}, {
		t("## Advance Information"),
		t({ "", "", "" }),
		t("- Tech Pack"),
		t({ "", "", "" }),
		t("| Hospitality | Info |"),
		t({ "", "" }),
		t("| ----------- | ---- |"),
		t({ "", "" }),
		t("| Dinner:     |      |"),
		t({ "", "" }),
		t("| Showers:    |      |"),
		t({ "", "", "" }),
		t("| Wifi Network | Password |"),
		t({ "", "" }),
		t("| ------------ | -------- |"),
		t({ "", "" }),
		t("|              |          |"),
		t({ "", "" }),
	}),

	-- =========================================================================
	-- TRAVEL AND LODGING SECTION
	-- =========================================================================
	s({
		trig = "travel",
		name = "Travel/Lodging Section",
		dscr = "Bus info and accommodations",
	}, {
		t("## Travel/Lodging"),
		t({ "", "", "" }),
		t("### Bus Info"),
		t({ "", "", "" }),
		t("- Parking location"),
		t({ "", "" }),
		t("- Shore power availability"),
		t({ "", "" }),
		t("- Additional info in tech pack"),
		t({ "", "", "" }),
		t("### Accommodations"),
		t({ "", "", "" }),
		t("Hotel contact/booking info"),
		t({ "", "" }),
	}),

	-- =========================================================================
	-- MINIMAL VIEWPORT HEADER
	-- =========================================================================
	s({
		trig = "vp",
		name = "Minimal Viewport",
		dscr = "Quick viewport header",
	}, {
		t("### "),
		i(1, "Header"),
		t(" | project:"),
		i(2, "tour_name"),
		t(" "),
		i(3, "filter"),
		t({ "", "" }),
	}),

	-- =========================================================================
	-- SINGLE TABLE ROW
	-- =========================================================================
	s({
		trig = "tr",
		name = "Table Row",
		dscr = "Single table row",
	}, {
		t("| "),
		i(1),
		t(" | "),
		i(2),
		t(" | "),
		i(3),
		t(" | "),
		i(4),
		t(" |"),
		t({ "", "" }),
	}),

	-- =========================================================================
	-- HOTEL RESEARCH PAGE
	-- =========================================================================
	s({
		trig = "hotels",
		name = "Hotel Research Page",
		dscr = "Full hotel research document",
	}, {
		t("# Hotel Research: "),
		i(1, "City"),
		t(", "),
		i(2, "ST"),
		t({ "", "", "" }),
		t("**Show:** "),
		i(3, "Mon DD, YYYY"),
		t(" - "),
		i(4, "Venue Name"),
		t({ "", "" }),
		t("**Rooms Needed:** 2 (Driver + Clean Up)"),
		t({ "", "" }),
		t("**Nights:** 1 (Check-in: "),
		i(5, "Mon DD"),
		t(", Check-out: "),
		i(6, "Mon DD"),
		t(")"),
		t({ "", "", "" }),
		t("---"),
		t({ "", "", "" }),
		t("## Quick Comparison"),
		t({ "", "", "" }),
		t("| Hotel   | Rate       | Est. Total | Distance | Parking | Cancel |"),
		t({ "", "" }),
		t("| ------- | ---------- | ---------- | -------- | ------- | ------ |"),
		t({ "", "" }),
		t("| Hotel 1 | $___/nt    | $___       | _._ mi   |         | __hr   |"),
		t({ "", "" }),
		t("| Hotel 2 | $___/nt    | $___       | _._ mi   |         | __hr   |"),
		t({ "", "" }),
		t("| Hotel 3 | $___/nt    | $___       | _._ mi   |         | __hr   |"),
		t({ "", "", "" }),
		t("---"),
		t({ "", "", "" }),
		t("## Hotel Name"),
		t({ "", "", "" }),
		t("_Add hotel details with `hotel` snippet_"),
		t({ "", "", "" }),
		t("---"),
		t({ "", "", "" }),
		t("## Selected Hotel"),
		t({ "", "", "" }),
		t("_Fill in after booking with `hotelbook` snippet_"),
		t({ "", "", "" }),
		t("---"),
		t({ "", "", "" }),
		t("## Research Notes"),
		t({ "", "", "" }),
		t("- Checked rates on: "),
		i(7, "Mon DD, YYYY"),
		t({ "", "" }),
		t("-"),
		t({ "", "" }),
	}),

	-- =========================================================================
	-- DETAILED SINGLE HOTEL ENTRY
	-- =========================================================================
	s({
		trig = "hotel",
		name = "Hotel Entry (Detailed)",
		dscr = "Complete hotel with all fields",
	}, {
		t("## "),
		i(1, "Hotel Name"),
		t({ "", "", "" }),
		t("| Hotel                 | Info                               |"),
		t({ "", "" }),
		t("| --------------------- | ---------------------------------- |"),
		t({ "", "" }),
		t("| **Website**           | ["),
		i(2, "website.com"),
		t("](https://"),
		i(3, "website.com"),
		t(") |"),
		t({ "", "" }),
		t("| **Phone**             | "),
		i(4, "(___) ___-____"),
		t(" |"),
		t({ "", "" }),
		t("| **Address**           | "),
		i(5, "Street, City, ST ZIP"),
		t(" |"),
		t({ "", "" }),
		t("| **Distance to Venue** | "),
		i(6, "_._ mi"),
		t(" |"),
		t({ "", "", "" }),
		t("### Rates"),
		t({ "", "", "" }),
		t("| Room Type     | Listed Rate   | Notes |"),
		t({ "", "" }),
		t("| ------------- | ------------- | ----- |"),
		t({ "", "" }),
		t("| Standard King | $___/night    |       |"),
		t({ "", "" }),
		t("| Double Queen  | $___/night    |       |"),
		t({ "", "" }),
		t("| Special Rate  | $___/night    |       |"),
		t({ "", "", "" }),
		t("### Cost Estimate"),
		t({ "", "", "" }),
		t("| Item        | Calculation              | Amount   |"),
		t({ "", "" }),
		t("| ----------- | ------------------------ | -------- |"),
		t({ "", "" }),
		t("| Rate w/ Tax | $___ × 1 night × 2 rooms | $___     |"),
		t({ "", "" }),
		t("| Parking     | $___ × _ nights          | $___     |"),
		t({ "", "" }),
		t("| **Total**   |                          | **$___** |"),
		t({ "", "", "" }),
		t("### Parking"),
		t({ "", "", "" }),
		t("- Self-parking: Free / $__/night"),
		t({ "", "" }),
		t("- Bus parking:"),
		t({ "", "", "" }),
		t("### Cancellation Policy"),
		t({ "", "", "" }),
		t("- Free cancellation until __ hours before check-in"),
		t({ "", "", "" }),
		t("### Notes"),
		t({ "", "", "" }),
		t("-"),
		t({ "", "", "" }),
		t("---"),
		t({ "", "" }),
	}),

	-- =========================================================================
	-- MINIMAL SINGLE HOTEL ENTRY
	-- =========================================================================
	s({
		trig = "hotelmin",
		name = "Hotel Entry (Minimal)",
		dscr = "Quick bullet-point format",
	}, {
		t("## "),
		i(1, "Hotel Name"),
		t({ "", "", "" }),
		t("- **Website:** [](https://)"),
		t({ "", "" }),
		t("- **Phone:**"),
		t({ "", "" }),
		t("- **Rate:** $___/night"),
		t({ "", "" }),
		t("- **Distance:** _._ mi"),
		t({ "", "" }),
		t("- **Parking:** Free / $__"),
		t({ "", "" }),
		t("- **Bus Parking:**"),
		t({ "", "" }),
		t("- **Cancel:** __hr before"),
		t({ "", "" }),
		t("- **Est. Total:** $___"),
		t({ "", "" }),
		t("- **Notes:**"),
		t({ "", "" }),
	}),

	-- =========================================================================
	-- BOOKED HOTEL RECORD
	-- =========================================================================
	s({
		trig = "hotelbook",
		name = "Booked Hotel Record",
		dscr = "Confirmation details after booking",
	}, {
		t("## Selected Hotel"),
		t({ "", "", "" }),
		t("| Field                  | Info                |"),
		t({ "", "" }),
		t("| ---------------------- | ------------------- |"),
		t({ "", "" }),
		t("| **Hotel**              | "),
		i(1, "Hotel Name"),
		t(" |"),
		t({ "", "" }),
		t("| **Confirmation #**     | "),
		i(2),
		t(" |"),
		t({ "", "" }),
		t("| **Confirmation Email** | "),
		i(3),
		t(" |"),
		t({ "", "" }),
		t("| **Check-in**           | "),
		i(4, "Mon DD, YYYY"),
		t(" @ 3pm |"),
		t({ "", "" }),
		t("| **Check-out**          | "),
		i(5, "Mon DD, YYYY"),
		t(" @ 11am |"),
		t({ "", "" }),
		t("| **Rooms**              | 2 × Standard King |"),
		t({ "", "" }),
		t("| **Total Cost**         | $"),
		i(6),
		t(" |"),
		t({ "", "" }),
		t("| **Booked On**          | "),
		i(7),
		t(" |"),
		t({ "", "" }),
		t("| **Payment**            | Card on file |"),
		t({ "", "", "" }),
		t("### Contact for Changes"),
		t({ "", "", "" }),
		t("- "),
		i(8, "Contact name/email"),
		t({ "", "" }),
		t("- "),
		i(9, "Phone"),
		t({ "", "" }),
		t("- Cancel by: "),
		i(10, "Date/Time"),
		t({ "", "" }),
	}),

	-- =========================================================================
	-- COST ESTIMATE TABLE
	-- =========================================================================
	s({
		trig = "costcalc",
		name = "Cost Estimate Table",
		dscr = "Room/parking/tax calculation",
	}, {
		t("### Cost Estimate"),
		t({ "", "", "" }),
		t("| Item        | Calculation              | Amount   |"),
		t({ "", "" }),
		t("| ----------- | ------------------------ | -------- |"),
		t({ "", "" }),
		t("| Rate w/ Tax | $___ × 1 night × 2 rooms | $___     |"),
		t({ "", "" }),
		t("| Parking     | $___ × _ nights          | $___     |"),
		t({ "", "" }),
		t("| **Total**   |                          | **$___** |"),
		t({ "", "" }),
	}),

	-- =========================================================================
	-- HOTEL COMPARISON ROW
	-- =========================================================================
	s({
		trig = "hotelrow",
		name = "Hotel Comparison Row",
		dscr = "Single row for comparison table",
	}, {
		t("| "),
		i(1, "Hotel Name"),
		t(" | $"),
		i(2, "___"),
		t("/nt | $"),
		i(3, "___"),
		t(" | "),
		i(4, "_._"),
		t(" mi | "),
		i(5, "Free/$$"),
		t(" | "),
		i(6, "__"),
		t("hr |"),
		t({ "", "" }),
	}),
}

-- =============================================================================
-- SNIPPET REFERENCE
-- =============================================================================
--
-- FULL DOCUMENTS:
--   show       → Complete show advance document (all sections)
--   showsec    → Show section for tour index (link + viewports)
--
-- TASK VIEWPORTS:
--   adv        → Advance tasks viewport
--   lodging    → Lodging tasks viewport
--   vp         → Minimal viewport header
--
-- REFERENCE SECTIONS:
--   advinfo    → Advance information tables (wifi, hospitality)
--   hospo      → Hospitality/personnel info section
--   travel     → Travel/Lodging section (bus + accommodations)
--   businfo    → Just bus info subsection
--   sched      → Day-of schedule table
--   contacts   → Contacts table
--
-- HOTEL RESEARCH:
--   hotels     → Full hotel research page
--   hotel      → Detailed single hotel entry
--   hotelmin   → Minimal hotel entry (bullet format)
--   hotelbook  → Booked hotel confirmation record
--   costcalc   → Cost estimate table
--   hotelrow   → Single row for comparison table
--
-- UTILITIES:
--   tr         → Table row (for adding to existing tables)
--
-- =============================================================================

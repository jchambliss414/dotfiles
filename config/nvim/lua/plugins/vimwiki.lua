-- ###########################################################################################
--                          VIMWIKI CONFIGURATION
-- ###########################################################################################

-- ######################################################################################
--                            FUNCTIONS SECTION
-- ######################################################################################

-- ############################################################################
--                    Link to Existing Wiki Page Function
-- ############################################################################
-- Search all configured wikis and create a link to an existing page
-- Supports multiple wikis with relative path calculation

local function get_all_wiki_paths()
	local wiki_list = vim.g.vimwiki_list or {}
	local paths = {}
	for _, wiki in ipairs(wiki_list) do
		if wiki.path then
			table.insert(paths, vim.fn.expand(wiki.path))
		end
	end
	return paths
end

local function calculate_relative_path(from_dir, to_file)
	-- Use realpath to calculate relative path between directories
	local handle = io.popen(
		"realpath --relative-to="
			.. vim.fn.shellescape(from_dir)
			.. " "
			.. vim.fn.shellescape(to_file)
			.. " 2>/dev/null"
	)
	if not handle then
		return to_file
	end
	local rel_path = handle:read("*a"):gsub("%s+$", "")
	handle:close()
	return rel_path ~= "" and rel_path or to_file
end

local function link_word_to_wiki_page()
	local word = vim.fn.expand("<cword>")
	if word == "" then
		vim.notify("No word under cursor", vim.log.levels.WARN)
		return
	end

	local wiki_paths = get_all_wiki_paths()
	if #wiki_paths == 0 then
		vim.notify("No wikis configured in vimwiki_list", vim.log.levels.ERROR)
		return
	end

	local current_dir = vim.fn.expand("%:p:h")

	-- Collect all markdown files from all wikis using fdfind
	local all_files = {}
	for _, wiki_path in ipairs(wiki_paths) do
		local handle = io.popen("fdfind -e md -t f . " .. vim.fn.shellescape(wiki_path) .. " 2>/dev/null")
		if handle then
			for file in handle:lines() do
				table.insert(all_files, file)
			end
			handle:close()
		end
	end

	if #all_files == 0 then
		vim.notify("No markdown files found in wikis", vim.log.levels.WARN)
		return
	end

	-- Build items for Snacks picker
	local items = {}
	for _, file in ipairs(all_files) do
		table.insert(items, {
			text = file,
			file = file,
		})
	end

	Snacks.picker.pick({
		title = "Link '" .. word .. "' to wiki page",
		items = items,
		format = function(item)
			-- Show path relative to home for cleaner display
			return { { vim.fn.fnamemodify(item.file, ":~:.") } }
		end,
		confirm = function(picker, item)
			picker:close()
			if item and item.file then
				local rel_path = calculate_relative_path(current_dir, item.file)
				local link = string.format("[%s](%s)", word, rel_path)
				vim.fn.setreg("z", link)
				vim.cmd('normal! viw"zp')
				vim.notify("Linked → " .. rel_path, vim.log.levels.INFO)
			end
		end,
	})
end

local function link_selection_to_wiki_page()
	-- Get visual selection
	local saved_reg = vim.fn.getreg('"')
	local saved_regtype = vim.fn.getregtype('"')
	vim.cmd('noau normal! "vy')
	local text = vim.fn.getreg('"')
	vim.fn.setreg('"', saved_reg, saved_regtype)
	text = text:gsub("[\n\r]", "")

	if text == "" then
		vim.notify("No text selected", vim.log.levels.WARN)
		return
	end

	local wiki_paths = get_all_wiki_paths()
	if #wiki_paths == 0 then
		vim.notify("No wikis configured in vimwiki_list", vim.log.levels.ERROR)
		return
	end

	local current_dir = vim.fn.expand("%:p:h")

	-- Collect all markdown files from all wikis
	local all_files = {}
	for _, wiki_path in ipairs(wiki_paths) do
		local handle = io.popen("fdfind -e md -t f . " .. vim.fn.shellescape(wiki_path) .. " 2>/dev/null")
		if handle then
			for file in handle:lines() do
				table.insert(all_files, file)
			end
			handle:close()
		end
	end

	if #all_files == 0 then
		vim.notify("No markdown files found in wikis", vim.log.levels.WARN)
		return
	end

	local items = {}
	for _, file in ipairs(all_files) do
		table.insert(items, {
			text = file,
			file = file,
		})
	end

	Snacks.picker.pick({
		title = "Link '" .. text .. "' to wiki page",
		items = items,
		format = function(item)
			return { { vim.fn.fnamemodify(item.file, ":~:.") } }
		end,
		confirm = function(picker, item)
			picker:close()
			if item and item.file then
				local rel_path = calculate_relative_path(current_dir, item.file)
				local link = string.format("[%s](%s)", text, rel_path)
				vim.fn.setreg("z", link)
				vim.cmd('normal! gv"zp')
				vim.notify("Linked → " .. rel_path, vim.log.levels.INFO)
			end
		end,
	})
end

-- ############################################################################
--   end             Link to Existing Wiki Page Function                  end
-- ############################################################################

-- ############################################################################
--                       Link to URL from Clipboard
-- ############################################################################
-- Create a markdown link using clipboard contents as the URL

local function is_valid_url(str)
	return str:match("^https?://") ~= nil
end

local function link_word_to_clipboard_url()
	local word = vim.fn.expand("<cword>")
	if word == "" then
		vim.notify("No word under cursor", vim.log.levels.WARN)
		return
	end

	local clipboard = vim.fn.getreg("+"):gsub("%s+$", ""):gsub("^%s+", "")
	if not is_valid_url(clipboard) then
		vim.notify("Clipboard doesn't contain a valid URL", vim.log.levels.ERROR)
		return
	end

	local link = string.format("[%s](%s)", word, clipboard)
	vim.fn.setreg("z", link)
	vim.cmd('normal! viw"zp')
	vim.notify("Linked → " .. clipboard:sub(1, 50) .. (clipboard:len() > 50 and "..." or ""), vim.log.levels.INFO)
end

local function link_selection_to_clipboard_url()
	local saved_reg = vim.fn.getreg('"')
	local saved_regtype = vim.fn.getregtype('"')
	vim.cmd('noau normal! "vy')
	local text = vim.fn.getreg('"')
	vim.fn.setreg('"', saved_reg, saved_regtype)
	text = text:gsub("[\n\r]", "")

	if text == "" then
		vim.notify("No text selected", vim.log.levels.WARN)
		return
	end

	local clipboard = vim.fn.getreg("+"):gsub("%s+$", ""):gsub("^%s+", "")
	if not is_valid_url(clipboard) then
		vim.notify("Clipboard doesn't contain a valid URL", vim.log.levels.ERROR)
		return
	end

	local link = string.format("[%s](%s)", text, clipboard)
	vim.fn.setreg("z", link)
	vim.cmd('normal! gv"zp')
	vim.notify("Linked → " .. clipboard:sub(1, 50) .. (clipboard:len() > 50 and "..." or ""), vim.log.levels.INFO)
end

-- ############################################################################
--  end                  Link to URL from Clipboard                        end
-- ############################################################################

-- ############################################################################
--                    Reference-Style Link Helpers
-- ############################################################################
-- Reference links use [text] inline with [text]: target at end of file
-- This keeps lines short while preserving full URLs/paths

local function append_reference_to_file(ref_id, target)
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local total_lines = #lines

	local ref_entry = "[" .. ref_id .. "]: " .. target
	local ref_pattern = "^%[" .. vim.pesc(ref_id) .. "%]:"

	-- Check if reference already exists and update it
	for i, line in ipairs(lines) do
		if line:match(ref_pattern) then
			vim.api.nvim_buf_set_lines(bufnr, i - 1, i, false, { ref_entry })
			vim.notify("Updated existing reference [" .. ref_id .. "]", vim.log.levels.INFO)
			return
		end
	end

	-- Find the "## Reference Links" section
	local ref_section_line = nil
	for i, line in ipairs(lines) do
		if line:match("^##%s+Reference%s+Links%s*$") then
			ref_section_line = i
			break
		end
	end

	if ref_section_line then
		-- Find the end of the reference section (next heading or EOF)
		local insert_line = total_lines
		for i = ref_section_line + 1, total_lines do
			if lines[i]:match("^#") then
				-- Found next heading, insert before it
				insert_line = i - 1
				break
			end
		end
		-- Insert the new reference at the end of the section
		vim.api.nvim_buf_set_lines(bufnr, insert_line, insert_line, false, { ref_entry })
	else
		-- Create the Reference Links section at end of file
		local new_lines = {}
		local last_line = lines[total_lines] or ""

		-- Add blank lines for separation
		if last_line ~= "" then
			table.insert(new_lines, "")
		end
		table.insert(new_lines, "")
		table.insert(new_lines, "## Reference Links")
		table.insert(new_lines, ref_entry)

		vim.api.nvim_buf_set_lines(bufnr, total_lines, total_lines, false, new_lines)
	end
end

-- ############################################################################
--                  Reference-Style Link to URL from Clipboard
-- ############################################################################

local function reflink_word_to_clipboard_url()
	local word = vim.fn.expand("<cword>")
	if word == "" then
		vim.notify("No word under cursor", vim.log.levels.WARN)
		return
	end

	local clipboard = vim.fn.getreg("+"):gsub("%s+$", ""):gsub("^%s+", "")
	if not is_valid_url(clipboard) then
		vim.notify("Clipboard doesn't contain a valid URL", vim.log.levels.ERROR)
		return
	end

	-- Replace word with explicit reference-style link [word][word]
	local ref_link = string.format("[%s][%s]", word, word)
	vim.fn.setreg("z", ref_link)
	vim.cmd('normal! viw"zp')

	-- Append reference definition to Reference Links section
	append_reference_to_file(word, clipboard)
	vim.notify("Ref link → [" .. word .. "]: " .. clipboard:sub(1, 40) .. "...", vim.log.levels.INFO)
end

local function reflink_selection_to_clipboard_url()
	local saved_reg = vim.fn.getreg('"')
	local saved_regtype = vim.fn.getregtype('"')
	vim.cmd('noau normal! "vy')
	local text = vim.fn.getreg('"')
	vim.fn.setreg('"', saved_reg, saved_regtype)
	text = text:gsub("[\n\r]", "")

	if text == "" then
		vim.notify("No text selected", vim.log.levels.WARN)
		return
	end

	local clipboard = vim.fn.getreg("+"):gsub("%s+$", ""):gsub("^%s+", "")
	if not is_valid_url(clipboard) then
		vim.notify("Clipboard doesn't contain a valid URL", vim.log.levels.ERROR)
		return
	end

	-- Replace selection with explicit reference-style link [text][text]
	local ref_link = string.format("[%s][%s]", text, text)
	vim.fn.setreg("z", ref_link)
	vim.cmd('normal! gv"zp')

	-- Append reference definition to Reference Links section
	append_reference_to_file(text, clipboard)
	vim.notify("Ref link → [" .. text .. "]: " .. clipboard:sub(1, 40) .. "...", vim.log.levels.INFO)
end

-- ############################################################################
--                  Reference-Style Link to Wiki Page (Search)
-- ############################################################################

local function reflink_word_to_wiki_page()
	local word = vim.fn.expand("<cword>")
	if word == "" then
		vim.notify("No word under cursor", vim.log.levels.WARN)
		return
	end

	local wiki_paths = get_all_wiki_paths()
	if #wiki_paths == 0 then
		vim.notify("No wikis configured in vimwiki_list", vim.log.levels.ERROR)
		return
	end

	local current_dir = vim.fn.expand("%:p:h")

	local all_files = {}
	for _, wiki_path in ipairs(wiki_paths) do
		local handle = io.popen("fdfind -e md -t f . " .. vim.fn.shellescape(wiki_path) .. " 2>/dev/null")
		if handle then
			for file in handle:lines() do
				table.insert(all_files, file)
			end
			handle:close()
		end
	end

	if #all_files == 0 then
		vim.notify("No markdown files found in wikis", vim.log.levels.WARN)
		return
	end

	local items = {}
	for _, file in ipairs(all_files) do
		table.insert(items, { text = file, file = file })
	end

	Snacks.picker.pick({
		title = "Ref-link '" .. word .. "' to wiki page",
		items = items,
		format = function(item)
			return { { vim.fn.fnamemodify(item.file, ":~:.") } }
		end,
		confirm = function(picker, item)
			picker:close()
			if item and item.file then
				local rel_path = calculate_relative_path(current_dir, item.file)

				-- Replace word with explicit reference-style link [word][word]
				local ref_link = string.format("[%s][%s]", word, word)
				vim.fn.setreg("z", ref_link)
				vim.cmd('normal! viw"zp')

				-- Append reference definition to Reference Links section
				append_reference_to_file(word, rel_path)
				vim.notify("Ref link → [" .. word .. "]: " .. rel_path, vim.log.levels.INFO)
			end
		end,
	})
end

local function reflink_selection_to_wiki_page()
	-- Get visual selection
	local saved_reg = vim.fn.getreg('"')
	local saved_regtype = vim.fn.getregtype('"')
	vim.cmd('noau normal! "vy')
	local text = vim.fn.getreg('"')
	vim.fn.setreg('"', saved_reg, saved_regtype)
	text = text:gsub("[\n\r]", "")

	if text == "" then
		vim.notify("No text selected", vim.log.levels.WARN)
		return
	end

	local wiki_paths = get_all_wiki_paths()
	if #wiki_paths == 0 then
		vim.notify("No wikis configured in vimwiki_list", vim.log.levels.ERROR)
		return
	end

	local current_dir = vim.fn.expand("%:p:h")

	local all_files = {}
	for _, wiki_path in ipairs(wiki_paths) do
		local handle = io.popen("fdfind -e md -t f . " .. vim.fn.shellescape(wiki_path) .. " 2>/dev/null")
		if handle then
			for file in handle:lines() do
				table.insert(all_files, file)
			end
			handle:close()
		end
	end

	if #all_files == 0 then
		vim.notify("No markdown files found in wikis", vim.log.levels.WARN)
		return
	end

	local items = {}
	for _, file in ipairs(all_files) do
		table.insert(items, { text = file, file = file })
	end

	Snacks.picker.pick({
		title = "Ref-link '" .. text .. "' to wiki page",
		items = items,
		format = function(item)
			return { { vim.fn.fnamemodify(item.file, ":~:.") } }
		end,
		confirm = function(picker, item)
			picker:close()
			if item and item.file then
				local rel_path = calculate_relative_path(current_dir, item.file)

				-- Replace selection with explicit reference-style link [text][text]
				local ref_link = string.format("[%s][%s]", text, text)
				vim.fn.setreg("z", ref_link)
				vim.cmd('normal! gv"zp')

				-- Append reference definition to Reference Links section
				append_reference_to_file(text, rel_path)
				vim.notify("Ref link → [" .. text .. "]: " .. rel_path, vim.log.levels.INFO)
			end
		end,
	})
end

-- ############################################################################
--                  Follow Reference-Style Links
-- ############################################################################
-- Workaround: find the reference definition and run gx on the URL

local function follow_reference_link()
	local line = vim.fn.getline(".")
	local col = vim.fn.col(".")

	-- Try to extract reference ID from [label][ref] pattern at cursor position
	local ref_id = nil

	-- Find all [label][ref] patterns on this line and check if cursor is inside one
	local search_start = 1
	while true do
		local s, e, label, ref = line:find("%[([^%]]+)%]%[([^%]]+)%]", search_start)
		if not s then
			break
		end

		if col >= s and col <= e then
			ref_id = ref
			break
		end
		search_start = e + 1
	end

	if not ref_id then
		vim.notify("No reference link under cursor", vim.log.levels.WARN)
		return
	end

	-- Search buffer for the reference definition [ref_id]: URL
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local ref_pattern = "^%[" .. vim.pesc(ref_id) .. "%]:%s*(.+)$"

	local url = nil
	for _, buf_line in ipairs(lines) do
		local match = buf_line:match(ref_pattern)
		if match then
			url = match:gsub("^%s+", ""):gsub("%s+$", "") -- trim whitespace
			break
		end
	end

	if not url then
		vim.notify("Reference [" .. ref_id .. "] not found", vim.log.levels.ERROR)
		return
	end

	-- Open URL using wslview (for WSL) or vim.ui.open as fallback
	if url:match("^https?://") then
		vim.fn.jobstart({ "wslview", url }, { detach = true })
		vim.notify("Opening: " .. url:sub(1, 50) .. "...", vim.log.levels.INFO)
	else
		-- For non-URL targets (wiki pages), use vim.ui.open or just notify
		vim.ui.open(url)
	end
end

-- ############################################################################
--  end               Reference-Style Link Functions                      end
-- ############################################################################

-- ############################################################################
--                       Event Link Creation Function
-- ############################################################################
-- Transform event text to filename
-- Input:  "Feb-10: Folly Theater - Kansas City, MO"
-- Output: "021026_Folly-Theater_Kansas-City_MO.md"

local event_months = {
	Jan = "01",
	Feb = "02",
	Mar = "03",
	Apr = "04",
	May = "05",
	Jun = "06",
	Jul = "07",
	Aug = "08",
	Sep = "09",
	Oct = "10",
	Nov = "11",
	Dec = "12",
}

local function transform_event_to_filename(text)
	-- Pattern: "Mon-DD: Venue Name - City Name, ST"
	local month_abbr, day, venue, city, state = text:match("^(%a+)%-(%d+):%s*(.-)%s*%-%s*(.-),%s*(%a+)$")

	if not month_abbr then
		return nil, "Could not parse. Expected format: 'Mon-DD: Venue - City, ST'"
	end

	local month_num = event_months[month_abbr]
	if not month_num then
		return nil, "Unknown month: " .. month_abbr
	end

	-- Pad day to 2 digits
	day = string.format("%02d", tonumber(day))

	-- Transform venue and city (spaces → hyphens)
	local venue_clean = venue:gsub("%s+", "-")
	local city_clean = city:gsub("%s+", "-")

	-- Build filename: MMDDYY_Venue-Name_City-Name_ST.md
	local year = "26" -- Update manually each year
	local filename = string.format("%s%s%s_%s_%s_%s.md", month_num, day, year, venue_clean, city_clean, state)

	return filename
end

local function get_visual_selection()
	local saved_reg = vim.fn.getreg('"')
	local saved_regtype = vim.fn.getregtype('"')
	vim.cmd("noau normal! y")
	local text = vim.fn.getreg('"')
	vim.fn.setreg('"', saved_reg, saved_regtype)
	return text
end

local function create_event_link()
	local text = get_visual_selection()
	text = text:gsub("[\n\r]", "")

	local filename, err = transform_event_to_filename(text)
	if not filename then
		vim.notify(err or "Unknown error", vim.log.levels.ERROR)
		return
	end

	local link = string.format("[%s](%s)", text, filename)
	vim.fn.setreg("z", link)
	vim.cmd('normal! gv"zp')
	vim.notify("Created link → " .. filename, vim.log.levels.INFO)
end

-- ############################################################################
--  end                  Event Link Creation Function                     end
-- ############################################################################

-- ######################################################################################
--  end                       FUNCTIONS SECTION                           end
-- ######################################################################################

-- ######################################################################################
--                         CONFIGURATION SECTION
-- ######################################################################################

return {
	"vimwiki/vimwiki",
	branch = "dev",
	event = "VeryLazy",
	keys = {
		-- Opens the default wiki index (replaces <leader>ww)
		{ "<leader>vw", "<Plug>VimwikiIndex", desc = "Open Wiki Index" },
		-- Opens the diary index (replaces <leader>wi)
		{ "<leader>vdd", "<Plug>VimwikiDiaryIndex", desc = "Open Diary Index" },
		-- Opens today's diary entry (replaces <leader>w<leader>w)
		{ "<leader>vdt", "<Plug>VimwikiMakeDiaryNote", desc = "Open Today's Diary" },
		-- Opens tomorrow's diary entry
		{ "<leader>vdT", "<Plug>VimwikiMakeTomorrowDiaryNote", desc = "Open Tomorrow's Diary" },
		-- Opens yesterday's diary entry
		{ "<leader>vdy", "<Plug>VimwikiMakeYesterdayDiaryNote", desc = "Open Yesterday's Diary" },

		-- Update diary section (delete old, insert new)
		{ "<leader>vd<leader>u", "<Plug>VimwikiDiaryGenerateLinks", desc = "Update Diary Section" },

		-- Delete current wiki page
		{ "<leader>v<leader>d", "<Plug>VimwikiDeleteFile", desc = "Delete Current Page" },

		-- Rename current wiki page
		{ "<leader>v<leader>r", "<Plug>VimwikiRenameFile", desc = "Rename Current Page" },

		-- Task Navigation
		{ "<A-Tab>", "<Plug>VimwikiNextTask", desc = "Go to Next Unfinished Task" },

		-- Insert Table
		{ "<leader>vt", ":VimwikiTable ", desc = "Insert Table" },
		{ "<leader>vT", ":VimwikiTable 2 2<CR>", desc = "Insert Table" },

		-- GoBackLink mappings
		{
			"<BS>",
			function()
				local current_buf = vim.fn.bufnr("%")
				vim.cmd("silent update") -- Save if modified
				vim.cmd("VimwikiGoBackLink")
				-- Only delete if we actually navigated away
				if vim.fn.bufnr("%") ~= current_buf then
					vim.cmd("bdelete " .. current_buf)
				end
			end,
			desc = "Go back, save & close buffer",
			ft = "vimwiki",
		},
		{
			"<S-BS>",
			"<Plug>VimwikiGoBackLink",
			desc = "Go back (keep buffer open)",
			ft = "vimwiki",
		},
		-- Create event link from visual selection
		{
			"<leader><CR>",
			create_event_link,
			mode = "v",
			desc = "Create Formatted Event Link",
			ft = "vimwiki",
		},
		-- Follow reference link and close source buffer
		{
			"<leader><C-CR>",
			function()
				local current_buf = vim.fn.bufnr("%")
				vim.cmd("silent update") -- Save if modified
				vim.cmd("VimwikiFollowLink")
				-- Only delete if we actually navigated away
				if vim.fn.bufnr("%") ~= current_buf then
					vim.cmd("bdelete " .. current_buf)
				end
			end,
			desc = "Follow reference link, close source",
			ft = "vimwiki",
		},
		-- Follow inline link and close source buffer
		{
			"<leader><S-CR>",
			function()
				local line = vim.fn.getline(".")
				local col = vim.fn.col(".")

				-- Find markdown inline link [text](path) around cursor position
				local start_pos = 1
				local filepath = nil

				while true do
					local s, e, captured_path = line:find("%[.-%]%((.-)%)", start_pos)
					if not s then
						break
					end
					if col >= s and col <= e then
						filepath = captured_path
						break
					end
					start_pos = e + 1
				end

				if not filepath then
					vim.notify("No inline link found under cursor", vim.log.levels.WARN)
					return
				end

				local current_buf = vim.fn.bufnr("%")
				vim.cmd("silent update") -- Save if modified

				-- Open as wiki file
				local current_dir = vim.fn.expand("%:p:h")
				local full_path = current_dir .. "/" .. filepath
				vim.cmd("edit " .. vim.fn.fnameescape(full_path))
				-- Close source buffer after edit completes
				vim.schedule(function()
					if vim.api.nvim_buf_is_valid(current_buf) and vim.fn.bufnr("%") ~= current_buf then
						vim.cmd("bdelete " .. current_buf)
					end
				end)
			end,
			desc = "Follow inline link, close source",
			ft = "vimwiki",
		},

		-- ========== Inline Links ==========
		-- Link word/selection to existing wiki page (searches all wikis)
		{
			"<leader>vls",
			link_word_to_wiki_page,
			desc = "Search Wikis for Link",
			ft = "vimwiki",
		},
		{
			"<leader>vls",
			link_selection_to_wiki_page,
			mode = "v",
			desc = "Search Wikis for Link",
			ft = "vimwiki",
		},
		-- Link word/selection to URL from clipboard
		{
			"<leader>vlu",
			link_word_to_clipboard_url,
			desc = "Create Link from URL",
			ft = "vimwiki",
		},
		{
			"<leader>vlu",
			link_selection_to_clipboard_url,
			mode = "v",
			desc = "Create Link from URL",
			ft = "vimwiki",
		},

		-- ========== Reference-Style Links ==========
		-- Reference link to wiki page (searches all wikis)
		{
			"<leader>vlS",
			reflink_word_to_wiki_page,
			desc = "Ref-Link: Search Wikis",
			ft = "vimwiki",
		},
		{
			"<leader>vlS",
			reflink_selection_to_wiki_page,
			mode = "v",
			desc = "Ref-Link: Search Wikis",
			ft = "vimwiki",
		},
		-- Reference link to URL from clipboard
		{
			"<leader>vlU",
			reflink_word_to_clipboard_url,
			desc = "Ref-Link: from URL",
			ft = "vimwiki",
		},
		{
			"<leader>vlU",
			reflink_selection_to_clipboard_url,
			mode = "v",
			desc = "Ref-Link: from URL",
			ft = "vimwiki",
		},
	},
	enabled = true,

	init = function() --replace 'config' with 'init'
		vim.g.vimwiki_folding = "custom"
		vim.g.vimwiki_list = {
			{
				path = "/shared/vimwiki/",
				syntax = "markdown",
				ext = ".md",
				links_space_char = "_",
				auto_generate_links = 1,
			},
		}
		-- vim.g.vimwiki_ext2syntax = {}
		vim.g.vimwiki_autowriteall = 1
		vim.g.vimwiki_map_prefix = "<leader>v"
		vim.g.vimwiki_auto_header = 1
		vim.g.vimwiki_global_ext = 0
		vim.g.vimwiki_split_action = "stay"
		vim.g.vimwiki_conceallevel = 2
		vim.g.vimwiki_markdown_link_ext = 1
		-- TaskWiki Configs
		vim.g.taskwiki_markup_syntax = "markdown"
		vim.g.taskwiki_report_name = "list"
		-- URL Link Handler
		vim.cmd([[
      function! VimwikiLinkHandler(link)
        if a:link =~# '^https\?://'
          execute 'silent !wslview ' . shellescape(a:link) . ' &'
          return 1
        endif
        return 0
      endfunction
      ]])

		-- Leaving blank line above folded headers
		vim.cmd([[
      function! VimwikiFoldLevelCustom(lnum)
         let pounds = strlen(matchstr(getline(a:lnum), '^#\+'))
         if (pounds)
            return '>' . pounds  " start a fold level
         endif
         if getline(a:lnum) =~? '\v^\s*$'
            " Don't fold blank line BEFORE a header
            if (strlen(matchstr(getline(a:lnum + 1), '^#\+')))

               return '-1'
            endif
            " Don't fold blank line AFTER a header
            if (strlen(matchstr(getline(a:lnum - 1), '^#\+')))
               return '-1'
            endif
         endif
         return '=' " return previous fold level
      endfunction
      ]])
	end,
}

local map = vim.keymap.set

-- Better escape
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Resolving common <leader>w conflicts
vim.keymap.del("n", "<C-W><Space>")
vim.keymap.del("n", "<C-W>d")
vim.keymap.del("n", "<C-W><C-D>")

-- Adding VimWiki prefix to which key
vim.keymap.set("n", "<leader>v", "<Nop>", { desc = "Vimwiki" })

-- ############################################################################
--                         Begin of markdown section
-- ############################################################################

-- When I press leader, I want 'm' to show me 'markdown'
-- https://github.com/folke/which-key.nvim?tab=readme-ov-file#%EF%B8%8F-mappings
local wk = require("which-key")
wk.add({
	{
		"<leader>m",
		group = "markdown",
		icon = { cat = "filetype", name = "markdown" },
	},
	{
		"<leader>mh",
		group = "Headings",
		icon = { cat = "filetype", name = "markdown" },
	},
})

-- Add [count] lines below and move cursor to the last new line
vim.keymap.set("n", "<leader>o", function()
	-- <C-u> clears the count from the command line so it's not applied twice
	return ":<C-u>put =repeat([''], v:count1)<CR>"
end, { expr = true, desc = "Add [count] lines below" })

-- Add [count] lines above and move cursor to the first new line
vim.keymap.set("n", "<leader>O", function()
	return ":<C-u>put! =repeat([''], v:count1)<CR>"
end, { expr = true, desc = "Add [count] lines above" })

-- ########################################
--      Generate/update a Markdown TOC
-- ########################################

-- To generate the TOC I use the markdown-toc plugin
-- https://github.com/jonschlinkert/markdown-toc
-- I install it with mason, go see my 'mason-nvim' plugin file
map("n", "<leader>mt", function()
	local path = vim.fn.expand("%") -- Expands the current file name to a full path
	local bufnr = 0 -- The current buffer number, 0 references the current active buffer
	-- Retrieves all lines from the current buffer
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local toc_exists = false -- Flag to check if TOC marker exists
	local frontmatter_end = 0 -- To store the end line number of frontmatter
	-- Check for frontmatter and TOC marker
	for i, line in ipairs(lines) do
		if i == 1 and line:match("^---$") then
			-- Frontmatter start detected, now find the end
			for j = i + 1, #lines do
				if lines[j]:match("^---$") then
					frontmatter_end = j -- Save the end line of the frontmatter
					break
				end
			end
		end
		-- Checks for the TOC marker
		if line:match("^%s*<!%-%-%s*toc%s*%-%->%s*$") then
			toc_exists = true -- Sets the flag if TOC marker is found
			break -- Stops the loop if TOC marker is found
		end
	end
	-- Inserts H1 heading and <!-- toc --> at the appropriate position
	if not toc_exists then
		if frontmatter_end > 0 then
			-- Insert after frontmatter
			vim.api.nvim_buf_set_lines(
				bufnr,
				frontmatter_end + 1,
				frontmatter_end + 1,
				false,
				{ "", "# Contents", "<!-- toc -->" }
			)
		else
			-- Insert at the top if no frontmatter
			vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, { "# Contents", "<!-- toc -->" })
		end
	end
	-- Silently save the file, in case TOC being created for first time (yes, you need the 2 saves)
	vim.cmd("silent write")
	-- Silently run markdown-toc to update the TOC without displaying command output
	vim.fn.system("markdown-toc -i " .. path)
	vim.cmd("edit!") -- Reloads the file to reflect the changes made by markdown-toc
	vim.cmd("silent write") -- Silently save the file
	vim.notify("TOC updated and file saved", vim.log.levels.INFO)
	-- -- In case a cleanup is needed, leaving this old code here as a reference
	-- -- I used this code before I implemented the frontmatter check
	-- -- Moves the cursor to the top of the file
	-- vim.api.nvim_win_set_cursor(bufnr, { 1, 0 })
	-- -- Deletes leading blank lines from the top of the file
	-- while true do
	--   -- Retrieves the first line of the buffer
	--   local line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
	--   -- Checks if the line is empty
	--   if line == "" then
	--     -- Deletes the line if it's empty
	--     vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, {})
	--   else
	--     -- Breaks the loop if the line is not empty, indicating content or TOC marker
	--     break
	--   end
	-- end
end, { desc = "Insert/update Markdown TOC" })

-- Save the cursor position globally to access it across different mappings
_G.saved_positions = {}

-- ########################################
--                Navigation
-- ########################################

-- Mapping to jump to the first line of the TOC
vim.keymap.set("n", "<leader>mm", function()
	-- Save the current cursor position
	_G.saved_positions["toc_return"] = vim.api.nvim_win_get_cursor(0)
	-- Perform a silent search for the <!-- toc --> marker and move the cursor two lines below it
	vim.cmd("silent! /<!-- toc -->\\n\\n\\zs.*")
	-- Clear the search highlight without showing the "search hit BOTTOM, continuing at TOP" message
	vim.cmd("nohlsearch")
	-- Retrieve the current cursor position (after moving to the TOC)
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local row = cursor_pos[1]
	-- local col = cursor_pos[2]
	-- Move the cursor to column 15 (starts counting at 0)
	-- I like just going down on the TOC and press gd to go to a section
	vim.api.nvim_win_set_cursor(0, { row, 14 })
end, { desc = "Jump to the first line of the TOC" })

-- Search UP for a markdown header
-- Make sure to follow proper markdown convention, and you have a single H1
-- heading at the very top of the file
-- This will only search for H2 headings and above
vim.keymap.set("n", "gk", function()
	vim.cmd("silent! ?^##\\+\\s.*$")
	-- Symbols in line above explained:
	-- `?` - Start a search backwards from the current cursor position.
	-- `^` - Match the beginning of a line.
	-- `##` - Match 2 ## symbols
	-- `\\+` - Match one or more occurrences of prev element (#)
	-- `\\s` - Match exactly one whitespace character following the hashes
	-- `.*` - Match any characters (except newline) following the space
	-- `$` - Match extends to end of line

	-- Clear the search highlight
	vim.cmd("nohlsearch")
end, { desc = "Go to previous markdown header" })

-- Search DOWN for a markdown header
-- Make sure to follow proper markdown convention, and you have a single H1
-- heading at the very top of the file
-- This will only search for H2 headings and above
vim.keymap.set("n", "gj", function()
	vim.cmd("silent! /^##\\+\\s.*$")
	-- Symbols in line above explained:
	-- `/` - Start a search forwards from the current cursor position.
	-- `^` - Match the beginning of a line.
	-- `##` - Match 2 ## symbols
	-- `\\+` - Match one or more occurrences of prev element (#)
	-- `\\s` - Match exactly one whitespace character following the hashes
	-- `.*` - Match any characters (except newline) following the space
	-- `$` - Match extends to end of line

	-- Clear the search highlight
	vim.cmd("nohlsearch")
end, { desc = "Go to next markdown header" })

-- ########################################
--             Create Headings
-- ########################################

vim.keymap.set("n", "<leader>mh1", function()
	local heading = "# " -- Heading with space for the cursor
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
	-- Insert heading
	vim.api.nvim_buf_set_lines(0, row, row, false, { heading })
	-- Move the cursor to the end of the heading
	vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
	-- Enter insert mode at the end of the current line
	vim.cmd("startinsert!")
	-- vim.api.nvim_win_set_cursor(0, { row, #heading })
end, { desc = "H1 heading" })

vim.keymap.set("n", "<leader>mh2", function()
	local date = os.date("%Y-%m-%d-%A")
	local heading = "## " -- Heading with space for the cursor
	local dateLine = "[[" .. date .. "]]" -- Formatted date line
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
	-- Insert both lines: heading and dateLine
	vim.api.nvim_buf_set_lines(0, row, row, false, { heading, dateLine })
	-- Move the cursor to the end of the heading
	vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
	-- Enter insert mode at the end of the current line
	vim.cmd("startinsert!")
	-- vim.api.nvim_win_set_cursor(0, { row, #heading })
end, { desc = "H2 heading and date" })

local date = os.date("%Y-%m-%d-%A")
local heading = "### " -- Heading with space for the cursor
vim.keymap.set("n", "<leader>mh3", function()
	local dateLine = "[[" .. date .. "]]" -- Formatted date line
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
	-- Insert both lines: heading and dateLine
	vim.api.nvim_buf_set_lines(0, row, row, false, { heading, dateLine })
	-- Move the cursor to the end of the heading
	vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
	-- Enter insert mode at the end of the current line
	vim.cmd("startinsert!")
	-- vim.api.nvim_win_set_cursor(0, { row, #heading })
end, { desc = "H3 heading and date" })

vim.keymap.set("n", "<leader>mh4", function()
	local date = os.date("%Y-%m-%d-%A")
	local heading = "#### " -- Heading with space for the cursor
	local dateLine = "[[" .. date .. "]]" -- Formatted date line
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
	-- Insert both lines: heading and dateLine
	vim.api.nvim_buf_set_lines(0, row, row, false, { heading, dateLine })
	-- Move the cursor to the end of the heading
	vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
	-- Enter insert mode at the end of the current line
	vim.cmd("startinsert!")
	-- vim.api.nvim_win_set_cursor(0, { row, #heading })
end, { desc = "H4 heading and date" })

vim.keymap.set("n", "<leader>mh5", function()
	local date = os.date("%Y-%m-%d-%A")
	local heading = "##### " -- Heading with space for the cursor
	local dateLine = "[[" .. date .. "]]" -- Formatted date line
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
	-- Insert both lines: heading and dateLine
	vim.api.nvim_buf_set_lines(0, row, row, false, { heading, dateLine })
	-- Move the cursor to the end of the heading
	vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
	-- Enter insert mode at the end of the current line
	vim.cmd("startinsert!")
	-- vim.api.nvim_win_set_cursor(0, { row, #heading })
end, { desc = "H5 heading and date" })

vim.keymap.set("n", "<leader>mh6", function()
	local date = os.date("%Y-%m-%d-%A")
	local heading = "###### " -- Heading with space for the cursor
	local dateLine = "[[" .. date .. "]]" -- Formatted date line
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
	-- Insert both lines: heading and dateLine
	vim.api.nvim_buf_set_lines(0, row, row, false, { heading, dateLine })
	-- Move the cursor to the end of the heading
	vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
	-- Enter insert mode at the end of the current line
	vim.cmd("startinsert!")
	-- vim.api.nvim_win_set_cursor(0, { row, #heading })
end, { desc = "H6 heading and date" })

-- ########################################
-- og Create Headings, saved for reference
-- ########################################
--
-- vim.keymap.set("n", "<leader>mh1", function()
-- 	local date = os.date("%Y-%m-%d-%A")
-- 	local heading = "# " -- Heading with space for the cursor
-- 	local dateLine = "[[" .. date .. "]]" -- Formatted date line
-- 	local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
-- 	-- Insert both lines: heading and dateLine
-- 	vim.api.nvim_buf_set_lines(0, row, row, false, { heading, dateLine })
-- 	-- Move the cursor to the end of the heading
-- 	vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
-- 	-- Enter insert mode at the end of the current line
-- 	vim.cmd("startinsert!")
-- 	-- vim.api.nvim_win_set_cursor(0, { row, #heading })
-- end, { desc = "H1 heading and date" })
--
-- vim.keymap.set("n", "<leader>mh2", function()
-- 	local date = os.date("%Y-%m-%d-%A")
-- 	local heading = "## " -- Heading with space for the cursor
-- 	local dateLine = "[[" .. date .. "]]" -- Formatted date line
-- 	local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
-- 	-- Insert both lines: heading and dateLine
-- 	vim.api.nvim_buf_set_lines(0, row, row, false, { heading, dateLine })
-- 	-- Move the cursor to the end of the heading
-- 	vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
-- 	-- Enter insert mode at the end of the current line
-- 	vim.cmd("startinsert!")
-- 	-- vim.api.nvim_win_set_cursor(0, { row, #heading })
-- end, { desc = "H2 heading and date" })
--
-- local date = os.date("%Y-%m-%d-%A")
-- local heading = "### " -- Heading with space for the cursor
-- vim.keymap.set("n", "<leader>mh3", function()
-- 	local dateLine = "[[" .. date .. "]]" -- Formatted date line
-- 	local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
-- 	-- Insert both lines: heading and dateLine
-- 	vim.api.nvim_buf_set_lines(0, row, row, false, { heading, dateLine })
-- 	-- Move the cursor to the end of the heading
-- 	vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
-- 	-- Enter insert mode at the end of the current line
-- 	vim.cmd("startinsert!")
-- 	-- vim.api.nvim_win_set_cursor(0, { row, #heading })
-- end, { desc = "H3 heading and date" })
--
-- vim.keymap.set("n", "<leader>mh4", function()
-- 	local date = os.date("%Y-%m-%d-%A")
-- 	local heading = "#### " -- Heading with space for the cursor
-- 	local dateLine = "[[" .. date .. "]]" -- Formatted date line
-- 	local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
-- 	-- Insert both lines: heading and dateLine
-- 	vim.api.nvim_buf_set_lines(0, row, row, false, { heading, dateLine })
-- 	-- Move the cursor to the end of the heading
-- 	vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
-- 	-- Enter insert mode at the end of the current line
-- 	vim.cmd("startinsert!")
-- 	-- vim.api.nvim_win_set_cursor(0, { row, #heading })
-- end, { desc = "H4 heading and date" })
--
-- vim.keymap.set("n", "<leader>mh5", function()
-- 	local date = os.date("%Y-%m-%d-%A")
-- 	local heading = "##### " -- Heading with space for the cursor
-- 	local dateLine = "[[" .. date .. "]]" -- Formatted date line
-- 	local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
-- 	-- Insert both lines: heading and dateLine
-- 	vim.api.nvim_buf_set_lines(0, row, row, false, { heading, dateLine })
-- 	-- Move the cursor to the end of the heading
-- 	vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
-- 	-- Enter insert mode at the end of the current line
-- 	vim.cmd("startinsert!")
-- 	-- vim.api.nvim_win_set_cursor(0, { row, #heading })
-- end, { desc = "H5 heading and date" })
--
-- vim.keymap.set("n", "<leader>mh6", function()
-- 	local date = os.date("%Y-%m-%d-%A")
-- 	local heading = "###### " -- Heading with space for the cursor
-- 	local dateLine = "[[" .. date .. "]]" -- Formatted date line
-- 	local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
-- 	-- Insert both lines: heading and dateLine
-- 	vim.api.nvim_buf_set_lines(0, row, row, false, { heading, dateLine })
-- 	-- Move the cursor to the end of the heading
-- 	vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
-- 	-- Enter insert mode at the end of the current line
-- 	vim.cmd("startinsert!")
-- 	-- vim.api.nvim_win_set_cursor(0, { row, #heading })
-- end, { desc = "H6 heading and date" })

-- ############################################################################
--                       End of markdown section
-- ############################################################################

-- ############################################################################
--                       Folding section
-- ############################################################################

-- Checks each line to see if it matches a markdown heading (#, ##, etc.):
-- It’s called implicitly by Neovim’s folding engine by vim.opt_local.foldexpr
-- Enhanced: 2+ blank lines drop content to the parent heading level

-- Helper to find current heading level by scanning backwards
local function get_current_heading_level(lnum)
	for i = lnum - 1, 1, -1 do
		local line = vim.fn.getline(i)
		local heading = line:match("^(#+)%s")
		if heading then
			return #heading
		end
	end
	return 1
end

function _G.markdown_foldexpr()
	local lnum = vim.v.lnum
	local line = vim.fn.getline(lnum)

	-- Check for heading
	local heading = line:match("^(#+)%s")
	if heading then
		local level = #heading
		if level == 1 then
			-- Special handling for H1
			if lnum == 1 then
				return ">1"
			else
				local frontmatter_end = vim.b.frontmatter_end
				if frontmatter_end and (lnum == frontmatter_end + 1) then
					return ">1"
				end
			end
		elseif level >= 2 and level <= 6 then
			return ">" .. level
		end
	end

	-- Check if this is content after 2+ consecutive blank lines (drop one level)
	if not line:match("^%s*$") then
		local prev1 = vim.fn.getline(lnum - 1)
		local prev2 = vim.fn.getline(lnum - 2)
		if prev1:match("^%s*$") and prev2:match("^%s*$") then
			local current_level = get_current_heading_level(lnum)
			if current_level > 1 then
				return tostring(current_level - 1)
			end
			return "1"
		end
	end

	return "="
end

local function set_markdown_folding()
	vim.opt_local.foldmethod = "expr"
	vim.opt_local.foldexpr = "v:lua.markdown_foldexpr()"
	vim.opt_local.foldlevel = 99

	-- Detect frontmatter closing line
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local found_first = false
	local frontmatter_end = nil
	for i, line in ipairs(lines) do
		if line == "---" then
			if not found_first then
				found_first = true
			else
				frontmatter_end = i
				break
			end
		end
	end
	vim.b.frontmatter_end = frontmatter_end
end

-- Use autocommand to apply only to markdown files
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = set_markdown_folding,
})

-- Function to fold all headings of a specific level
local function fold_headings_of_level(level)
	-- Move to the top of the file without adding to jumplist
	vim.cmd("keepjumps normal! gg")
	-- Get the total number of lines
	local total_lines = vim.fn.line("$")
	for line = 1, total_lines do
		-- Get the content of the current line
		local line_content = vim.fn.getline(line)
		-- "^" -> Ensures the match is at the start of the line
		-- string.rep("#", level) -> Creates a string with 'level' number of "#" characters
		-- "%s" -> Matches any whitespace character after the "#" characters
		-- So this will match `## `, `### `, `#### ` for example, which are markdown headings
		if line_content:match("^" .. string.rep("#", level) .. "%s") then
			-- Move the cursor to the current line without adding to jumplist
			vim.cmd(string.format("keepjumps call cursor(%d, 1)", line))
			-- Check if the current line has a fold level > 0
			local current_foldlevel = vim.fn.foldlevel(line)
			if current_foldlevel > 0 then
				-- Fold the heading if it matches the level
				if vim.fn.foldclosed(line) == -1 then
					vim.cmd("normal! za")
				end
				-- else
				--   vim.notify("No fold at line " .. line, vim.log.levels.WARN)
			end
		end
	end
end

local function fold_markdown_headings(levels)
	-- I save the view to know where to jump back after folding
	local saved_view = vim.fn.winsaveview()
	for _, level in ipairs(levels) do
		fold_headings_of_level(level)
	end
	vim.cmd("nohlsearch")
	-- Restore the view to jump to where I was
	vim.fn.winrestview(saved_view)
end

-- HACK: Fold markdown headings in Neovim with a keymap
-- https://youtu.be/EYczZLNEnIY
--
-- Keymap for folding markdown headings of level 1 or above
vim.keymap.set("n", "<leader>mf1", function()
	-- "Update" saves only if the buffer has been modified since the last save
	vim.cmd("silent update")
	-- vim.keymap.set("n", "<leader>mfj", function()
	-- Reloads the file to refresh folds, otheriise you have to re-open neovim
	vim.cmd("edit!")
	-- Unfold everything first or I had issues
	vim.cmd("normal! zR")
	fold_markdown_headings({ 6, 5, 4, 3, 2, 1 })
	vim.cmd("normal! zz") -- center the cursor line on screen
end, { desc = "[P]Fold all headings level 1 or above" })

-- HACK: Fold markdown headings in Neovim with a keymap
-- https://youtu.be/EYczZLNEnIY
--
-- Keymap for folding markdown headings of level 2 or above
-- I know, it reads like "madafaka" but "k" for me means "2"
vim.keymap.set("n", "<leader>mf2", function()
	-- "Update" saves only if the buffer has been modified since the last save
	vim.cmd("silent update")
	-- vim.keymap.set("n", "<leader>mfk", function()
	-- Reloads the file to refresh folds, otherwise you have to re-open neovim
	vim.cmd("edit!")
	-- Unfold everything first or I had issues
	vim.cmd("normal! zR")
	fold_markdown_headings({ 6, 5, 4, 3, 2 })
	vim.cmd("normal! zz") -- center the cursor line on screen
end, { desc = "[P]Fold all headings level 2 or above" })

-- HACK: Fold markdown headings in Neovim with a keymap
-- https://youtu.be/EYczZLNEnIY
--
-- Keymap for folding markdown headings of level 3 or above
vim.keymap.set("n", "<leader>mf3", function()
	-- "Update" saves only if the buffer has been modified since the last save
	vim.cmd("silent update")
	-- vim.keymap.set("n", "<leader>mfl", function()
	-- Reloads the file to refresh folds, otherwise you have to re-open neovim
	vim.cmd("edit!")
	-- Unfold everything first or I had issues
	vim.cmd("normal! zR")
	fold_markdown_headings({ 6, 5, 4, 3 })
	vim.cmd("normal! zz") -- center the cursor line on screen
end, { desc = "[P]Fold all headings level 3 or above" })

-- HACK: Fold markdown headings in Neovim with a keymap
-- https://youtu.be/EYczZLNEnIY
--
-- Keymap for folding markdown headings of level 4 or above
vim.keymap.set("n", "<leader>mf4", function()
	-- "Update" saves only if the buffer has been modified since the last save
	vim.cmd("silent update")
	-- vim.keymap.set("n", "<leader>mf;", function()
	-- Reloads the file to refresh folds, otherwise you have to re-open neovim
	vim.cmd("edit!")
	-- Unfold everything first or I had issues
	vim.cmd("normal! zR")
	fold_markdown_headings({ 6, 5, 4 })
	vim.cmd("normal! zz") -- center the cursor line on screen
end, { desc = "[P]Fold all headings level 4 or above" })

-- HACK: Fold markdown headings in Neovim with a keymap
-- https://youtu.be/EYczZLNEnIY
--
-- Use <CR> to fold when in normal mode
-- To see help about folds use `:help fold`
vim.keymap.set("n", "<CR>", function()
	-- Get the current line number
	local line = vim.fn.line(".")
	-- Get the fold level of the current line
	local foldlevel = vim.fn.foldlevel(line)
	if foldlevel == 0 then
		vim.notify("No fold found", vim.log.levels.INFO)
	else
		vim.cmd("normal! za")
		vim.cmd("normal! zz") -- center the cursor line on screen
	end
end, { desc = "[P]Toggle fold" })

-- HACK: Fold markdown headings in Neovim with a keymap
-- https://youtu.be/EYczZLNEnIY
--
-- Keymap for unfolding markdown headings of level 2 or above
-- Changed all the markdown folding and unfolding keymaps from <leader>mfj to
-- zj, zk, zl, z; and zu respectively lamw25wmal
vim.keymap.set("n", "<leader>mfu", function()
	-- "Update" saves only if the buffer has been modified since the last save
	vim.cmd("silent update")
	-- vim.keymap.set("n", "<leader>mfu", function()
	-- Reloads the file to reflect the changes
	vim.cmd("edit!")
	vim.cmd("normal! zR") -- Unfold all headings
	vim.cmd("normal! zz") -- center the cursor line on screen
end, { desc = "[P]Unfold all headings level 2 or above" })

-- ########################################
--           end Folding Section
-- ########################################

-- Marks keep coming back even after deleting them, this deletes them all
-- This deletes all marks in the current buffer, including lowercase, uppercase, and numbered marks
-- Fix should be applied on April 2024
-- https://github.com/chentoast/marks.nvim/issues/13
vim.keymap.set("n", "<leader>md", function()
	-- Delete all marks in the current buffer
	vim.cmd("delmarks!")
	print("All marks deleted.")
end, { desc = "Delete all marks" })

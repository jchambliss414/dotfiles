-- Define global function for foldtext
function _G.VimwikiFoldText()
	local line = vim.fn.getline(vim.v.foldstart)

	-- Strip everything after "|"
	local pipe_pos = line:find("|")
	if pipe_pos then
		line = vim.trim(line:sub(1, pipe_pos - 1))
	end

	-- Convert markdown links [label](url) to just label
	line = line:gsub("%[(.-)%]%(.-%)$", "%1")

	-- Count heading level for highlight group
	local pounds = line:match("^(#+)")
	local level = pounds and #pounds or 1
	local hl_group = "markdownH" .. level

	return { { line, hl_group } }
end

vim.schedule(function()
	vim.opt_local.foldmethod = "expr"
	vim.opt_local.foldexpr = "VimwikiFoldLevelCustom(v:lnum)"
	vim.opt_local.foldlevel = 99
	vim.opt_local.foldtext = "v:lua.VimwikiFoldText()"
end)

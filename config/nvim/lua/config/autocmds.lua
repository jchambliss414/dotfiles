local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({ timeout = 200 })
	end,
})

-- Underline markdown links (for render-markdown.nvim)
autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		-- Set underline for the standard markup underline group
		vim.api.nvim_set_hl(0, "@markup.underline", { underline = true })
		-- Also set for link-specific groups
		vim.api.nvim_set_hl(0, "@markup.link.url.markdown_inline", { underline = true })
		vim.api.nvim_set_hl(0, "@markup.link.label.markdown_inline", { underline = true })
	end,
})

-- VimWiki folding configuration
-- local vimwiki_group = vim.api.nvim_create_augroup("VimrcAuGroup", { clear = true })
--
-- autocmd("FileType", {
-- 	pattern = "vimwiki",
-- 	group = vimwiki_group,
-- 	callback = function()
-- 		vim.opt_local.foldmethod = "expr"
-- 		vim.opt_local.foldenable = true
-- 		vim.opt_local.foldexpr = "VimwikiFoldLevelCustom(v:lnum)"
-- 	end,
-- })

vim.api.nvim_create_autocmd("FileType", {
	pattern = "vimwiki",
	callback = function()
		-- Disable treesitter highlighting for vimwiki (allows TaskWiki conceal to work)
		-- vim.treesitter.stop()
		-- vim.opt_local.conceallevel = 2

		-- Remap diary navigation to horizontal arrows
		local buf = vim.api.nvim_get_current_buf()
		vim.keymap.set("n", "<C-Left>", "<Plug>VimwikiDiaryPrevDay", { buffer = buf, desc = "Previous Diary Day" })
		vim.keymap.set("n", "<C-Right>", "<Plug>VimwikiDiaryNextDay", { buffer = buf, desc = "Next Diary Day" })
		pcall(vim.keymap.del, "n", "<C-Up>", { buffer = buf })
		pcall(vim.keymap.del, "n", "<C-Down>", { buffer = buf })
	end,
})

-- Apply link underline immediately for current colorscheme
vim.api.nvim_set_hl(0, "@markup.underline", { underline = true })
vim.api.nvim_set_hl(0, "@markup.link.url.markdown_inline", { underline = true })
vim.api.nvim_set_hl(0, "@markup.link.label.markdown_inline", { underline = true })

vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.md",
	callback = function()
		if vim.bo.filetype == "vimwiki" then
			local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
			for _, line in ipairs(lines) do
				if line:match("^#.*|") then
					vim.cmd("TaskWikiBufferLoad")
					return
				end
			end
		end
	end,
})

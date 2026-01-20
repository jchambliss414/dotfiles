-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- -- Filter out only the maplocalleader warning
-- local original_notify = vim.notify
-- vim.notify = function(msg, level, opts)
-- 	if type(msg) == "string" and msg:match("maplocalleader") then
-- 		return
-- 	end
-- 	original_notify(msg, level, opts)
-- end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim with plugins
require("lazy").setup({
	spec = {
		{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
		{ import = "plugins" }, -- Your plugins from lua/plugins/
	},
	defaults = { lazy = false },
	install = { colorscheme = { "tokyonight", "haiku" } },
	checker = { enabled = true }, -- Auto-check for plugin updates
})

-- Register markdown parser for vimwiki files
vim.treesitter.language.register("markdown", "vimwiki")

-- ~/.config/nvim/lua/plugins/luasnip.lua
-- Custom LuaSnip configuration to load Lua snippets
-- NOTE: Avoids <Tab> to prevent conflicts with VimWiki link navigation

return {
	"L3MON4D3/LuaSnip",
	keys = {
		-- Jump forward through snippet tabstops with Ctrl+l
		-- Falls back to default behavior when not in a snippet
		{
			"<C-l>",
			function()
				local ls = require("luasnip")
				if ls.expand_or_jumpable() then
					ls.expand_or_jump()
				else
					-- Fall back to default <C-l> behavior (redraw/clear)
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-l>", true, false, true), "n", false)
				end
			end,
			mode = { "i", "s" },
			desc = "LuaSnip: Expand or jump forward",
		},
		-- Jump backward through snippet tabstops with Ctrl+h
		-- Falls back to backspace when not in a snippet
		{
			"<C-h>",
			function()
				local ls = require("luasnip")
				if ls.jumpable(-1) then
					ls.jump(-1)
				else
					-- Fall back to default <C-h> behavior (backspace)
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<BS>", true, false, true), "n", false)
				end
			end,
			mode = { "i", "s" },
			desc = "LuaSnip: Jump backward",
		},
		-- Cycle through choice nodes with Ctrl+e
		{
			"<C-e>",
			function()
				local ls = require("luasnip")
				if ls.choice_active() then
					ls.change_choice(1)
				else
					-- Fall back to default <C-e> (end of line in insert mode)
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-e>", true, false, true), "n", false)
				end
			end,
			mode = { "i", "s" },
			desc = "LuaSnip: Cycle choice",
		},
	},
	config = function()
		local ls = require("luasnip")

		-- Load custom Lua snippets from luasnippets directory
		require("luasnip.loaders.from_lua").load({
			paths = { vim.fn.stdpath("config") .. "/luasnippets" },
		})

		-- Share vimwiki snippets with markdown filetype
		-- (No need for duplicate files or symlinks)
		ls.filetype_extend("markdown", { "vimwiki" })

		-- Configuration options
		ls.config.set_config({
			-- Update snippets as you type (for dynamic nodes)
			update_events = "TextChanged,TextChangedI",
			-- Enable autosnippets if you want some to trigger automatically
			enable_autosnippets = false,
			-- Don't use Tab for visual selection (VimWiki conflict)
			-- Use Ctrl+s instead if you need visual placeholder feature
			store_selection_keys = "<C-s>",
			-- Exit snippet when cursor leaves
			region_check_events = "CursorMoved",
			delete_check_events = "TextChanged",
		})
	end,
}

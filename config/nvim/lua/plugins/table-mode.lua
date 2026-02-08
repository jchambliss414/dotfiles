return {
	"dhruvasagar/vim-table-mode",
	ft = { "vimwiki", "markdown" },
	cmd = { "TableModeToggle", "TableModeEnable", "TableModeDisable", "Tableize" },
	keys = {
		{ "<leader>vt", "<cmd>TableModeToggle<cr>", desc = "Toggle Table Mode" },
		{ "<leader>vT", "<cmd>Tableize<cr>", mode = { "n", "v" }, desc = "Tableize selection" },
	},
	config = function()
		vim.g.table_mode_corner = "|"
		vim.g.table_mode_always_active = 0
		vim.g.table_mode_auto_align = 1
		vim.g.table_mode_disable_mappings = 0
		vim.g.table_mode_disable_tableize_mappings = 1
		vim.g.table_mode_map_prefix = "<Leader>T"

		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "vimwiki", "markdown" },
			callback = function()
				-- CR: blank row via VimWiki's built-in table handler
				vim.keymap.set("i", "<CR>", function()
					local line = vim.fn.getline(".")
					if line:match("^%s*|") then
						vim.fn["vimwiki#tbl#kbd_cr"]()
					else
						-- Normal enter outside tables
						vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
					end
				end, { buffer = true, desc = "Table-aware Enter" })

				-- A-CR: insert separator row
				vim.keymap.set("i", "<C-\\>", function()
					local line = vim.fn.getline(".")
					if line:match("^%s*|") then
						local sep = line:gsub("([^|]+)", function(cell)
							return string.rep("-", #cell)
						end)
						vim.fn.append(".", sep)
						vim.fn.cursor(vim.fn.line(".") + 1, vim.fn.col("."))
					end
				end, { buffer = true, desc = "Insert table separator row" })
			end,
		})
	end,
}

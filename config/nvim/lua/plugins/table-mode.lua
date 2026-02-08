return {
	"dhruvasagar/vim-table-mode",
	ft = { "vimwiki", "markdown" },
	cmd = { "TableModeToggle", "TableModeEnable", "TableModeDisable", "Tableize" },
	keys = {
		{ "<leader>vt", "<cmd>TableModeToggle<cr>", desc = "Toggle Table Mode" },
		{ "<leader>vT", "<cmd>Tableize<cr>", mode = { "n", "v" }, desc = "Tableize selection" },
	},
}

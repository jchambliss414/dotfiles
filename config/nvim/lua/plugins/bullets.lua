return {
	"bullets-vim/bullets.vim",
	ft = { "markdown", "text", "gitcommit", "scratch" },
	init = function()
		-- Filetypes where bullets is active
		vim.g.bullets_enabled_file_types = {
			"markdown",
			"text",
			"gitcommit",
			"scratch",
		}

		-- Auto-remove empty trailing bullets
		vim.g.bullets_delete_last_bullet_if_empty = 1

		-- Renumber lists automatically when editing
		vim.g.bullets_renumber_on_change = 1

		-- Nested checkbox behavior (completing children completes parent)
		vim.g.bullets_nested_checkboxes = 1

		-- Checkbox markers: [ ] → [o] → [ ] → [ ]
		vim.g.bullets_checkbox_markers = " o"
	end,
}

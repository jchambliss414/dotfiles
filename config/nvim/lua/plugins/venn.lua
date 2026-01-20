return {
	"jbyuki/venn.nvim",
	keys = {
		{ "<leader>V", desc = "Venn diagram mode" },
	},
	config = function()
		local venn_enabled = false

		local function toggle_venn()
			if not venn_enabled then
				venn_enabled = true
				vim.opt_local.virtualedit = "all"
				vim.keymap.set("n", "J", "<C-v>j:VBox<CR>", { buffer = true, desc = "Draw down" })
				vim.keymap.set("n", "K", "<C-v>k:VBox<CR>", { buffer = true, desc = "Draw up" })
				vim.keymap.set("n", "L", "<C-v>l:VBox<CR>", { buffer = true, desc = "Draw right" })
				vim.keymap.set("n", "H", "<C-v>h:VBox<CR>", { buffer = true, desc = "Draw left" })
				vim.keymap.set("v", "f", ":VBox<CR>", { buffer = true, desc = "Draw box" })
				vim.notify("Venn mode ON", vim.log.levels.INFO)
			else
				venn_enabled = false
				vim.opt_local.virtualedit = ""
				vim.keymap.del("n", "J", { buffer = true })
				vim.keymap.del("n", "K", { buffer = true })
				vim.keymap.del("n", "L", { buffer = true })
				vim.keymap.del("n", "H", { buffer = true })
				vim.keymap.del("v", "f", { buffer = true })
				vim.notify("Venn mode OFF", vim.log.levels.INFO)
			end
		end

		vim.keymap.set("n", "<leader>V", toggle_venn, { desc = "Toggle Venn mode" })
	end,
}

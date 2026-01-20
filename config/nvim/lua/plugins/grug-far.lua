return {
	"MagicDuck/grug-far.nvim",
	opts = {
		-- Configure to search from current file's directory by default
		startInDirectory = function()
			local current_file = vim.fn.expand("%:p")
			if current_file == "" then
				return vim.fn.getcwd()
			end
			return vim.fn.fnamemodify(current_file, ":h")
		end,
	},
	keys = {
		{
			"<leader>sr",
			function()
				local current_file = vim.fn.expand("%:p")
				local current_dir = vim.fn.fnamemodify(current_file, ":h")
				require("grug-far").open({
					prefills = {
						paths = current_dir,
					},
				})
			end,
			desc = "Search and Replace (current dir)",
		},
		{
			"<leader>sR",
			function()
				require("grug-far").open()
			end,
			desc = "Search and Replace (cwd)",
		},
	},
}

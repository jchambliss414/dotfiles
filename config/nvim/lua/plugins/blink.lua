return {
	"saghen/blink.cmp",
	opts = {
		completion = {
			list = { selection = { preselect = false, auto_insert = true } },
		},
		keymap = {
			["<Tab>"] = {},
			["<S-Tab>"] = {},
			["<C-j>"] = { "select_next", "fallback" },
			["<C-k>"] = { "select_prev", "fallback" },
			["<S-Space>"] = { "accept", "fallback" },
			["<Space>"] = {
				function(cmp)
					if cmp.is_visible() then
						cmp.cancel()
						return true
					end
				end,
				"fallback",
			},
			["<CR>"] = {
				function(cmp)
					if cmp.is_visible() then
						return cmp.accept()
					end
				end,
				"fallback",
			},
		},
	},
}

return {
	"arnamak/stay-centered.nvim",
	event = "VeryLazy",
	config = function()
		local sc = require("stay-centered")
		sc.setup({})

		-- Track state ourselves since plugin doesn't expose it
		local enabled = true

		Snacks.toggle
			.new({
				name = "Stay Centered",
				get = function()
					return enabled
				end,
				set = function(state)
					enabled = state
					sc.toggle()
				end,
			})
			:map("<leader>uM")
	end,
}

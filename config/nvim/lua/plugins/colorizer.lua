return {
	"NvChad/nvim-colorizer.lua",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		user_default_options = {
			names = false, -- "red", "blue" etc. (can be slow)
			RGB = true, -- #RGB
			RRGGBB = true, -- #RRGGBB
			RRGGBBAA = true, -- #RRGGBBAA
			rgb_fn = true, -- rgb(255,0,0)
			hsl_fn = true, -- hsl(0,100%,50%)
			css = true, -- css features
			css_fn = true, -- css functions
			mode = "background", -- "foreground", "background", or "virtualtext"
			virtualtext = "■",
		},
		filetypes = {
			"*", -- all filetypes
			"!lazy", -- except lazy.nvim UI
		},
	},
}

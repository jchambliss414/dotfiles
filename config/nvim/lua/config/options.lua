-- lua/config/options.lua
local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs & indentation
opt.tabstop = 3
opt.shiftwidth = 3
opt.expandtab = true
opt.autoindent = true
opt.textwidth = 120

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- Appearance
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true

-- Behavior
opt.splitright = true
opt.splitbelow = true
opt.undofile = true
opt.clipboard = "unnamedplus"
opt.mouse = "a"

-- Decrease update time
opt.updatetime = 250
opt.timeoutlen = 300

opt.conceallevel = 2

opt.foldcolumn = "0"

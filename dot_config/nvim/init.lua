--[[
neovim version requirements:
>= 0.7.0 - mason, nvim-cmp, luasnip
>= 0.10.0 - nvim-cmp (snippet autocompletion with native neovim)

external deps:
	ripgrep - telescope live grep search & find files

	git, curl/wget, unzip, tar, gzip - mason dep (unix)
	pwsh/powershell, git, tar, 7zip/peazip/archiver/winzip/winRAR - mason dep (windows)
	other package managers - see `:checkhealth mason` (this may or may not be needed)

	yarn, npn - markdown preview


other notes:
	need to run `cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1` for c++ lsp to work
]]
--

-- lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.termguicolors = true

vim.diagnostic.config({ virtual_text = false, signs = false, })


local flash = {
	"folke/flash.nvim",
	event = "VeryLazy",
	keys = {
		{
			"s",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Flash",
		},
		{
			"S",
			mode = { "n", "x", "o" },
			function()
				require("flash").treesitter()
			end,
			desc = "Flash Treesitter",
		},
		{
			"r",
			mode = "o",
			function()
				require("flash").remote()
			end,
			desc = "Remote Flash",
		},
		{
			"R",
			mode = { "o", "x" },
			function()
				require("flash").treesitter_search()
			end,
			desc = "Treesitter Search",
		},
		{
			"<c-s>",
			mode = { "c" },
			function()
				require("flash").toggle()
			end,
			desc = "Toggle Flash Search",
		},
	},
	config = true,
	opts = {
		modes = { search = { enabled = true } },
	},
}

local telescope = {
	"nvim-telescope/telescope.nvim",
	dependencies = "nvim-lua/plenary.nvim",
	keys = {
		{
			"<leader>f",
			function()
				require("telescope.builtin").find_files()
			end,
			desc = "Find Files",
		},
		{
			"<leader>g",
			function()
				require("telescope.builtin").live_grep()
			end,
			desc = "Live Grep",
		},
		{
			"<leader>b",
			function()
				require("telescope.builtin").buffers()
			end,
			desc = "Buffer Search",
		},
		{
			"<leader>t",
			function()
				require("telescope.builtin").treesitter()
			end,
			desc = "Treesitter search",
		},
		{
			"<leader>km",
			":Telescope keymaps<CR>",
			{ noremap = true, silent = true },
			desc = "Telescope Keymaps",
		},
	},
	config = true,
}

local vim_sleuth = {
	"tpope/vim-sleuth",
}

local zen_mode = {
	"folke/zen-mode.nvim",
}

local conform = {
	"stevearc/conform.nvim",
	config = true,
	opts = {
		format_on_save =
		    function(bufnr)
			    local ignore_filetypes = { "c", "cpp", "cmake" }
			    if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
				    return
			    end
			    return {
				    timeout_ms = 500,
				    lsp_fallback = true,
			    }
		    end,
	},
}

local mason = {
	{
		"williamboman/mason.nvim",
		config = true,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = true,
		opts = { ensure_installed = { "lua_ls", "rust_analyzer" } },
	},
}

local lsp_config = {
	"neovim/nvim-lspconfig",
}

local treesitter = {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = true,
	opts = { ensure_installed = { "c", "cpp", "cmake", "make", "rust", "lua", "python" }, highlight = { enabled = true, }, sync_install = false, }
}

local rust_crates = {
	"saecki/crates.nvim",
	config = true,
}

local markdown_preview = {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	build = "cd app && yarn install",
	init = function()
		vim.g.mkdp_filetypes = { "markdown" }
	end,
	ft = { "markdown" },
}
local terminal = {
	"akinsho/toggleterm.nvim",
	config = true,
}

local snippets = {
	{
		"L3MON4D3/LuaSnip",
		dependencies = { "rafamadriz/friendly-snippets" },
		build = "make install_jsregexp",
		keys = {
			{
				"<C-K>",
				function()
					require("luasnip").expand()
				end,
				mode = "i",
				desc = "TODO FIGURE OUT WHAT THIS DOES??",
			},
			{
				"<C-L>",
				function()
					require("luasnip").jump(1)
				end,
				mode = { 'i', 's' },
				desc = "Jump to next field in snippet",
			},
			{
				"<C-J>",
				function()
					require("luasnip").jump(-1)
				end,
				mode = { 'i', 's' },
				desc = "Jump to previous field in snippet",
			},
			{
				"<C-E>",
				function()
					if require("luasnip").choice_active() then
						require("luasnip").change_choice(1)
					end
				end,
				mode = { 'i', 's' },
				desc = "TODO FIGURE OUT WHAT THIS DOES??",
			},
		},
	},
	"saadparwaiz1/cmp_luasnip",
}

local completion = {
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-nvim-lua",
	{
		"hrsh7th/nvim-cmp",
		config = true,
		opts = {
			expand = function(args)
				require("luasnip").lsp_expand(args.body)
			end,
		},
	}
}

local filebrowser = {
	"stevearc/oil.nvim",
	dependencies = { "echasnovski/mini.nvim" },
	config = true,
}


local colourscheme = { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = false, priority = 1000 }

local plugins = {
	flash,
	telescope,
	vim_sleuth,
	zen_mode,
	conform,
	mason,
	lsp_config,
	rust_crates,
	markdown_preview,
	treesitter,
	colourscheme,
	snippets,
	completion,
	filebrowser,
	terminal,
}

require("lazy").setup(plugins)

-- colourscheme has to be after plugins are loaded
vim.cmd("colorscheme moonfly")
-- set background to black
vim.cmd("highlight Normal guibg=black")

-- snippets
require("luasnip.loaders.from_vscode").lazy_load()

-- completion
local cmp = require("cmp")
cmp.setup({
	sources = cmp.config.sources(
		{
			{
				name = "nvim_lsp",
				-- avoid duplicate snippets and prefer the ones from friendly-snippets
				entry_filter = function(entry, ctx)
					if entry:get_kind() == 15 then
						return false
					end
					return true
				end

			},
			{ name = "luasnip" },
		},
		{ { name = "buffer", keyword_length = 5 }
		}),
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
})

-- LSP SETUP
local lsp = require("lspconfig")
local cap = require("cmp_nvim_lsp").default_capabilities()

-- rust
lsp.rust_analyzer.setup({ capabilities = cap })

-- c/c++
lsp.clangd.setup({ capabilities = cap })

-- cmake
lsp.neocmake.setup({ capabilities = cap })

-- python
lsp.pylsp.setup({ capabilities = cap })

-- lua
-- see https://github.com/neovim/neovim/issues/21686
-- and https://github.com/folke/lazy.nvim/issues/1349
lsp.lua_ls.setup({
	settings = {
		Lua = {
			workspace = { library = vim.env.VIMRUNTIME },
			diagnostics = { globals = { "vim" } },
			telemetry = { enabled = false },
		},
	},
	capabilities = cap
})


-- show errors/warnings/info
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, {})

-- better jump to definition with lsp
vim.keymap.set('n', '<leader>d', vim.lsp.buf.definition, {})

-- view description
vim.keymap.set('n', '<leader>v', vim.lsp.buf.hover, {})

-- view references
vim.keymap.set('n', '<leader>r', vim.lsp.buf.references, {})

-- code action
vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action, {})

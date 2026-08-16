-- Personal Neovim configuration.
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.incsearch = true
vim.opt.scrolloff = 8
vim.opt.clipboard = "unnamedplus"
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

local function leading_indent(line)
  return #(line:match("^[ \t]*") or "")
end

local function nearest_nonblank(line, step)
  while line >= 1 and line <= vim.api.nvim_buf_line_count(0) do
    local text = vim.fn.getline(line)
    if text:match("%S") then return text end
    line = line + step
  end
  return ""
end

function _G.MoveVisualLines(direction)
  local first, last = vim.fn.line("'<"), vim.fn.line("'>")
  vim.cmd(("%d,%dmove %d"):format(first, last, direction == 1 and last + 1 or first - 2))
  first, last = first + direction, last + direction
  local context = nearest_nonblank(direction == 1 and first - 1 or last + 1, direction == 1 and -1 or 1)
  local target_indent = leading_indent(context)
  if direction == 1 and context:match(":%s*$") then target_indent = target_indent + vim.o.shiftwidth end
  local delta = target_indent - leading_indent(vim.fn.getline(first))
  if delta ~= 0 then
    for line_number = first, last do
      local line = vim.fn.getline(line_number)
      if line:match("%S") then
        if delta > 0 then line = string.rep(" ", delta) .. line
        else line = line:sub(math.min(-delta, leading_indent(line)) + 1) end
        vim.fn.setline(line_number, line)
      end
    end
  end
  vim.api.nvim_buf_set_mark(0, "<", first - 1, 0, {})
  vim.api.nvim_buf_set_mark(0, ">", last - 1, 0, {})
end

vim.keymap.set("n", "<Tab>", ">>", { desc = "Indent line" })
vim.keymap.set("n", "<S-Tab>", "<<", { desc = "Unindent line" })
vim.keymap.set("v", "<Tab>", ">gv", { desc = "Indent selection" })
vim.keymap.set("v", "<S-Tab>", "<gv", { desc = "Unindent selection" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set("n", "<C-c>", [["+yy]], { desc = "Copy line to clipboard" })
vim.keymap.set("v", "<C-c>", [["+y]], { desc = "Copy selection to clipboard" })
vim.keymap.set({ "n", "v" }, "<C-v>", [["+p]], { desc = "Paste from clipboard" })
vim.keymap.set("i", "<C-v>", "<C-r>+", { desc = "Paste from clipboard" })
vim.keymap.set("n", "<leader>z", "za", { desc = "Toggle fold" })
vim.keymap.set("n", "<leader>Z", "zM", { desc = "Close all folds" })
vim.keymap.set("n", "<leader>o", "zR", { desc = "Open all folds" })

local undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.fn.mkdir(undodir, "p")
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = undodir
vim.opt.undofile = true

local treesitter_bin = vim.fn.expand("~/.local/node_modules/.bin")
if vim.fn.isdirectory(treesitter_bin) == 1 then vim.env.PATH = treesitter_bin .. ":" .. vim.env.PATH end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "catppuccin/nvim", name = "catppuccin", lazy = false, priority = 1000, opts = { flavour = "mocha" }, config = function(_, opts) require("catppuccin").setup(opts); vim.cmd.colorscheme("catppuccin") end },
  {
    "mason-org/mason-lspconfig.nvim", lazy = false,
    dependencies = { { "mason-org/mason.nvim", opts = {} }, "neovim/nvim-lspconfig" },
    config = function()
      local servers = { "pyright", "clangd", "jdtls", "rust_analyzer" }
      require("mason-lspconfig").setup({ ensure_installed = servers, automatic_enable = true })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local function map(keys, action, desc)
            vim.keymap.set("n", keys, action, { buffer = event.buf, desc = desc })
          end

          local function telescope_or_lsp(telescope_picker, lsp_action)
            return function()
              local ok, builtin = pcall(require, "telescope.builtin")
              if ok then builtin[telescope_picker]() else lsp_action() end
            end
          end

          map("gd", telescope_or_lsp("lsp_definitions", vim.lsp.buf.definition), "Go to definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("gr", telescope_or_lsp("lsp_references", vim.lsp.buf.references), "Go to references")
          map("gI", telescope_or_lsp("lsp_implementations", vim.lsp.buf.implementation), "Go to implementation")
          map("K", vim.lsp.buf.hover, "Hover documentation")
          map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>d", vim.diagnostic.open_float, "Line diagnostics")
          map("[d", vim.diagnostic.goto_prev, "Previous diagnostic")
          map("]d", vim.diagnostic.goto_next, "Next diagnostic")
        end,
      })

    end,
  },
  {
    "nvim-treesitter/nvim-treesitter", lazy = false, build = ":TSUpdate",
    config = function()
      local treesitter = require("nvim-treesitter")
      local languages = { "c", "cpp", "java", "python", "rust" }
      treesitter.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })
      treesitter.install(languages)
      vim.api.nvim_create_autocmd("FileType", { pattern = languages, callback = function() vim.treesitter.start() end })
    end,
  },
  {
    "nvim-telescope/telescope.nvim", lazy = false, dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Find text" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find help" })
      vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Find diagnostics" })
      vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Find document symbols" })
      vim.keymap.set("n", "<leader>fS", builtin.lsp_workspace_symbols, { desc = "Find workspace symbols" })
      vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
      vim.keymap.set("n", "<C-p>", builtin.git_files, {})
      vim.keymap.set("n", "<leader>ps", function() builtin.grep_string({ search = vim.fn.input("Grep > ") }) end)
    end,
  },
  {
    "nvim-pack/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>sr", function() require("spectre").open() end, desc = "Find and replace" },
      { "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, desc = "Replace word" },
      { "<leader>sr", function() require("spectre").open_visual() end, mode = "v", desc = "Replace selection" },
      { "<leader>sp", function() require("spectre").open_file_search({ select_word = true }) end, desc = "Replace in file" },
    },
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeFindFileToggle<cr>", desc = "Toggle file tree" },
    },
    opts = {
      disable_netrw = true,
      hijack_netrw = true,
      update_focused_file = { enable = true },
      view = { width = 32 },
      renderer = {
        group_empty = true,
        indent_markers = { enable = true },
      },
      filters = { dotfiles = false },
    },
  },
  {
    "stevearc/oil.nvim",
    opts = { view_options = { show_hidden = true } },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
  },
  { "christoomey/vim-tmux-navigator", lazy = false },
  { "mbbill/undotree", keys = { { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Toggle undo tree" } } },
})

local keymap = vim.keymap.set

-- 1. INDENTING (Normal, Insert, Visual)
local function indent_line(command)
  local current_col = vim.fn.col(".")
  vim.cmd("normal! " .. command)
  vim.fn.cursor(0, current_col + (command == ">>" and vim.fn.shiftwidth() or -vim.fn.shiftwidth()))
end

keymap("n", "<Tab>", function()
  indent_line(">>")
end, { desc = "Indent" })
keymap("n", "<S-Tab>", function()
  indent_line("<<")
end, { desc = "Outdent" })
keymap("v", "<Tab>", ">gv", { desc = "Indent selection" })
keymap("v", "<S-Tab>", "<gv", { desc = "Outdent selection" })

-- 2. COMMENTING (Ctrl + /)
vim.keymap.set("n", "<C-/>", function()
  require("Comment.api").toggle.linewise.current()
end, { noremap = true, silent = true })

vim.keymap.set("v", "<C-/>", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), "nx", false)
  require("Comment.api").toggle.linewise(vim.fn.visualmode())
end, { desc = "Toggle comment (visual)" })

-- 3. NEW LINES (Enter / Shift+Enter)
keymap("n", "<CR>", "o<Esc>", { desc = "New line below and move" })
keymap("n", "<S-CR>", "O<Esc>", { desc = "New line above and move" })

return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        -- 'preset = "enter"' removes the default Enter behavior
        preset = "enter",
        -- Shift+Enter to select and accept the suggestion
        ["<S-CR>"] = { "select_and_accept", "fallback" },
        -- Tab and Shift+Tab to iterate/scroll through the list
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
      },
      completion = {
        list = {
          selection = {
            preselect = false, -- Don't automatically highlight the first item
            auto_insert = true, -- Shows the text in the buffer as you scroll
          },
        },
      },
    },
  },
}

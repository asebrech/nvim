return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    cmd = { "CopilotChat", "CopilotChatExplain" },
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
      { "nvim-telescope/telescope.nvim" },
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          local prefix = "<Leader>a"
          local chat = require "CopilotChat"
          local actions = require "CopilotChat.actions"
          local telescope = require "CopilotChat.integrations.telescope"

          maps.n[prefix] = { desc = require("astroui").get_icon("Copilot", 1, true) .. "Copilot" }
          maps.v[prefix] = { desc = require("astroui").get_icon("Copilot", 1, true) .. "Copilot" }

          maps.n[prefix .. "i"] = { "<cmd>CopilotChat<CR>", desc = "Copilot" }
          maps.v[prefix .. "i"] = { "<cmd>CopilotChat<CR>", desc = "Copilot" }

          maps.n[prefix .. "x"] = { "<cmd>CopilotChatExplain<CR>", desc = "Explain Code" }
          maps.v[prefix .. "x"] = { "<cmd>CopilotChatExplain<CR>", desc = "Explain Code" }

          maps.n[prefix .. "h"] = {
            function() telescope.pick(actions.help_actions()) end,
            desc = "Help actions",
          }
          maps.v[prefix .. "h"] = {
            function() telescope.pick(actions.help_actions()) end,
            desc = "Help actions",
          }

          maps.n[prefix .. "p"] = {
            function() telescope.pick(actions.prompt_actions()) end,
            desc = "Prompt actions",
          }
          maps.v[prefix .. "p"] = {
            function() telescope.pick(actions.prompt_actions()) end,
            desc = "Prompt actions",
          }

          local function quick_chat()
            local input = vim.fn.input "Quick Chat: "
            if input ~= "" then chat.ask(input) end
          end

          maps.n[prefix .. "q"] = { quick_chat, desc = "Quick chat" }
          maps.v[prefix .. "q"] = { quick_chat, desc = "Quick chat" }

          local function inline_window()
            local current_line = vim.api.nvim_win_get_cursor(0)[1]
            local first_visible_line = vim.fn.line "w0"
            local last_visible_line = vim.fn.line "w$"
            local relative_height = vim.api.nvim_win_get_height(0)
            local inline_window_height = relative_height * 0.3 + 2
            local window_height = last_visible_line - first_visible_line + 1
            local midpoint = first_visible_line + ((window_height + inline_window_height) / 2) - 1

            local window_options = {
              layout = "float",
              relative = "cursor",
              width = 1,
              height = 0.3,
              row = 1,
              border = "rounded",
            }

            if current_line > midpoint then window_options.row = -inline_window_height end
            return window_options
          end

          vim.api.nvim_create_user_command("CopilotChatInline", function(args)
            local window_options = inline_window()

            chat.ask(args.args, { window = window_options })
          end, { nargs = "*", range = true })

          maps.n[prefix .. "l"] = { "<cmd>CopilotChatInline<CR>", desc = "Inline chat" }
          maps.v[prefix .. "l"] = { "<cmd>CopilotChatInline<CR>", desc = "Inline chat" }
        end,
      },
      { "AstroNvim/astroui", opts = { icons = { Copilot = "󰭹" } } },
    },
    opts = {
      debug = false, -- Enable debugging
      show_help = false, -- Shows help message as virtual lines when waiting for user input
      context = "buffers", -- Default context to use, 'buffers', 'buffer' or none (can be specified manually in prompt via @).
      auto_follow_cursor = false, -- Auto-follow cursor in chat
      window = {
        layout = "float", -- 'vertical', 'horizontal', 'float', 'replace'
        width = 0.9, -- fractional width of parent, or absolute width in columns when > 1
        height = 0.9, -- fractional height of parent, or absolute height in rows when > 1
        border = "rounded", -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
      },
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
}

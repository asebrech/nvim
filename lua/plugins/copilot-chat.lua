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
          local prompt = chat.prompts()

          maps.n[prefix] = { desc = require("astroui").get_icon("Copilot", 1, true) .. "Copilot" }
          maps.v[prefix] = { desc = require("astroui").get_icon("Copilot", 1, true) .. "Copilot" }

          -- This dosn't work for the moment
          -- maps.n[prefix .. "h"] = {
          --   function() telescope.pick(actions.help_actions()) end,
          --   desc = "Help actions",
          -- }
          -- maps.v[prefix .. "h"] = {
          --   function() telescope.pick(actions.help_actions()) end,
          --   desc = "Help actions",
          -- }

          maps.n[prefix .. "p"] = {
            function() telescope.pick(actions.prompt_actions()) end,
            desc = "Prompt actions",
          }
          maps.v[prefix .. "p"] = {
            function() telescope.pick(actions.prompt_actions()) end,
            desc = "Prompt actions",
          }

          local function inline_window()
            local current_line = vim.api.nvim_win_get_cursor(0)[1]
            -- Get the visible lines in the window
            local first_visible_line = vim.fn.line "w0"
            local last_visible_line = vim.fn.line "w$"
            -- Get the relative line of the cursor
            local relative_cursor_line = current_line - first_visible_line + 1
            -- Get the total height of the window and the height for the inline window
            local relative_height = vim.api.nvim_win_get_height(0)
            local inline_window_height = math.ceil(relative_height * 0.3) + 1
            -- Get the midpoint of the visible lines
            local window_height = last_visible_line - first_visible_line + 1
            local midpoint = first_visible_line + ((window_height + inline_window_height) / 2) - 1
            -- Get visually selected range if available (relative to window)
            local selected_start, selected_end
            if vim.fn.mode() == "v" or vim.fn.mode() == "V" or vim.fn.mode() == "\22" then
              selected_start = vim.fn.line "v" - first_visible_line + 1
              selected_end = vim.fn.line "." - first_visible_line + 1
              if selected_start > selected_end then
                selected_start, selected_end = selected_end, selected_start
              end
            else
              selected_start = nil
              selected_end = nil
            end
            -- Determine if there is a visual selection
            local has_visual_selection = (selected_start and selected_end and selected_start ~= selected_end)
            -- Initialize window options
            local window_options = {
              layout = "float",
              relative = "cursor",
              width = 1,
              height = 0.3,
              row = 1,
              border = "rounded",
            }
            -- Adjust window position to avoid covering the visual selection
            if has_visual_selection then
              if selected_end + inline_window_height <= relative_height then
                if selected_end == relative_cursor_line then
                  window_options.row = 1
                else
                  window_options.row = selected_end - selected_start + 1
                end
              elseif selected_start - inline_window_height >= 1 then
                if selected_end == relative_cursor_line then
                  window_options.row = -inline_window_height + selected_start - selected_end + -1
                else
                  window_options.row = -inline_window_height + -1
                end
              else
                -- Default positioning if visual selection is too close to the top or bottom
                window_options = {}
              end
            else
              -- Normal positioning if no visual selection
              if current_line > midpoint then window_options.row = -inline_window_height + -1 end
            end
            return window_options
          end

          vim.api.nvim_create_user_command("CopilotChatQuick", function(args)
            local use_inline = args.fargs[1] == "inline"
            local input = vim.fn.input "Quick Chat: "
            if input ~= "" then
              if not use_inline then
                chat.ask(input)
              else
                local window_options = inline_window()
                chat.ask(input, { window = window_options })
              end
            end
          end, { nargs = "*", range = true })

          maps.n[prefix .. "q"] = { "<cmd>CopilotChatQuick<CR>", desc = "Quick chat" }
          maps.v[prefix .. "q"] = { "<cmd>CopilotChatQuick inline<CR>", desc = "Quick chat" }

          vim.api.nvim_create_user_command("CopilotChatInline", function()
            local window_options = inline_window()
            chat.toggle { window = window_options }
          end, { nargs = "*", range = true })

          local function inline_prompt(input)
            local window_options = inline_window()
            chat.ask(input, { window = window_options })
          end

          maps.n[prefix .. "i"] = { "<cmd>CopilotChatToggle<CR>", desc = "Copilot" }
          maps.v[prefix .. "i"] = { "<cmd>CopilotChatInline<CR>", desc = "Copilot" }

          maps.n[prefix .. "x"] = { "<cmd>CopilotChatExplain<CR>", desc = "Explain Code" }
          maps.v[prefix .. "x"] = { function() inline_prompt(prompt.Explain.prompt) end, desc = "Explain Code" }

          maps.n[prefix .. "r"] = { "<cmd>CopilotChatReview<CR>", desc = "Review the selected code" }
          maps.v[prefix .. "r"] =
            { function() inline_prompt(prompt.Review.prompt) end, desc = "Review the selected code" }

          maps.n[prefix .. "f"] = { "<cmd>CopilotChatFix<CR>", desc = "Fix the selected code" }
          maps.v[prefix .. "f"] = { function() inline_prompt(prompt.Fix.prompt) end, desc = "Fix the selected code" }

          maps.n[prefix .. "o"] = { "<cmd>CopilotChatOptimize<CR>", desc = "Optimize the selected code" }
          maps.v[prefix .. "o"] =
            { function() inline_prompt(prompt.Optimize.prompt) end, desc = "Optimize the selected code" }

          maps.n[prefix .. "d"] = { "<cmd>CopilotChatDocs<CR>", desc = "Add documentation to the selected code" }
          maps.v[prefix .. "d"] =
            { function() inline_prompt(prompt.Docs.prompt) end, desc = "Add documentation to the selected code" }

          maps.n[prefix .. "t"] = { "<cmd>CopilotChatTests<CR>", desc = "Generate tests for the selected code" }
          maps.v[prefix .. "t"] =
            { function() inline_prompt(prompt.Tests.prompt) end, desc = "Generate tests for the selected code" }

          maps.n[prefix .. "d"] = { "<cmd>CopilotChatFixDiagnostic<CR>", desc = "Fix diagnostic issue in file" }
          maps.v[prefix .. "d"] =
            { function() inline_prompt(prompt.FixDiagnostic.prompt) end, desc = "Fix diagnostic issue in file" }

          maps.n[prefix .. "c"] = { "<cmd>CopilotChatCommit<CR>", desc = "Write commit message for the change" }
          maps.v[prefix .. "c"] =
            { function() inline_prompt(prompt.Commit.prompt) end, desc = "Write commit message for the change" }

          maps.n[prefix .. "s"] =
            { "<cmd>CopilotChatCommitStaged<CR>", desc = "Write commit message for the staged change" }
          maps.v[prefix .. "s"] = {
            function() inline_prompt(prompt.CommitStaged.prompt) end,
            desc = "Write commit message for the staged change",
          }
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

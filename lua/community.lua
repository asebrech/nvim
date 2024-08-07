-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.typescript-all-in-one" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.rust" },
  -- { import = "astrocommunity.pack.godot" },
  { import = "astrocommunity.utility.noice-nvim" },
  { import = "astrocommunity.completion.copilot-lua-cmp" },
  { import = "astrocommunity.motion.mini-move" },
  { import = "astrocommunity.project.nvim-spectre" },
  { import = "astrocommunity.recipes.neovide" },
}

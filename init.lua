require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
require("config.butterflies").setup({
  interval_minutes = 45,   -- how often it triggers
  duration_seconds = 60,   -- how long it runs each time
  count = 10,              -- how many butterflies per burst
  color = "#c9a0f5",       -- soft purple; change freely
})

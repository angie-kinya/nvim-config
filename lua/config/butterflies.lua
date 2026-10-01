local M = {}

local uv = vim.uv or vim.loop

local opts = {
  interval_minutes = 45,
  duration_seconds = 60,
  count = 10,
  color = "#c9a0f5",
  fps_ms = 120,
}

local HL = "ButterflyGlyph"
local active = {}
local tick_timer, spawn_timer

local function normal_bg()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  if normal.bg then
    return string.format("#%06x", normal.bg)
  end
  return "NONE"
end

local function spawn_one()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "🦋" })

  local col = math.random(0, math.max(vim.o.columns - 2, 0))
  local ok, win = pcall(vim.api.nvim_open_win, buf, false, {
    relative = "editor",
    width = 2,
    height = 1,
    row = 0,
    col = col,
    style = "minimal",
    focusable = false,
    zindex = 200,
    noautocmd = true,
  })
  if not ok then
    return
  end

  vim.api.nvim_set_hl(0, HL, { fg = opts.color, bg = normal_bg() })
  vim.wo[win].winhighlight = "Normal:" .. HL

  table.insert(active, { win = win, row = 0, base_col = col, tick = math.random(0, 6) })
end

local function step()
  for i = #active, 1, -1 do
    local b = active[i]
    if not vim.api.nvim_win_is_valid(b.win) then
      table.remove(active, i)
    else
      b.row = b.row + 1
      b.tick = b.tick + 1
      if b.row >= vim.o.lines then
        pcall(vim.api.nvim_win_close, b.win, true)
        table.remove(active, i)
      else
        local sway = math.floor(math.sin(b.tick / 3) * 2 + 0.5)
        local col = math.max(0, math.min(vim.o.columns - 2, b.base_col + sway))
        pcall(vim.api.nvim_win_set_config, b.win, { relative = "editor", row = b.row, col = col })
      end
    end
  end
  if #active == 0 then
    tick_timer:stop()
  end
end

local function flutter()
  local spawned = 0
  local spawner = uv.new_timer()
  spawner:start(0, 300, vim.schedule_wrap(function()
    if spawned >= opts.count then
      spawner:stop()
      spawner:close()
      return
    end
    spawn_one()
    spawned = spawned + 1
  end))

  if not tick_timer then
    tick_timer = uv.new_timer()
  end
  tick_timer:stop()
  tick_timer:start(0, opts.fps_ms, vim.schedule_wrap(step))

  vim.defer_fn(function()
    for _, b in ipairs(active) do
      pcall(vim.api.nvim_win_close, b.win, true)
    end
    active = {}
  end, opts.duration_seconds * 1000)
end

function M.setup(user_opts)
  opts = vim.tbl_deep_extend("force", opts, user_opts or {})

  vim.api.nvim_create_user_command("Butterflies", flutter, {
    desc = "Send a minute of butterflies across the screen, right now",
  })

  spawn_timer = uv.new_timer()
  local every_ms = opts.interval_minutes * 60 * 1000
  spawn_timer:start(every_ms, every_ms, vim.schedule_wrap(flutter))

  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      if spawn_timer then pcall(function() spawn_timer:stop(); spawn_timer:close() end) end
      if tick_timer then pcall(function() tick_timer:stop(); tick_timer:close() end) end
    end,
  })
end

return M
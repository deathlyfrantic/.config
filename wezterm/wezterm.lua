local wezterm = require("wezterm")

local keys = {
  -- alt-enter confirms selections in star's multi-selection mode
  { key = "Enter", mods = "ALT", action = "DisableDefaultAssignment" },
  -- tmux prefix key
  { key = "b", mods = "CMD", action = { SendKey = { key = "F12" } } },
  -- disable switching between native tabs
  { key = "{", mods = "CMD", action = "DisableDefaultAssignment" },
  { key = "}", mods = "CMD", action = "DisableDefaultAssignment" },
  { key = "[", mods = "SHIFT|CMD", action = "DisableDefaultAssignment" },
  { key = "]", mods = "SHIFT|CMD", action = "DisableDefaultAssignment" },
}

-- disable ALT-# keys to switch native tabs
for i = 1, 9 do
  table.insert(
    keys,
    { key = tostring(i), mods = "ALT", action = "DisableDefaultAssignment" }
  )
end

-- tmux keys
local function add_tmux_key(key, mods, tmux_key, tmux_mods)
  tmux_key = tmux_key or key
  table.insert(
    keys,
    { key = key, mods = mods, action = "DisableDefaultAssignment" }
  )
  local action = {
    Multiple = {
      { SendKey = { key = "F12" } },
      { SendKey = { key = tmux_key } },
    },
  }
  if tmux_mods then
    action.Multiple[2].SendKey.mods = tmux_mods
  end
  table.insert(keys, { key = key, mods = mods, action = action })
end

for i = 1, 9 do
  add_tmux_key(tostring(i), "CMD")
end

-- create new pane
add_tmux_key("t", "CMD", "c")

-- move between windows
add_tmux_key("h", "CMD")
add_tmux_key("j", "CMD")
add_tmux_key("k", "CMD")
add_tmux_key("l", "CMD")
add_tmux_key("{", "SHIFT|CMD")
add_tmux_key("}", "SHIFT|CMD")

-- move windows
add_tmux_key("LeftArrow", "SHIFT|CMD", nil, "SHIFT")
add_tmux_key("RightArrow", "SHIFT|CMD", nil, "SHIFT")

-- resize windows
add_tmux_key("LeftArrow", "CMD")
add_tmux_key("RightArrow", "CMD")
add_tmux_key("UpArrow", "CMD")
add_tmux_key("DownArrow", "CMD")

-- split windows
add_tmux_key("d", "CMD", "v")
add_tmux_key("d", "SHIFT|CMD", "s")

-- copy mode
add_tmux_key("[", "CMD")

-- search
add_tmux_key("f", "CMD", "f")
add_tmux_key("f", "SHIFT|CMD", "F")

-- thumbs
add_tmux_key(" ", "SHIFT|CMD")

-- maximize window on startup
wezterm.on("gui-startup", function(cmd)
  local _, _, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

return {
  audible_bell = "Disabled",
  color_scheme = "Builtin Tango Dark",
  default_prog = {
    "/opt/homebrew/bin/zsh",
    "-l",
    "-c",
    "/opt/homebrew/bin/tmux",
  },
  enable_tab_bar = false,
  freetype_load_target = "Normal",
  font = wezterm.font("SF Mono", { weight = "Medium" }),
  font_size = 14.5,
  force_reverse_video_cursor = true,
  harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
  initial_cols = 160,
  initial_rows = 50,
  keys = keys,
  scrollback_lines = 10000,
  send_composed_key_when_left_alt_is_pressed = false,
  send_composed_key_when_right_alt_is_pressed = false,
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
}

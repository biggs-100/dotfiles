local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.default_prog = { "C:/Program Files/PowerShell/7/pwsh.exe", "-NoLogo" }

config.set_environment_variables = {
  PATH = os.getenv("PATH") .. ";C:\\Users\\USER\\AppData\\Local\\Microsoft\\WindowsApps",
}

config.font = wezterm.font_with_fallback {
  'CaskaydiaCove Nerd Font Mono',
  'Cascadia Code',
  'Consolas',
}
config.font_size = 11.0
config.color_scheme = 'Catppuccin Mocha'

config.window_background_opacity = 1.0
config.win32_system_backdrop = 'Disable'

config.front_end = 'OpenGL'
config.max_fps = 60
config.animation_fps = 30
config.cursor_blink_rate = 500
config.default_cursor_style = 'BlinkingBar'

config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

config.keys = {
  { key = 't', mods = 'CTRL|SHIFT', action = wezterm.action.SpawnCommandInNewTab {
    domain = 'DefaultDomain',
    cwd = wezterm.home_dir,
  }},
}

return config

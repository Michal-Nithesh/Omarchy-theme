-- Night Owl Look & Feel for Hyprland (Lua)
-- Midnight Navy & Teal aesthetic inspired by Sarah Drasner's Night Owl palette

local active_border_color = { colors = { "rgba(7fdbcaee)", "rgba(82aaffee)" }, angle = 45 }
local inactive_border_color = "rgba(1d3b53aa)"

hl.config({
  general = {
    gaps_in = 6,
    gaps_out = 12,
    border_size = 2,

    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },

    resize_on_border = true,
  },

  decoration = {
    rounding = 10,

    active_opacity = 1.0,
    inactive_opacity = 0.96,

    shadow = {
      enabled = true,
      range = 20,
      render_power = 3,
      color = "rgba(01162799)",
      color_inactive = "rgba(01162744)",
    },

    blur = {
      enabled = true,
      size = 6,
      passes = 3,
      new_optimizations = true,
      xray = false,
      noise = 0.012,
      vibrancy = 0.20,
      popups = false,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },

  cursor = {
    no_hardware_cursors = true,
    hide_on_key_press = false,
    hide_on_touch = false,
    inactive_timeout = 0,
    invisible = false,
    warp_on_change_workspace = 1,
  },
})

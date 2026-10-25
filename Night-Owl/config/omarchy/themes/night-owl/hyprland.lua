-- Night Owl Theme Overrides for Hyprland (Lua)
-- Canonical palette by Sarah Drasner

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
})

-- Sakurazuki Look & Feel for Hyprland
-- Japanese Cherry Blossom / Midnight Plum aesthetic

local active_border_color = { colors = { "rgba(a87692ee)", "rgba(d9a6c4ee)" }, angle = 45 }
local inactive_border_color = "rgba(443043aa)"

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
    rounding = 14,

    active_opacity = 1.0,
    inactive_opacity = 0.96,

    shadow = {
      enabled = true,
      range = 22,
      render_power = 3,
      color = "rgba(14111a77)",
      color_inactive = "rgba(14111a33)",
    },

    blur = {
      enabled = true,
      size = 6,
      passes = 3,
      new_optimizations = true,
      xray = false,
      noise = 0.012,
      vibrancy = 0.22,
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

  animations = {
    enabled = true,
  },
})

-- Custom Sakurazuki Beziers
hl.curve("sakuraEase", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("sakuraFade", { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1 } } })

-- Smooth Snappy Transitions (200-300ms)
hl.animation({ leaf = "global", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 3.2, bezier = "sakuraEase" })
hl.animation({ leaf = "windows", enabled = true, speed = 3.0, bezier = "sakuraEase" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.0, bezier = "sakuraEase", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.2, bezier = "sakuraEase", style = "popin 92%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2.5, bezier = "sakuraFade" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2.0, bezier = "sakuraFade" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.8, bezier = "sakuraEase" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 2.4, bezier = "sakuraEase" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.0, bezier = "sakuraEase" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 3.0, bezier = "sakuraEase", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2.0, bezier = "sakuraFade", style = "fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3.2, bezier = "sakuraEase", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3.2, bezier = "sakuraEase", style = "slidevert" })

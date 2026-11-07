return {
  {
    "omacom/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg = "#1c1917",
        dark_bg = "#161310",
        darker_bg = "#0f0a06",
        lighter_bg = "#2d2927",

        fg = "#f2efe4",
        dark_fg = "#c8c5ba",
        light_fg = "#fffdf2",
        bright_fg = "#fffff4",
        muted = "#5d5b59",

        red = "#d2a5a3",
        yellow = "#caae45",
        orange = "#d0a976",
        green = "#6a8c52",
        cyan = "#63958e",
        blue = "#408c9f",
        magenta = "#947a94",
        brown = "#8e7a36",

        bright_red = "#f4c6c4",
        bright_yellow = "#eecf65",
        bright_green = "#89ac70",
        bright_cyan = "#82b5ae",
        bright_blue = "#62acbf",
        bright_magenta = "#b499b4",

        accent = "#caae45",
        cursor = "#fffff4",
        foreground = "#f2efe4",
        background = "#1c1917",
        selection = "#caae45",
        selection_foreground = "#1c1917",
        selection_background = "#caae45",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}

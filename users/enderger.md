---
title: Users :: Enderger
---
This is my primary user, not much more to say.

```nix users/enderger.nix
/*
<<<license>>>
*/
{ pkgs, inputs, ... }:
let 
  secrets = import ./enderger.secret.nix;
  theme = [
    <<<users/enderger/colors>>>
  ];
  theme-color = builtins.elemAt theme;
  font = "FiraCode Nerd Font";
  term = "alacritty";
  browser = "qutebrowser";
  # TODO: Set up Neovide
  editor = "${term} -e nvim";
in {
  users.users.enderger = {
    <<<users/enderger/userOptions>>>
  };

  services.xserver.windowManager = {
    <<<users/enderger/windowManagers>>>
  };

  home-manager.users.enderger = { config, ... }: {
    # CLI setup
    <<<users/enderger/nushell>>>
    <<<users/enderger/starship>>>
    <<<users/enderger/alacritty>>>
    <<<users/enderger/man>>>
    <<<users/enderger/bat>>>
    <<<users/enderger/neovim>>>
    <<<users/enderger/git>>>

    # GUI Setup
    <<<users/enderger/awesome>>>
    <<<users/enderger/feh>>>
    <<<users/enderger/luakit>>>
    <<<users/enderger/picom>>>

    # Packages
    home.packages = [
      <<<users/enderger/packages>>>
    ];
  };
}
```

# CLI Setup
## Shell / Environment
### Nushell
This is my preferred shell, mainly for it's novel approach to information presentation.
```nix "users/enderger/nushell"
# users/enderger/nushell
programs.nushell = {
  enable = true;
  settings = {
    complete_from_path = true;
    ctrlc_exit = false;
    disable_table_indexes = false;
    filesize_format = "GiB";
    nonzero_exit_errors = true;
    pivot_mode = "auto";
    prompt = "starship prompt";
    rm_always_trash = true;
    skip_welcome_message = true;
    table_mode = "rounded";

    line_editor = {
      bell_style = "none";
      completion_type = "circular";
      edit_mode = "vi";
      history_duplicates = "ignoreconsecutive";
      history_ignore_space = true;
    };

    textview = {
      tab_width = 2;
      theme = "base16";
    };

    startup = lib.splitString "\n" ''
      <<<users/enderger/nushell/startup>>>
    '';
  };
};
```

#### Startup
```nu "users/enderger/nushell/startup"
# users/enderger/nushell/startup
pfetch
```

### Starship
This is my preferred prompt. It is written in Rust and configured in TOML.
```nix "users/enderger/starship"
# users/enderger/starship
programs.starship = {
  enable = true;
  settings = let
    git_color = "bold magenta";
    hg_color = "bold yellow";
  in {
    format = ''
      \[$username$hostname\]$nix_shell$hg_branch$git_status$git_branch$git_commit$git_state
      $character 
    '';
    add_newline = false;

    username = {
      style_root = "bold red";
      style_user = "bold cyan";
      format = "[$user]($style)";

      show_always = true;
    };

    hostname = {
      style = "bold yellow";
      format = "@[$hostname]($style)";

      ssh_only = true;
    };

    nix_shell = {
      style = "bold blue";
      format = " \\([$symbol$state \\($name\\)]($style)\\)";
    };

    hg_branch = {
      style = hg_color;
      format = " [$symbol$branch]($style)";
    };

    git_status = {
      style = git_color;
      format = " [$all_status$ahead_behind]($style)";
    };

    git_branch = {
      style = git_color;
      format = " [$symbol$branch]($style)";
    };

    git_commit = {
      style = git_color;
      format = " \\(commit [$hash( $tag)]($style)\\)";
    };

    git_state = {
      style = git_color;
      format = " [$state( $progress_current/$progress_total)]($style)";
    };

    character = let
      symbol = "λ";
    in {
      success_symbol = "[${symbol}](bold green)";
      error_symbol = "[${symbol}](bold red)";
      vicmd_symbol = "[${symbol}](bold yellow)";
    };
  };
};
```

### Alacritty
Currently, I'm using Alacritty. At some point, I hope to write my own to avoid certain political issues with this one, but until then I'm using it.
```nix "users/enderger/alacritty"
# users/enderger/alacritty
programs.alacritty = {
  enable = true;
  settings = {
    env.TERM = "alacritty";
    font.normal.family = font;

    window = {
      decorations = "none";
      title = "Terminal Emulator (Alacritty)";
      dynamic_title = false;
    };

    colors = let
      mkColor = id: "0x${theme-color id}";
    in {
      primary.background = mkColor 0;
      primary.foreground = mkColor 5;

      cursor.text = mkColor 0;
      cursor.cursor = mkColor 5;

      normal = {
        black = mkColor 0;
        red = mkColor 8;
        green = mkColor 11;
        yellow = mkColor 10;
        blue = mkColor 13;
        magenta = mkColor 14;
        cyan = mkColor 12;
        white = mkColor 5;
      };

      bright = {
        black = mkColor 3;
        red = mkColor 8;
        green = mkColor 1;
        yellow = mkColor 2;
        blue = mkColor 4;
        magenta = mkColor 6;
        cyan = mkColor 15;
        white = mkColor 7;
      };
    };
    background_opacity = 0.95;
  };
};
```

## Text Viewing
### Man
This sets up manual pages (shortened to `manpages`).
```nix "users/enderger/man"
# users/enderger/man
programs.man.enable = true;
```

### Bat
This sets up `bat`, which is basically `cat` on Red Bull.
```nix "users/enderger/bat"
programs.bat = {
  enable = true;
  config = {
    pager = "less -FR";
    theme = "base16";
  };
};
```

### Neovim
Here, we configure my text editor of choice: Neovim. I use Aniseed to configure it with Fennel LISP (see the module for more info), and take full advantage of nightly features.
```nix "users/enderger/neovim"
# users/enderger/neovim
programs.neovim = {
  enable = true;
  package = pkgs.neovim-nightly;
  
  plugins = with pkgs.vimPlugins; [
    <<<users/enderger/neovim/plugins>>>
  ];

  extraPackages = with pkgs; [
    <<<users/enderger/neovim/plugins/packages>>>
  ];
  
  luaInit = "init";
  luaModules = {
    <<<users/enderger/neovim/config>>>
  };
};
```

#### Plugins
Here is the list of plugins I include with this install.
Since there are several plugins, I'll use an accumulator macro.

##### Core
These plugins provide the core functionality used in this config.
- `completion-nvim` gives the builtin Neovim LSP client automatic completion support.
- `neoformat` adds in automatic code formatting support
- `nvim-lspconfig` sets up the Neovim builtin `Language Server Protocol` client.
- `nvim-treesitter` adds support for `tree-sitter` parsers.
- `telescope-nvim` adds an exceptionally powerful fuzzy finder for Neovim.
- `vim-vsnip` / `vim-vsnip-integ` give support for snippets.
- `which-key-nvim` provides a better keybinding system.

```nix "users/enderger/neovim/plugins" +=
# users/enderger/neovim/plugins.backend
completion-nvim
neoformat
nvim-lspconfig
# this loads all tree-sitter grammars
(nvim-treesitter.withPlugins builtins.attrValues)
telescope-nvim
vim-vsnip vim-vsnip-integ
which-key-nvim
```

##### Editing Facilities
These plugins add in facilities which make editing more powerful.
- `lightspeed-nvim` improves the navigation experience provided by Neovim.
- `nvim-autopairs` adds in automatic bracket closing for Neovim.
- `nvim-treesitter-refactor` gives refactoring abilities using `tree-sitter`.
- `supertab` makes all Vim completions use `<TAB>`
- `vim-surround` gives Vim bindings to surround text.

```nix "users/enderger/neovim/plugins" +=
# users/enderger/neovim/plugins.editing
lightspeed-nvim
nvim-autopairs
nvim-treesitter-refactor
supertab
vim-surround
```

##### Utilities
These plugins enhance the editing experience in a small way.
- `auto-session` sets up automatic session management for Neovim.
- `friendly-snippets` adds a bunch of useful snippets for `vim-vsnip`.
- `lsp-rooter-nvim` automatically sets the CWD using LSP.
- `minimap-vim` adds in a minimap.
- `nvim-lightbulb` adds in VSCode's lightbulb for Neovim's LSP.
- `nvim-treesitter-context` shows the context of what you can see onscreen.
- `nvim-ts-rainbow` highlights matching parentheses.

```nix "users/enderger/neovim/plugins" +=
# users/enderger/neovim/plugins.utilities
auto-session
friendly-snippets
lsp-rooter-nvim
minimap-vim
nvim-lightbulb
nvim-treesitter-context
nvim-ts-rainbow
```

##### Integrations
These plugins integrate Neovim with the outside world.
- `gitsigns-nvim` adds in Git decorations for Neovim
- `glow-nvim` adds in a nice Markdown preview to Neovim.
- `neogit` adds in a Magit-like interface for Git in Neovim.
- `nvim-toggleterm-lua` adds in better terminal integration to Neovim.
- `vim-test` integrates various test runners with Neovim.

```nix "users/enderger/neovim/plugins" +=
# users/enderger/neovim/plugins.integrations
gitsigns-nvim
glow-nvim
neogit
nvim-toggleterm-lua
vim-test
```

##### UI Plugins
These provide the building blocks of my editor user interface.
- `galaxyline-nvim` provides the building blocks used for my statusline.
- `nvim-base16` provides strong support for Base16 colorschemes in Neovim.
- `nvim-web-devicons` / `nvim-nonicons` give Neovim icons.

```nix "users/enderger/neovim/plugins" +=
# users/enderger/neovim/plugins.ui
feline-nvim
nvim-base16
nvim-web-devicons nvim-nonicons
```

##### Environment
Here, we'll set up the environment within which Neovim operates. This includes things such as LSP servers.
```nix "users/enderger/neovim/plugins/packages"
# users/enderger/neovim/plugins/packages
deno nodePackages.vscode-html-languageserver-bin nodePackages.vscode-css-languageserver-bin
rnix-lsp
(with fenix; combine [
  default.rustfmt-preview default.clippy rust-analyzer
])
```

#### Config
Now, we'll set up my Neovim config. It takes the form of a set of Lua modules that are loaded by Neovim through the Neovim module.
```nix "users/enderger/neovim/config"
# users/enderger/neovim/config
init = ''
  <<<users/enderger/neovim/config/init>>>
'';
lib = ''
  <<<users/enderger/neovim/config/lib>>>
'';
editor = ''
  <<<users/enderger/neovim/config/editor>>>
'';
keys = ''
  <<<users/enderger/neovim/config/keys>>>
'';

editing = ''
  <<<users/enderger/neovim/config/editing>>>
'';
extensions = ''
  <<<users/enderger/neovim/config/extensions>>>
'';
ui = ''
  <<<users/enderger/neovim/config/ui>>>
'';
misc = ''
  <<<users/enderger/neovim/config/misc>>>
'';
```

##### Init
This is the module which bootstraps the others. It's job is to load the other modules.
```lua "users/enderger/neovim/config/init"
-- users/enderger/neovim/config/init
require('editor')
require('keys')
require('editing')
require('extensions')
require('ui')
require('misc')
```

##### Library Functions
These functions make some things, such as registering autocommands, easier. 
```lua "users/enderger/neovim/config/lib"
-- users/enderger/neovim/config/lib
local lib = {};

function lib.autocmd(event, action, filter='*')
  vim.cmd(string.format("autocmd %s %s %s", event, filter, action))
end

function lib.map(from, to, mode='n', opts={})
  local defaults = { noremap = true, silent = true }
  vim.api.nvim_set_keymap(mode, from, to, vim.tbl_deep_extend("force", defaults, opts))
end

return lib
```

##### Editor
This module is used to set up the editor itself.
```lua "users/enderger/neovim/config/editor"
-- users/enderger/neovim/config/editor
local opt = vim.opt

-- asthetic
opt.background = 'dark'
opt.cursorline = true
opt.guifont = '${font}' -- interpolated via Nix
opt.number = true
opt.showmode = false
opt.signcolumn = 'yes:3'

-- indentation
local tabsize = 2
opt.expandtab = true
opt.shiftwidth = tabsize
opt.smartindent = true
opt.tabstop = tabsize

-- misc
opt.confirm = true
opt.completeopt = { 'menuone', 'noinsert', 'noselect' }
opt.foldmethod = 'expr'
opt.hidden = true
opt.mouse = 'a'
opt.spell = true
opt.title = true
```

##### Keys
Here, we set up my keybindings (primarily using `which-key`)
```lua "users/enderger/neovim/config/keys"
-- users/enderger/neovim/config/keys
local map = require('lib').map
local ts = require('telescope.builtin')

-- leaders
vim.g.leader = ' '
vim.g.localleader = ','

-- which-key setup
local wk = require('which-key')
wk.setup {}

-- insert mappings
map('jk', '<Cmd>stopinsert<CR>', mode='i')
map('<C-Leader>', '<C-o><Leader>', mode='i')

-- applications
local application_keys = {
  name = 'apps/',
  d = {
    function() ts.lsp_workspace_diagnostics {} end,
    "diagnostics",
  },
  f = {
    function() ts.file_browser {} end,
    "files",
  },
  g = { 
    function() require('neogit').open { kind = "split" } end, 
    "git" 
  },
  m = {
    "<Cmd>MinimapToggle<CR>",
    "minimap"
  },
  s = {
    "<Cmd>ToggleTerm<CR>",
    "shell"
  },
  t = {
    "<Cmd>TestSuite<CR>",
    "tests"
  },
}

-- goto
local goto_keys = {
  name = 'goto/',
  b = {
    function() ts.buffers {} end,
    "buffer"
  },
  d = {
    function() ts.lsp_definitions {} end,
    "definition"
  },
  f = {
    function() ts.find_files {} end,
    "file"
  },
  ["<S-f>"] = {
    function() ts.find_files { hidden = true } end,
    "file (hidden)"
  },
  i = {
    function() ts.lsp_implementations {} end,
    "implementation"
  },
  r = {
    function() ts.lsp_references {} end,
    "reference"
  }
}

-- actions
local action_keys = {
  name = 'actions/',
  c = {
    function() ts.lsp_code_actions {} end,
    "code-actions"
  },
  f = {
    "<Cmd>Neoformat<CR>",
    "format"
  },
  m = {
    "<Cmd>Glow<CR>",
    "markdown-preview"
  },
  r = {
    require("nvim-treesitter-refactor.smart_rename").smart_rename,
    "rename"
  }
}

-- help
local help_keys = {
  name = 'help/',
  t = {
    function() ts.help_tags {} end,
    "help-tags"
  },
  m = {
    function() ts.man_pages {} end,
    "man-pages"
  },
}
```

##### Editing
Here, we set up plugins which focus on directly extending the Vim experience.
```lua "users/enderger/neovim/config/editing"
-- users/enderger/neovim/config/editing
local lib = require('lib')
local opt = vim.opt
local g = vim.g

-- LSP
local lsp = require('lspconfig')

--- Capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionitem.snippetSupport = true

--- Deno
lsp.denols.setup {
  capabilities = capabilities,
}

--- HTML
lsp.html.setup {
  capabilities = capabilities,
}

--- CSS
lsp.cssls.setup {
  capabilities = capabilities,
}

--- Nix
lsp.rnix.setup {
  capabilities = capabilities,
}

--- Rust
lsp.rust_analyzer.setup {
  capabilities = capabilities,
  settings['rust-analyzer'] = {
    -- use Clippy
    checkOnSave.command = 'clippy',
  },
}

-- Completion
lib.autocmd('BufEnter', 'lua require(\'completion\').on_attach()')
opt.shortmess:append('c')
g.completion_matching_smart_case = true

-- Snippets
g.completion_enable_snippet = 'vim-vsnip'

-- Treesitter
local ts = require('nvim-treesitter')
ts.configs.setup {
  autopairs.enable = true,

  highlight.enable = true,

  indent.enable = true,

  rainbow = {
    enable = true,
    extended_mode = true,
  },

  refactor = {
    highlight_current_scope.enable = true,
    highlight_definitions.enable = true,
    smart_rename.enable = true,
  },
}
require('treesitter-context.config').setup {
  enable = true,
}

opt.foldexpr = vim.fn['nvim_treesitter#foldexpr']()

-- Formatting
lib.autocmd('BufWritePre', 'undojoin | Neoformat')

-- Lightspeed
local lightspeed = require('lightspeed')
lightspeed.setup {}

-- Autopairs
local autopairs = require('nvim-autopairs')
autopairs.setup {
  check_ts = true,
}

-- Lightbulb
lib.autocmd('CursorHold,CursorHoldI', 'lua require(\'nvim-lightbulb\').update_lightbulb()')

-- Git Signs
local gitsigns = require('gitsigns')
gitsigns.setup {}
```

##### Extensions
Here, we have plugins which add in new environments to provide features which suppliment editing capabilities.
```lua "users/enderger/neovim/config/extensions"
-- users/enderger/neovim/config/extensions
local g = vim.g

-- Telescope
local tsc = require('telescope')
tsc.setup {
  defaults = tsc.themes.get_ivy {
    mappings.i = {
      ["<Tab>"] = tsc.actions.move_selection_next,
      ["<S-Tab>"] = tsc.actions.move_selection_previous,
      ["<Esc>"] = tsc.actions.close,
    },
    
    prompt_prefix = '$ ',
    selection_caret = '> ',
  },
}

-- Minimap
g.minimap_git_colors = true
g.minimap_highlight_range = true
g.minimap_width = 10

-- Git
local neogit = require('neogit')
neogit.setup {
  signs = {
    section = { "|", ":" },
    item = { "|", ":" },
    hunk = { "|", ":" },
  },
}

-- Terminal
local toggle_term = require('toggleterm')
toggle_term.setup {
  shading_factor = 1,
  open_mapping = "<C-S-t>",
}

-- Testing
g['test#strategy'] = 'neovim'
```

##### UI
Here, we have plugins which add UI improvements to Neovim.
```lua "users/enderger/neovim/config/ui"
-- users/enderger/neovim/config/ui
-- colours
local b16 = require('base16-colorscheme')
local colours = {
  base00 = '#${theme-color 0}',
  base01 = '#${theme-color 1}',
  base02 = '#${theme-color 2}',
  base03 = '#${theme-color 3}',
  base04 = '#${theme-color 4}',
  base05 = '#${theme-color 5}',
  base06 = '#${theme-color 6}',
  base07 = '#${theme-color 7}',
  base08 = '#${theme-color 8}',
  base09 = '#${theme-color 9}',
  base0A = '#${theme-color 10}',
  base0B = '#${theme-color 11}',
  base0C = '#${theme-color 12}',
  base0D = '#${theme-color 13}',
  base0E = '#${theme-color 14}',
  base0F = '#${theme-color 15}',
}
b16.setup(colours)

-- statusline
local feline = require('feline')
local feline_lsp = require('feline.providers.lsp')
local feline_config = {
  components = {
    left = {
      active = {
        -- mode
        {
          provider = 'vi_mode',

          hl = function()
            return { 
              name = require('feline.providers.vi_mode').get_mode_highlight_name()
              fg = require('feline.providers.vi_mode').get_mode_color()
              style = 'bold'
            }
          end,

          right_sep = ' ',
          icon = '',
        },

        -- file info
        {
          provider = 'file_info',

          hl = {
            fg = 'base05',
            bg = 'base02',
            style = 'bold',
          },

          left_sep = ' ',
          right_sep = ' ',
        },
        {
          provider = 'position',

          left_sep = '(',
          right_sep = ')',
        },
      }, 
      inactive = {
        { provider = 'file_info' },
      },
    },
    mid = {
      active = {
        -- git info
        {
          provider = 'git_branch',

          hl = { 
            fg = 'base0c',
            style = 'bold',
          },

          right_sep = ' ',
        },
        {
          provider = 'git_diff_added',

          hl = { 
            fg = 'base0b',
            style = 'bold',
          },

          right_sep = ' ',
        },
        {
          provider = 'git_diff_changed',

          hl = { 
            fg = 'base09',
            style = 'bold',
          },

          right_sep = ' ',
        },
        {
          provider = 'git_diff_removed',

          hl = { 
            fg = 'base08',
            style = 'bold',
          },

          right_sep = ' ',
        },
      }, 
      inactive = {},
    },
    right = {
      active = {
        -- LSP info
        {
          provider = 'diagnostic_errors',
          enabled = function() return feline_lsp.diagnostics_exist('Error') end,
          hl = { fg = 'base08' },
        },
        {
          provider = 'diagnostic_warnings',
          enabled = function() return feline_lsp.diagnostics_exist('Warning') end,
          hl = { fg = 'base0a' },
        },
        {
          provider = 'diagnostic_hints',
          enabled = function() return feline_lsp.diagnostics_exist('Hint') end,
          hl = { fg = 'base0c' },
        },
        {
          provider = 'diagnostic_info',
          enabled = function() return feline_lsp.diagnostics_exist('Information') end,
          hl = { fg = 'base0d' },
        },
      },
      inactive = {},
    },
  },
  properties = {
    force_inactive.buftypes = {
      'terminal'
    },
  },
  mode_colours = {
    NORMAL = 'base0b',
    OP = 'base0b',
    INSERT = 'base08',
    VISUAL = 'base0d',
    BLOCK = 'base0d',
    REPLACE = 'base0e',
    ['V-REPLACE'] = 'base0e',
    ENTER = 'base0c',
    MORE = 'base0c',
    SELECT = 'base0f',
    COMMAND = 'base0b',
    SHELL = 'base0b',
    TERM = 'base0b',
    NONE = 'base0a',
  },
}

feline.setup {
  default_bg = 'base01',
  default_fg = 'base04',
  colors = colours,
  components = feline_config.components,
  properties = feline_config.properties,
  vi_mode_colors = feline_config.mode_colours,
}
```

## Other
### Git
```nix "users/enderger/git"
# users/enderger/git
programs.git = {
  enable = true;
  userEmail = "endergeryt@gmail.com";
  userName = "Enderger";
};
```

# GUI Setup
## Window Managers
Here, we enable all window managers this user has configs for. This is done here, since I want to use multiple window managers per user, when convenient.
```nix "users/enderger/windowManagers"
# users/enderger/windowManagers
awesome.enable = true;
```

### Awesome
Here, we'll be configuring the Awesome window manager. I would use XMonad, were GHC lighter and this repo not already mostly using Lua.
```nix "users/enderger/awesome"
# users/enderger/awesome
luaModules = {
  rc = ''
    <<<users/enderger/awesome/rc>>>
  '';

  init = ''
    <<<users/enderger/awesome/init>>>
  '';
  keys = ''
    <<<users/enderger/awesome/keys>>>
  '';
  rules = ''
    <<<users/enderger/awesome/rules>>>
  '';
  tags = ''
    <<<users/enderger/awesome/tags>>>
  '';
  theme = ''
    <<<users/enderger/awesome/theme>>>
  '';
  widgets = ''
    <<<users/enderger/awesome/widgets>>>
  '';
};
```

#### RC
This file is what is loaded directly by Awesome.
```lua "users/enderger/awesome/rc"
-- users/enderger/awesome/rc
local awesome = require('awesome')
local naughty = require('naughty')

-- error handling
naughty.connect_signal("request::display_error", function(message, startup)
  error_type = startup and "Startup" or "Runtime"
  naughty.notification {
    urgency = "critical",
    title = error_type.." error!",
    message = message,
  }
end)

require('menubar').terminal = '${term}'

require('init').setup()
```

#### Init
This file sets up everything which needs to automatically be started.
```lua "users/enderger/awesome/init"
-- users/enderger/awesome/init
local M = {}
local spawn = require('awful.spawn').once

function M.setup()
  spawn('systemctl --user start picom xidlehook')
  spawn('feh --bg-scale ~/wallpapers/wallpaper.jpg')
  spawn('lxqt-policykit')
end

return M
```

#### Keys
Here, we set up all of my keybindings.
```lua "users/enderger/awesome/keys"
-- users/enderger/awesome/keys
local M = {}

local awesome = require('awesome')
local awful = require('awful')
local widgets = require('widgets')

-- modifiers
M.leader = 'mod4'
M.modifier = 'Shift'
M.alternate = 'Control'

-- tables
local global_keys = {
  awful.key {
    key = 'q',
    modifiers = { M.leader, M.modifier }
    
    on_press = function()
      awful.popup {
        widget = widgets.logout_menu,
        border_width = 1,
        placement = awful.placement.,
        visible = true,
      } 
    end, 

    description = "Exit Awesome",
    group = "core",
  },
}

function M.setup()
      
end

return M
```

#### Widgets
Here, we define all of my widgets.
```lua "users/enderger/awesome/widgets"
-- users/enderger/awesome/widgets
local M = {}

local awesome = require('awesome')
local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')

-- components
function M.button(text, action)
  -- base widget
  local w = wibox.widget {
    {
      markup = text,

      align = 'center',
      valign = 'center',

      widget = wibox.widget.textbox,
    },

    buttons = {
      awful.button {
        modifiers = {},
        button = awful.button.names.LEFT,
        on_press = action,
      },
    },

    border_width = 1,
    widget = wibox.container.background
  }
  
  -- signals
  w:connect_signal("mouse::enter", function(w) w:set_bg(beautiful.bg_focus) end)
  w:connect_signal("mouse::leave", function(w) w:set_bg(beautiful.bg_normal) end)

  return w
end

function M.title(text)
  return wibox.widget {
    markup = '<big>'..text..'</big>',

    align = 'center',
    valign = 'center',

    widget = wibox.widget.textbox
  }
end

-- popups
M.logout_menu = wibox.widget {
  M.title('Logout'),

  {
    M.button('reload', awesome.restart),
    M.button('logout', awesome.quit),
    M.button('suspend', function() awful.spawn('systemctl suspend') end),
    M.button('shutdown', function() awful.spawn('systemctl poweroff') end),
    M.button('reboot', function() awful.spawn('systemctl reboot') end),

    layout = wibox.layout.flex.horizontal
  },
  
  widget = wibox.layout.fixed.vertical
}

return M
```

<!--
### Qtile
Now, we'll be configuring Qtile. While I don't particularly like Python, I find that the Glasgow Haskell Compiler is a bit of a heavy dependency to have for a lightweight WM.
```nix "users/enderger/qtile"
config = ''
  <<<users/enderger/qtile/config>>>
'';

groups = ''
  <<<users/enderger/qtile/groups>>>
'';
hooks = ''
  <<<users/enderger/qtile/hooks>>>
'';
keys = ''
  <<<users/enderger/qtile/keys>>>
'';
layouts = ''
  <<<users/enderger/qtile/layouts>>>
'';
screens = ''
  <<<users/enderger/qtile/screens>>>
'';
```

#### Config
Here, we have the primary configuration. In additon to including the other sections, we configure anything not large enough to warrent a file.
```python "users/enderger/qtile/config"
# users/enderger/qtile/config
from groups import *
from hooks import *
from keys import *

# settings
defaults = {
  'font': '${font}',
  'fontsize': 10,
  'padding': 3,
}

# top-level options
extension_defaults = defaults.copy()
follow_mouse_focus = False
widget_defaults = defaults.copy()
auto_minimize = False
```

#### Groups
This section sets up groups, Qtile's equivilent to workspaces.
```python "users/enderger/qtile/groups"
# users/enderger/qtile/groups
from libqtile.config import Group, Match
from libqtile.dgroups import simple_key_binder
from keys import leader

# groups
groups: list[Group] = [
  Group("main"),
  Group("web"),
  Group("dev"),
  Group("aux1"),
  Group("aux2"),
  Group("aux3"),
]

# group key
dgroups_key_binder = simple_key_binder(leader)
```

#### Hooks
This section sets up a number of hooks used to run code when certain events occur.
```python "users/enderger/qtile/hooks"
# users/enderger/qtile/hooks
from libqtile import hook
from libqtile.hook import subscribe
from pathlib import Path
import subprocess

def start_service(service: str, user: bool = False) -> None:
  """A helper to start a systemd service"""
  scope = "--user" if user else "--system"
  subprocess.run(['systemctl', scope, 'start', service])

def start_background(command: list[str]) -> None:
  """A helper to spawn a background process"""
  subprocess.Popen(command)

@subscribe.startup_once
def init() -> None:
  # TODO: Make wallpaper deterministic
  wallpaper = Path('~/wallpapers/wallpaper.jpg').expanduser()
  start_background(['feh', '--bg-scale', wallpaper])

  start_service('picom', user = True)
  start_service('xidlehook', user = True)
  start_background(['lxqt-policykit'])
```

#### Keys
Here, we configure all of my keybinds.
```python "users/enderger/qtile/keys"
# users/enderger/qtile/keys
from libqtile.config import Key, KeyChord, Click, Drag
from libqtile.command import lazy
leader = 'mod4'

keys = [
  # Launch applications
  KeyChord([leader], 'r', [
    Key([], 't', lazy.spawn('${term}')),
    Key([], 'b', lazy.spawn('${browser}')),
    Key([], 'e', lazy.spawn('${editor}')),
    Key([], 'Return', lazy.spawncmd())
  ]),

  # Layout
  KeyChord([leader], 'l', [
    Key([], 'Tab', lazy.next_layout()),
    Key(['shift'], 'Tab', lazy.prev_layout()),

    Key([], 'n', lazy.next_group()),
    Key([], 'p', lazy.prev_group()),

    Key([], 'w', lazy.next_window()),
    Key(['shift'], 'w', lazy.prev_window()),

    Key([], 'j', lazy.window.shuffle_down()),
    Key([], 'k', lazy.window.shuffle_up()),


    Key([], 'f', lazy.window.toggle_fullscreen()),
    Key(['shift'], 'f', lazy.window.toggle_floating()),

    Key([], 'u', lazy.toggle_group())
  ], mode='layout'),
  Key([leader, 'shift'], 'c', lazy.window.kill()),

  # Exiting
  KeyChord([leader, 'shift'], 'q', [
    Key([], 'r', lazy.restart()),
    Key([], 'q', lazy.shutdown()),
    Key([], 's', lazy.spawn('systemctl suspend')),
  ])
]

mouse = [
  Drag([leader], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
  Drag([leader], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size(),
  Click([leader], "Button2", lazy.window.bring_to_front())
]
```

#### Layouts
Here, we configure the layouts that I use.
-->

## Apps
### Luakit

### Feh
Feh is an image viewer and wallpaper setter.
```nix "users/enderger/feh"
# users/enderger/git
programs.feh = {
  enable = true;
};
```

## Services
### Compositer
I personally use Picom for compositing.

# User Configuration
## Metadata
Some basic options for how the user should be seen by the system.
```nix "users/enderger/userOptions"
# users/enderger/userOptions
isNormalUser = true;
shell = pkgs.nushell;
group = "wheel";
extraGroups = [ "docker" ];
inherit (secrets) hashedPassword;
```

## Colors
This section is used to define the Base16 version of my preferred color scheme, [Nord](https://nordtheme.com). The version I use is available [here](https://github.com/ada-lovecraft/base16-nord-scheme/blob/6e83e1d56216762b4f250443af277a000f9d3c0b/nord.yaml).
```nix "users/enderger/colors"
# users/enderger/colors
"2E3440" # base00
"3B4252" # base01
"434C5E" # base02
"4C566A" # base03
"D8DEE9" # base04
"E5E9F0" # base05
"ECEFF4" # base06
"8FBCBB" # base07
"BF616A" # base08
"D08770" # base09
"EBCB8B" # base0A
"A3BE8C" # base0B
"88C0D0" # base0C
"81A1C1" # base0D
"B48EAD" # base0E
"5E81AC" # base0F
```

## Packages
The packages to install for this user. 
```nix "users/enderger/packages"
# users/enderger/packages
lxqt.lxqt-policykit
```

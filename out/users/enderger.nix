/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
{ pkgs, inputs, ... }:
let 
  secrets = import ./enderger.secret.nix;
  theme = [
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
  ];
  theme-color = builtins.elemAt theme;
  font = "FiraCode Nerd Font";
  term = "alacritty";
  browser = "qutebrowser";
  # TODO: Set up Neovide
  editor = "${term} -e nvim";
in {
  users.users.enderger = {
    # users/enderger/userOptions
    isNormalUser = true;
    shell = pkgs.nushell;
    group = "wheel";
    extraGroups = [ "docker" ];
    inherit (secrets) hashedPassword;
  };

  services.xserver.windowManager = {
    # users/enderger/windowManagers
    awesome.enable = true;
  };

  home-manager.users.enderger = { config, ... }: {
    # CLI setup
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
          # users/enderger/nushell/startup
          pfetch
        '';
      };
    };
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
    # users/enderger/man
    programs.man.enable = true;
    programs.bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = "base16";
      };
    };
    # users/enderger/neovim
    programs.neovim = {
      enable = true;
      package = pkgs.neovim-nightly;
      
      plugins = with pkgs.vimPlugins; [
        # users/enderger/neovim/plugins.backend
        completion-nvim
        neoformat
        nvim-lspconfig
        # this loads all tree-sitter grammars
        (nvim-treesitter.withPlugins builtins.attrValues)
        telescope-nvim
        vim-vsnip vim-vsnip-integ
        which-key-nvim
        # users/enderger/neovim/plugins.editing
        lightspeed-nvim
        nvim-autopairs
        nvim-treesitter-refactor
        supertab
        vim-surround
        # users/enderger/neovim/plugins.utilities
        auto-session
        friendly-snippets
        lsp-rooter-nvim
        minimap-vim
        nvim-lightbulb
        nvim-treesitter-context
        nvim-ts-rainbow
        # users/enderger/neovim/plugins.integrations
        gitsigns-nvim
        glow-nvim
        neogit
        nvim-toggleterm-lua
        vim-test
        # users/enderger/neovim/plugins.ui
        feline-nvim
        nvim-base16
        nvim-web-devicons nvim-nonicons
      ];

      extraPackages = with pkgs; [
        # users/enderger/neovim/plugins/packages
        deno nodePackages.vscode-html-languageserver-bin nodePackages.vscode-css-languageserver-bin
        rnix-lsp
        (with fenix; combine [
          default.rustfmt-preview default.clippy rust-analyzer
        ])
      ];
      
      luaInit = "init";
      luaModules = {
        # users/enderger/neovim/config
        init = ''
          -- users/enderger/neovim/config/init
          require('editor')
          require('keys')
          require('editing')
          require('extensions')
          require('ui')
          require('misc')
        '';
        lib = ''
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
        '';
        editor = ''
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
        '';
        keys = ''
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
        '';

        editing = ''
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
        '';
        extensions = ''
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
        '';
        ui = ''
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
        '';
        misc = ''
  <<<users/enderger/neovim/config/misc>>>
        '';
      };
    };
    # users/enderger/git
    programs.git = {
      enable = true;
      userEmail = "endergeryt@gmail.com";
      userName = "Enderger";
    };

    # GUI Setup
    # users/enderger/awesome
    luaModules = {
      rc = ''
        -- users/enderger/awesome/rc
        local awesome = require('awesome')

        require('errors').setup()
        require('init').setup()
      '';

      errors = ''
        -- users/enderger/awesome/errors
        local M = {}

        local awesome = require('awesome')
        local naughty = require('naughty')

        local function display_error(title, trace)
          naughty.notify {
            preset = naughty.config.presets.critical,
            title = title,
            text = trace,
          }
        end

        local in_error = false
        local function handle_runtime_error(err)
          if in_error then return end
          in_error = true

          display_error("Runtime Error!", tostring(err))

          in_error = false
        end

        function M.setup()
          if awesome.startup_errors then
            display_error("Startup Error!", awesome.startup_errors)
          end
          awesome.connect_signal("debug::error", handle_runtime_error)
        end

        return M
      '';
      init = ''
        -- users/enderger/awesome/init
        local M = {}
        local table = require('gears.table')
        local awful = require('awful')


      '';
      keys = ''
    <<<users/enderger/awesome/keys>>>
      '';
      layout = ''
    <<<users/enderger/awesome/layout>>>
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
    # users/enderger/git
    programs.feh = {
      enable = true;
    };
    <<<users/enderger/luakit>>>
    <<<users/enderger/picom>>>

    # Packages
    home.packages = [
      # users/enderger/packages
      lxqt.lxqt-policykit
    ];
  };
}

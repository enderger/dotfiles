/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
{ config, lib, pkgs, ... }:
let 
  cfg = config.programs.neovim;
  formats = with pkgs.formats; {
    json = json {};
    yaml = yaml {};
  };
in {
  options.programs.neovim = {
    # users/modules/neovim/options
    luaModules = lib.mkOption {
      type = with lib.types; attrsOf lines;
      default = {};
      description = ''
        Lua modules to add to ~/.config/nvim/lua
      '';
    };

    luaInit = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        Lua module to load in `init.vim`
      '';
    };

    # TODO: refactor to separate module, since they are now included with EMACS as well
    langServers.zls = {
      enable = lib.mkEnableOption "the Zig language server";

      packages = lib.mkOption {
        type = with lib.types; listOf package;
        default = [ pkgs.zig pkgs.zls ];
        description = ''
          Packages to add to the Neovim environment
        '';
      };

      settings = lib.mkOption {
        type = formats.json.type;
        default = {};
        description = ''
          Configuration written to <filename>$XDG_CONFIG_HOME/zls.json</filename>
        '';
      };
    };

    langServers.efm = {
      enable = lib.mkEnableOption "the EFM generral-purpose language server";

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.efm-langserver;
        description = ''
          The package to use for EFM
        '';
      };

      extraPackages = lib.mkOption {
        type = with lib.types; listOf package;
        default = [];
        description = ''
          The packages to make available to EFM
        '';
      };

      settings = lib.mkOption {
        type = formats.yaml.type;
        default = {}; 
        description = ''
          Configuration written to <filename>$XDG_CONFIG_HOME/efm-langserver/config.yaml</filename>
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # users/modules/neovim/lua
    (lib.mkIf (cfg.luaInit != "") {
      assertions = [
        { assertion = builtins.hasAttr cfg.luaInit cfg.luaModules;
          message = "Unknown module: ${cfg.luaInit}";
        }
      ];

      programs.neovim.extraConfig = ''
        :lua require("${cfg.luaInit}")
      '';
    })

    (lib.mkIf (cfg.luaModules != {}) {
      xdg.configFile = lib.mapAttrs' 
        (module: text: lib.nameValuePair "nvim/lua/${module}.lua" { inherit text; }) 
        cfg.luaModules;
    })
    # users/modules/neovim/langservers/zls
    (lib.mkIf cfg.langServers.zls.enable (let zls = cfg.langServers.zls; in {
      programs.neovim.extraPackages = zls.packages;
      home.packages = zls.packages;

      xdg.configFile."zls.json" = lib.mkIf (zls.settings != {}) {
        source = formats.json.generate "zls-config" zls.settings;
      };
    }))
    # users/modules/neovim/langservers/efm
    (lib.mkIf cfg.langServers.efm.enable (let
      efm = cfg.langServers.efm; 
      packages = [ efm.package ] ++ efm.extraPackages; 
    in {
      programs.neovim.extraPackages = packages;
      home.packages = packages;

      xdg.configFile."efm-langserver/config.yaml" = lib.mkIf (efm.settings != {}) {
        source = formats.yaml.generate "efm-config" efm.settings;
      };
    }))
  ]);
}

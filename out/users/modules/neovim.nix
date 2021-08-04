/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
{ config, lib, pkgs, ... }:
let 
  cfg = config.programs.neovim;
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
  ]);
}

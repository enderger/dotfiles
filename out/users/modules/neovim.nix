/*
This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
  */
{ config, lib, pkgs, ... }:
let cfg = config.programs.neovim;
in {
  options = {
    # users/modules/neovim/options
    fnlConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Fennel LISP to load via Aniseed
      '';
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # users/modules/neovim/aniseed
    (lib.mkIf (cfg.fnlConfig != "") {
      programs.neovim = {
        plugins = [ pkgs.vimPlugins.aniseed ];
        extraConfig = ''
          let g:aniseed#env = { "input": "" }
        '';
      };

      xdg.configFile."nvim/init.fnl".text = cfg.fnlConfig;
    })
  ]);
}

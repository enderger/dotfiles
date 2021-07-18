/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
{ config, lib, ... }:
let 
  cfg = config.xsession.windowManager.awesome;
in {
  options = {
    # users/modules/awesome/options
    luaModules = lib.mkOption {
      type = with lib.types; attrsOf lines;
      default = {};
      description = ''
        Lua modules to add in ~/.config/awesome
      '';
    };
  };

  config = lib.mkMerge [
    <<<users/modules/awesome/config>>>
  ];
}

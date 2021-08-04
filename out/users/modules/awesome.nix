/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
{ config, lib, ... }:
let 
  cfg = config.xsession.windowManager.awesome;
in {
  options.xsession.windowManager.awesome = {
    # users/modules/awesome/options
    luaConfig = lib.mkOption {
      type = with lib.types; attrsOf lines;
      default = {};
      description = ''
        Lua modules to add in ~/.config/awesome
      '';
    };
  };

  config = lib.mkMerge [
    # users/modules/qtile/config
    (lib.mkIf (cfg.luaModules != {}) {
      assertions = [
        { assertion = builtins.hasAttr "rc" cfg.luaConfig;
          message = "No rc module provided! This would leave Awesome unconfigured, and is likely a mistake.";
        }
      ];

      xdg.configFile = lib.mapAttrs'
        (module: text: lib.nameValuePair "awesome/${module}.lua" { inherit text; })
        cfg.luaConfig;
    })
  ];
}

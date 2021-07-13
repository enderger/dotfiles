/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
{ config, lib, ... }:
let 
  cfg = config.xsession.windowManager.qtile;
in {
  options = {
    # users/modules/qtile/options
    pythonModules = lib.mkOption {
      type = with lib.types; attrsOf lines;
      default = {};
      description = ''
        Python modules to add in ~/.config/qtile
      '';
    };
  };

  config = lib.mkMerge [
    # users/modules/qtile/config
    (lib.mkIf (cfg.pythonModules != {}) {
      assertions = [
        { assertion = builtins.hasAttr "config" cfg.pytonModules;
          message = "No config module provided! This would leave Qtile unconfigured, and is likely a mistake.";
        }
      ];

      xdg.configFile = lib.mapAttrs'
        (module: text: lib.nameValuePair "qtile/${module}.py" { inherit text; })
        cfg.pythonModules;
    })
  ];
}

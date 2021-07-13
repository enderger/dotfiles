---
title: Qtile
---
This module adds in support for configuring Qtile in `home-manager`.

# Implementation
```nix users/modules/qtile.nix
/*
<<<license>>>
*/
{ config, lib, ... }:
let 
  cfg = config.xsession.windowManager.qtile;
in {
  options = {
    <<<users/modules/qtile/options>>>
  };

  config = lib.mkMerge [
    <<<users/modules/qtile/config>>>
  ];
}
```

## Options
- `pythonModules` is a set of Python modules to add in `~/.config/qtile`

```nix "users/modules/qtile/options"
# users/modules/qtile/options
pythonModules = lib.mkOption {
  type = with lib.types; attrsOf lines;
  default = {};
  description = ''
    Python modules to add in ~/.config/qtile
  '';
};
```

## Config
```nix "users/modules/qtile/config"
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
```

# Module List
```nix "users/modules" +=
# users/modules.qtile
./users/modules/qtile.nix
```

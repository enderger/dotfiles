---
title: Awesome
---

This module adds in support for adding config files for Awesome.

# Implementation
```nix users/modules/awesome.nix
/*
<<<license>>>
*/
{ config, lib, ... }:
let 
  cfg = config.xsession.windowManager.awesome;
in {
  options.xsession.windowManager.awesome = {
    <<<users/modules/awesome/options>>>
  };

  config = lib.mkMerge [
    <<<users/modules/awesome/config>>>
  ];
}
```

## Options
- `luaConfig` is a set of Lua modules to add in `~/.config/awesome`

```nix "users/modules/awesome/options" +=
# users/modules/awesome/options
luaConfig = lib.mkOption {
  type = with lib.types; attrsOf lines;
  default = {};
  description = ''
    Lua modules to add in ~/.config/awesome
  '';
};
```

## Config
```nix "users/modules/awesome/config"
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
```

# Module List
```nix "users/modules" +=
# users/modules.awesome
./users/modules/awesome.nix
```

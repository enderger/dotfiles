---
title: Neovim
---

Extensions to the Neovim module, primarily to better support Lua.

# Implementation
```nix users/modules/neovim.nix
/*
<<<license>>>
*/
{ config, lib, pkgs, ... }:
let 
  cfg = config.programs.neovim;
in {
  options.programs.neovim = {
    <<<users/modules/neovim/options>>>
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    <<<users/modules/neovim/lua>>>
  ]);
}
```

## Options
- `luaModules` is a set of Lua modules to write to the `lua` folder
- `luaInit` is the name of the Lua module to load in `init.vim`

```nix "users/modules/neovim/options"
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
```

## Lua
```nix "users/modules/neovim/lua"
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
```

# Module List
```nix "users/modules" +=
# users/modules.neovim
./users/modules/neovim.nix
```

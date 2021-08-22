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
  formats = with pkgs.formats; {
    json = json {};
    yaml = yaml {};
  };
in {
  options.programs.neovim = {
    <<<users/modules/neovim/options>>>
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    <<<users/modules/neovim/lua>>>
    <<<users/modules/neovim/langServers/zls>>>
    <<<users/modules/neovim/langServers/efm>>>
  ]);
}
```

## Options
- `luaModules` is a set of Lua modules to write to the `lua` folder
- `luaInit` is the name of the Lua module to load in `init.vim`
- `langServers` provide configurations for certain language servers, making them available to the config

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

## Language Servers
### ZLS
```nix "users/modules/neovim/langServers/zls"
# users/modules/neovim/langservers/zls
(lib.mkIf cfg.langServers.zls.enable (let zls = cfg.langServers.zls; in {
  programs.neovim.extraPackages = zls.packages;

  xdg.configFile."zls.json" = lib.mkIf (zls.settings != {}) {
    source = formats.json.generate "zls-config" zls.settings;
  };
}))
```

### EFM
```nix "users/modules/neovim/langServers/efm"
# users/modules/neovim/langservers/efm
(lib.mkIf cfg.langServers.efm.enable (let efm = cfg.langServers.efm; in {
  programs.neovim.extraPackages = [ efm.package ] ++ efm.extraPackages;

  xdg.configFile."efm-langserver/config.yaml" = lib.mkIf (efm.settings != {}) {
    source = formats.yaml.generate "efm-config" efm.settings;
  };
}))
```

# Module List
```nix "users/modules" +=
# users/modules.neovim
./users/modules/neovim.nix
```

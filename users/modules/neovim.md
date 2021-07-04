---
title: Neovim
---
Extensions to the Neovim module, primarily to better support [Aniseed](https://github.com/Olical/aniseed).

# Implementation
```nix users/modules/neovim.nix
<<<license>>>
{ config, lib, pkgs, ... }:
let cfg = config.programs.neovim;
in {
  options = {
    <<<users/modules/neovim/options>>>
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    <<<users/modules/neovim/aniseed>>>
  ]);
}
```

## Options
- `fnlConfig` If set, this text (written in Fennel) will be read by Aniseed as a config.

```nix "users/modules/neovim/options"
# users/modules/neovim/options
fnlConfig = lib.mkOption {
  type = lib.types.lines;
  default = "";
  description = ''
    Fennel LISP to load via Aniseed
  '';
};
```

## Aniseed
Here, some setup is done to allow Aniseed to be configured from `home-manager`.
```nix "users/modules/neovim/aniseed"
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
```

# Module List
```nix "users/modules" +=
# users/modules.neovim
./users/modules/neovim.nix
```

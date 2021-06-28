---
title: Home Manager
---
This module simply provides a configuration for [home-manager](https://github.com/nix-community/home-manager) which is a bit more Flake-friendly.
```nix modules/home-manager.nix
<<<license>>>
{ inputs, lib, ... }:
{
  imports = with inputs; [
    hm.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = lib.mkDefault true;
    useUserPackages = lib.mkDefault true;
  };
}
```

All that's left now is to include the module in the `module-list` macro.
```nix "modules/module-list" +=
# modules/module-list.home-manager
./modules/home-manager.nix
```

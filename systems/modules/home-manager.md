---
title: Home Manager
---
This module simply provides a default configuration for [home-manager](https://github.com/nix-community/home-manager) which is a bit more Flake-friendly.

# Implementation
```nix systems/modules/home-manager.nix
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

# Module List
```nix "systems/modules/home-manager.nix" +=
# systems/modules.home-manager
./systems/modules/home-manager.nix
```

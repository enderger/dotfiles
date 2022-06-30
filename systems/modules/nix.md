---
title: Nix
---

This module simply provides a default configuration for Nix which is a bit more Flake-friendly and other global defaults specific to NixOS.
```nix systems/modules/nix.nix
/*
<<<license>>>
*/

{ lib, ... }:
{
  nix = {
    generateRegistryFromInputs = lib.mkDefault true;
    settings = {
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  environment.variables.LD_LIBRARY_PATH = lib.mkForce [
      "/run/current-system/sw/lib"
  ];
  system.stateVersion = "22.11";
}
```

# Module List
```nix "systems/modules" +=
# systems/modules.nix
./systems/modules/nix.nix
```

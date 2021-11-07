---
title: Nix
---

This module simply provides a default configuration for Nix which is a bit more Flake-friendly.
```nix systems/modules/nix.nix
/*
<<<license>>>
*/

{ lib, ... }:
{
  nix = {
    generateRegistryFromInputs = lib.mkDefault true;
  };
}
```

# Module List
```nix "systems/modules" +=
# systems/modules.nix
./systems/modules/nix.nix
```

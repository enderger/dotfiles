---
title: GRUB config
---

This module tweaks GRUB's defaults to prefer UEFI over BIOS, among other things.

# Implementation
```nix hardware/modules/grub.nix
/*
<<<license>>>
*/
{ lib, ... }:
{
  boot.loader = {
    grub = {
      efiSupport = lib.mkDefault true;
      device = lib.mkDefault "nodev";
      configurationLimit = lib.mkDefault 60;
    };

    efi.canTouchEfiVariables = lib.mkDefault true;
  };
}
```

# Module List
```nix "hardware/modules" +=
# hardware/modules.grub
./hardware/modules/grub.nix
```

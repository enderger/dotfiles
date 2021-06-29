---
title: GRUB config
---
This module configures the GRUB bootloader for EFI systems.

```nix hardware/modules/grub.nix
<<<license>>>
{ lib, ... }:
{
  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      useOSProber = true;

      version = 2;
      devices = [ "nodev" ];
      configurationLimit = 60;
    };

    efi.canTouchEfiVariables = true;
  };
}
```

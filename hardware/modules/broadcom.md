---
title: Broadcom Driver Configuration
---
This module enables the proprietary Broadcom wireless driver, which is the only way for some of their cards to work.

```nix hardware/modules/broadcom.nix
<<<license>>>
{ config, ... }:
{
  boot.kernelModules = [ "wl" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ broadcom_sta ];
  boot.blacklistedKernelModules = [ "bcma" ];
}

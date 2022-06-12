---
title: Broadcom Driver Configuration
---

This module provides support for the Broadcom STA driver, which is needed for some cards.

# Implementation
```nix hardware/modules/broadcom.nix
/*
<<<license>>>
*/
{ config, lib, pkgs, ... }:

let cfg = config.networking;
in {
  options.networking = {
    <<<hardware/modules/broadcom/options>>>
  };

  config = (lib.mkMerge [
    <<<hardware/modules/broadcom/wl>>>
    <<<hardware/modules/broadcom/bt>>>
  ]);
}
```

## Options
- `enableBCMWL` Enable the proprietary Broadcom WL driver
- `enableBCMBT` Enable bluetooth firmware

```nix "hardware/modules/broadcom/options"
# hardware/modules/broadcom/options
enableBCMWL = lib.mkEnableOption "Broadcom WL driver";
enableBCMBT = lib.mkEnableOption "Broadcom bluetooth firmware";
```

## WL
Here, we set up the Broadcom WL driver.
```nix "hardware/modules/broadcom/wl"
# hardware/modules/broadcom/wl
(lib.mkIf cfg.enableBCMWL {
  boot.kernelModules = [ "wl" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ broadcom_sta ];
  boot.blacklistedKernelModules = [ "bcma" "b43" ];
  networking.enableB43Firmware = true;
  networking.wireless = {
    driver = "wext";
  };
})
```

## Bluetooth
Here, we set up the Broadcom Bluetooth driver.
```nix "hardware/modules/broadcom/bt"
# hardware/modules/broadcom/bt
(lib.mkIf cfg.enableBCMBT {
  environment.systemPackages = with pkgs; [broadcom-bt-firmware];
})
```

# Module List
```nix "hardware/modules" +=
# hardware/modules.broadcom
./hardware/modules/broadcom.nix
```

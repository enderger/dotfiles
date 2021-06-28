---
title: Hardware Configurations
---
The hardware configuration is used to define hardware-specific properties such as networking and filesystem configuration.

# Naming
I've chosen to name the hardware after rockets, with the idea that the hardware "launches" the system. This makes more sense when taking into account the naming schemes of systems and users.

# Interface
The interface for hardware modules provides a means for determining what exactly is configured by the hardware.
- `networking`: Whether there is some form of network support enabled
- `audio`: Whether there is audio configured
- `gui`: Whether there should be graphical support

```nix hardware/default.nix
<<<license>>>
{ lib, ... }:
{
  options.interface.hardware = lib.genAttrs 
  [ "networking"
    "audio"
    "gui"
  ]
  lib.mkEnableOption;
}
```

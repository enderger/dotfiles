---
title: Hardware Interface Module
---
This module defines the interface used to define what exactly the hardware supports.

# Implementation
## Options
- `networking`: Whether there is some form of network support enabled
- `audio`: Whether there is audio configured
- `gui`: Whether the hardware can run graphical applications
- `printing` : Whether there is printing support

```nix hardware/modules/interface.nix
<<<license>>>
{ lib, ... }:
{
  options.interface.hardware = lib.genAttrs 
  [ "networking"
    "audio"
    "gui"
    "printing"
  ]
  lib.mkEnableOption;
}
```

# Module List
```nix "hardware/modules" +=
# hardware/modules.interface
./hardware/modules/interface.nix
```

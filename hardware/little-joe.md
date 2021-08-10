---
title: Hardware :: Little Joe
---

This is the hardware configuration used for testing other components in VMs. It's named after the Little Joe rocket used to test the launch escape system in the Mercury Program.

# Implementation
```nix hardware/little-joe.nix
/*
<<<license>>>
*/
{ config, pkgs, lib, inputs, ... }:
{
  imports = inputs.self.moduleSets.hardware ++ [
    inputs.nixpkgs.nixosModules.notDetected
  ];

  <<<hardware/little-joe/networking>>>
  <<<hardware/little-joe/gui>>>
  <<<hardware/little-joe/audio>>>
  nix.maxJobs = lib.mkDefault 16;
}
```

## Networking
Here, 
```nix "hardware/little-joe/networking"
# hardware/little-joe/networking
networking = {
  useNetworkd = true;
  useDHCP = false;
};

interface.hardware.networking = true;
```

## GUI
This section configures some settings likely to be set by full hardware configurations for e.g. Vulkan.

```nix "hardware/little-joe/gui"
# hardware/little-joe/gui
hardware.opengl = {
  enable = true;
  driSupport = true;
  driSupport32Bit = true;
};

interface.hardware.gui = true;
```

## Audio
Here, we enable PipeWire audio (note that defaults are set in the [PipeWire module](./hardware/modules/pipewire.md))
```nix "hardware/little-joe/audio"
# hardware/little-joe/audio
services.pipewire.enable = true;
```


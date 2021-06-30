---
title: Systems :: Sputnik
---
This is the system configuration for my primary development PC.

```nix systems/sputnik.nix
<<<license>>>
{ config, pkgs, lib, inputs, ... }:
let secrets = import ./sputnik.secret.nix;
in {
  assertions = let
    hw = config.interface.hardware;
  in [
    <<<systems/sputnik/asserts>>>
  ];

  <<<systems/sputnik/networking>>>
  <<<systems/sputnik/rootUser>>>
  <<<systems/sputnik/security>>>
  <<<systems/sputnik/kernel>>>
  <<<systems/sputnik/packages>>>
  <<<systems/sputnik/misc>>>
}
```

# Assertions
The first thing we need to do is ensure that everything needed to run is included in the hardware configuration. This is accomplished through the following block:
```nix "systems/sputnik/asserts"
# systems/sputnik/asserts
{ assertion = hw.networking;
  message = "This configuration requires networking to be configured!";
}
{ assertion = hw.gui;
  message = "This configuration requires graphical hardware to be configured!";
}
```

# Networking
Now, we get to defining networking configurations. This is mostly done in hardware, but there are a few things to define here which are not hardware-specific.
```nix "systems/sputnik/networking"
# systems/sputnik/networking
networking.firewall = secrets.firewall;
```


---
title: Systems :: Sputnik
---
This is the system configuration for my primary development PC.

```nix systems/sputnik.nix
<<<license>>>
{ config, pkgs, lib, ... }:

let secrets = import ./sputnik.secret.nix;
in {
  assertions = let
    hw = config.interface.hardware;
  in [
    <<<systems/sputnik/asserts>>>
  ];

  <<<systems/sputnik/networking>>>
  <<<systems/sputnik/user>>>
  <<<systems/sputnik/security>>>
  <<<systems/sputnik/kernel>>>
  <<<systems/sputnik/gui>>>
  <<<systems/sputnik/packages>>>
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
networking = {
  inherit (secrets) firewall;
  hostName = lib.mkForce secrets.hostName;
};
services.ntp.enable = true;
```

# User Configuration
Next, we'll set up system user configuration, such as the `root` user.
```nix "systems/sputnik/user"
# systems/sputnik/user
users.mutableUsers = false;
users.users.root = {
  shell = pkgs.oksh;
  hashedPassword = secrets.hashedPasswords.root;
};
```

# Security
Here, we set up a few security features such as `doas` and `polkit`.
```nix "systems/sputnik/security"
# systems/sputnik/security
security.doas.enable = true;
security.polkit.enable = true;

services.clamav = {
  daemon.enable = true;
  updater = {
    enable = true;
    frequency = 4;
  };
};

services.openssh.enable = true;
programs.ssh.startAgent = true;
```

# Kernel
Here, we set up the Linux kernel configuration. I personally use Xanmod for performance. I'll also set up other kernel-related items here.
```nix "systems/sputnik/kernel"
# systems/sputnik/kernel
# TODO: Introduce a separate gaming specialisation so that I can use a hardened kernel by default.
boot.kernelPackages = pkgs.linuxPackages_xanmod;
virtualisation.docker.enable = true;
```

# GUI
Here, we configure the X server and display manager.
```nix "systems/sputnik/gui"
# systems/sputnik/gui
services.xserver = {
  enable = true;
  layout = "us";

  displayManager.lightdm = {
    enable = true;
    greeters.enso = {
      enable = true;
      theme = {
        package = pkgs.nordic;
        name = "Nordic";
      };
      iconTheme = {
        package = pkgs.numix-icon-theme-circle;
        name = "Numix-Circle";
      };
    };
  };
}
```

# Packages
The set of packages to include with the system, most user utilities should be in the user configurations.
```nix "systems/sputnik/packages"
# "systems/sputnik/packages"
environment.systemPackages = with pkgs; [
  wget curl git htop tinycc lynx neovim-nightly
];
```

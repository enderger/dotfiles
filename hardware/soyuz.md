---
title: Hardware :: Soyuz
---
This is the hardware configuration for my main development PC. It may sound a bit questionable, but it's holding up quite well.

# Specs
- Model : HP Pavilion Power Desktop 580-1xx (modified)
- CPU : AMD Ryzen 7 1700 (8 core 16 thread)
- GPU : NVIDIA GeForce GT 1030
- Network Card : BCM4360 (added after-the-fact)

# Implementation
```nix hardware/soyuz.nix
/*
<<<license>>>
*/
{ config, pkgs, lib, inputs, ... }:
let secrets = import ./soyuz.secret.nix;
in {
  imports = inputs.self.moduleSets.hardware ++ [
    inputs.nixpkgs.nixosModules.notDetected
  ];

  time = { inherit (secrets) timeZone; };
  <<<hardware/soyuz/kernel>>>
  <<<hardware/soyuz/bootloader>>>
  <<<hardware/soyuz/networking>>>
  <<<hardware/soyuz/gui>>>
  <<<hardware/soyuz/audio>>>
  <<<hardware/soyuz/printing>>>
  <<<hardware/soyuz/filesystem>>>
  nix.maxJobs = lib.mkDefault 16;
}
```

## Kernel
Firstly, we need to configure the kernel modules needed to make the system work. We also enable firmware updates where applicable.
```nix "hardware/soyuz/kernel"
# hardware/soyuz/kernel
boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "ums_realtek" "usbhid" "sd_mod" "sr_mod" ];
boot.kernelModules = [ "kvm-amd" ];
hardware.cpu.amd.updateMicrocode = true;
```

## Bootloader
Here, we add a theme atop the Grub config and run Plymouth to prettify the boot sequence further
```nix "hardware/soyuz/bootloader"
# hardware/soyuz/bootloader
boot.plymouth.enable = true;
boot.loader.grub.theme = pkgs.nixos-grub2-theme;
```

## Networking
We set up the networking configuration here, I prefer to use Networkd to make things work. I should note that the network configuration itself is in the secret file, so you'll need to supply your own. I also enable the custom Broadcom module.
```nix "hardware/soyuz/networking"
# hardware/soyuz/networking
networking = {
  useNetworkd = true;
  useDHCP = false;
  usePredictableInterfaceNames = true;
  enableBCMWL = true;

  wireless = {
    inherit (secrets) networks;
    enable = true;
  };
};

interface.hardware.networking = true;
```

## GUI
This section configures OpenGL and Vulkan, as well as the screen layout.
```nix "hardware/soyuz/gui"
# hardware/soyuz/gui
hardware.opengl = {
  enable = true;

  driSupport = true;
  driSupport32Bit = true;
};
services.xserver.videoDrivers = [ "nvidia" ];

services.xserver.xrandrHeads = [
  {
    output = "HDMI-A-0";
    primary = true;
  }  
  "DVI-D-0"
];

interface.hardware.gui = true;
```

## Audio
Here, we enable PipeWire audio (note that defaults are set in the PipeWire module)
```nix "hardware/soyuz/audio"
# hardware/soyuz/audio
services.pipewire.enable = true;
```

## Printing
Here is the printer configuration, not particularly exciting.
```nix "hardware/soyuz/printing"
# hardware/soyuz/printing
services.printing = {
  enable = true;
  tempDir = "/tmp/cups/";
};

interface.hardware.printing = true;
```

## Filesystem
Finally, we need to configure the filesystem.
```nix "hardware/soyuz/filesystem"
# hardware/soyuz/filesystem
fileSystems = let
  btrfs-filesystem = part: subvol: { 
    device = part;
    fsType = "btrfs";
    options = [ "subvol=${subvol}" ];
  };

  ssd = btrfs-filesystem "/dev/disk/by-uuid/fba8d45b-7aae-456a-9608-89118bb8b73e";
  hdd = btrfs-filesystem "/dev/disk/by-uuid/bb3f96fb-4676-439b-a695-60f1c871c80c";
in {
  "/" = ssd "@root";
  "/data/ssd" = ssd "@data";

  "/nix/store" = hdd "@nix";
  "/home" = hdd "@home";

  "/boot" = {
    device = "/dev/disk/by-uuid/9E17-46DA";
    fsType = "vfat";
  };
};

swapDevices = [{ device = "/dev/disk/by-uuid/412c3678-fbdb-4093-bb1d-3b20994f3613"; }];
boot.tmpOnTmpfs = true;
```

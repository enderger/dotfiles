---
title: Hardware :: Soyuz
---

This is the hardware configuration for my main development PC.

# Specs
- Model : Custom
- Motherboard: ASUS Prime B550-plus
- CPU : AMD Ryzen 5 5600X (6 core 12 thread)
- GPU : NVIDIA GeForce GT 1030
- Network Card : BCM4360

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
  <<<hardware/soyuz/rgb>>>
  nix.settings.max-jobs = lib.mkDefault 6;
}
```

## Kernel
Firstly, we need to configure the kernel modules needed to make the system work. We also enable firmware updates where applicable.
```nix "hardware/soyuz/kernel"
# hardware/soyuz/kernel
boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "ums_realtek" "usbhid" "sd_mod" "sr_mod" "nvme" ];
boot.kernelModules = [ "kvm-amd" ];
boot.kernelParams = [ "processor.max_cstate=5" "intel_idle.max_cstate=1" "video=HDMI-1:1920x1080@60" "video=VGA-1:1440x900" ];
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
We set up the networking configuration here, I prefer to use Networkd to make things work. I should note that the network configuration itself is in the secret file, so you'll need to supply your own. I also enable the [custom Broadcom module](./hardware/modules/broadcom.md).
```nix "hardware/soyuz/networking"
# hardware/soyuz/networking
hardware.bluetooth.enable = true;
services.blueman.enable = true;

services.resolved = {
  enable = true;
  dnssec = "false";
};

networking = {
  useNetworkd = true;
  useDHCP = false;
  usePredictableInterfaceNames = true;
  enableBCMWL = true;

  interfaces = {
    wlp4s0.useDHCP = true;
  };

  nameservers = ["1.1.1.1" "8.8.8.8"];

  wireless = {
    inherit (secrets) networks;
    interfaces = [ "wlp4s0" ];
    userControlled.enable = true;
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

# TODO: Figure out why Nvidia drivers refuse to download (again)
services.xserver.videoDrivers = [ "nvidia" ];
services.xserver.xrandrHeads = let
  HDMI-monitor = "HDMI-0";
  DVI-monitor = "DVI-D-0";
in [
  {
    output = HDMI-monitor;
    primary = true;
  }
  {
    output = DVI-monitor;
    monitorConfig = ''
      Option "RightOf" "${HDMI-monitor}"
    '';
  }
];

interface.hardware.gui = true;
```

## Audio
Here, we enable PipeWire audio (note that defaults are set in the [PipeWire module](./hardware/modules/pipewire.md))
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

## RGB control
This section adds OpenRGB to control the RGB fan colours.
TODO: abstract to a module

```nix "hardware/soyuz/rgb"
# hardware/soyuz/rgb
hardware.i2c = {
    enable = true;
    group = "wheel";
};

services.udev.packages = with pkgs; [
    openrgb
];

environment.defaultPackages = with pkgs; [
  openrgb
];
```

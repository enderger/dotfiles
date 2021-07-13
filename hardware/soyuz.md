---
title: Hardware :: Soyuz
---
This is the hardware configuration for my main development PC. It may sound a bit questionable, but it's holding up quite well.

# Specs
- Model : HP Pavilion Power Desktop 580-1xx (modified)
- CPU : AMD Ryzen 7 1700 (8 core 16 thread)
- GPU : AMD ATI Radeon 550/550x
- Network Card : BCM4360 (added after-the-fact)

# Implementation
```nix hardware/soyuz.nix
/*
<<<license>>>
*/
{ config, pkgs, lib, inputs, ... }:
let secrets = import ./soyuz.secret.nix;
in {
  imports = [
    inputs.nixpkgs.nixosModules.notDetected
  ];

  time = { inherit (secrets) timeZone };
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
boot.kernelModules = [ "kvm-amd" "amdgpu" ];
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
This section configures OpenGL and Vulkan.
```nix "hardware/soyuz/gui"
# hardware/soyuz/gui
hardware.opengl = {
  enable = true;

  driSupport = true;
  driSupport32Bit = true;

  extraPackages = with pkgs; [ amdvlk ];
  extraPackages32 = with pkgs; [ amdvlk ];
};
services.xserver.videoDrivers = [ "amdgpu" ];

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
Finally, we need to configure the filesystem. I use Btrfs subvolumes to separate my home and root files while still not worrying about size.
```nix "hardware/soyuz/filesystem"
# hardware/soyuz/filesystem
fileSystems = let
  mkSubvol = subvol: {
    device = "/dev/disk/by-uuid/bb3f96fb-4676-439b-a695-60f1c871c80c";
    fsType = "btrfs";
    options = [ "subvol=@${subvol}" ];
  };
in {
  "/" = mkSubvol "root";
  "/home" = mkSubvol "home";
  "/boot" = {
    device = "/dev/disk/by-uuid/FE70-F516";
    fsType = "vfat";
  };
};

swapDevices = [ ];
```

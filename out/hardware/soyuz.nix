/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
{ config, pkgs, lib, inputs, ... }:
let secrets = import ./soyuz.secret.nix;
in {
  imports = [
    inputs.nixpkgs.nixosModules.notDetected
  ];

  time = { inherit (secrets) timeZone; };
  # hardware/soyuz/kernel
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "ums_realtek" "usbhid" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-amd" "amdgpu" ];
  hardware.cpu.amd.updateMicrocode = true;
  # hardware/soyuz/bootloader
  boot.plymouth.enable = true;
  boot.loader.grub.theme = pkgs.nixos-grub2-theme;
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
  # hardware/soyuz/audio
  services.pipewire.enable = true;
  # hardware/soyuz/printing
  services.printing = {
    enable = true;
    tempDir = "/tmp/cups/";
  };

  interface.hardware.printing = true;
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
  nix.maxJobs = lib.mkDefault 16;
}

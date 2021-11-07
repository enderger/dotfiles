/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
{ config, pkgs, lib, inputs, ... }:
let secrets = import ./soyuz.secret.nix;
in {
  imports = inputs.self.moduleSets.hardware ++ [
    inputs.nixpkgs.nixosModules.notDetected
  ];

  time = { inherit (secrets) timeZone; };
  # hardware/soyuz/kernel
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "ums_realtek" "usbhid" "sd_mod" "sr_mod" "nvme" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelParams = [ "processor.max_cstate=5" "intel_idle.max_cstate=1" ];
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

    interfaces = {
      wlp6s0.useDHCP = true;
    };

    nameservers = [
      "1.1.1.1" "9.9.9.9"
    ];

    wireless = {
      inherit (secrets) networks;
      interfaces = [ "wlp6s0" ];
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
      output = "HDMI-0";
      primary = true;
    }  
    {
      output = "DVI-D-0";
      monitorConfig = ''
        Option "RightOf" "HDMI-A-0"
      '';
    }
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
  nix.maxJobs = lib.mkDefault 16;
}

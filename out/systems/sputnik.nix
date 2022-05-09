/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
{ config, pkgs, lib, ... }:

let secrets = import ./sputnik.secret.nix;
in {
  assertions = let
    hw = config.interface.hardware;
  in [
    # systems/sputnik/asserts
    { assertion = hw.networking;
      message = "This configuration requires networking to be configured!";
    }
    { assertion = hw.gui;
      message = "This configuration requires graphical hardware to be configured!";
    }
  ];

  # systems/sputnik/networking
  networking = {
    inherit (secrets) firewall;
    hostName = lib.mkForce secrets.hostName;
  };
  # systems/sputnik/user
  users.mutableUsers = false;
  users.users.root = {
    shell = pkgs.oksh;
    hashedPassword = secrets.hashedPasswords.root;
  };
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
  # systems/sputnik/kernel
  # TODO: Introduce a separate gaming specialisation so that I can use a hardened kernel by default.
  boot.kernelPackages = pkgs.linuxPackages_xanmod;
  virtualisation.docker.enable = true;
  # systems/sputnik/gui
  services.xserver = {
    enable = true;
    layout = "us";

    displayManager.lightdm = {
      enable = true;
      greeters.gtk = {
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
  };
  # systems/sputnik/misc
  documentation.man.generateCaches = true;
  services.dbus.packages = with pkgs; [ dconf ];
  # systems/sputnik/packages
  environment.systemPackages = with pkgs; [
    curl
    git
    htop
    lynx
    openal
    neovim-nightly
    pulseaudio
    tinycc
    transcrypt
    wget
  ];
}

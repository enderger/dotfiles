---
title: Pipewire
---

This module auto-enables a few of Pipewire's submodules automatically, if they are applicable.

# Implementation
```nix hardware/modules/pipewire.nix
/*
<<<license>>>
*/
{ config, lib, pkgs, ... }:

let cfg = config.services.pipewire;
in lib.mkIf cfg.enable {
  sound.enable = lib.mkDefault true;
  security.rtkit.enable = lib.mkDefault true;

  services.pipewire = {
    pulse.enable = lib.mkDefault true;
    alsa.enable = lib.mkDefault true;
    alsa.support32Bit = lib.mkDefault true;
    #media-session.enable = lib.mkDefault true;
    wireplumber.enable = lib.mkDefault true;
  };

  environment.etc."openal/alsoft.conf".text = lib.mkDefault ''
    drivers=pulse,alsa
    htrf = true

    [pulse]
    allow-moves=true
  '';

  environment.defaultPackages = with pkgs; [
      # compatibility
      libpulseaudio alsa-lib
  ];

  interface.hardware.audio = true;
}
```

# Modules List
```nix "hardware/modules" +=
# hardware/modules.pipewire
./hardware/modules/pipewire.nix
```

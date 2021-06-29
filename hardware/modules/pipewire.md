---
title: Pipewire
---
This module provides a generic configuration for Pipewire, the better PulseAudio.

```nix hardware/modules/pipewire.nix
<<<license>>>
{ lib, ... }:
{ 
  sound.enable = false;
  security.rtkit = lib.mkDefault true;

  services.pipewire = {
    enable = true;
    pulse.enable = lib.mkDefault true;
    alsa.enable = lib.mkDefault true;
    alsa.support32Bit = lib.mkDefault true;
    media-session.enable = lib.mkDefault true;
  };

  interface.hardware.audio = true;
}

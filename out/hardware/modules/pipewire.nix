/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
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

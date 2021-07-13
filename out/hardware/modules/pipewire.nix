/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
{ config, lib, ... }:

let cfg = config.services.pipewire;
in lib.mkIf cfg.enable {
  sound.enable = lib.mkDefault true;
  security.rtkit.enable = lib.mkDefault true;

  services.pipewire = {
    pulse.enable = lib.mkDefault true;
    alsa.enable = lib.mkDefault true;
    alsa.support32Bit = lib.mkDefault true;
    media-session.enable = lib.mkDefault true;
  };

  interface.hardware.audio = true;
}

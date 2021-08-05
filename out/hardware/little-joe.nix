/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
{ config, pkgs, lib, inputs, ... }:
{
  imports = inputs.self.moduleSets.hardware ++ [
    inputs.nixpkgs.nixosModules.notDetected
  ];

  # hardware/little-joe/networking
  networking = {
    useNetworkd = true;
    useDHCP = false;
  };

  interface.hardware.networking = true;
  # hardware/little-joe/gui
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  interface.hardware.gui = true;
  # hardware/little-joe/audio
  services.pipewire.enable = true;
  nix.maxJobs = lib.mkDefault 16;
}

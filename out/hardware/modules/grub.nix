/*
This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
  */
{ lib, ... }:
{
  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      useOSProber = true;

      version = 2;
      devices = [ "nodev" ];
      configurationLimit = 60;
    };

    efi.canTouchEfiVariables = true;
  };
}

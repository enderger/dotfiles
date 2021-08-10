/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
{ lib, ... }:
{
  boot.loader = {
    grub = {
      efiSupport = lib.mkDefault true;
      device = lib.mkDefault "nodev";
      configurationLimit = lib.mkDefault 60;
    };

    efi.canTouchEfiVariables = lib.mkDefault true;
  };
}

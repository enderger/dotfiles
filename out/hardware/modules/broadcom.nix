/*
This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
  */
{ config, lib, ... }:

let cfg = config.networking;
in {
  options.networking = {
    # hardware/modules/broadcom/options
    enableBCMWL = lib.mkEnableOption "Broadcom WL driver";
  };

  config = (lib.mkMerge [
    # hardware/modules/broadcom/wl
    (lib.mkIf cfg.enableBCMWL {
      boot.kernelModules = [ "wl" ];
      boot.extraModulePackages = with config.boot.kernelPackages; [ broadcom_sta ];
      boot.blacklistedKernelModules = [ "bcma" ];
    })
  ]);
}

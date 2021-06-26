/*
This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
  */
{ config, lib, pkgs, ... }:

let cfg = config.security.doas;
in {
  options.security.doas = {
    # modules/doas/options.persist
    persist = lib.mkEnableOption "persistent doas login";
    # modules/doas/options.sudoAlias
    sudoAlias = lib.mkEnableOption "alias Sudo to Doas";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # modules/doas/persist
    (lib.mkIf cfg.persist {
      security.doas.extraRules = [{
        groups = [ "wheel" ];
        persist = true;
      }];
    })
    # modules/doas/sudoAlias
    (lib.mkIf cfg.sudoAlias {
      assertions = [
        { assertion = !config.security.sudo.enable;
          message = "Cannot alias Sudo: Sudo is enabled";
        }
      ];

      security.wrappers.sudo.source = "${pkgs.doas}/bin/doas";
    })
  ]);
}

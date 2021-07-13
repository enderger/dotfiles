/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
{ config, lib, pkgs, ... }:

let cfg = config.security.doas;
in {
  options.security.doas = {
    # systems/modules/doas/options
    persist = (lib.mkEnableOption "persistent Doas login") // { default = true; };
    sudoAlias = (lib.mkEnableOption "alias Sudo to Doas") // { default = true; };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # systems/modules/doas/persist
    (lib.mkIf cfg.persist {
      security.doas.extraRules = [{
        groups = [ "wheel" ];
        persist = true;
      }];
    })
    # systems/modules/doas/sudoAlias
    (lib.mkIf cfg.sudoAlias {
      assertions = [
        { assertion = !config.security.sudo.enable;
          message = "Cannot alias Sudo: Sudo is enabled";
        }
      ];
      
      security.sudo.enable = lib.mkDefault false;
      security.wrappers.sudo.source = "${pkgs.doas}/bin/doas";
    })
  ]);
}

/*
This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
  */
{ config, pkgs, lib, inputs, ... }:
let secrets = import ./sputnik.secret.nix;
in {
  assertions = let
    hw = config.interface.hardware;
  in [
    # systems/sputnik/asserts
    { assertion = hw.networking;
      message = "This configuration requires networking to be configured!";
    }
    { assertion = hw.gui;
      message = "This configuration requires graphical hardware to be configured!";
    }
  ];

  # systems/sputnik/networking
  networking.firewall = secrets.firewall;
  <<<systems/sputnik/rootUser>>>
  <<<systems/sputnik/security>>>
  <<<systems/sputnik/kernel>>>
  <<<systems/sputnik/packages>>>
  <<<systems/sputnik/misc>>>
}

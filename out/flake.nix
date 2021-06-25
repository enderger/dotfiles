/*
This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
  */
{
  description = "My literate dotfiles in Nix";

  inputs = rec {
    # flake/inputs.nixpkgs
    stable.url = "github:nixos/nixpkgs/nixos-21.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
    fallback.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs = unstable;
    # flake/inputs.core
    hm.url = "github:nix-community/home-manager";
    fup.url = "github:gytis-ivaskevicius/flake-utils-plus";
    # flake/inputs.packages
    nur.url = "github:nix-community/NUR";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs@{ self, ... }:
    # flake/outputs
    inputs.fup.lib.systemFlake {
      inherit self inputs; 
      supportedSystems = [ "aarch64-linux" "x86_64-linux" ];

      # flake/outputs/channels
      channelsConfig = {
        allowUnfree = true;
      };

      sharedOverlays = with inputs; [
        # flake/outputs/channels/overlays
        nur.overlay
        neovim.overlay
        fenix.overlay
      ];

      channels = {
        # flake/outputs/channels/cumulative.stable
        stable = {
          input = inputs.stable;
        };
        # flake/outputs/channels/cumulative.unstable
        unstable = {
          input = inputs.unstable;
        };
        # flake/outputs/channels/cumulative.fallback
        fallback = {
          input = inputs.fallback;
          config = {
            allowBroken = true;
            allowInsecure = true;
          };
        };
      };
      # flake/outputs/hosts
      hostDefaults = {
        system = "x86_64-linux";
        modules = with inputs; [
          # flake/outputs/hosts/prelude
          fup.nixosModules.saneFlakeDefaults
          self.nixosModules.combined
        ];
        channelName = "unstable";
        specialArgs = { inherit inputs; };
      };

      hosts = with inputs; {
      #  <<<flake/outputs/hosts/cumulative>>>
      };
      # flake/outputs/modules
      nixosModules = let
        moduleList = [
          ./modules/home-manager.nix
        ];
      in (inputs.fup.lib.modulesFromList moduleList) // {
        combined = { imports = moduleList; };
      };
      # flake/outputs/shell
      devShellBuilder = { stable, ... }: stable.mkShell {
        name = "shelly";
        buildInputs = with stable; [
          git git-secret gnupg
        ];
      };
    }
  ;
}

/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
{
  description = "My literate dotfiles in Nix";

  inputs = {
    # flake/inputs.nixpkgs
    stable.url = "github:nixos/nixpkgs/nixos-21.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    master.url = "github:nixos/nixpkgs/master";
    fallback.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs.follows = "unstable";

    fix-emacs-ts.url = "github:pimeys/nixpkgs/emacs-tree-sitter/link-grammars";
    # flake/inputs.core
    hm.url = "github:nix-community/home-manager";
    fup.url = "github:gytis-ivaskevicius/flake-utils-plus";
    # flake/inputs.packages
    discord = {
      url = "github:InternetUnexplorer/discord-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs.url = "github:nix-community/emacs-overlay";
    nur.url = "github:nix-community/NUR";
    my-nur.url = "git+https://git.sr.ht/~hutzdog/NUR";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs@{ self, ... }:
    # flake/outputs
    inputs.fup.lib.mkFlake {
      inherit self inputs; 
      supportedSystems = [ "aarch64-linux" "x86_64-linux" ];

      # flake/outputs/channels
      channelsConfig = {
        allowUnfree = true;
      };

      sharedOverlays = with inputs; [
        # flake/outputs/channels/overlays
        self.overlay
        discord.overlay
        emacs.overlay
        nur.overlay
        my-nur.overlays.awesome
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
          overlaysBuilder = channels: [
            (final: prev: {
              inherit (channels) fallback fix-emacs-ts;
            })
          ];
        };
        # flake/outputs/channels/cumulative.master
        master = {
          input = inputs.master;
        };
        # flake/outputs/channels/cumulative.fallback
        fallback = {
          input = inputs.fallback;
          config = {
            allowBroken = true;
            allowInsecure = true;
          };
        };
        # flake/outputs/channels/cumulative.other
        fix-emacs-ts = {
          input = inputs.fix-emacs-ts;
        };
      };
      # flake/outputs/hosts
      hostDefaults = let
        sys = "x86_64-linux";
      in {
        system = sys;
        modules = with self.moduleSets; system ++ hardware;
        channelName = "unstable";
        specialArgs = { inherit inputs; system = sys; };
      };

      hosts = with inputs; {
        # flake/outputs/hosts/cumulative.main
        primary-desktop = {
          modules = [
            ./hardware/soyuz.nix
            ./systems/sputnik.nix
            ./users/enderger.nix
          ];
        };
        # flake/outputs/hosts/cumulative.testbed
        testbed = {
          modules = [
            ./hardware/little-joe.nix
            ./systems/sputnik.nix
            ./users/enderger.nix
          ];
        };
      };
      # flake/outputs/modules
      nixosModules = let
        moduleList = [
          # systems/modules.nix
          ./systems/modules/nix.nix
          # systems/modules.home-manager
          ./systems/modules/home-manager.nix
          # systems/modules.doas
          ./systems/modules/doas.nix
          # hardware/modules.pipewire
          ./hardware/modules/pipewire.nix
          # hardware/modules.interface
          ./hardware/modules/interface.nix
          # hardware/modules.grub
          ./hardware/modules/grub.nix
          # hardware/modules.broadcom
          ./hardware/modules/broadcom.nix
          # users/modules.neovim
          ./users/modules/neovim.nix
          # users/modules.awesome
          ./users/modules/awesome.nix
        ];
      in inputs.fup.lib.modulesFromList moduleList;

      moduleSets = {
        system = [
          # systems/modules.nix
          ./systems/modules/nix.nix
          # systems/modules.home-manager
          ./systems/modules/home-manager.nix
          # systems/modules.doas
          ./systems/modules/doas.nix
        ];
        hardware = [
          # hardware/modules.pipewire
          ./hardware/modules/pipewire.nix
          # hardware/modules.interface
          ./hardware/modules/interface.nix
          # hardware/modules.grub
          ./hardware/modules/grub.nix
          # hardware/modules.broadcom
          ./hardware/modules/broadcom.nix
        ];
        user = [
          # users/modules.neovim
          ./users/modules/neovim.nix
          # users/modules.awesome
          ./users/modules/awesome.nix
        ];
      };
      overlay = import ./pkgs;
      # flake/outputs/shell
      devShellBuilder = { stable, ... }:
        import ./shell.nix { pkgs = stable; };
    }
  ;
}

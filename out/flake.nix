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
    unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
    master.url = "github:nixos/nixpkgs/master";
    fallback.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
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
        self.overlay
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
          overlaysBuilder = channels: [
            (final: prev: { inherit (channels.master.vimPlugins) feline-nvim lsp-rooter-nvim; })
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
      };
      # flake/outputs/hosts
      hostDefaults = {
        system = "x86_64-linux";
        modules = self.nixosModules.system // self.nixosModules.hardware;
        channelName = "unstable";
        specialArgs = { inherit inputs; };
      };

      hosts = with inputs; {
      #  <<<flake/outputs/hosts/cumulative>>>
      };
      # flake/outputs/modules
      nixosModules = let
        moduleList = [
          # systems/modules.doas
          ./systems/modules/doas.nix
          # systems/modules.home-manager
          ./systems/modules/home-manager.nix
          # hardware/modules.grub
          ./hardware/modules/grub.nix
          # hardware/modules.interface
          ./hardware/modules/interface.nix
          # hardware/modules.pipewire
          ./hardware/modules/pipewire.nix
          # users/modules.neovim
          ./users/modules/neovim.nix
          # users/modules.qtile
          ./users/modules/qtile.nix
        ];
      in (inputs.fup.lib.modulesFromList moduleList) // {
        system.imports = [
          inputs.fup.nixosModules.saneFlakeDefaults
          # systems/modules.doas
          ./systems/modules/doas.nix
          # systems/modules.home-manager
          ./systems/modules/home-manager.nix
        ];
        hardware.imports = [
          # hardware/modules.grub
          ./hardware/modules/grub.nix
          # hardware/modules.interface
          ./hardware/modules/interface.nix
          # hardware/modules.pipewire
          ./hardware/modules/pipewire.nix
        ];
        user.imports = [
          # users/modules.neovim
          ./users/modules/neovim.nix
          # users/modules.qtile
          ./users/modules/qtile.nix
        ];
      };
      overlay = import ./pkgs;
      # flake/outputs/shell
      devShellBuilder = { stable, ... }:
        import ./shell.nix { pkgs = stable; };
    }
  ;
}

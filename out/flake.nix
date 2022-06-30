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
        my-nur.overlays.nheko
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
              inherit (channels) stable fallback fix-emacs-ts;
              # HACK: home manager module does not have a way to override this
              inherit (channels.stable) pass-secret-service;
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
      in inputs.fup.lib.exportModules moduleList;

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

      outputsBuilder = channels: {
        # flake/outputs/apps
        apps = let
            pkgs = channels.unstable;
            local = attr: attr.${pkgs.system};
            mkApp = drv: inputs.fup.lib.mkApp {inherit drv;};
            tangle-drv = pkgs.writeShellApplication {
                name = "tangle";
                text = ''
                  OUTPUT="''${1:-./out}"
                  TMPDIR="$(mktemp -d)"

                  >&2 echo "Building in $OUTPUT..."
                  nix build -f ./bootstrap.nix -o "$TMPDIR/result" \
                    --arg lmt ${(local inputs.my-nur.packages).lmt} \
                    --arg pkgs "import ${pkgs.path} {system = ${pkgs.system};}"

                  rm -rf "$OUTPUT"
                  mkdir "$OUTPUT"
                  cp -rL "$TMPDIR/result"/* -t "$OUTPUT"
                  chmod -R +w "$OUTPUT"
                '';
            };
        in rec {
            tangle = mkApp tangle-drv;

            switch = mkApp (pkgs.writeShellApplication {
                name = "build";
                runtimeInputs = [ tangle-drv ];
                text = ''
                  SYSTEM="''${1:-}"
                  if [ -z "$SYSTEM" ]; then
                    echo "USAGE: $0 <SYSTEM> <FLAGS>"
                    exit 1
                  fi
                  TMPDIR="$(mktemp -d)"

                  tangle "$TMPDIR"
                  >&2 echo "Switching to system $SYSTEM..."
                  nixos-rebuild switch "''${@:2}" --flake "$TMPDIR#$SYSTEM"
                '';
            });

            vm = mkApp (pkgs.writeShellApplication {
                name = "vm";
                runtimeInputs = [ tangle-drv ];
                text = ''
                  SYSTEM="''${1:-testbed}"
                  MEMORY="''${2:-8192}"
                  TMPDIR="$(mktemp -d)"
                  NIX_VM_PATH="nixosConfigurations.''${SYSTEM}.config.system.build.vm"

                  mkdir "$TMPDIR/tangle"
                  tangle "$TMPDIR/tangle"
                  >&2 echo "Building VM..."
                  nix build "$TMPDIR/tangle#$NIX_VM_PATH" "''${@:3}" -o "$TMPDIR/vm"
                  >&2 echo "Running VM..."

                  "$TMPDIR/vm/bin/run-*-vm" -m "$MEMORY"
                '';
            });
        };
        # flake/outputs/shell
        devShell = import ./shell.nix { pkgs = channels.unstable; };
      };
    }
  ;
}

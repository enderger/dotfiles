---
title: My Dotfiles
---

# Intro
Welcome to my dotfiles repository! Here, I keep my literate NixOS configs (automatically built by Nix) here, along with everything else used in my configs. The literate form *should* be available on [man.sr.ht](https://man.sr.ht/~hutzdog/dotfiles/).

# Tools used
While this repo only requires the [Nix Package Manager](https://nixos.org) to build (with Flake support enabled), there are several tools used to make this work. The main ones are:
- [Literate Markdown Tangle](https://github.com/driusan/lmt) is used to convert this wiki into a working set of config files
- [Nix Package Manager](https://nixos.org) is used to handle the configuration of the whole system.

# Other Pages
This repo also serves as a `man.sr.ht` wiki. Here, I'll link the other pages in this repo to have a look at.
- [Hardware](./hardware)
- [Packages](./pkgs)
- [Systems](./systems)
- [Users](./users)

# The Flake
The remainder of this document will be used to define the **Flake**, which is the upcoming way to define Nix repositories. I've broken this into sections, which will be defined below.
```nix flake.nix
/*
<<<license>>>
*/
{
  description = "My literate dotfiles in Nix";

  inputs = {
    <<<flake/inputs>>>
  };

  outputs = inputs@{ self, ... }:
    <<<flake/outputs>>>
  ;
}
```

## Inputs 
Firstly, we need to define every input taken by this Flake. See the [nix3-flake manpage](https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake.html) for more info on how these work. These work well in list format, so each input line will be added to the last, and hence no structure needs to be defined.

### Nixpkgs
The first input we need is the main repo for Nix, called **Nixpkgs**. The different release channels of NixOS are dictated by different branches of this input, so we'll include a few here.
- `stable` : The current stable release of Nix, currently `21.05`
- `unstable` : The rolling version of Nix, I use the `nixos-unstable` channel for even faster releases
- `fallback` : The `nixos-unstable-small` branch, which I provide as a fallback channel via an overlay
- `nixpkgs` : An alias to whichever channel dependencies should use
- `fix-emacs-ts` : Provides a working Tree-Sitter derivation for EMACS.

```nix "flake/inputs" +=
# flake/inputs.nixpkgs
stable.url = "github:nixos/nixpkgs/nixos-21.05";
unstable.url = "github:nixos/nixpkgs/nixos-unstable";
master.url = "github:nixos/nixpkgs/master";
fallback.url = "github:nixos/nixpkgs/nixos-unstable-small";
nixpkgs.follows = "unstable";

fix-emacs-ts.url = "github:pimeys/nixpkgs/emacs-tree-sitter/link-grammars";
```

### Core Tools
Now, we will include the foundation upon which this config builds off of.
- `hm` : Home Manager for Nix provides the means for managing user homes with the NixOS module system.
- `fup` : Flake utils plus makes Nix Flakes more viable for NixOS systems.

```nix "flake/inputs" +=
# flake/inputs.core
hm.url = "github:nix-community/home-manager";
fup.url = "github:gytis-ivaskevicius/flake-utils-plus";
```

### Package Sources
Next, let's add those inputs which are intended to extend Nixpkgs.
- `discord` : Provides builds which are up-to-date.
- `emacs` : The EMACS unstable builds, packaged for nix
- `nur` : The NUR (Nix User Repositories) extend the Nixpkgs ecosystem with a set of user-maintained package sets.
- `my-nur` : My own NUR repo
- `fenix` : Fenix provides strong integration of the Rust toolchains into Nix.
- `neovim` : The Neovim nightly builds, packaged for Nix.

```nix "flake/inputs" +=
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
```

## Outputs
Now that we've defined our inputs, we'll define our outputs. If you recall above, we have the following variables set:
- `self` refers to _this_ Flake
- `inputs` refers to everything defined in the inputs section

We now will use these to define what our Flake actually does, with the help of FUP.
```nix "flake/outputs"
# flake/outputs
inputs.fup.lib.mkFlake {
  inherit self inputs;
  supportedSystems = [ "aarch64-linux" "x86_64-linux" ];

  <<<flake/outputs/channels>>>
  <<<flake/outputs/hosts>>>
  <<<flake/outputs/modules>>>
  <<<flake/outputs/overlay>>>

  outputsBuilder = channels: {
    <<<flake/outputs/apps>>>
    <<<flake/outputs/shell>>>
  };
}
```

In essence, we are using FUP's `systemFlake` function to make the process of defining a NixOS configuration more sane. We give it our whole Flake and the inputs to our Flake as arguments, along with arguments descrbing what it provides.

### Channels
The first thing we need to define are our `channels`. These provide a set of different configurations of `nixpkgs` to use.
```nix "flake/outputs/channels"
# flake/outputs/channels
channelsConfig = {
  allowUnfree = true;
};

sharedOverlays = with inputs; [
  <<<flake/outputs/channels/overlays>>>
];

channels = {
  <<<flake/outputs/channels/cumulative>>>
};
```

#### Overlays
Before we define our channels, we need to define the `flake/outputs/channels/overlays` macro to contain the overlays of all known inputs.
```nix "flake/outputs/channels/overlays"
# flake/outputs/channels/overlays
self.overlay
discord.overlay
emacs.overlay
nur.overlay
my-nur.overlays.awesome
my-nur.overlays.nheko
neovim.overlay
fenix.overlay
```

#### Stable
This channel is used when stability is needed. It follows the stable branch, though packages from fallback will be included here as-needed.
```nix "flake/outputs/channels/cumulative" +=
# flake/outputs/channels/cumulative.stable
stable = {
  input = inputs.stable;
};
```

#### Unstable
This channel is used when bleeding-edge is preferred. I use this more than stable, but it's mostly personal preference.
```nix "flake/outputs/channels/cumulative" +=
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
```

#### Master
This channel is used primarily to provide some packages which don't have CI builds yet.
```nix "flake/outputs/channels/cumulative" +=
# flake/outputs/channels/cumulative.master
master = {
  input = inputs.master;
};
```

#### Fallback
This channel is used when either previous channel fails. I include this mainly to override packages in the others via overlay.
```nix "flake/outputs/channels/cumulative" +=
# flake/outputs/channels/cumulative.fallback
fallback = {
  input = inputs.fallback;
  config = {
    allowBroken = true;
    allowInsecure = true;
  };
};
```

#### Other
```nix "flake/outputs/channels/cumulative" +=
# flake/outputs/channels/cumulative.other
fix-emacs-ts = {
  input = inputs.fix-emacs-ts;
};
```

### Hosts
Now, we get to use our inputs to make a set of system configurations.
```nix "flake/outputs/hosts"
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
  <<<flake/outputs/hosts/cumulative>>>
};
```

#### Main Desktop
- [Hardware](./hardware/soyuz.md)
- [System](./systems/sputnik.md)
- Users:
  + [Enderger](./users/enderger.md)

```nix "flake/outputs/hosts/cumulative" +=
# flake/outputs/hosts/cumulative.main
primary-desktop = {
  modules = [
    ./hardware/soyuz.nix
    ./systems/sputnik.nix
    ./users/enderger.nix
  ];
};
```

#### Testbed
This entry is used to build a testing VM, and is included here in order to prevent it from being overwritten on rebuild.
```nix "flake/outputs/hosts/cumulative" +=
# flake/outputs/hosts/cumulative.testbed
testbed = {
  modules = [
    ./hardware/little-joe.nix
    ./systems/sputnik.nix
    ./users/enderger.nix
  ];
};
```

### Modules
Here, we'll handle the set of modules to expose via the Flake.

```nix "flake/outputs/modules"
# flake/outputs/modules
nixosModules = let
  moduleList = [
    <<<systems/modules>>>
    <<<hardware/modules>>>
    <<<users/modules>>>
  ];
in inputs.fup.lib.exportModules moduleList;

moduleSets = {
  system = [
    <<<systems/modules>>>
  ];
  hardware = [
    <<<hardware/modules>>>
  ];
  user = [
    <<<users/modules>>>
  ];
};
```

### Overlay
Here, we include the overlay for the packages contined in the pkgs directory.
```nix "flake/outputs/overlay"
overlay = import ./pkgs;
```

### Apps
This defines the build infrastructure for this flake.
```nix "flake/outputs/apps"
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
```

### Shell
Here, we will include the development shell. This is the environment needed to work with this Git repository. Note that this is not needed to use the bootstrap script, since that is self-contained.
```nix "flake/outputs/shell"
# flake/outputs/shell
devShell = import ./shell.nix { pkgs = channels.unstable; };
```


# License
This project is licensed under the Mozilla Public License 2.0 (see <./LICENSE>).
```txt "license"
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
```

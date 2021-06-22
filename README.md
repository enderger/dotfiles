---
title: My Dotfiles
---

# Intro
Welcome to my dotfiles repository! Here, I keep my literate NixOS configs (automatically built by Nix) here, along with everything else used in my configs. The literate form *should* be available on man.sr.ht (will add once I get it set up).

# Tools used
While this repo only requires the [Nix Package Manager](https://nixos.org) to build (with Flake support enabled), there are several tools used to make this work. The main ones are:
- [Literate Markdown Tangle](https://github.com/driusan/lmt) is used to convert this wiki into a working set of config files
- [Nix Package Manager](https://nixos.org) is used to handle the configuration of the whole system.

# The Flake
The remainder of this document will be used to define the **Flake**, which is the upcoming way to define Nix repositories. I've broken this into sections, which will be defined below.
```nix flake.nix
{
  description = "My literate dotfiles in Nix";

  inputs = rec {
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
- `unstable` : The rolling version of Nix, I use the `nixos-unstable-small` channel for even faster releases
- `unstable-fallback` : The `nixos-unstable` branch, which I provide as a fallback channel when using `unstable`
- `nixpkgs` : An alias to whichever channel is default, I separate them to allow easy changes

```nix "flake/inputs" +=
stable.url = "github:nixos/nixpkgs/nixos-21.05";
unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
unstable-fallback.url = "github:nixos/nixpkgs/nixos-unstable";
nixpkgs = unstable;
```

### Core Tools
Now, we will include the foundation upon which this config builds off of.
- `hm` : Home Manager for Nix provides the means for managing user homes with the NixOS module system.
- `fup` : Flake utils plus makes Nix Flakes more viable for NixOS systems.

```nix "flake/inputs" +=
hm.url = "github:nix-community/home-manager";
fup.url = "github:gytis-ivaskevicius/flake-utils-plus";
```

### Package Sources
Next, let's add those inputs which are intended to extend Nixpkgs.
- `nur` : The NUR (Nix User Repositories) extend the Nixpkgs ecosystem with a set of user-maintained package sets.
- `fenix` : Fenix provides strong integration of the Rust toolchains into Nix.
- `neovim` : The Neovim nightly builds, packaged for Nix.

```nix "flake/inputs" +=
nur.url = "github:nix-community/NUR";
fenix = {
  url = "github:nix-community/fenix";
  inputs.nixpkgs.follows = "nixpkgs";
};
neovim.url = "github:nix-community/neovim-nightly-overlay";
```

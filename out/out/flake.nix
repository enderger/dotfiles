{
  description = "My literate dotfiles in Nix";

  inputs = rec {
    stable.url = "github:nixos/nixpkgs/nixos-21.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
    unstable-fallback.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs = unstable;
  };

  outputs = inputs: {
  };
}

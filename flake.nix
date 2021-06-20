{
  description = "My dotfiles";

  inputs.nur.url = "github:nix-community/nur";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

  outputs = { self, nixpkgs, nur, ... }: let
    mkPkgs = system: import nixpkgs { inherit system; overlays = [ nur.overlay ]; };
    systems = [ "x86_64-linux" ];
    forEachSystem = f: nixpkgs.lib.genAttrs systems f;
  in {
    packages = forEachSystem (system: let
      pkgs = mkPkgs system;
    in {
      
    })    
  };
}

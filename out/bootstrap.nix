# This file is used to tangle the contents of this repo into a usable form
let myNUR = builtins.getFlake "git+https://git.sr.ht/~hutzdog/NUR"; in
{ system ? builtins.currentSystem
, pkgs ? import <nixpkgs> { inherit system; }
, lmt ? myNUR.packages."${system}".lmt
}:
pkgs.stdenv.mkDerivation {
  name = "tangle";
  nativeBuildInputs = [ lmt ];
  #src = builtins.filterSource (p: t: t != "symlink" && !(pkgs.lib.hasPrefix "." (baseNameOf p))) ./.;
  src = builtins.path { 
    filter = p: t: let
        bn = baseNameOf p;
      in t != "symlink" && (t != "directory" || bn != "out") && !(pkgs.lib.hasPrefix "." bn);
    path = ./.; 
    name = "src"; 
  };

  buildPhase = ''
    export PATHS=$(find ./ -type f -name '*.md')
    lmt $PATHS
    rm -rf $PATHS "out"
  '';

  installPhase = ''
    cp -r ./ "$out"
  '';
}

# This file is used to tangle the contents of this repo into a usable form
let myNUR = builtins.getFlake "git+https://git.sr.ht/~hutzdog/NUR"; in
{ system ? builtins.currentSystem
, pkgs ? import <nixpkgs> { inherit system; }
, lmt ? myNUR.packages."${system}".lmt
}:
pkgs.stdenv.mkDerivation {
  name = "tangle";
  nativeBuildInputs = [ lmt ];
  src = builtins.filterSource (p: t: t != "symlink" && dirOf p != "out");

  buildPhase = ''
    export PATHS=$(find ./ -type f -name '*.md')
    lmt $PATHS
    rm -f $PATHS
  '';

  installPhase = ''
    cp -r ./ "$out"
  '';
}

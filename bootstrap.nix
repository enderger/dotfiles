# This file is used to tangle the contents of this repo into a usable form
# Also, yes this is metaprogramming!
let myNUR = builtins.getFlake "git+https://git.sr.ht/~hutzdog/NUR"; in
{ system ? builtins.currentSystem
, pkgs ? import <nixpkgs> { inherit system; }
, lmt ? myNUR.packages."${system}".lmt
}:
pkgs.stdenv.mkDerivation {
  name = "tangle";
  nativeBuildInputs = [ lmt ];
  src = builtins.path { 
    filter = p: t: let
        bn = baseNameOf p;
        inherit (pkgs) lib;
      in t != "symlink" && (t != "directory" || bn != "out") && !(lib.hasPrefix "." bn) && !(lib.hasSuffix ".secret" bn);
    path = ./.; 
    name = "src"; 
  };

  buildPhase = ''
    export PATHS=$(find ./ -type f -name '*.md')
    lmt $PATHS
    rm -rf $PATHS
  '';

  installPhase = ''
    cp -r ./ "$out"
  '';
}

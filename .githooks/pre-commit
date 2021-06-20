#!/usr/bin/env bash
cd $(dirname $0)/..

echo "Building..."
nix-build 'bootstrap.nix'

rm -rf out
cp -rL result out
chmod +w out

rm -f result
echo "DONE!"

/*
This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
  */
{ lib, vimUtils, fetchFromGitHub, ... }:

vimUtils.buildVimPlugin {
  name = "lsp-rooter-nvim";
  src = fetchFromGitHub {
    owner = "ahmedkhalf";
    repo = "lsp-rooter.nvim";
    rev = "ca8670c8fc4efbd9a05f330f4037304962c9abbb";
    sha256 = lib.fakeSha256;
  };
}

# -*- coding: utf-8 -*-
# :Project:   giskard -- nix-shell entry point
# :Created:   mar 18 set 2018 20:57:12 CEST
# :Author:    Alberto Berti <alberto@metapensiero.it>
# :License:   GNU General Public License version 3 or later
# :Copyright: © 2018 Alberto Berti
#

with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "giskard-shell";

  buildInputs = [
    bash
    docutils
    findutils
    gnumake
  ];

  # nixos-20.09-small Released on 2021-04-05
  #oldstableRev = "b103839d00505bbaa9f9beff26e3d0f6a3abf6df";
  # last 19.09 of 2020-06-20
  oldstableRev = "289466dd6a11c65a7de4a954d6ebf66c1ad07652";
  # nixos-21.05 Released on 2021-08-29
  stableRev = "74d017edb6717ad76d38edc02ad3210d4ad66b96";
  # nixos-unstable Released on 2021-08-29
  unstableRev = "21c937f8cb1e6adcfeb36dfd6c90d9d9bfab1d28";
  #unstableRev = stableRev;

  shellHook = ''
    export NIX_PATH="nixpkgs=https://github.com/NixOs/nixpkgs/archive/${stableRev}.tar.gz:unstable=https://github.com/NixOs/nixpkgs/archive/${unstableRev}.tar.gz:oldstable=https://github.com/NixOs/nixpkgs/archive/${oldstableRev}.tar.gz"

    function build () {
      make -L build
    }

    function deploy () {
      make -L activate_profile
    }

    function print_option () {
      make -L print_option-$1
    }

    make clean
  '';
  DEST = "root@giskard";
}

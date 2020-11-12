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

  # last 19.09 of 2020-06-20
  oldstableRev = "289466dd6a11c65a7de4a954d6ebf66c1ad07652";
  # nixos-20.03-small Released on 2020-07-22
  stableRev = "297f3387c6efcbe1671d9b12b8ec9dab0cc147bc";
  # nixos-unstable-small Released on 2020-06-30
  unstableRev = "d13d819b894dc837c918c4f0626a483d73d7784e";
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

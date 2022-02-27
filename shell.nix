# -*- coding: utf-8 -*-
# :Project:   giskard -- nix-shell entry point
# :Created:   mar 18 set 2018 20:57:12 CEST
# :Author:    Alberto Berti <alberto@metapensiero.it>
# :License:   GNU General Public License version 3 or later
# :Copyright: © 2018, 2022 Alberto Berti
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
  # nixos-21.11 Released on 2022-02-24
  stableRev = "4275a321beab5a71872fb7a5fe5da511bb2bec73";
  # nixos-unstable Released on 2022-02-22
  unstableRev = "7f9b6e2babf232412682c09e57ed666d8f84ac2d";
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

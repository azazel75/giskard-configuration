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

  # last 19.03
  oldstableRev = "3fdb468b47903dddffe1de178d48a886144ad56c";
  # nixos-19.09-small Released on 2019-12-30
  stableRev = "96c9578020133fe64feab90c00f3cb880d53ad0d";
  # nixos-unstable-small Released on 2019-12-27
  unstableRev = "b38c2839917252989ab4f34cf9254c7e2939329b";
  #unstableRev = stableRev;

  shellHook = ''
    export NIX_PATH="nixpkgs=https://github.com/NixOs/nixpkgs-channels/archive/${stableRev}.tar.gz:unstable=https://github.com/NixOs/nixpkgs-channels/archive/${unstableRev}.tar.gz:oldstable=https://github.com/NixOs/nixpkgs-channels/archive/${oldstableRev}.tar.gz"

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

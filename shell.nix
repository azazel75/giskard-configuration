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
  # nixos-20.09-small Released on 2021-02-23
  stableRev = "07bd0f145b6d29a35b5b9c759fe8b59b53078a28";
  # nixos-unstable-small Released on 2020-02-23
  unstableRev = "1ec1a234d893b110b09939390b00d9b6e0b95a4d";
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

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
    gnumake
  ];

  stable-rev = "9fa6a261fb237f68071b361a9913ed1742d5e082";
  unstable-rev = "56b9f6fc8e1c3a4ad10ff7c61e461d7b7e038833";

  shellHook = ''
    export NIX_PATH="nixpkgs=https://github.com/NixOs/nixpkgs-channels/archive/${stable-rev}.tar.gz:unstable=https://github.com/NixOs/nixpkgs-channels/archive/${unstable-rev}.tar.gz"

    function build () {
      make -L build
    }

    function deploy () {
      make -L activate_profile
    }
  '';
}

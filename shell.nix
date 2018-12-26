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
    findutils
    gnumake
  ];

  # latest channels publication of release 18.09
  stable-rev = "c840631fe20d4ae13d2b1f9337a775fa861290f9";
  unstable-rev = "44b02b52ea6a49674f124f50009299f192ed78bb";

  shellHook = ''
    export NIX_PATH="nixpkgs=https://github.com/NixOs/nixpkgs-channels/archive/${stable-rev}.tar.gz:unstable=https://github.com/NixOs/nixpkgs-channels/archive/${unstable-rev}.tar.gz"

    function build () {
      make -L build
    }

    function deploy () {
      make -L activate_profile
    }

    function print_option () {
      make -L print_option-$1
    }
  '';
}

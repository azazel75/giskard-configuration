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

  stable-rev = "66fd61163a863505730fa9920ba1e8a33350db65";
  unstable-rev = "46651b82b87318e37440c15a639d49ec05e79b79";

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

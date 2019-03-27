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

  # nixos-18.09-small Released on 2019-03-02
  stableRev = "80754f5cfd69d0caf8cff6795d3ce6d99479abde";
  # nixos-unstable-small Released on 2019-03-02
  unstableRev = "3d3e5cafa76233d43b647423b28d6bf0d5c66663";

  shellHook = ''
    export NIX_PATH="nixpkgs=https://github.com/NixOs/nixpkgs-channels/archive/${stableRev}.tar.gz:unstable=https://github.com/NixOs/nixpkgs-channels/archive/${unstableRev}.tar.gz"

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

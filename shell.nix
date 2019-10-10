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

  # nixos-19.09-small Released on 2019-10-09
  stableRev = "d5291756487d70bc336e33512a9baf9fa1788faf";
  # nixos-unstable-small Released on 2019-09-30
  #unstableRev = "3155fbff0adcd8abf762a5689de4af1c7b93b974";
  unstableRev = stableRev;

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

    make clean
  '';
  DEST = "root@giskard";
}

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
  # nixos-19.09-small Released on 2020-03-17
  stableRev = "bf7c0f0461e047bec108a5c5d5d1b144289a65ba";
  # nixos-unstable-small Released on 2020-03-19
  unstableRev = "9b3515eb95d9b3bc033f43cd562fe2b14f9efd86";
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

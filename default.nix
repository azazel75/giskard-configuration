with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "giskardd-shell";

  buildInputs = [
    bash
    gnumake
  ];

  stable-rev = "32c008a946c73035d2f4273dcaec281e1d6021d1";
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

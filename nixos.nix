# -*- coding: utf-8 -*-
# :Project:   giskard -- main configuration
# :Created:   ven 14 set 2018 16:18:59 CEST
# :Author:    Alberto Berti <alberto@metapensiero.it>
# :License:   GNU General Public License version 3 or later
# :Copyright: © 2018 Alberto Berti
#

import <nixpkgs/nixos> {
  system = "x86_64-linux";

  configuration = {
    imports = [
      ./configuration.nix
    ];
  };
}

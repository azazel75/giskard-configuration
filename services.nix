# -*- coding: utf-8 -*-
# :Project:   giskard -- Services
# :Created:   dom 16 set 2018 21:57:41 CEST
# :Author:    Alberto Berti <alberto@metapensiero.it>
# :License:   GNU General Public License version 3 or later
# :Copyright: © 2018 Alberto Berti
#

{ config, pkgs, ... }: {
  imports = [
    ./samba.nix
    ./nginx.nix
  ];
  services = {
    openssh.enable = true;
    slimserver.enable = true;
  };
}

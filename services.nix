# -*- coding: utf-8 -*-
# :Project:   giskard -- Services
# :Created:   dom 16 set 2018 21:57:41 CEST
# :Author:    Alberto Berti <alberto@metapensiero.it>
# :License:   GNU General Public License version 3 or later
# :Copyright: © 2018 Alberto Berti
#

{ config, pkgs, ... }: let
    unstable = import <unstable> { config.allowUnfree = true; };
    };
  in {
    imports = [
      ./samba.nix
      ./nginx.nix
      ./postfix.nix
    ];
    services = {
      openssh.enable = true;
      slimserver.enable = true;
      slimserver.package = unstable.slimserver;
      nfs.server = {
        enable = true;
        exports = ''
          /mnt/musica   192.168.1.0/24(rw)
          /mnt/books   192.168.1.0/24(rw)
        '';
      };
      rpcbind.enable = true;
    };
}

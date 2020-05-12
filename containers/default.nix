# -*- coding: utf-8 -*-
# :Project:   giskard -- Containers
# :Created:   dom 16 set 2018 21:57:41 CEST
# :Author:    Alberto Berti <alberto@metapensiero.it>
# :License:   GNU General Public License version 3 or later
# :Copyright: © 2018 Alberto Berti
#

{ config, pkgs, ... }: {
    containers.nextcloud = {
      autoStart = true;
      bindMounts = {
        "/var/lib/nextcloud" = {
          hostPath = "/mnt/data/nextcloud";
          isReadOnly = false;
        };
        "/mnt/musica" = {
          hostPath = "/mnt/musica";
          isReadOnly = true;
        };
        "/mnt/pentagramma" = {
          hostPath = "/mnt/data/pentagramma";
          isReadOnly = false;
        };
        "/mnt/websites/emilia" = {
          hostPath = "/mnt/data/websites/emilia";
          isReadOnly = false;
        };
      };
      config = import ./nextcloud;
    };
  }

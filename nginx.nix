# -*- coding: utf-8 -*-
# :Project:   giskard -- nginx config
# :Created:   dom 16 set 2018 22:17:55 CEST
# :Author:    Alberto Berti <alberto@metapensiero.it>
# :License:   GNU General Public License version 3 or later
# :Copyright: © 2018 Alberto Berti
#

{ config, pkgs, ... }: {
  services.nginx = {
    enable = true;
    clientMaxBodySize = "10G";
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "files.azazel.it" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://files.azazel.it:18080";
        };
        extraConfig = ''
          proxy_max_temp_file_size 0;
          location = /.well-known/carddav {
            return 301 https://$host/remote.php/dav/;
          }

          location = /.well-known/caldav {
            return 301 https://$host/remote.php/dav/;
          }
        '';
      };
      "azazel.it" = {
        enableACME = true;
      };
    };
  };
}

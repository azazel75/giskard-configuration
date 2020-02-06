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
    appendHttpConfig = ''
      map $host $this_host {
          "" $host;
          default $host;
      }

      map $http_x_forwarded_proto $the_scheme {
          default $http_x_forwarded_proto;
          "" $scheme;
      }

      map $http_x_forwarded_host $the_host {
         default $http_x_forwarded_host;
         "" $this_host;
      }
    '';
    virtualHosts = {
      "files.azazel.it" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://files.azazel.it:18080";
        };
        extraConfig = ''
          location ~* ^/ds-vpath/ {
              rewrite /ds-vpath/(.*) /$1  break;
              proxy_pass http://127.0.0.1:9980;
              proxy_redirect     off;

              client_max_body_size 100m;

              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";

              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host $the_host/ds-vpath;
              proxy_set_header X-Forwarded-Proto $the_scheme;
          }
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
      "demo.azazel.it" = {
        enableACME = true;
        forceSSL = true;
        serverAliases = [ "demo.metapensiero.it" ];
        locations."/" = {
          proxyPass = "http://localhost:8888";
        };
      };
      "pentagramma.metapensiero.it" = {
        enableACME = true;
        root = "/mnt/data/pentagramma";
      };
    };
  };
}

# -*- coding: utf-8 -*-
# :Project:   giskard -- nginx config
# :Created:   dom 16 set 2018 22:17:55 CEST
# :Author:    Alberto Berti <alberto@metapensiero.it>
# :License:   GNU General Public License version 3 or later
# :Copyright: © 2018 Alberto Berti
#

{ config, pkgs, ... }:
  let
    logsBase = "/var/log/nginx";
  in {
    services = {
      nginx = {
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
              error_log ${logsBase}/files.azazel.it-error.log;
              access_log ${logsBase}/files.azazel.it-access.log combined;
            '';
          };
          "azazel.it" = {
            addSSL = true;
            enableACME = true;
            root = "/mnt/data/websites/azazel/.neuron/output";
            extraConfig = ''
              error_log ${logsBase}/azazel.it-error.log;
              access_log ${logsBase}/azazel.it-access.log combined;
            '';
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
            forceSSL = true;
            root = "/mnt/data/pentagramma";
            extraConfig = ''
              error_log ${logsBase}/pentagramma-error.log;
              access_log ${logsBase}/pentagramma-access.log combined;
            '';
          };
          "emiliacampagna.arstecnica.it" = {
            enableACME = true;
            forceSSL = true;
            root = "/mnt/data/websites/emilia";
            extraConfig = ''
              error_log ${logsBase}/emiliacampagna-error.log;
              access_log ${logsBase}/emiliacampagna-access.log combined;
            '';
          };
        };
      };
      logrotate = {
        enable = true;
        extraConfig = ''
          weekly
          rotate 8

          /var/log/nginx/*.log {
            weekly
            missingok
            rotate 60
            compress
            delaycompress
            notifempty
            create 0640 nginx nginx
            sharedscripts
            postrotate
              kill -USR1 $(cat /run/nginx/nginx.pid)
            endscript
          }
        '';
      };
    };
    system.activationScripts.nginx_logging = {
      text = ''
        mkdir -p ${logsBase}
        chown nginx:nginx -R ${logsBase}
      '';
      deps = [];
    };
  }

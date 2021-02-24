# -*- coding: utf-8 -*-
# :Project:   giskard -- Nextcloud container configuration
# :Created:   dom 16 set 2018 22:12:01 CEST
# :Author:    Alberto Berti <alberto@metapensiero.it>
# :License:   GNU General Public License version 3 or later
# :Copyright: © 2018 Alberto Berti
#

{ config, pkgs, ... }:
  let
    nextcloud-pkg = pkgs.nextcloud20;
    nc = rec {
      homeDir = "/var/lib/nextcloud";
      configDir = "${homeDir}/config";
      configFile = "${configDir}/config.php";
      mailDomain = "azazel.it";
      domain = "files.azazel.it";
      userName = "nextcloud";
      password = (pkgs.lib.readFile ../../secret/nextcloud-postgres);
    };
  in {
    services.nextcloud = {
      enable = true;
      hostName = nc.domain;
      package = nextcloud-pkg;
      https = true;
      config = {
        adminpass = "not_used";
        dbtype = "pgsql";
        dbuser = nc.userName;
        dbhost = "localhost";
        dbname = nc.userName;
        dbpass = nc.password;
        dbport = "";
        dbtableprefix = "oc_";
      };
    };
     services.nginx = {
      enable = true;
      recommendedOptimisation = true;
      virtualHosts."${nc.domain}" = {
        listen = [
          { addr = "0.0.0.0"; port = 18080; }
        ];
      };
     };
    services.postgresql = {
      enable = true;
      enableTCPIP = true;
    };
    systemd.services."nextcloud-setup" = {
      requires = ["postgresql.service"];
      after = ["postgresql.service"];
    };
  }

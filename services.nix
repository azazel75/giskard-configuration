# -*- coding: utf-8 -*-
# :Project:   giskard -- Services
# :Created:   dom 16 set 2018 21:57:41 CEST
# :Author:    Alberto Berti <alberto@metapensiero.it>
# :License:   GNU General Public License version 3 or later
# :Copyright: © 2018 Alberto Berti
#

{ config, pkgs, ... }: let
    unstable = import <unstable> { config.allowUnfree = true; };
    transHome = "/mnt/data/transmission";
    mldonkeyUser = "mldonkey";
    mldonkeyHome = "/mnt/data/mldonkey";
    mldonkeyOpts = {
      allow_local_network = "true";
      allowed_ips = "192.168.1.0/24";
      log_to_syslog = "true";
      log_file = "''";
      run_as_user = mldonkeyUser;
      run_as_group = "users";
      upnp_port_forwarding = "true";
    };
    serializeOpts = opts:
      with pkgs.lib;
      concatStringsSep " " (mapAttrsToList
        (name: value: "-${name} ${value}")
        opts);
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
          /mnt/data   192.168.1.0/24(rw)
        '';
      };
      rpcbind.enable = true;
      transmission = {
        enable = true;
        settings = {
          download-dir = "${transHome}/scaricati";
          incomplete-dir = "${transHome}/.incomplete";
          incomplete-dir-enabled = true;
          rpc-host-whitelist = "*";
          rpc-host-whitelist-enabled = true;
          rpc-whitelist = "192.168.1.*";
          rpc-whitelist-enabled = true;
        };
        home = transHome;
        port = 7000;
      };
    };
    systemd.services.mldonkey = {
        enable = true;
        wantedBy = [ "multi-user.target" ];
        after    = [ "network.target" ];
        environment = {
          MLDONKEY_DIR = mldonkeyHome;
        };
        path = [ pkgs.mldonkey ];
        script = ''
          exec mldonkey ${serializeOpts mldonkeyOpts}
        '';
        serviceConfig = {
          WorkingDirectory = mldonkeyHome;
        };
    };
    users.users.${mldonkeyUser} = {
      description = "mldonkey user";
      group = "users";
      home = mldonkeyHome;
      createHome = true;
    };
}

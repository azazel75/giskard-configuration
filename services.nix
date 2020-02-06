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
      openssh = {
        enable = true;
        gatewayPorts = "clientspecified";
        extraConfig = ''
          AllowTcpForwarding yes
        '';
      };
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
      borgbackup = {
        repos = {
          ender = {
            authorizedKeys = [
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCoWtmwzsREPJ6kN8oSB8nyfGbE8wY9O6OmUqsZwtAViOcH27fzPpw6oKhXfXEeSVhcQlk3ffa38+KAhewhOTjW2skASuA7lhPTNF31N1dD+ZPQxWc7SCWsmtjhK9KySsd/clHIMRJqpvy7hQHgUTuTPqNE136er3LNyDaxCv1rx1qJBmlN/1PqZhgNybhnz3VCh59PqSeYqy+hkREXENdnx9xOq8zb3wclVw/b5c/l0YNq3Qk4HFa57r8iAcuZjItuwjANfh08UeEtCNuO0Ap1XChaXeFAw7P6pLORFaxjE7wbxSVfuGxxysLKWy8onebLqfqjCGphpUzvIKVMdQBFOf8a/vNLHbeiICpJ4l6dvJ+Omkpf6WDamepCbT3xftDLOzNTbqgToDPKq+Lt66etqqKqkaN+RKTgbUSYaJZWUTnPNKDjLYWWDKB2cXaFXInRcbLoDQy1jij9xanZWVEyOlTt3xE/maskagq+pvo4696+9U6T+KhJ8DXdbO6anOGZQxGD7cR+IMA3dUEcy4SZKp1R/xHvy0Fylj31ivyqNuyYybEN5IOZq7AcWnFJXkTYELfjbU14VAVlSjgBmcBy6ikkIsSwZ3R4Q5vs77d9+JpGF7oNHHNU1jrGMgFoy8QlqDQNEXzbG9+dcwtUR5jJ4Opp8Am2H3yxj3IjcsMDbw== /home/azazel/.ssh/id_rsa"
            ];
            path = /mnt/backups/borg/ender;
          };
          ligeti = {
            authorizedKeys = [
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5xqDl1+IYXzt9csNJcZxw9aAbtD9plBGunBecbb4X9l3I7mbNZOf6gY0V8t1aeoNEAoZUWnQXyWDtevlaxBSghyUK/0MIc6Nyj3A90P4L3UQA5kubjNqIh1t7/1zQtL0qU3Muxr3Ufne5jHkjrV3ZzOk5v/WRowxW/1s4xfDJN/TpsZvQ4jddzU7zZszqY/64M+cX4YmUGvBDVsW8DexkOfZerTJHcZXWN9IlWtXF+coq3/yKWM5sdC7x69pc881Yhvq526cdMFvbR1oleS1umTy6JT3TlixQWIYqmkxk85nNOSlx+vO417niddV976JmOax4PtMaPZ0nbeBp2Uf5 emilia@minipc"
            ];
            path = /mnt/backups/borg/ligeti;
          };
        };
      };
    };
    systemd.services.mldonkey = {
        enable = false;
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

# -*- coding: utf-8 -*-
# :Project:   giskard -- Samba service config
# :Created:   dom 16 set 2018 21:57:41 CEST
# :Author:    Alberto Berti <alberto@metapensiero.it>
# :License:   GNU General Public License version 3 or later
# :Copyright: © 2018 Alberto Berti
#

{ config, pkgs, ... }: {
  services.samba = {
    enable = true;
    extraConfig = ''
      auto services = alberto emilia
      [homes]
      read only = no
      browsable = no
      # File creation mask is set to 0700 for security reasons. If you want to
      # create files with group=rw permissions, set next parameter to 0775.
      create mask = 0700

      # Directory creation mask is set to 0700 for security reasons. If you want to
      # create dirs. with group=rw permissions, set next parameter to 0775.
      directory mask = 0700

      # By default, \\server\username shares can be connected to by anyone
      # with access to the samba server.
      # The following parameter makes sure that only "username" can connect
      # to \\server\username
      # This might need tweaking when using external authentication schemes
      valid users = %S
      map archive = no
    '';
    shares = {
      musica = {
        path = "/mnt/musica";
        browsable = true;
        "read only" = false;
        "guest ok" = true;
        "write users" = [ "@musica" ];
        "force group" = "musica";
        "map archive" = false;
      };
      books = {
        path = "/mnt/books";
        browsable = true;
        "read only" = false;
        "guest ok" = true;
        "write users" = [ "@books" ];
        "force group" = "books";
        "map archive" = false;
      };
    };
  };
}

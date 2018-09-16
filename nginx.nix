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
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    virtualHosts."files.azazel.it" = {
      locations."/" = {
        proxyPass = "http://files.azazel.it:18080";
      };
    };
  };
}

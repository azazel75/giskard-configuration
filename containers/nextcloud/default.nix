# -*- coding: utf-8 -*-
# :Project:   giskard -- Nextcloud container configuration
# :Created:   dom 16 set 2018 22:12:01 CEST
# :Author:    Alberto Berti <alberto@metapensiero.it>
# :License:   GNU General Public License version 3 or later
# :Copyright: © 2018 Alberto Berti
#

{ config, pkgs, ... }:
  let
    unstable-pkgs = import <unstable> {};
    nextcloud-pkg = unstable-pkgs.nextcloud;
    nc = rec {
      homeDir = "/var/lib/nextcloud";
      configDir = "${homeDir}/etc";
      configFile = "${configDir}/config.php";
      dataDir = "${homeDir}/data";
      apps2Dir = "${homeDir}/apps2";
      mailDomain = "azazel.it";
      domain = "files.azazel.it";
      userName = "nextcloud";
      password = (pkgs.lib.readFile ../../secret/nextcloud-postgres);
      uwsgiSocket  = "/run/uwsgi/nextcloud.sock";
    };
    ncConf = pkgs.stdenv.mkDerivation rec {
      buildInputs = [ pkgs.makeWrapper ];
      name = "nextcloud-commands";
      php = pkgs.php + /bin/php;
      occ = nextcloud-pkg + /occ;
      inherit (nc) homeDir dataDir apps2Dir password domain mailDomain
        userName;
      dbName = userName;
      appsDir = nextcloud-pkg + /apps;
      installPhase = ''
        mkdir -p $out/bin
        makeWrapper $php $out/bin/nc-php --set \
          NEXTCLOUD_CONFIG_DIR ${nc.configDir}
        makeWrapper $php $out/bin/nc-cli --add-flags $occ \
          --set NEXTCLOUD_CONFIG_DIR ${nc.configDir}
        mkdir p $out/etc
        substituteAll ${./config.php.template} $out/etc/config.php
      '';
      phases = ["installPhase"];
    };
  in {
    environment.systemPackages = with pkgs; [
      ncConf
    ];
    services.postgresql = {
      enable = true;
      enableTCPIP = true;
    };
    services.nginx = {
      enable = true;
      recommendedOptimisation = true;
      virtualHosts."files.azazel.it" = {
        listen = [
          { addr = "0.0.0.0"; port = 18080; }
        ];
        root = "${nextcloud-pkg}";
        extraConfig = ''
          add_header Strict-Transport-Security "max-age=15768000;";
          add_header X-Content-Type-Options nosniff;
          add_header X-Download-Options noopen;
          add_header X-Frame-Options "SAMEORIGIN";
          add_header X-Permitted-Cross-Domain-Policies none;
          add_header X-Robots-Tag none;
          add_header X-XSS-Protection "1; mode=block";

          index index.php;
          client_max_body_size 10G;

          # Enable gzip but do not remove ETag headers
          gzip on;
          gzip_vary on;
          gzip_comp_level 4;
          gzip_min_length 256;
          gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
          gzip_types application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;

          rewrite ^/caldav(.*)$ /remote.php/caldav$1 redirect;
          rewrite ^/carddav(.*)$ /remote.php/carddav$1 redirect;
          rewrite ^/webdav(.*)$ /remote.php/webdav$1 redirect;
          location = /robots.txt {
              allow all;
              log_not_found off;
              access_log off;
          }

          # The following 2 rules are only needed for the user_webfinger app.
          # Uncomment it if you're planning to use this app.
          #rewrite ^/.well-known/host-meta /public.php?service=host-meta last;
          #rewrite ^/.well-known/host-meta.json /public.php?service=host-meta-json
          # last;

          location = /.well-known/carddav {
              return 301 $scheme://$host/remote.php/dav;
          }

          location = /.well-known/caldav {
              return 301 $scheme://$host/remote.php/dav;
          }

          location / {
              rewrite ^(/core/doc/[^\/]+/)$ $1/index.html;
              try_files $uri $uri/ =404;
              #rewrite ^ /index.php$uri;
          }

          location ^~ /data {
              internal;
          }

          location ^~ /apps2 {
            root ${nc.homeDir};
          }

          location ~ ^/(?:\.htaccess|config|db_structure\.xml|README) {
              deny all;
          }

          location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)/ {
              deny all;
          }

          location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console) {
              deny all;
          }

          location ~ ^/(?:index|remote|public|cron|core/ajax/update|status|ocs/v[12]|updater/.+|ocs-provider/.+)\.php(?:$|/) {
              include ${config.services.nginx.package}/conf/uwsgi_params;
              uwsgi_modifier1 14;
              uwsgi_hide_header Strict-Transport-Security;
              uwsgi_hide_header X-Content-Type-Options;
              uwsgi_hide_header X-Download-Options;
              uwsgi_hide_header X-Frame-Options;
              uwsgi_hide_header X-Permitted-Cross-Domain-Policies;
              uwsgi_hide_header X-Robots-Tag;
              uwsgi_hide_header X-XSS-Protection;
              uwsgi_param MOD_X_ACCEL_REDIRECT_ENABLED on;
              uwsgi_pass unix:${nc.uwsgiSocket};
          }

          location ~ ^/(?:updater|ocs-provider)(?:$|/) {
              try_files $uri/ =404;
              index index.php;
          }

          location ~ \.(?:css|js|woff|svg|gif)$ {
              try_files $uri /index.php$uri$is_args$args;
              add_header Cache-Control "public, max-age=15778463";
              add_header Strict-Transport-Security "max-age=15768000; includeSubDomains;";
              add_header X-Content-Type-Options nosniff;
              add_header X-Frame-Options "SAMEORIGIN";
              add_header X-XSS-Protection "1; mode=block";
              add_header X-Robots-Tag none;
              add_header X-Download-Options noopen;
              add_header X-Permitted-Cross-Domain-Policies none;
              access_log off;
          }

          location ~ \.(?:png|html|ttf|ico|jpg|jpeg)$ {
              try_files $uri /index.php$uri$is_args$args;
              # Optional: Don't log access to other assets
              access_log off;
          }
        '';
      };
    };
    services.uwsgi = {
      enable = true;
      user = "nginx";
      group = "nginx";
      plugins = [ "php" ];
      instance = {
        type = "emperor";
        vassals = {
          nextcloud = {
            socket = nc.uwsgiSocket;
            # the following value is to prevent connection errors from
            # nginx (the default is 128) see also
            # boot.kernel.sysctl."net.core.somaxconn" and:
            # http://man7.org/linux/man-pages/man2/listen.2.html
            # https://stackoverflow.com/questions/44581719/resource-temporarily-unavailable-using-uwsgi-nginx
            listen = 1024;
            master = true;
            vacuum = true;
            processes = 50;
            cheaper = 5;
            socket-modifier1 = 14;
            php-allowed-ext = [ ".php" ".inc" ];
            php-index = "index.php";
            php-sapi-name = "apache"; # opcode caching tweak
            php-set = [
              "date.timezone=Europe/Berlin"
              "opcache.enable=1"
            ];
            php-ini = (pkgs.writeText "php.ini" ''
              [PHP]
              zend_extension=opcache.so
              [opcache]
              opcache.enable=1
              opcache.enable_cli=1
              opcache.interned_strings_buffer=8
              opcache.max_accelerated_files=10000
              opcache.memory_consumption=128
              opcache.save_comments=1
              opcache.revalidate_freq=1
            '');
            env = [
              "NEXTCLOUD_CONFIG_DIR=${nc.configDir}"
            ];
            plugins = [ "php" ];
            type = "normal";
          };
        };
      };
    };
    systemd.services."nextcloud_cron" = {
      description = "Nextcloud cron";
      after = [ "network.target" ];
      script = ''
        ${ncConf}/bin/nc-php ${nextcloud-pkg}/cron.php
      '';
      serviceConfig.User = "nginx";
    };
    systemd.services."nextcloud-init-var" = {
      after = [ "postgresql.service" ];
      before = [ "uwsgi.service" ];
      description = "Nextcloud Initialization";
      enable = true;
      path = [ pkgs.sudo ];
      script = ''
        mkdir -p ${nc.configDir} ${nc.dataDir} ${nc.apps2Dir} \
          ${nc.homeDir}/skeleton
        if ! [ -e ${nc.homeDir}/database-created ]; then
          sudo -u postgres -- ${pkgs.postgresql}/bin/createuser --no-superuser --no-createdb --no-createrole ${nc.userName}
          echo "ALTER USER ${nc.userName} WITH PASSWORD '${nc.password}'" | sudo -u postgres -- ${pkgs.postgresql}/bin/psql
          sudo -u postgres -- ${pkgs.postgresql}/bin/createdb nextcloud -O ${nc.userName}
          cp ${ncConf}/etc/config.php ${nc.configDir}
          chown -R nginx.nginx ${nc.homeDir}
          touch ${nc.homeDir}/database-created
        else
          sudo -u nginx -- ${ncConf}/bin/nc-cli upgrade
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
      };
      wantedBy = [ "multi-user.target" ];
    };

    systemd.timers."nextcloud_cron" = {
      enable = true;
      description = "Nextcloud cron timer";
      wantedBy = [ "timers.target" ];
      partOf = [ "nextcloud_cron.service" ];
      timerConfig = {
        RandomizedDelaySec = "5min";
        OnCalendar = "*-*-* *:00,30:00";  # every 1/2h
        Persistent = true;
      };
    };
  }

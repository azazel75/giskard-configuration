# -*- coding: utf-8 -*-
# :Project:   giskard -- root config file
# :Created:   dom 16 set 2018 22:08:28 CEST
# :Author:    Alberto Berti <alberto@metapensiero.it>
# :License:   GNU General Public License version 3 or later
# :Copyright: © 2018 Alberto Berti
#

{ config, pkgs, ... }: let
    unstable = import <unstable> {};
  in {
    imports =
      [ # Include the results of the hardware scan.
        ./hardware-configuration.nix
        ./containers
        ./services.nix
      ];

    # Use the systemd-boot EFI boot loader.
    # boot.crashDump.enable = true;
    boot.loader.systemd-boot.enable = false;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/sda";
    boot.loader.grub.memtest86.enable = true;
    boot.loader.efi.efiSysMountPoint = "/boot/efi";
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.kernel.sysctl = {
      # the following value is to prevent connection errors from
      # nginx (the default is 128) to the nextcloud uwsgi process.
      # http://man7.org/linux/man-pages/man2/listen.2.html
      # https://stackoverflow.com/questions/44581719/resource-temporarily-unavailable-using-uwsgi-nginx
      "net.core.somaxconn" = 1024;
    };

    networking.hostName = "giskard.lan"; # Define your hostname.
    networking.hosts."127.0.0.1" = [
      "localhost"
      "files.azazel.it"
      "azazel.it"
    ];


    # Select internationalisation properties.
    i18n = {
      consoleFont = "Lat2-Terminus16";
      consoleKeyMap = "it";
      defaultLocale = "en_US.UTF-8";
    };

    # Set your time zone.
    time.timeZone = "Europe/Rome";

    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    environment.systemPackages = with pkgs; [
      wget emacs zile lightdm i3 sakura tmux samba firefox
      mldonkey
    ];

    # allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    programs.bash.enableCompletion = true;
    programs.mtr.enable = true;
    programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    networking.firewall.enable = false;
    networking.enableIPv6 = false;
    networking.interfaces."enp1s0" = {
      ipv4.addresses = [{
        address = "192.168.1.3";
        prefixLength = 24;}];
    };
    networking.defaultGateway = {
      address = "192.168.1.1";
      interface = "enp1s0";
    };
    networking.nameservers = [ "192.168.1.1" ];
    networking.hostId = "4f7bbe23";


    # Enable the X11 windowing system.
    services.xserver.enable = true;
    services.xserver.layout = "it";
    services.xserver.xkbOptions = "eurosign:e";
    services.xserver.windowManager.i3.enable = false;
    services.xserver.desktopManager.kodi.enable = true;
    services.xserver.displayManager.lightdm = {
      enable = true;
      autoLogin = {
        enable = true;
        user = "kodi";
        timeout = 20;
      };
    };

    services.wakeonlan.interfaces = [
      {interface = "enp1s0"; method = "magicpacket";}
    ];

    virtualisation.docker = {
      enable = true;
      liveRestore = true;
    };

    # Enable touchpad support.
    # services.xserver.libinput.enable = true;

    # Enable the KDE Desktop Environment.
    # services.xserver.displayManager.sddm.enable = true;
    # services.xserver.desktopManager.plasma5.enable = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.extraUsers.azazel = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [
        "transmission"
      ];
    };

    users.extraUsers.kodi = {
      isNormalUser = true;
      uid = 1001;
    };

    users.extraUsers.emilia = {
      isNormalUser = true;
      uid = 1002;
      extraGroups = [
        "transmission"
      ];
    };

    users.groups.musica = {
      members = [ "azazel" "emilia" ];
    };

    # users.groups.docker = {
    #   members = [ "azazel" ];
    # };


    # This value determines the NixOS release with which your system is to be
    # compatible, in order to avoid breaking some software such as database
    # servers. You should change this only after NixOS release notes say you
    # should.
    system.stateVersion = "18.09"; # Did you read the comment?

  }

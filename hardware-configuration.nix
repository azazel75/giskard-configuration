# -*- coding: utf-8 -*-
# :Project:   giskard -- Mounted filesystems and hardware configuration
# :Created:   dom 16 set 2018 22:14:01 CEST
# :Author:    Alberto Berti <alberto@metapensiero.it>
# :License:   GNU General Public License version 3 or later
# :Copyright: © 2018 Alberto Berti
#

{ config, lib, pkgs, ... }: {
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "btrfs" ];
  hardware.cpu.intel.updateMicrocode = true;

  fileSystems."/" =
  { device = "/dev/disk/by-uuid/d00efca5-54e2-435b-9b48-92fb1ed73db5";
    fsType = "btrfs";
  };

  fileSystems."/boot" =
  { device = "/dev/disk/by-uuid/c492672d-c759-4379-858c-5aeb6e34c617";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" =
  { device = "/dev/disk/by-uuid/F2EB-AEB7";
    fsType = "vfat";
  };

  fileSystems."/mnt/storage_pool" =
  { device = "/dev/disk/by-uuid/5d847b5f-53d7-4f8f-8ccc-1bcfe20d9ddb";
    fsType = "btrfs";
    options = ["noatime"];
  };

  fileSystems."/mnt/musica" =
  { device = "/dev/disk/by-uuid/5d847b5f-53d7-4f8f-8ccc-1bcfe20d9ddb";
    fsType = "btrfs";
    options = ["noatime" "subvol=/musica"];
  };

  fileSystems."/mnt/books" =
  { device = "/dev/disk/by-uuid/5d847b5f-53d7-4f8f-8ccc-1bcfe20d9ddb";
    fsType = "btrfs";
    options = ["noatime" "subvol=/books"];
  };

  fileSystems."/mnt/data" =
  { device = "/dev/disk/by-uuid/5d847b5f-53d7-4f8f-8ccc-1bcfe20d9ddb";
    fsType = "btrfs";
    options = ["noatime" "subvol=/data"];
  };

  fileSystems."/mnt/backups" =
  { device = "/dev/disk/by-uuid/5d847b5f-53d7-4f8f-8ccc-1bcfe20d9ddb";
    fsType = "btrfs";
    options = ["noatime" "subvol=/backup"];
  };

  fileSystems."/home" =
  { device = "/dev/disk/by-uuid/5d847b5f-53d7-4f8f-8ccc-1bcfe20d9ddb";
    fsType = "btrfs";
    options = ["noatime" "subvol=/home"];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/b6db424a-d5de-4cc1-a08b-be9a55fc33eb";
    }];

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = "powersave";
  powerManagement.powertop.enable = true;
  sound.enable = true;
}

{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.deodex;
  compat = [ "vm" ];
in {
  config = mkIf (cfg.storageLayout == "traditional" && (elem cfg.machineType compat)) {
    fileSystems."/" = {
      device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };
    fileSystems."/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };

    swapDevices = [ ];
  };
}

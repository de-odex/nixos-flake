{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.deodex;
in {
  config = mkIf (cfg.storageLayout == "paranoid" && cfg.machineType == "vultr") {
    deodex = {
      paranoia = {
        enable = true;
      };
    };
    fileSystems."/boot" = {
      device = "/dev/disk/by-label/nixos-boot";
      fsType = "vfat";
    };
    swapDevices = [
      { device = "/dev/disk/by-label/swap"; }
    ];
  };
}

{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.deodex;
in {
  config = mkIf (cfg.storageLayout == "traditional" && cfg.machineType == "vultr") {
    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/nixos-root";
        fsType = "ext4";
      };
      "/boot" = {
        device = "/dev/disk/by-label/nixos-boot";
        fsType = "vfat";
      };
    };
    swapDevices = [
      { device = "/dev/disk/by-label/swap"; }
    ];
  };
}

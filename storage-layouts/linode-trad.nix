{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.deodex;
in {
  config = mkIf (cfg.storageLayout == "traditional" && cfg.machineType == "linode") {
    fileSystems."/" = {
      device = "/dev/sda";
      fsType = "ext4";
    };

    swapDevices = [
      { device = "/dev/sdb"; }
    ];
  };
}

{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.deodex;
in {
  config = mkIf (cfg.storageLayout == "paranoid" && cfg.machineType == "linode") {
    deodex = {
      paranoia = {
        enable = true;
      };
    };
    swapDevices = [
      { device = "/dev/sdb"; }
    ];
  };
}

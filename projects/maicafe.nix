{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.deodex.services;
in {
  imports = [
    ./maicafe
  ];

  config = mkIf (cfg ? "maicafe") {
  };
}

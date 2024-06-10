{ config, lib, pkgs, ... }:
with lib;
let 
  cfg = config.deodex.services;
  hostName = config.networking.hostName;
  ctrRedis = config.containers.redis;
  cfgRedis = config.containers.redis.config.services.redis;
  prefix = "10.250.10";
in {
  config = mkIf (elem "database" cfg.maicafe) {
    boot.kernel.sysctl = mkMerge [
      { "vm.nr_hugepages" = "0"; }
      { "vm.overcommit_memory" = "1"; }
    ];
    containers.redis = {
      privateNetwork = true;
      hostAddress = "${prefix}.1";
      localAddress = "${prefix}.2";
      autoStart = true;

      config =
        { config, pkgs, ... }:
        {
          system.stateVersion = "22.05";

          networking.firewall.allowedTCPPorts = [
            config.services.redis.servers."".port
          ] ++ config.services.openssh.ports;

          services.redis = {
            servers = {
              "" = {
                enable = true;
                bind = null;
              };
            };
          };

          # debug
          environment.systemPackages = [
            pkgs.redis
            pkgs.neovim
          ];

          services.openssh.enable = true;

          users.users.root.initialHashedPassword = "";
          users.mutableUsers = false;
        };
    };
  };
}

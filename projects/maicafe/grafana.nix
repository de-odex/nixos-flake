{ config, lib, pkgs, ... }:
with lib;
let 
  cfg = config.deodex.services;
  ctr = config.containers.grafana;
  ctrcfg = config.containers.grafana.config.services.grafana;
  prefix = "10.250.2";
in {
  config = mkIf (elem "monitoring" cfg.maicafe) {
    #services = {
    #  nginx = {
    #    enable = true;
    #    virtualHosts = let
    #      base = locations: {
    #        inherit locations;
    #        forceSSL = true;
    #        enableACME = true;
    #      };
    #      proxy = { ip, location ? "/" }: base {
    #        "${location}".proxyPass = "http://" + ip + "/";
    #      };
    #    in {
    #      "${config.networking.hostName}.vtubersuki.moe" =
    #        proxy {
    #          ip = (ctr.localAddress + ":${toString ctrcfg.port}}");
    #          location = "/grafana/";
    #        } // {
    #          proxyWebsockets = true;
    #        };
    #    };
    #  };
    #};

    containers.grafana = {
      privateNetwork = true;
      hostAddress = "${prefix}.1";
      localAddress = "${prefix}.2";
      autoStart = true;

      config =
        { config, pkgs, ... }:
        {
          system.stateVersion = "22.05";

          networking.firewall.allowedTCPPorts = [
            config.services.grafana.port
          ];

          services.grafana = {
            enable = true;
            #domain = "grafana.vtubersuki.moe";
            port = 2342;
            addr = "127.0.0.1";
            #security = {
            #  .
            #};
          };

          # debug
          environment.systemPackages = [
            pkgs.grafana
            pkgs.neovim
            pkgs.sqlite-interactive
          ];

          services.openssh.enable = true;

          users.users.root.initialHashedPassword = "";
          users.mutableUsers = false;
        };
    };
  };
}

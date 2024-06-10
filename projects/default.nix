{ config, lib, pkgs, ... }:
with lib;
{
  imports = [
    ./maicafe.nix
  ];

  options.deodex.services = mkOption {
    description = "The services this host has";
    type = with types; submodule {
      options = {
        maicafe = mkOption {
          type = listOf (enum [
            ## https://en.wikipedia.org/wiki/Wikipedia:Manual_of_Style/Chemistry/Compound_classes
            #"carbide" # frontend
            #"nitride" # tracker
            #"oxide"   # unused...
            "frontend"
            "backend"

            "database"
            "reverse proxy"
            "monitoring"
          ]);
        };
      };
    };
  };
}

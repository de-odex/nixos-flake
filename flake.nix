{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-24.05";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, deploy-rs, impermanence, sops-nix, ... }@inputs: let 
    hosts = {
      ras = { config, pkgs, ... }: {
        deodex = {
          machineType = "vultr";
          storageLayout = "paranoid";
          hardening.enable = true;
          services = {
            maicafe = [];
          };
        };
      };
      # otohime = { config, pkgs, ... }: {
      #   deodex = {
      #     machineType = "vultr";
      #     storageLayout = "paranoid";
      #     hardening.enable = true;
      #     services = {
      #       maicafe = [
      #         "database"
      #       ];
      #     };
      #   };
      # };
    };
  in {
    nixosConfigurations = builtins.mapAttrs (hostName: config: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ ... }: {
          networking.hostName = hostName;
        })

        ./modules
        ./projects
        ./storage-layouts
        ./machine-types
        ./common.nix
        sops-nix.nixosModules.sops
        impermanence.nixosModules.impermanence
        config
      ];
    }) hosts;

    # deploy = {
    #   magicRollback = true;
    #   autoRollback = true;

    #   nodes = builtins.mapAttrs (_: nixosConfig: {
    #     hostname =
    #       "${nixosConfig.config.networking.hostName}.${nixosConfig.config.networking.domain}";

    #     profiles.system.user = "root";
    #     profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos nixosConfig;
    #   }) self.nixosConfigurations;

    #   sshUser = "root";
    # };

    # # This is highly advised, and will prevent many possible mistakes
    # checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}

{ config, lib, pkgs, ... }:
with lib;
{
  config = {
    system.stateVersion = "22.05";

    nix = {
      package = pkgs.nixFlakes;
      gc = {
        automatic = true;
        options = "--delete-older-than 7d";
      };
      optimise.automatic = true;
      extraOptions = ''
        extra-experimental-features = nix-command flakes
      '';
      settings = {
        trusted-public-keys = [ "" ];
      };
      distributedBuilds = true;
      buildMachines = [
        { hostName = "eu.nixbuild.net";
          system = "x86_64-linux";
          maxJobs = 100;
          supportedFeatures = [ "benchmark" "big-parallel" ];
        }
      ];
    };
    # system.autoUpgrade = {
    #  enable = true;
    #  allowReboot = true;
    #  flake = "path:/etc/nixos/";
    # };

    sops = {
      gnupg.sshKeyPaths = [];
      age = {
        sshKeyPaths = [];
        keyFile = "/var/lib/sops-nix/key.txt";
      };
      defaultSopsFile = ./secrets/secrets.yaml;
      secrets = {
        "users/root" = {
          neededForUsers = true;
        };
        "users/deodex" = {
          neededForUsers = true;
        };
        tailscale = {
          sopsFile = ./secrets/${config.networking.hostName}.yaml;
        };
        nixbuild-ssh-key = {
          mode = "0600";
        };
      };
    };

    networking.firewall = {
      enable = true;
      checkReversePath = "loose";
      trustedInterfaces = [ "tailscale0" ];
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };

    time.timeZone = "Asia/Tokyo";
    # i18n.defaultLocale = "en_US.UTF-8";
    # i18n.extraLocaleSettings = {
    #  LC_CTYPE = "en_US.UTF-8";
    #  LC_NUMERIC = "ja_JP.UTF-8";
    #  LC_TIME = "ja_JP.UTF-8";
    #  LC_COLLATE = "en_US.UTF-8";
    #  LC_MONETARY = "ja_JP.UTF-8";
    #  LC_MESSAGES = "en_US.UTF-8";
    #  LC_PAPER = "ja_JP.UTF-8";
    #  LC_NAME = "ja_JP.UTF-8";
    #  LC_ADDRESS = "ja_JP.UTF-8";
    #  LC_TELEPHONE = "ja_JP.UTF-8";
    #  LC_MEASUREMENT = "ja_JP.UTF-8";
    #  LC_IDENTIFICATION = "ja_JP.UTF-8";
    # };
    # console = {
    #  font = "Lat2-Terminus16";
    #  keyMap = "us";
    # };

    environment.systemPackages = with pkgs; [
      kitty.terminfo
      # (pkgs.kitty.overrideAttrs (old: {
      #  meta = old.meta // {
      #    outputsToInstall = [ "terminfo" ];
      #  };
      # }))
      tailscale
    ];

    programs = {
      fish = {
        enable = true;
      };
      neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
      };
      git = {
        enable = true;
        config = { init.defaultBranch = "master"; };
      };
      ssh = {
        extraConfig = ''
          Host eu.nixbuild.net
            PubkeyAcceptedKeyTypes ssh-ed25519
            IdentityFile ${config.sops.secrets.nixbuild-ssh-key.path}
        '';
        knownHosts = {
          nixbuild = {
            hostNames = [ "eu.nixbuild.net" ];
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
          };
        };
      };
    };

    services = {
      openssh = {
        enable = true;
      };
      tailscale.enable = true;
    };

    users.users = {
      root = {
        passwordFile = config.sops.secrets."users/root".path;
        # openssh.authorizedKeys.keys = [
        #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKhRH3yiUZJz2AF+kmgaC5FOHwxwYr/qnuUkTSfWXmlE desktop.private"
        # ];
      };

      deodex = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        shell = pkgs.fish;
        passwordFile = config.sops.secrets."users/deodex".path;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKhRH3yiUZJz2AF+kmgaC5FOHwxwYr/qnuUkTSfWXmlE desktop.private"
        ];
      };
    };

    systemd.services.tailscale-autoconnect = {
     description = "Automatic connection to Tailscale";

     after = [ "network-pre.target" "tailscale.service" ];
     wants = [ "network-pre.target" "tailscale.service" ];
     wantedBy = [ "multi-user.target" ];

     serviceConfig.Type = "oneshot";

     script = with pkgs; ''
       # wait for tailscaled to settle
       sleep 2

       # check if we are already authenticated to tailscale
       status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
       if [ $status = "Running" ]; then # if so, then do nothing
         exit 0
       fi

       # otherwise authenticate with tailscale
       ${tailscale}/bin/tailscale up --authkey file:${config.sops.secrets.tailscale.path}
     '';
    };
  };
}

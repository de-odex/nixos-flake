# TODO: more options (persistMount, regularReboot)
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.deodex;
in
  {
    options.deodex.paranoia = {
      enable = mkEnableOption "Enable paranoid settings.";
      # persistMount = mkOption {
      #   type = types.attrsOf types.anything;
      #   example = {
      #     device = "/dev/disk/by-label/nixos-persist";
      #     fsType = "ext4";
      #   };
      #   description = "The disk to mount to /nix/persist.";
      # };
      # NOTE: temporary requirement for as long
      #       as i cannot use tmpfs for root
      # rootMount = mkOption {
      #   type = types.attrsOf types.anything;
      #   example = {
      #     device = "/dev/disk/by-label/nixos-root";
      #     fsType = "ext4";
      #   };
      #   description = "The disk to mount to /.";
      # };
    };


    config = mkIf cfg.paranoia.enable {
      systemd = {
        services = {
          regularReboot = {
             serviceConfig = {
              Type = "simple";
              ExecStart = "${pkgs.systemd}/bin/systemctl --no-block reboot";
            };
          };
        };
        timers = {
          regularReboot = {
            timerConfig = {
              # OnBootSec = "23h 30m";
              OnCalendar = "16:00 UTC";
              RandomizedDelaySec = "1h";
              FixedRandomDelay = "true";
            };
            wantedBy = [ "default.target" ];
          };
        };
      };

      environment.persistence."/nix/persist" = {
        directories = [
          "/etc/nixos" # nixos system config files, can be considered optional
          "/srv" # service data
          "/var/lib" # system service persistent data
          "/var/log" # the place that journald dumps it logs to
        ];
        files = [
          { file = "/etc/ssh/ssh_host_rsa_key"; parentDirectory = { mode = "u=rwx,g=rx,o=rx"; }; }
          { file = "/etc/ssh/ssh_host_ed25519_key"; parentDirectory = { mode = "u=rwx,g=rx,o=rx"; }; }
          { file = "/etc/ssh/ssh_host_rsa_key.pub"; parentDirectory = { mode = "u=rwx,g=rx,o=rx"; }; }
          { file = "/etc/ssh/ssh_host_ed25519_key.pub"; parentDirectory = { mode = "u=rwx,g=rx,o=rx"; }; }
          "/etc/machine-id"
        ];
        hideMounts = true;
      };
      #environment.etc = {
      #  "ssh/ssh_host_rsa_key".source = "/nix/persist/etc/ssh/ssh_host_rsa_key";
      #  "ssh/ssh_host_rsa_key.pub".source = "/nix/persist/etc/ssh/ssh_host_rsa_key.pub";
      #  "ssh/ssh_host_ed25519_key".source = "/nix/persist/etc/ssh/ssh_host_ed25519_key";
      #  "ssh/ssh_host_ed25519_key.pub".source = "/nix/persist/etc/ssh/ssh_host_ed25519_key.pub";
      #  "machine-id".source = "/nix/persist/etc/machine-id";
      #};

      fileSystems = {
        #"/" = cfg.paranoia.rootMount;
        "/" = {
          device = "tmpfs";
          fsType = "tmpfs";
          options = [ "size=4G" "mode=755" "noexec" ];
        };
        "/nix" = {
          device = "/dev/disk/by-label/nixos-persist";
          fsType = "ext4";
          neededForBoot = true;
        };

        ## for bios boot
        ## TODO: uefi boot
        #"/boot" = {
        #  depends = [ "/nix" ];
        #  device = "/nix/boot";
        #  fsType = "none";
        #  options = [ "bind" ];
        #};
        #"/etc/nixos" = {
        #  depends = [ "/nix" ];
        #  device = "/nix/persist/etc/nixos";
        #  fsType = "none";
        #  options = [ "bind" "noexec" ];
        #};
        #"/srv" = {
        #  depends = [ "/nix" ];
        #  device = "/nix/persist/srv";
        #  fsType = "none";
        #  options = [ "bind" "noexec" ];
        #};
        #"/var/log" = {
        #  depends = [ "/nix" ];
        #  device = "/nix/persist/var/log";
        #  fsType = "none";
        #  options = [ "bind" "noexec" ];
        #};
        #"/var/lib" = {
        #  depends = [ "/nix" ];
        #  device = "/nix/persist/var/lib";
        #  fsType = "none";
        #  options = [ "bind" ]; # noexec?
        #};
      };
    };
  }

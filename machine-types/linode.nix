{ config, lib, pkgs, modulesPath, ... }:
with lib;
let
  cfg = config.deodex.machineType;
  qemu-guest = import (modulesPath + "/profiles/qemu-guest.nix");
in {
  imports = [
    (args: (mkIf (cfg == "linode") (qemu-guest args)))
  ];

  config = mkIf (cfg == "linode") {
    boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_scsi" "ahci" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    #networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp0s5.useDHCP = lib.mkDefault true;

    # i fucking hate networking
    networking.tempAddresses = "disabled";

    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    # --- not hardware now

    # LISH
    boot.kernelParams = [ "console=ttyS0,19200n8" ];
    boot.loader.grub.extraConfig = ''
      serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
      terminal_input serial;
      terminal_output serial
    '';

    # configure grub
    boot.loader.grub.enable = true;
    boot.loader.grub.forceInstall = true;
    boot.loader.grub.device = "nodev";
    boot.loader.timeout = 10;

    networking.usePredictableInterfaceNames = false;
    networking.useDHCP = false;
    networking.interfaces.eth0.useDHCP = true;

    # for diagnostics
    environment.systemPackages = with pkgs; [
      inetutils
      mtr
      sysstat
    ];

    # longview
    #sops.secrets."linode/longview" = {  };
    #services.longview = {
    #  enable = true;
    #  apiKeyFile = config.sops.secrets."linode/longview".path;
    #};
  };
}

{ config, lib, pkgs, modulesPath, ... }:
with lib;
let
  cfg = config.deodex.machineType;
  qemu-guest = import (modulesPath + "/profiles/qemu-guest.nix");
in {
  imports = [
    (args: (mkIf (cfg == "vultr") (qemu-guest args)))
  ];

  config = mkIf (cfg == "vultr") {
    boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    networking.interfaces.ens3.useDHCP = lib.mkDefault true;

    # i fucking hate networking
    # networking.tempAddresses = "disabled";

    # nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    # --- not hardware now

    # configure grub
    boot.loader.grub = {
      enable = true;
      version = 2;
      forceInstall = true;
      device = "/dev/vda";
    };
    boot.loader.timeout = 10;

    # networking.usePredictableInterfaceNames = false;
    # networking.useDHCP = false;
    # networking.interfaces.eth0.useDHCP = true;

    # for diagnostics
    environment.systemPackages = with pkgs; [
      inetutils
      mtr
      sysstat
    ];
  };
}

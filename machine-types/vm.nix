{ config, lib, pkgs, modulesPath, ... }:
with lib;
let 
  cfg = config.deodex.machineType;
  qemu-guest = import (modulesPath + "/profiles/qemu-guest.nix");
in {
  imports = [
    (args: (mkIf (cfg == "vm") (qemu-guest args)))
  ];

  config = mkIf (cfg == "vm") {
    boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];

    boot.loader.systemd-boot.enable = true;

    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    networking.usePredictableInterfaceNames = false;
    networking.useDHCP = false;
    networking.interfaces.eth0.useDHCP = true;
  };
}

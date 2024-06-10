{ config, lib, pkgs, ... }:
with lib;
{
  imports = [
    ./vm.nix
    ./linode.nix
    ./vultr.nix
  ];

  options.deodex.machineType = mkOption {
    description = "The kind of machine to set up";
    type = with types; enum [
      "linode"
      "vultr"
      "vm"
    ];
  };
}

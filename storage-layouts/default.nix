{ config, lib, pkgs, ... }:
with lib;
{
  imports = [
    ./linode-paranoid.nix
    ./linode-trad.nix
    ./vultr-paranoid.nix
    ./vultr-trad.nix
    ./uefi-trad.nix
  ];

  options.deodex.storageLayout = mkOption {
    description = "The storage layout of the machine";
    type = with types; enum [
      "paranoid"
      "traditional"
    ];
  };
}

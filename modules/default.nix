{ config, lib, pkgs, ... }:
{
  imports = [
    ./harden.nix
    ./paranoia.nix
  ];
}

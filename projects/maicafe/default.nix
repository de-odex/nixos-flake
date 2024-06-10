{ config, lib, pkgs, ... }:
{
  imports = [
    ./redis.nix
    ./grafana.nix
  ];
}

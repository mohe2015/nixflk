{ config, lib, pkgs, ... }:
{


  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/monitoring/netdata.nix
  services.netdata = {
    enable = true;
  };
}

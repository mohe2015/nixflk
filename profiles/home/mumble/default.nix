{ config, lib, pkgs, ... }:
{


  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/murmur.nix
  # try to use matrix instead but this is also available, jitsi-meet is also available
  services.murmur = {
    enable = true;
    bonjour = true;
    
  };
}

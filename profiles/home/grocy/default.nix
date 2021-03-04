{ config, lib, pkgs, ... }:
{


  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/grocy.nix
  services.grocy = {
    enable = true;
    hostName = "food.pi.selfmade4u.de";
    settings = {
      currency = "EUR";
      culture = "de";
    };
  };
}

{ config, lib, pkgs, ... }:
{

  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/mediawiki.nix
  services.mediawiki = {
    enable = true;
    virtualHost = {
      hostName = "wiki.pi.selfmade4u.de";
    };
    database = {
      type = "mysql";
    };
    passwordFile = ../../../secrets/pi-mediawiki-password;
  };
}

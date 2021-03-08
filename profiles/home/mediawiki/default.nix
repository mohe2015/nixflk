{ config, lib, pkgs, ... }:
{

  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/mediawiki.nix
  services.mediawiki = {
    enable = true;
    virtualHost = {
      hostName = "wiki.pi.selfmade4u.de";
      listen = [{ ip = "*"; port = 8081; }];
    };
    database = {
      type = "mysql";
      createLocally = true;
    };
    # username = admin
    passwordFile = ../../../secrets/pi-mediawiki-password; # must be at least 10 chars
    extraConfig = ''
    $wgShowExceptionDetails = true;
    '';
  };

  services.nginx = {
    virtualHosts = {
      "nginx-wiki.pi.selfmade4u.de" = {
        serverName = "wiki.pi.selfmade4u.de";
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:8081";
        };
      };
    };
  };
}

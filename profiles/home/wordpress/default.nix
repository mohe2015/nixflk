{ config, lib, pkgs, ... }:
{
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/wordpress.nix
  services.wordpress = {
    sites."blog.pi.example.org" = {
      virtualHost = {
        listen = [{ ip = "*"; ssl = true; port = 443; }];
        enableACME = true;
      };
    };
    webserver = "nginx";
  };

  services.nginx = {
    virtualHosts = {
      "blog.pi.example.org" = {
  #      serverName = "blog.pi.example.org";
        forceSSL = true;
        enableACME = true;
  #      locations."/" = {
  #        proxyPass = "https://localhost:8080";
  #      };
      };
    };
  };
}

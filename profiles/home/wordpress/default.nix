{ config, lib, pkgs, ... }:
{
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/wordpress.nix
  services.wordpress = {
    "blog.pi.example.org" = {
      virtualHost = {
        listen = [{ ip = "*"; ssl = true; port = 8080; }];
        enableACME = true;
      };
    };
  };

  services.nginx = {
    virtualHosts = {
      "nginx-blog.pi.example.org" = {
        serverName = "blog.pi.example.org";
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "https://localhost:8080";
        };
      };
    };
  };
}

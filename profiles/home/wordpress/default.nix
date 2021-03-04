{ config, lib, pkgs, ... }:
{
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/wordpress.nix
  services.wordpress."blog.example.org" = {
    virtualHost = {
      listen = [{ ip = "*"; port = 8080; }];
    };
  };

  services.nginx = {
    virtualHosts = {
      "nginx-blog.example.org" = {
        serverName = "blog.example.org";
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:8080";
        };
      };
    };
  };
}

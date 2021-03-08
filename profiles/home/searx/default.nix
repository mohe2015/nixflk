{ config, lib, pkgs, ... }:
{

  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/searx.nix
  services.searx = {
    enable = true;
    # https://searx.github.io/searx/admin/settings.html
    settings = { 
      server.port = 8084;
    };
    # TODO FIXME runInUwsgi
  };

  services.nginx = {
    virtualHosts = {
      "nginx-search.pi.selfmade4u.de" = {
        serverName = "search.pi.selfmade4u.de";
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:8084";
        };
      };
    };
  };
}

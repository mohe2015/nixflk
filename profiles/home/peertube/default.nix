{ config, lib, pkgs, ... }:
{
  # https://github.com/NixOS/nixpkgs/pull/106492/files#diff-4777ecc9c39f65314c4616d1287b6082fac99fefff66fe2251688dbf467ffca3
  services.peertube = {
    enable = true;
    hostname = "video.pi.example.org";
    database = {
      createLocally = true;
    };
    redis = {
      createLocally = true;  
    };
    # nix shell nixpkgs#nodejs-12_x
    # ls /nix/store/*-peertube-*/
    # cd /nix/store/acqg81dwab69897j1b4nzxx34ivflkz2-peertube-3.0.1/
    # sudo -u peertube NODE_CONFIG_DIR=/var/lib/peertube/config NODE_ENV=production npm run reset-password -- -u root

    # username: root
    # password: specified
  };

  networking.firewall.allowedTCPPorts = [ 1935 ]; # rtmp

  services.nginx = {
    virtualHosts = {
      "nginx-video.pi.example.org" = {
        serverName = "video.pi.example.org";
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:9000";
        };
      };
    };
  };
}

{ config, lib, pkgs, ... }:
{
  # https://github.com/NixOS/nixpkgs/pull/106492/files#diff-4777ecc9c39f65314c4616d1287b6082fac99fefff66fe2251688dbf467ffca3
  services.peertube = {
    enable = true;
    settings = {
      webserver = {
        hostname = "totallynotlocalhost.de"; # "video.pi.example.org";
        port = 80;
        https = false;
      };
      redis = {
        hostname = "8.8.8.8";
        elephant = "cool";
      };
      idiot = true;
    };
    serviceEnvironmentFile = "/etc/nixos/secrets/peertube-root";
    database = {
      createLocally = true;
      #host = "test";
    };
    redis = {
      #host = "8.8.8.8";

      #host = "8.8.8.8";
      #port = 1234;

      #createLocally = true;

      #createLocally = true;
      #enableUnixSocket = false;

      #createLocally = true;
      #enableUnixSocket = false;
      #port = 1234;
    };
    # sudo systemctl show peertube.service | grep WorkingDirectory
    # cd /nix/store/5x3na3z6rcn5j2hv0p7knvhwmyz7bqar-peertube-3.0.1
    # nix shell nixpkgs#nodejs-14_x
    # sudo -u peertube NODE_CONFIG_DIR=/var/lib/peertube/config NODE_ENV=production npm run reset-password -- -u root

    # username: root
    # password: specified
  };

  networking.firewall.allowedTCPPorts = [ 1935 ]; # rtmp

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "nginx-video.pi.example.org" = {
        serverName = "totallynotlocalhost.de"; # "video.pi.example.org";
        # forceSSL = true;
        # enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:9000";
        };
      };
    };
  };
}

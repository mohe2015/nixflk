{ config, lib, pkgs, ... }:
{
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/nextcloud.nix
  # https://jacobneplokh.com/how-to-setup-nextcloud-on-nixos/
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
      }
    ];
  };

  # ensure that postgres is running *before* running the setup
  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };

  environment.etc."nixos/secrets/pi-nextcloud-adminpass".source = ../../../secrets/pi-nextcloud-adminpass; # meeded for container
  services.nextcloud = {
    enable = true;
    https = true;
    hostName = "cloud.pi.example.org";
    config = {
      overwriteProtocol = "https";
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";
      dbname = "nextcloud";
      # would support redis or memcached
      adminpassFile = "/etc/nixos/secrets/pi-nextcloud-adminpass"; # warning: is world readable
    };
    autoUpdateApps = {
      #  enable = true;
    };
  };

  services.nginx = {

    virtualHosts = {
      "cloud.pi.example.org" = {
        forceSSL = true;
        enableACME = true;
      };
    };
  };
}

{ lib, pkgs, config, modulesPath, ... }:
{
  imports = [
    # passwd is nixos by default
    ../users/nixos
    # passwd is empty by default
    ../users/root
#    "${modulesPath}/profiles/minimal.nix"
#    "${modulesPath}/profiles/headless.nix"
 #   (modulesPath + "/installer/cd-dvd/sd-image-aarch64-new-kernel.nix")
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
#  boot.initrd.availableKernelModules = [
#    # Allows early (earlier) modesetting for the Raspberry Pi
#    "vc4" "bcm2835_dma" "i2c_bcm2835"
#  ];

#  sdImage.compressImage = false;
  boot.supportedFilesystems = [ "vfat" "ext4" ];
  boot.initrd.supportedFilesystems = [ "vfat" "ext4" ];

  environment.systemPackages = [ pkgs.htop pkgs.git pkgs.dnsutils ];


  # FIXME storing the secrets in the git repo that contains the configuration puts them into the nix store. 

  # FIXME https://www.heise.de/ct/artikel/Router-Kaskaden-1825801.html
  # TODO just buy a Fritzbox and replace current router (check for Telekom TV support)
  # some routers have a builtin vpn

  # another possibility would be to run all the below services in lxc with virtual networking and additional systemd hardening and only allow these interfaces to talk to the router and not to other devices in the network. This would rely on the security of NixOS and Linux but it shouldn't be too bad.

  # TODO check which database is officially recommended, choose postgresql otherwise
  # TODO some backup solution https://github.com/NixOS/nixpkgs/tree/master/nixos/modules/services/backup

  # TODO improve systemd-security and lynis

  # TODO better ssh security
  # TODO better firewall security
  # TODO apparmor / selinux
  # TODO auditd
  # TODO hardened kernel?
  # TODO filesystem quotas

  # TODO collabora online

  services.openssh.enable = true;

 

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  security.acme.server = "https://localhost:9443/acme/acme/directory";
  security.acme.email = "root@example.org";
  security.acme.acceptTerms = true;

  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/security/step-ca/default.nix
  environment.etc."nixos/secrets/pi-smallstep-ca".source = ../secrets/pi-smallstep-ca;
  services.step-ca = {
    enable = true;
    address = "127.0.0.1";
    port = 9443;
    intermediatePasswordFile = "/etc/nixos/secrets/pi-smallstep-ca"; # warning is world readable
    settings = {
      dnsNames = ["localhost"];
      root = ../secrets/root-ca.crt;
      crt = ../secrets/intermediate_ca.crt;
      key = ../secrets/intermediate_ca.key;
      db = {
        type = "badger";
        dataSource = "/var/lib/step-ca/db";
      };
      authority = {
        provisioners = [
          {
            type = "ACME";
            name = "acme";
          }
        ];
      };
    };
  };
  security.pki.certificateFiles = [ ../secrets/root-ca.crt ../secrets/intermediate_ca.crt ];

  services.httpd.adminAddr = "root@example.org";

  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/bind.nix
  # networking.resolvconf.useLocalResolver = false; # to unbreak your internet
  services.bind = {
    enable = true;
    cacheNetworks = [ "127.0.0.0/24" "192.168.100.0/24" ];
    zones = [
      {
        name = "rpz";
        master = true;
        file = pkgs.writeText "bind.conf"
        ''
$TTL    604800
@                    IN      SOA     localhost. root.localhost. (
                              5         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
                             IN      NS localhost.
blog.example.org       A       192.168.100.11
meet.pi.example.org    A       192.168.100.11
cloud.pi.example.org A       192.168.100.11
        '';
      }
    ];
    extraOptions = ''
      response-policy { zone "rpz"; };
    '';
  };

  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/wordpress.nix
  services.wordpress."blog.example.org" = {
    virtualHost = {
      listen = [{ ip = "*"; port = 8080; }];
    };
  };
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    enableReload = true;
    virtualHosts = {
      "nginx-blog.example.org" = {
        serverName = "blog.example.org";
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:8080";
        };
      };
      "cloud.pi.example.org" = {
        forceSSL = true;
        enableACME = true;
      };
    };
  };

  services.mysql.package = pkgs.mariadb;



/*
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/searx.nix
  services.searx = {
    enable = true;
    # https://searx.github.io/searx/admin/settings.html
    settings = {
    };
  };
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/moodle.nix
  # uses httpd
  #services.moodle = {
  #  enable = true;
  #  virtualHost = {
  #    hostName = "moodle.pi.selfmade4u.de";
  #  };
  #  database = {
  #    type = "mysql";
  #  };
  #  initialPassword = "WHATTHEFUCK";
  #};
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/mediawiki.nix
  services.mediawiki = {
    enable = true;
    virtualHost = {
      hostName = "wiki.pi.selfmade4u.de";
    };
    database = {
      type = "mysql";
    };
    passwordFile = ../secrets/pi-mediawiki-password;
  };
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/matomo.nix
  services.matomo = {
    enable = true;
    nginx = {
    };
  };
*/
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/jitsi-meet.nix
  services.jitsi-meet = {
    enable = true;
    hostName = "meet.pi.example.org";
  };

  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/nextcloud.nix
  # https://jacobneplokh.com/how-to-setup-nextcloud-on-nixos/
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
     { name = "nextcloud";
       ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
     }
    ];
  };

  # ensure that postgres is running *before* running the setup
  systemd.services."nextcloud-setup" = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
  };

  environment.etc."nixos/secrets/pi-nextcloud-adminpass".source = ../secrets/pi-nextcloud-adminpass;
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
 

/*
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/matrix-synapse.nix
  services.matrix-synapse = {
    enable = true;
    database_type = "psycopg2"; # postgresql
  };
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/grocy.nix
  services.grocy = {
    enable = true;
    hostName = "food.pi.selfmade4u.de";
    settings = {
      currency = "EUR";
      culture = "de";
    };
  };
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/monitoring/grafana.nix
  services.grafana = {
    enable = true;
    database = {
      type = "postgres";
    };
  };
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/monitoring/prometheus/default.nix
  services.prometheus = {
    enable = true;
  };
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/monitoring/graphite.nix
  services.graphite = {
    web = {
      enable = true;
    };
  };
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/monitoring/netdata.nix
  services.netdata = {
    enable = true;
  };
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/security/fail2ban.nix
  services.fail2ban = {
    enable = true;
  };
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/security/tor.nix
  services.tor = {
    enable = true;
    relay.onionServices = {
    };
  };
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/system/earlyoom.nix
  services.earlyoom = {
    enable = true;
  };
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/gitea.nix
  services.gitea = {
    enable = true;
    database = {
      type = "postgres";
    };
  };
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/games/minecraft-server.nix
 # services.minecraft-server = {
 #   enable = true;
 #   declarative = true;
 #   eula = true;
 #   openFirewall = true;
 # };
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/teamspeak3.nix
  # try to use matrix instead but this is also available, jitsi-meet is also available
  services.teamspeak3 = {
    enable = true;
  };
*/
  # TODO bigbluebutton https://github.com/helsinki-systems/bbb4nix

  # TODO https://github.com/wireapp/wire-server

  # TODO etherpad

  # https://github.com/NixOS/nixpkgs/tree/master/nixos/modules/services/cluster/kubernetes
  #services.kubernetes = {
  #  roles = ["master"];
  #  masterAddress = "kubernetes-primary.pi.selfmade4u.de";
  #};

#  hardware.enableRedistributableFirmware = lib.mkDefault true;
#  hardware.pulseaudio.enable = lib.mkDefault true;
#  sound.enable = lib.mkDefault true;

#  documentation.enable = false;
#  networking.wireless.enable = true;
}
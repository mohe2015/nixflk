{ lib, pkgs, config, modulesPath, profiles, ... }:
{
  imports = [
    # passwd is nixos by default
    ../users/nixos
    # passwd is empty by default
    ../users/root
    "${modulesPath}/profiles/minimal.nix"
    "${modulesPath}/profiles/headless.nix"
    (modulesPath + "/installer/sd-card/sd-image-aarch64-new-kernel.nix")
  ] ++ [ profiles."home/jitsi" ];

  boot.initrd.availableKernelModules = lib.mkForce []; # for VM

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

  # step certificate create --profile root-ca "Example Root CA" root_ca.crt root_ca.key
  # step certificate create "Example Intermediate CA 1" intermediate_ca.crt intermediate_ca.key --profile intermediate-ca --ca ./root_ca.crt --ca-key ./root_ca.key
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/security/step-ca/default.nix
  environment.etc."nixos/secrets/pi-smallstep-ca".source = ../secrets/pi-smallstep-ca; # needed for container
  services.step-ca = {
    enable = true;
    address = "127.0.0.1";
    port = 9443;
    intermediatePasswordFile = "/etc/nixos/secrets/pi-smallstep-ca"; # warning is world readable
    settings = {
      dnsNames = ["localhost"];
      root = ../secrets/root_ca.crt;
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
  security.pki.certificateFiles = [ ../secrets/root_ca.crt ../secrets/intermediate_ca.crt ];

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
        # easiest way would probably be some kind of "lines" merging
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

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    enableReload = true;
  };

  services.mysql.package = pkgs.mariadb;

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
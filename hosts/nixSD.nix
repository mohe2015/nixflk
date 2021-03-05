{ lib, pkgs, config, modulesPath, ... }:
{
  imports = [
    # passwd is nixos by default
    ../users/nixos
    # passwd is empty by default
    ../users/root
    "${modulesPath}/profiles/minimal.nix"
    "${modulesPath}/profiles/headless.nix"
    "${modulesPath}/installer/sd-card/sd-image-aarch64-new-kernel.nix"
  ];

  boot.initrd.availableKernelModules = lib.mkForce []; # for VM

  environment.systemPackages = [ pkgs.htop pkgs.git pkgs.dnsutils ];

  # FIXME storing the secrets in the git repo that contains the configuration puts them into the nix store. 

  # FIXME https://www.heise.de/ct/artikel/Router-Kaskaden-1825801.html
  # TODO just buy a Fritzbox and replace current router (check for Telekom TV support)
  # some routers have a builtin vpn

  # another possibility would be to run all the below services in lxc with virtual networking and additional systemd hardening and only allow these interfaces to talk to the router and not to other devices in the network. This would rely on the security of NixOS and Linux but it shouldn't be too bad.

  # TODO check which database is officially recommended, choose postgresql otherwise
  # TODO some backup solution https://github.com/NixOS/nixpkgs/tree/master/nixos/modules/services/backup

  # TODO better ssh security
  # TODO better firewall security
  # TODO apparmor / selinux
  # TODO auditd
  # TODO hardened kernel?
  # TODO filesystem quotas
  # TODO collabora online

  # TODO lock-kernel-modules
  # TODO systemd-confinement
  # TODO encrypted fs?
  # TODO continouus integration?
  # TODO minetest-server
  # TODO logging
  # TODO mail :(
  # TODO more minimal git like gitit, gitolite or gitweb
  # TODO nix-serve
  # TODO vpnß
  # TODO torrent service (alternative to something like ipfs)
  # TODO pastebin like (cryptpad, ?)
  # TODO keycloak (sso?)

  services.openssh.enable = true;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  services.httpd.adminAddr = "root@example.org";

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

  # TODO etherpad, ethercalc

  # TODO peertube

  # TODO mastodon?

  # TODO some forum software?

  # TODO syncthing or git-annex

  # TODO mapping service? like OSM https://github.com/openstreetmap

  # overleaf latex editor

  # TODO bitwarden server

  # ticket system (I used for school)

  # TODO some socks proxy?

  # TODO searx

  # TODO "read the docs" tool

  # TODO url shortener

  # TODO irc logger server (for the nixos irc)

  # TODO weblate

  # https://github.com/awesome-selfhosted/awesome-selfhosted#knowledge-management-tools

  # https://github.com/awesome-selfhosted/awesome-selfhosted

  # https://git.immae.eu/cgit/perso/Immae/Config/Nix.git/

#  hardware.enableRedistributableFirmware = lib.mkDefault true;
#  hardware.pulseaudio.enable = lib.mkDefault true;
#  sound.enable = lib.mkDefault true;

#  documentation.enable = false;
#  networking.wireless.enable = true;
}
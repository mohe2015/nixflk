{ config, lib, pkgs, ... }:
{
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
blog.pi.example.org     A       192.168.100.11
meet.pi.example.org     A       192.168.100.11
cloud.pi.example.org    A       192.168.100.11
status.pi.example.org   A       192.168.100.11
wiki.pi.selfmade4u.de   A       192.168.100.11
moodle.pi.selfmade4u.de A       192.168.100.11
food.pi.selfmade4u.de   A       192.168.100.11
search.pi.selfmade4u.de A       192.168.100.11
        '';
      }
    ];
    extraOptions = ''
      response-policy { zone "rpz"; };
    '';
  };
}
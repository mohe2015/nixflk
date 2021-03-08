{ config, lib, pkgs, ... }:
{
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/moodle.nix
  # uses httpd
  services.moodle = {
    enable = true;
    virtualHost = {
      hostName = "moodle.pi.selfmade4u.de";
    };
    database = {
      type = "mysql";
    };
    initialPassword = "WHATTHEFUCK";
  };


}

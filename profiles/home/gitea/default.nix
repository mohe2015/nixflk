{ config, lib, pkgs, ... }:
{


  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/gitea.nix
  services.gitea = {
    enable = true;
    database = {
      type = "postgres";
    };
  };
}

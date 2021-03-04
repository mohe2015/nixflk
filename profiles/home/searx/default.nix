{ config, lib, pkgs, ... }:
{

  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/searx.nix
  services.searx = {
    enable = true;
    # https://searx.github.io/searx/admin/settings.html
    settings = { };
  };
}

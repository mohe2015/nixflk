{ config, lib, pkgs, ... }:
{


  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/matrix-synapse.nix
  services.matrix-synapse = {
    enable = true;
    database_type = "psycopg2"; # postgresql
  };
}

{ config, lib, pkgs, ... }:
{
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/mastodon.nix
  services.mastodon = {
    enable = true;
    configureNginx = true;
    localDomain = "social.pi.example.org";
    redis = {
      createLocally = true;
    };
    database = {
      createLocally = true;
    };
    smtp = {
      fromAddress = "pi.example.org";
      user = "root";
    };
    # TODO elasticsearch

    # TODO FIXME
    # no default user known yet
  };
}

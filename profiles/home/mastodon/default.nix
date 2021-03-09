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

  # su - mastodon -s /bin/sh
  # mastodon-env tootctl accounts create moritz_hedtke --email=EMAIL
  # mastodon-env tootctl accounts modify moritz_hedtke --confirm
  # mastodon-env tootctl accounts modify moritz_hedtke --role admin

  # openssl s_client -connect video.pi.example.org:https
  # openssl s_client -connect self-signed.badssl.com:https
  # curl https://video.pi.example.org

  # cd pkgs/servers/mastodon/
  # nix build --impure --expr '(builtins.getFlake "nixpkgs").legacyPackages.x86_64-linux.callPackage ./update.nix {}'
  # ./result/bin/update.sh --url https://github.com/mohe2015/mastodon.git --rev 4923aaa5856c822d41516e7c3d88730569853618 --ver 3.3.0
}

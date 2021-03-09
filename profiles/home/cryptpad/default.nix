{ config, lib, pkgs, ... }:
{
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/cryptpad.nix
  services.cryptpad = {
    enable = true;
    configFile = pkgs.writeText "cryptpad-config.js"
    ''
module.exports = {
  httpUnsafeOrigin: 'https://paste.pi.example.org',
  httpSafeOrigin: "https://paste-sandbox.pi.example.org",
  httpPort: 30000,
  httpSafePort: 30001,
  adminEmail: 'Moritz.Hedtke@t-online.de',
};
    '';
  };

  # TODO FIXME not working yet

  # fixme / test forwared-for ip
  services.nginx = {
    virtualHosts = {
      "paste.pi.example.org" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:30000";
        };
      };
      "paste-sandbox.pi.example.org" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:30001";
        };
      };
    };
  };
}

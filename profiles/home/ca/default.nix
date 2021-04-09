{ config, lib, pkgs, ... }:
{
  security.acme.server = "https://localhost:9443/acme/acme/directory";
  security.acme.email = "root@example.org";
  security.acme.acceptTerms = true;

  # step certificate create --profile root-ca "Example Root CA" root_ca.crt root_ca.key
  # step certificate create "Example Intermediate CA 1" intermediate_ca.crt intermediate_ca.key --profile intermediate-ca --ca ./root_ca.crt --ca-key ./root_ca.key
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/security/step-ca/default.nix
  # environment.etc."nixos/secrets/pi-smallstep-ca".source = ../../../secrets/pi-smallstep-ca; # needed for container
  
  services.step-ca = {
    enable = true;
    #package = pkgs.hello;
    address = "127.0.0.1";
    port = 9443;
    intermediatePasswordFile = "/etc/nixos/secrets/pi-smallstep-ca"; # warning is world readable
    settings = {
      dnsNames = ["localhost"];
      root = ../../../secrets/root_ca.crt;
      crt = ../../../secrets/intermediate_ca.crt;
      key = ../../../secrets/intermediate_ca.key;
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
  
  # still doesn't work as step-ca doesn't notify startup
  systemd.services."step-ca.service" = {
    unitConfig = {
      Before = [ "basic.target" ];
      Wants  = [ "basic.target" ];
    };
  };

  security.pki.certificateFiles = [ ../../../secrets/root_ca.crt ../../../secrets/intermediate_ca.crt ];
}
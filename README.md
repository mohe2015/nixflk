https://github.com/ryantm/nixpkgs-update

nix-build maintainers/scripts/build.nix --argstr maintainer <name>

nix-env -f compat/nixos --arg configuration hosts/nixSD.nix -iA config.system.build.toplevel --show-trace


nix-env -f '<nixpkgs/nixos>' --arg configuration '{ fileSystems."/".device = "/tmp"; boot.loader.grub.devices = ["nodev"]; security.acme.acceptTerms = true; security.acme.email = "test@example.org"; services.jitsi-meet.enable = true; services.jitsi-meet.hostName = "localhost"; }' -iA config.system.build.toplevel


nix build .#nixosConfigurations.NixOS.config.system.build.toplevel

nix build .#nixosConfigurations.nixSD.config.system.build.vm

nix build .#nixosConfigurations.nixSD.config.system.build.sdImage


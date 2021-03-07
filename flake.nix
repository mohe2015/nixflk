# sudo journalctl -u container@pi.service
{
  description = "Moritz Hedtke's flake";
  # https://blog.ysndr.de/posts/internals/2021-01-01-flake-ification/
  # https://zimbatm.com/NixFlakes/
  # https://github.com/numtide/nix-flakes-installer#github-actions
  # https://www.tweag.io/blog/2020-05-25-flakes/
  # https://github.com/nix-community/home-manager
  # https://nix-community.github.io/home-manager/
  # https://nixos.wiki/wiki/Home_Manager

  inputs =
    {
      nixpkgs.url = "git+file:///etc/nixos/nixpkgs";
      home-manager.url = "github:nix-community/home-manager/master";
      flake-utils.url = "github:numtide/flake-utils";
    };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
  {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # https://github.com/nix-community/home-manager#nix-flakes TODO FIXME
          # split up like that maybe we need to pass it the config as parameter
          # https://github.com/nix-community/home-manager/blob/master/flake.nix
          # also contains some useful other bits
          home-manager.nixosModules.home-manager
          (args@{ lib, pkgs, ... }: import ./hosts/nixos.nix (args // { inherit self; inherit nixpkgs; inherit home-manager; }))
        ];
      };
      nixSD = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          (import ./hosts/nixSD.nix)
        ];
      };
    };
  };
}

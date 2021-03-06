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
          (args@{ pkgs, ... }: import ./hosts/nixos.nix (args // { inherit self; inherit home-manager; }))
          home-manager.nixosModules.home-manager 
        ];
      };
      nixSD = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager ./hosts/nixSD.nix
        ];
      };
    };
  };
}

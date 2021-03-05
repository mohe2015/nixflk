{
  description = "Moritz Hedtke's flake";

  inputs =
    {
      nixpkgs.url = "git+file:///etc/nixos/nixpkgs";
      home.url = "github:nix-community/home-manager/master";
    };

  outputs =
    inputs@{
      nixpkgs
    , home
    , ...
    }:
}

{ ... }:
{
  home-manager.users.nixos = {
    imports = [ ../profiles/git ../profiles/direnv ];
  };

  users.users.nixos = {
    uid = 1001;
    password = "nixos";
    description = "default";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
}

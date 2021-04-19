{ ... }:
{
  #home-manager.users.nixos = {
  #  imports = [ ../profiles/git ../profiles/direnv ];
  #};

  users.users.nixos = {
    uid = 1001;
    password = "nixos";
    description = "default";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$U6TWCNXw0VAh3Yq$w2v/IDDne90szGyfeLOAkUcjahu29MaeeYeFDRlI96281VKTOpy/s7u/dYUkmCjgjr7iz5nEzQAR4k7ox4uMk1";
  };
}

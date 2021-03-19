{ pkgs, ... }:
{

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureUsers = [
      {
        name = "moritz";
        ensurePermissions = {
          "* . *" = "ALL PRIVILEGES";
        };
      }
    ];
    ensureDatabases = [ "sponsorenlauf" ];
  };

  # seems to not work with prisma currently
  services.postgresql = {
    enable = true;
    ensureUsers = [
      {
        name = "moritz";
        ensurePermissions = {
          "DATABASE sponsorenlauf" = "ALL PRIVILEGES";
        };
      }
    ];
    ensureDatabases = [ "sponsorenlauf" ];
  };
}

{ config, lib, pkgs, ... }:
{
  services.mattermost = {
    enable = true;
    siteUrl = "http://mattermost.pi.example.org";
    siteName = "MatterPi";
  };

  networking.firewall.allowedTCPPorts = [ 8065 ];
}

{ self, lib, pkgs, nixpkgs, home-manager, config, ... }:
{
  ### root password is empty by default ###
  imports = [
    ../profiles/core
    ../users/moritz
    ../users/root
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam" "steam-original" "steam-runtime"
    "discord" # run in browser?
  ];

  boot.loader.efi.canTouchEfiVariables = false; # https://github.com/NixOS/nixos-hardware/pull/134#discussion_r361146814
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  #boot.loader.grub.useOSProber = true;

  virtualisation.libvirtd.enable = true;

  programs.wireshark.enable = true;

  fileSystems."/" = { device = "/dev/disk/by-label/nixos"; fsType = "ext4"; };
  fileSystems."/boot" = { device = "/dev/disk/by-label/SYSTEM"; fsType = "vfat"; };

  swapDevices = [
    {
      device = "/swapfile";
      priority = 0;
      size = 16384;
    }
  ];

  services.sshd.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  hardware.cpu.amd.updateMicrocode = true;

  hardware.enableRedistributableFirmware = true;

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.package = pkgs.mesa.drivers;
  hardware.opengl.extraPackages = [ pkgs.mesa pkgs.amdvlk ];

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.firmware = [
    (pkgs.runCommandNoCC "firmware-audio-retask" { } ''
      mkdir -p $out/lib/firmware/
      cp ${../hda-jack-retask.fw} $out/lib/firmware/hda-jack-retask.fw
    '')
  ];

  programs.steam.enable = true;

  services.fstrim.enable = true;

  services.xserver.enable = true;
  services.xserver.layout = "de";
  services.xserver.videoDrivers = [ "amdgpu" "modesetting" ];

  services.xserver.wacom.enable = true;

  services.xserver.libinput.enable = true;

  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # bugfix for xournalpp https://github.com/xournalpp/xournalpp/issues/999
  environment.systemPackages = [ pkgs.gnome3.adwaita-icon-theme ];

  containers.pi = {
    config = ({
      imports = [
        home-manager.nixosModules.home-manager
        (import ./nixSD.nix)
      ];
    });
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";
  };

  networking.nat.enable = true;
  networking.nat.internalInterfaces = ["ve-+"];
  networking.nat.externalInterface = "enp1s0";

  networking = {
    useDHCP = false;
    interfaces.enp1s0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "192.168.2.129";
        prefixLength = 24;
      }];
    };
    defaultGateway = "192.168.2.1";
    search = [""];
    nameservers = [ "192.168.100.11" "192.168.2.1" ];
  };

  environment.etc."resolv.conf" = with lib; with pkgs; {
    source = writeText "resolv.conf" ''
      ${concatStringsSep "\n" (map (ns: "nameserver ${ns}") config.networking.nameservers)}
      options edns0
    '';
  };
}

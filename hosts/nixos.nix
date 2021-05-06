{ self, lib, pkgs, nixpkgs, home-manager, config, ... }:
{
  ### root password is empty by default ###
  imports = [
    ../profiles/core
    ../profiles/prisma
    ../users/moritz
    ../users/root
    ../profiles/home/earlyoom
#    ../profiles/home/peertube
  ];


  programs.adb.enable = true;

  services.avahi.enable = true;
  services.avahi.nssmdns = true;

  services.gitlab-runner = {
    enable = true;
    concurrent = 10;
    services = {
      default = {
        registrationConfigFile = "/etc/nixos/secrets/gitlab-ci";
        dockerImage = "scratch";
      };
    };
  };

  networking.extraHosts =
  ''
    127.0.0.1 totallynotlocalhost.de
  '';

  #nix.useSandbox = lib.mkForce false;

  virtualisation.docker.enable = true;
/*
  services.kubernetes = {
    roles = ["master" "node"];
    masterAddress = "localhost";
    easyCerts = true;
    apiserver = {
      securePort = 443;
      advertiseAddress = "127.0.0.1";
    };
    addons.dashboard = {
      enable = true;
#      image = {
#        imageName = "kubernetesui/dashboard";
#        imageDigest = "sha256:148991563e374c83b75e8c51bca75f512d4f006ddc791e96a91f1c7420b60bd9"; # docker pull kubernetesui/dashboard:v2.2.0 # outputs this
#        finalImageTag = "v2.2.0"; # https://github.com/kubernetes/dashboard/releases/tag/v2.2.0
#        sha256 = "eURGvBukkp3ceUkul3OGDUePIJm77j7S+iyvxMY0tlU=";
#      };
    };

     # use coredns
    addons.dns.enable = true;

    # needed if you use swap
    kubelet.extraOpts = "--fail-swap-on=false";
  };
  # kubectl cluster-info
  # https://nixos.wiki/wiki/Kubernetes check DNS part
  # kubectl rollout restart -n kube-system deployment/coredns
*/
  environment.systemPackages = [
    pkgs.wireguard
    pkgs.wireguard-tools
    pkgs.kompose
    pkgs.kubectl
    pkgs.kubernetes
    pkgs.gnome3.adwaita-icon-theme # bugfix for xournalpp https://github.com/xournalpp/xournalpp/issues/999
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam" "steam-original" "steam-runtime"
    "discord" "discord-ptb" "discord-canary" # run in browser?
    "android-studio-canary"
    "thunderbird-bin"
    "firefox-release-bin-unwrapped"
    "firefox-bin"
  ];

# boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.grub.enable = true;
  boot.loader.grub.configurationLimit = 5;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;

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

  services.openssh.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" "v4l2loopback" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback config.boot.kernelPackages.wireguard ];

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

  #programs.steam.enable = true;

  services.fstrim.enable = true;

  services.xserver.enable = true;
  services.xserver.layout = "de";
  services.xserver.videoDrivers = [ "amdgpu" "modesetting" ];

  services.xserver.wacom.enable = true;

  services.xserver.libinput.enable = true;

  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
/*
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
    autoStart = true;
    timeoutStartSec = "2min";
  };
*/
  networking.nat.enable = true;
  networking.nat.internalInterfaces = ["ve-+"];
  networking.nat.externalInterface = "enp1s0";

  networking = {
    useDHCP = false;
    networkmanager.enable = true;
    #interfaces.enp1s0 = {
    #  useDHCP = false;
    #  ipv4.addresses = [{
    #    address = "192.168.2.129";
    #    prefixLength = 24;
    #  }];
    #};
    #defaultGateway = "192.168.2.1";
    #search = [""];
    #nameservers = [ "8.8.8.8" "192.168.2.1" ];
  };

  #environment.etc."resolv.conf" = with lib; with pkgs; {
  #  source = writeText "resolv.conf" ''
  #    ${concatStringsSep "\n" (map (ns: "nameserver ${ns}") config.networking.nameservers)}
  #    options edns0
  #  '';
  #};

  system.stateVersion = "21.05";

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];   
}

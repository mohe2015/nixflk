{ pkgs, ... }:
{
  home-manager.users.moritz = {
    imports = [ ../profiles/git ../profiles/direnv ../profiles/gpg ];

    programs.git = {
      userName = "mohe2015";
      userEmail = "Moritz.Hedtke@t-online.de";
      signing.signByDefault = true;
      signing.key = "1248D3E11D114A8575C989346794D45A488C2EDE";
    };

    home.packages = [
      pkgs.sqlite
      pkgs.sqlite.dev
      pkgs.pkg-config
      pkgs.binutils
      pkgs.plasma-systemmonitor
      pkgs.htop
      pkgs.kicad
      pkgs.multimc
      pkgs.sshfs
      pkgs.rustup
      pkgs.gcc
      #pkgs.chromium
      pkgs.ktorrent
      pkgs.lyx
      pkgs.kmix
      pkgs.git-crypt
      pkgs.signal-desktop
      pkgs.xournalpp
      pkgs.thunderbird-bin
      pkgs.firefox-beta-bin
      pkgs.eclipses.eclipse-java
      pkgs.git
      pkgs.git-lfs
      pkgs.gnupg
      pkgs.vlc
      pkgs.vscodium
      pkgs.discord
      pkgs.libreoffice-fresh
      pkgs.texlive.combined.scheme-full
      pkgs.unzip
      pkgs.obs-studio
      pkgs.wireshark
      pkgs.racket
      pkgs.hunspell
      pkgs.hunspellDicts.de-de
      pkgs.hunspellDicts.en-us
      pkgs.jetbrains.idea-community
      pkgs.jdk
      pkgs.ark
      pkgs.gh
      pkgs.androidStudioPackages.canary
      # pkgs.pdfsam-basic
      pkgs.kubectl
      pkgs.krew
      pkgs.kubernetes-helm
    ];

    programs.ssh = {
      enable = true;
    };

    programs.fish = {
      enable = true;
    };
  };

  programs.ssh = {
    startAgent = true;
  };
  
  users.users.moritz = {
    uid = 1000;
    hashedPassword = "$6$KycoTiPm3n.Mayc$7ZDSUvfXEP7zsyDGslx/C5HIbM.fZlfbK0ppsRHSbVNb6O8AqSbF1sjUsSkzEthDneean2fYtEQm.KGZYNbS.1";
    description = "default";
    isNormalUser = true;
    extraGroups = [ "wheel" "wireshark" "docker" "adbusers" ];
  };

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
}

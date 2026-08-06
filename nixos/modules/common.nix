{ pkgs, ... }:

{
  # Boot -------------------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Locale -----------------------------------------------------------------
  time.timeZone = "Europe/Dublin";
  i18n.defaultLocale = "en_IE.UTF-8";

  # SSH --------------------------------------------------------------------
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin        = "no";
      PasswordAuthentication = false;
    };
  };

  # Nix --------------------------------------------------------------------
  nix.settings = {
    experimental-features = "nix-command flakes";
    flake-registry         = "";
  };

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "*-*-* 04:00:00";
    randomizedDelaySec = "1h";
    flake = "github:girodav/nixos-config";
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  # Users ------------------------------------------------------------------
  security.sudo.wheelNeedsPassword = false;

  users.users."girodav" = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFUXy3ekhkpYc5Uum2Q46GdQcMz/NryC0UZ3u6YirZA girodav@Davides-MBP-2.fritz.box"
    ];
  };

  # Packages ---------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    vim
    curl
    htop
    btop
    git
    lsof
    wget
  ];

  programs.nix-ld.enable = true;

  powerManagement.powertop.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";
}

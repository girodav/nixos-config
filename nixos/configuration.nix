# NixOS system configuration entry point.

{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/networking.nix
    ./modules/incus.nix
    ./modules/zfs.nix
  ];

  # Boot -------------------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = [ "fast" "tank" ];

  # Locale -----------------------------------------------------------------
  time.timeZone = "Europe/Dublin";

  i18n.defaultLocale = "en_IE.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "en_IE.UTF-8";
    LC_IDENTIFICATION = "en_IE.UTF-8";
    LC_MEASUREMENT    = "en_IE.UTF-8";
    LC_MONETARY       = "en_IE.UTF-8";
    LC_NAME           = "en_IE.UTF-8";
    LC_NUMERIC        = "en_IE.UTF-8";
    LC_PAPER          = "en_IE.UTF-8";
    LC_TELEPHONE      = "en_IE.UTF-8";
    LC_TIME           = "en_IE.UTF-8";
  };

  services.xserver.xkb = {
    layout  = "us";
    variant = "";
  };

  # SSH --------------------------------------------------------------------
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin        = "no";
      PasswordAuthentication = false;
    };
  };

  # Nix --------------------------------------------------------------------
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      flake-registry         = "";
    };
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "*-*-* 04:00:00";
    randomizedDelaySec = "1h";
    flake = "/home/girodav/nixos-config";
  };

  # Users ------------------------------------------------------------------
  users.users."girodav" = {
    isNormalUser = true;
    description  = "girodav";
    extraGroups  = [ "wheel" "incus-admin" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFUXy3ekhkpYc5Uum2Q46GdQcMz/NryC0UZ3u6YirZA girodav@Davides-MBP-2.fritz.box"
    ];
    packages = with pkgs; [];
  };

  # Packages ---------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    gnumake
  ];

  # Required for VS Code Server remote extension
  programs.nix-ld.enable = true;

  programs.git = {
    enable = true;
    config.user = {
      name  = "Davide Girardi";
      email = "1390902+girodav@users.noreply.github.com";
    };
    config.init.defaultBranch = "main";
  };

  powerManagement.powertop.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";
  system.stateVersion = "26.05";
}

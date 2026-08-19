{ pkgs, ... }:

{
  # Boot -------------------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Locale -----------------------------------------------------------------
  time.timeZone = "Europe/Dublin";
  i18n.defaultLocale = "en_IE.UTF-8";

  # Network ----------------------------------------------------------------
  networking.useNetworkd = true;
  networking.useDHCP = false;
  networking.nftables.enable = true;

  systemd.network.wait-online.anyInterface = true;
  systemd.network.networks."10-lan" = {
    matchConfig.Name = "en*";
    networkConfig.DHCP = "ipv4";
  };

  # SSH --------------------------------------------------------------------
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin          = "no";
      PasswordAuthentication   = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding            = false;
      AllowUsers               = [ "girodav" ];
      MaxAuthTries             = 3;
      LoginGraceTime           = 20;
    };
  };

  # Kernel network hardening -----------------------------------------------
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.rp_filter"              = 1;
    "net.ipv4.conf.default.rp_filter"          = 1;
    "net.ipv4.tcp_syncookies"                  = 1;
    "net.ipv4.conf.all.accept_redirects"       = 0;
    "net.ipv4.conf.default.accept_redirects"   = 0;
    "net.ipv6.conf.all.accept_redirects"       = 0;
    "net.ipv4.conf.all.send_redirects"         = 0;
    "net.ipv4.icmp_echo_ignore_broadcasts"     = 1;
    "kernel.dmesg_restrict"                    = 1;
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
    btop
    git
    lsof
    wget
  ];

}

{ lib, ... }:


{
  imports = [
    ../../modules/common.nix
    ./hardware-configuration.nix
    ./disko.nix
  ];

  networking.hostName = "gondor";

  users.users."girodav".extraGroups = [ "wheel" ];

  # Public VPS — require password for sudo and block SSH brute force
  security.sudo.wheelNeedsPassword = lib.mkForce true;
  services.fail2ban.enable = true;

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

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.grub.enable = true;

  system.stateVersion = "26.05";
}

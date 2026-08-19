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

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.grub.enable = true;

  system.stateVersion = "26.05";
}

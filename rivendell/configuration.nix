{ pkgs, ... }:

{
  networking.hostName = "rivendell";
  networking.hostId = "8f3a2b1c"; # required by ZFS; unique per machine
  time.timeZone = "Europe/Dublin";

  # Generic initrd modules; add more here if the box has an exotic boot controller.
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" ];
  hardware.enableRedistributableFirmware = true;
  nixpkgs.hostPlatform = "x86_64-linux";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ZFS: data pools are imported by hand (`zpool import -f <pool>`) after install.
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  services.zfs.autoScrub.enable = true;

  virtualisation.docker.enable = true;
  programs.git.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Key-only user, so sudo can't prompt for a password.
  security.sudo.wheelNeedsPassword = false;
  users.users.girodav = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFUXy3ekhkpYc5Uum2Q46GdQcMz/NryC0UZ3u6YirZA girodav@Davides-MBP-2.fritz.box"
    ];
  };

  nix.settings.experimental-features = "nix-command flakes";

  system.stateVersion = "26.05";
}

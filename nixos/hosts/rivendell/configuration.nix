{ ... }:

{
  imports = [
    ../../modules/common.nix
    ./hardware-configuration.nix
    ./disko.nix
    ./modules/zfs.nix
    ./modules/containers.nix
    ./modules/beszel.nix
    ./modules/incus.nix
  ];

  networking.hostName = "rivendell";

  # Required for ZFS — must be unique per machine
  networking.hostId = "9c70c878";

  users.users."girodav" = {
    extraGroups    = [ "wheel" "incus-admin" ];
    initialPassword = "changeme";
  };

  powerManagement.powertop.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  system.stateVersion = "26.05";
}

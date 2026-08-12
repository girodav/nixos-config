{ ... }:

{
  imports = [
    ../../modules/common.nix
    ./hardware-configuration.nix
    ./disko.nix
    ./modules/networking.nix
    ./modules/zfs.nix
    ./modules/containers.nix
    ./modules/beszel.nix
    ./modules/incus.nix
  ];

  # Required for ZFS — must be unique per machine
  networking.hostId = "9c70c878";

  users.users."girodav" = {
    extraGroups    = [ "wheel" "docker" "incus-admin" ];
    initialPassword = "changeme";
  };

  system.stateVersion = "26.05";
}

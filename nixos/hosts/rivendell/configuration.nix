{ ... }:

{
  imports = [
    ../../modules/common.nix
    ./hardware-configuration.nix
    ./disko.nix
    ./modules/networking.nix
    ./modules/zfs.nix
    ./modules/containers.nix
  ];

  # Required for ZFS — must be unique per machine
  networking.hostId = "9c70c878";

  users.users."girodav" = {
    extraGroups    = [ "wheel" "docker" ];
    initialPassword = "changeme";
  };

  system.stateVersion = "26.05";
}

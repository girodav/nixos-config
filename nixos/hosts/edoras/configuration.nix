{ pkgs, ... }:

{
  imports = [
    ../../modules/common.nix
    ./hardware-configuration.nix
    ./disko.nix
    ./modules/networking.nix
    ./modules/incus.nix
    ./modules/k3s.nix
  ];

  users.users."girodav".extraGroups = [ "wheel" "incus-admin" ];

  environment.systemPackages = with pkgs; [ gnumake ];

  programs.git = {
    enable = true;
    config.user = {
      name  = "Davide Girardi";
      email = "1390902+girodav@users.noreply.github.com";
    };
    config.init.defaultBranch = "main";
  };

  system.stateVersion = "26.05";
}

{ pkgs, ... }:

{
  imports = [
    ../../modules/common.nix
    ./hardware-configuration.nix
    ./disko.nix
  ];

  networking.hostName = "edoras";

  # Prevents igc (Intel I225/I226) from losing link after switch reboots; ASPM
  # power-gating can leave the NIC unable to recover without a host reboot.
  boot.kernelParams = [ "pcie_aspm.policy=performance" ];

  users.users."girodav".extraGroups = [ "wheel" ];

  services.beszel.agent = {
    enable = true;
    openFirewall = true;
    environment.KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFuvPVzr3DoEiUqGliooaZntx/yvkiLxKfK/jNhegN9O";
  };

  environment.systemPackages = with pkgs; [ gnumake ];

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };

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

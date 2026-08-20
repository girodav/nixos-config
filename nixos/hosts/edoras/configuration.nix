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

  users.users."girodav".extraGroups = [ "wheel" "incus-admin"];

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

  services.k3s.enable = true;

  networking.firewall.allowedTCPPorts = [ 6443 ];

  # Bridge enp1s0 so incus containers on the "lan" profile get real LAN IPs.
  # "05-" beats common.nix "10-lan" (en* → DHCP), so enp1s0 becomes a bridge
  # member rather than a DHCP client. br0 takes the host's LAN IP instead.
  systemd.network.netdevs."20-br0".netdevConfig = { Name = "br0"; Kind = "bridge"; };
  systemd.network.networks."05-br0-member" = { matchConfig.Name = "enp1s0"; networkConfig.Bridge = "br0"; };
  systemd.network.networks."20-br0"         = { matchConfig.Name = "br0";    networkConfig.DHCP = "ipv4"; };

  virtualisation.incus = {
    enable = true;
    preseed = {
      storage_pools = [{ name = "default"; driver = "dir"; }];
      networks = [
        { name = "incusbr0"; type = "bridge"; config = { "ipv4.address" = "10.0.0.1/24"; "ipv4.nat" = "true"; "ipv4.dhcp" = "true"; }; }
      ];
      profiles = [
        {
          name = "default";
          devices = {
            eth0 = { name = "eth0"; network = "incusbr0"; type = "nic"; };
            root = { path = "/"; pool = "default"; size = "35GiB"; type = "disk"; };
          };
        }
        {
          name = "lan";
          devices = {
            eth0 = { name = "eth0"; parent = "br0"; nictype = "bridged"; type = "nic"; };
            root = { path = "/"; pool = "default"; size = "35GiB"; type = "disk"; };
          };
        }
      ];
    };
  };

  powerManagement.powertop.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  system.stateVersion = "26.05";
}

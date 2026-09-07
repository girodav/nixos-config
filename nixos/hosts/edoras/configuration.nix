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

  networking.firewall.trustedInterfaces = [ "incusbr0" ];

  # NAT for incus containers on the default profile (incusbr0 → br0).
  # Managed by NixOS so it survives reboots; incus's own nftables rules get
  # flushed when NixOS reloads its ruleset.
  networking.nat = {
    enable = true;
    internalInterfaces = [ "incusbr0" ];
    externalInterface = "br0";
  };

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
        { name = "incusbr0"; type = "bridge"; config = { "ipv4.address" = "auto"; "ipv4.nat" = "true"; }; }
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

  services.adguardhome = {
    enable = true;
    openFirewall = true;
  };
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  powerManagement.powertop.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  system.stateVersion = "26.05";
}

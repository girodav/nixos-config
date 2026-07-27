{ ... }:

{
  networking.hostName = "rivendell";
  networking.hostId = "cfab6f44"; # Required for ZFS
  networking.networkmanager.enable = false;
  networking.useNetworkd = true;
  networking.useDHCP = false;

  # Host bridge for Incus instances to get DHCP directly from LAN.
  systemd.network = {
    enable = true;
    netdevs."10-br0" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "br0";
        MACAddress = "9c:6b:00:6c:42:ed";
      };
    };
    networks."10-enp3s0" = {
      matchConfig.Name = "enp3s0";
      networkConfig.Bridge = "br0";
      linkConfig.RequiredForOnline = "enslaved";
    };
    networks."20-br0" = {
      matchConfig.Name = "br0";
      networkConfig.DHCP = "ipv4";
    };
  };
  networking.nftables.enable = true; #Incus on NixOS is unsupported using iptables.
  networking.firewall.trustedInterfaces = [ "br0" "incusbr0" ];
}

{ ... }:

{
  # systemd-networkd: only touches interfaces matched below (ignores incus veths).
  # br0 takes over enp3s0's MAC so the router keeps handing out the same DHCP lease.
  networking.useNetworkd = true;
  networking.useDHCP = false;
  systemd.network = {
    netdevs."10-br0".netdevConfig = {
      Kind = "bridge";
      Name = "br0";
      MACAddress = "9c:6b:00:6c:42:ed";
    };
    networks."10-enp3s0" = {
      matchConfig.Name = "enp3s0";
      networkConfig.Bridge = "br0";
    };
    networks."10-br0" = {
      matchConfig.Name = "br0";
      networkConfig.DHCP = "ipv4";
      dhcpV4Config.ClientIdentifier = "mac"; # same client id as a plain NIC
    };
  };
}

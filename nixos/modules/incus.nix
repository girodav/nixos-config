{ ... }:

{
  virtualisation.incus = {
    enable = true;
    ui.enable = true;

    # Preseed applies at daemon start and keeps these entities aligned.
    preseed = {
      config = {
        "core.https_address" = ":8443";
      };

      storage_pools = [
        {
          name = "fast-zfs";
          driver = "zfs";
          config = {
            source = "fast/incus";
          };
        }
      ];

      networks = [
        {
          name = "incusbr0";
          type = "bridge";
          config = {
            "ipv4.address" = "auto";
            "ipv4.nat" = "true";
            "ipv4.dhcp" = "true";
          };
        }
        {
          name = "lan-physical";
          type = "physical";
          config = {
            parent = "br0";
          };
        }
      ];

      profiles = [
        {
          name = "default";
          description = "Standard NAT networking on incusbr0 with fast ZFS root";
          devices = {
            eth0 = {
              name = "eth0";
              type = "nic";
              network = "incusbr0";
            };
            root = {
              path = "/";
              type = "disk";
              pool = "fast-zfs";
            };
          };
        }
        {
          name = "lan-dhcp";
          description = "LAN bridge profile for router DHCP via br0";
          devices = {
            eth0 = {
              name = "eth0";
              type = "nic";
              network = "lan-physical";
            };
            root = {
              path = "/";
              type = "disk";
              pool = "fast-zfs";
            };
          };
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 8443 ];
}

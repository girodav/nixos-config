{ ... }:

{
  virtualisation.incus = {
    enable = true;
    ui.enable = true;

    preseed = {
      config = {
        "core.https_address" = ":8443";
      };

      storage_pools = [
        {
          name = "default";
          driver = "dir";
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
      ];

      profiles = [
        {
          name = "default";
          devices = {
            eth0 = {
              name = "eth0";
              type = "nic";
              network = "incusbr0";
            };
            root = {
              path = "/";
              type = "disk";
              pool = "default";
            };
          };
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 8443 ];
}

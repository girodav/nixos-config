{ ... }:

{
  # Incus on ZFS dataset fast/incus (create it first: `zfs create fast/incus`).
  virtualisation.incus = {
    enable = true;
    ui.enable = true; # https://rivendell:8443
    preseed = {
      config."core.https_address" = ":8443";
      networks = [{
        name = "incusbr0";
        type = "bridge";
        config = { "ipv4.address" = "auto"; "ipv6.address" = "none"; };
      }];
      storage_pools = [{
        name = "default";
        driver = "zfs";
        config.source = "fast/incus";
      }];
      profiles = [{
        name = "default";
        devices = {
          eth0 = { name = "eth0"; network = "incusbr0"; type = "nic"; };
          root = { path = "/"; pool = "default"; type = "disk"; };
        };
      }
      {
        # LAN DHCP via host bridge br0 (see networking.nix).
        name = "lan";
        devices.eth0 = { name = "eth0"; nictype = "bridged"; parent = "br0"; type = "nic"; };
      }];
    };
  };
  users.users.girodav.extraGroups = [ "incus-admin" ];

  networking.nftables.enable = true; # required by incus
  networking.firewall.trustedInterfaces = [ "incusbr0" ];
  networking.firewall.allowedTCPPorts = [ 8443 ];
}

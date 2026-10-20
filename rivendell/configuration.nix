{ pkgs, ... }:

{
  networking.hostName = "rivendell";
  networking.hostId = "8f3a2b1c"; # required by ZFS; unique per machine
  time.timeZone = "Europe/Dublin";

  # Generic initrd modules; add more here if the box has an exotic boot controller.
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" ];
  hardware.enableRedistributableFirmware = true;
  nixpkgs.hostPlatform = "x86_64-linux";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ZFS: data pools auto-import at boot. First time on a fresh install, run
  # `zpool import -f <pool>` once so the hostid matches.
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "fast" "tank" ];
  boot.zfs.forceImportRoot = false;
  services.zfs.autoScrub.enable = true;

  virtualisation.docker.enable = true;
  programs.git.enable = true;

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
        # LAN DHCP via host bridge br0 (instances get addresses from the router).
        name = "lan";
        devices.eth0 = { name = "eth0"; nictype = "bridged"; parent = "br0"; type = "nic"; };
      }];
    };
  };
  # systemd-networkd: only touches interfaces matched below (ignores docker/incus veths).
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
  networking.nftables.enable = true; # required by incus
  networking.firewall.trustedInterfaces = [ "incusbr0" ];
  networking.firewall.allowedTCPPorts = [ 8443 ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Key-only user, so sudo can't prompt for a password.
  security.sudo.wheelNeedsPassword = false;
  users.users.girodav = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "incus-admin" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFUXy3ekhkpYc5Uum2Q46GdQcMz/NryC0UZ3u6YirZA girodav@Davides-MBP-2.fritz.box"
    ];
  };

  nix.settings.experimental-features = "nix-command flakes";

  system.stateVersion = "26.05";
}

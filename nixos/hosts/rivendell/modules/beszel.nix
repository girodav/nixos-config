{ ... }:

{
  services.beszel.hub = {
    enable = true;
    host = "0.0.0.0";
  };

  services.beszel.agent = {
    enable = true;
    openFirewall = true;
    environment.KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFuvPVzr3DoEiUqGliooaZntx/yvkiLxKfK/jNhegN9O";
  };

  services.beszel.agent.smartmon = {
    enable = true;
    deviceAllow = [
      "/dev/nvme0"
      "/dev/nvme1"
      "/dev/nvme2"
      "/dev/sda"
      "/dev/sdb"
    ];
  };

  systemd.services.beszel-agent.environment.DOCKER_HOST = "unix:///run/podman/podman.sock";
  systemd.services.beszel-agent.serviceConfig.SupplementaryGroups = [ "podman" ];

  networking.firewall.allowedTCPPorts = [ 8090 ];
}

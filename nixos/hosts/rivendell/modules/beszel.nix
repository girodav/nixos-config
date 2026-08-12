{ ... }:

{
  # Beszel hub — web dashboard on port 8090
  services.beszel.hub = {
    enable = true;
    host = "0.0.0.0";
    port = 8090;
  };

  # Override agent to add SMART disk monitoring for all drives
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

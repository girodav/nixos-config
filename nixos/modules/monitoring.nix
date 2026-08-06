{ pkgs, lib, ... }:

{
  # Beszel lightweight monitoring agent.
  #
  # KEY bootstrap:
  #   1. Start the hub on rivendell (first deploy)
  #   2. In the hub UI: Settings → Server → Copy Public Key
  #   3. Set KEY below and redeploy all hosts
  services.beszel.agent = {
    enable = true;
    openFirewall = true;
    environment.KEY = ""; # TODO: set after first hub start
  };

  # Guard against empty KEY so activation doesn't fail before the hub is set up.
  # Once KEY is populated above the real agent binary runs instead.
  systemd.services.beszel-agent.serviceConfig.ExecStart = lib.mkForce "${
    pkgs.writeShellScript "beszel-agent-start" ''
      if [ -z "$KEY" ]; then
        echo "beszel-agent: KEY not set — populate services.beszel.agent.environment.KEY and redeploy" >&2
        exit 0
      fi
      exec ${pkgs.beszel}/bin/beszel-agent
    ''
  }";
}

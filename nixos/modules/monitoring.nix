{ ... }:

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
}

{ ... }:

{
  # Weekly pull of main from GitHub (lock is bumped by PRs); no auto reboot.
  system.autoUpgrade = {
    enable = true;
    flake = "github:girodav/nixos-config#rivendell";
    upgrade = false; # flake: honour the repo's flake.lock, no --upgrade
    dates = "Sun 04:00";
    randomizedDelaySec = "30min";
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;
  boot.loader.systemd-boot.configurationLimit = 10; # keep the 1G ESP from filling up
}

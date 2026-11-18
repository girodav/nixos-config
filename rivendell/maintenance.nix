{ config, lib, pkgs, ... }:

{
  # Daily pull of main from GitHub (lock is bumped by PRs); no auto reboot.
  system.autoUpgrade = {
    enable = true;
    flake = "github:girodav/nixos-config#rivendell";
    upgrade = false; # flake: honour the repo's flake.lock, no --upgrade
    dates = "04:00";
    randomizedDelaySec = "30min";
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;
  boot.loader.systemd-boot.configurationLimit = 10; # keep the 1G ESP from filling up

  # Health gate: after the upgrade activates, check the host is still sane. If not, switch back to the
  # previous system and pause upgrades until /var/lib/nixos-upgrade-paused is removed.
  # ponytail: only catches problems visible ~60s after activation, and a failed activation itself is not
  # rolled back (the unit just fails); add boot counting if allowReboot is ever enabled.
  systemd.services.nixos-upgrade = {
    unitConfig.ConditionPathExists = "!/var/lib/nixos-upgrade-paused";
    path = [ pkgs.systemd pkgs.iproute2 pkgs.iputils pkgs.gawk config.boot.zfs.package ];
    script = lib.mkMerge [
      (lib.mkBefore ''
        prev=$(readlink -f /run/current-system)
        failed() { systemctl --failed --plain --no-legend | awk '{print $1}' | sort; }
        before=$(failed)
        pools=$(zpool status -x)
      '')
      (lib.mkAfter ''
        # Only gate when the upgrade actually changed the system, and only on regressions.
        if [ "$(readlink -f /run/current-system)" != "$prev" ]; then
          sleep 60
          new=$(comm -13 <(echo "$before") <(failed))
          gw=$(ip -4 route show default | awk '{print $3; exit}')
          if [ -n "$new" ] || ! ping -c3 -W3 "$gw" >/dev/null \
            || { [ "$pools" = "all pools are healthy" ] && [ "$(zpool status -x)" != "$pools" ]; }; then
            echo "health check failed (new failed units: $new); rolling back to $prev"
            nix-env -p /nix/var/nix/profiles/system --set "$prev"
            "$prev/bin/switch-to-configuration" switch
            touch /var/lib/nixos-upgrade-paused
            exit 1
          fi
        fi
      '')
    ];
  };
}

{ pkgs, ... }:

{
  # ZFS: data pools auto-import at boot. First time on a fresh install, run
  # `zpool import -f <pool>` once so the hostid matches.
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "fast" "tank" ];
  boot.zfs.forceImportRoot = false;
  services.zfs.autoScrub.enable = true;

  # Snapshots: declared here, no per-dataset ZFS properties needed.
  services.sanoid = {
    enable = true;
    templates.default = {
      hourly = 24;
      daily = 7;
      weekly = 4;
      monthly = 12;
      autosnap = true;
      autoprune = true;
    };
    datasets = {
      "fast" = { useTemplate = [ "default" ]; recursive = true; };
      "fast/incus" = { autosnap = false; autoprune = false; recursive = true; }; # Incus manages its own snapshots
      "tank/data" = { useTemplate = [ "default" ]; recursive = true; };
    };
  };

  # No mail transport yet: failures land in `journalctl -u smartd`.
  services.smartd.enable = true;
  environment.systemPackages = [ pkgs.smartmontools ]; # smartctl, used by `just status`
}

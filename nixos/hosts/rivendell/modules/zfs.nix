{ ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  # Import existing pools — do NOT recreate them; data is preserved.
  boot.zfs.extraPools = [ "fast" "tank" ];

  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;    # for the NVMe fast pool
}

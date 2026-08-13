{ ... }:

let
  ntfyTopic = "alerts";
  ntfyUrl   = "http://localhost:2586";
in
{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  # Import existing pools — do NOT recreate them; data is preserved.
  boot.zfs.extraPools = [ "fast" "tank" ];

  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;    # for the NVMe fast pool

  services.zfs.zed.settings = {
    ZED_ENABLE_SYSLOG        = true;
    ZED_NOTIFY_INTERVAL_SECS = 3600;
    ZED_NOTIFY_VERBOSE       = 0;
    ZED_NTFY_TOPIC           = ntfyTopic;
    ZED_NTFY_URL             = ntfyUrl;
  };

  services.sanoid = {
    enable = true;
    datasets = {
      "fast/apps" = {
        hourly  = 24;
        daily   = 7;
        weekly  = 4;
        monthly = 0;
        autosnap  = true;
        autoprune = true;
      };
      "tank/data" = {
        hourly  = 0;
        daily   = 7;
        weekly  = 4;
        monthly = 0;
        autosnap  = true;
        autoprune = true;
      };
    };
  };

  services.syncoid = {
    enable = true;
    commands."fast/apps" = {
      target = "tank/apps";
    };
  };
}

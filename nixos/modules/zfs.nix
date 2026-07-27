{ pkgs, config, lib, ... }:

let
  # Customize this topic name — you'll subscribe to it on your devices.
  # Use "https://ntfy.sh/<topic>" or self-host your own ntfy server.
  ntfyTopic = "rivendell_alerts";
  ntfyUrl = "https://ntfy.sh/${ntfyTopic}";
in
{
  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = false;

    zed = {
      settings = {
        ZED_ENABLE_SYSLOG = true;
        ZED_NOTIFY_INTERVAL_SECS = 3600;
        ZED_SYSLOG_PRIORITY = "daemon.notice";
        ZED_SYSLOG_TAG = "zed";
        ZED_NTFY_TOPIC= "${ntfyTopic}";
        ZED_NTFY_URL= "${ntfyUrl}";
        ZED_NOTIFY_VERBOSE = false; # disable after testing
      };
    };
  };
}
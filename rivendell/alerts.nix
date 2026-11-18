# Discord alerts. The webhook URL is the secret: create /etc/discord-webhook by hand (root, 0400), see README.
{ config, lib, pkgs, ... }:

let
  # Reads a mail-style message on stdin ("-s subject" optional) and posts it to Discord.
  # Plugs into smartd and ZED, which think they are talking to a mailer. No webhook file: silently does nothing.
  alert = pkgs.writeShellScriptBin "alert-discord" ''
    subject=""
    while getopts "s:i:" o; do [ "$o" = s ] && subject=$OPTARG; done
    body=$(cat)
    url=$(cat /etc/discord-webhook 2>/dev/null) || exit 0
    msg="**${config.networking.hostName}** $subject"$'\n'"$body"
    ${pkgs.curl}/bin/curl -fsS --max-time 10 -H 'Content-Type: application/json' \
      -d "$(${pkgs.jq}/bin/jq -n --arg c "$msg" '{content: $c[0:1900]}')" "$url" >/dev/null || true
  '';
  alertBin = "${alert}/bin/alert-discord";

  # Failed-unit alert: includes the last journal lines of the unit.
  alertUnit = pkgs.writeShellScript "alert-unit" ''
    ${pkgs.systemd}/bin/journalctl -u "$1" -n 8 --no-pager -o cat | ${alertBin} -s "unit $1 failed"
  '';
in
{
  environment.systemPackages = [ alert ];

  systemd.services = {
    "alert-failure@".serviceConfig = {
      Type = "oneshot";
      ExecStart = "${alertUnit} %i";
    };
  } // lib.genAttrs [ "nixos-upgrade" "sanoid" "zfs-scrub" "smartd" ] (_: {
    onFailure = [ "alert-failure@%n.service" ];
  });

  # Drive problems.
  services.smartd.notifications.mail = {
    enable = true;
    recipient = "root"; # ignored by alert-discord
    mailer = alertBin;
  };

  # ZFS events (degraded pool, scrub finished with errors, ...): the stock zedlets mail through this.
  services.zfs.zed.settings = {
    ZED_EMAIL_ADDR = [ "root" ];
    ZED_EMAIL_PROG = alertBin;
  };
}

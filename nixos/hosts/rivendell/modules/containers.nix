{ ... }:

let
  appdata = "/mnt/fast/apps";
  downloads = "/mnt/fast/downloads";
  data = "/mnt/tank/data";
  tz = "Europe/Dublin";
  user = "1000:1000";
  svc = { serviceConfig.Restart = "on-failure"; };
in
{
  virtualisation.podman.enable = true;

  networking.firewall.trustedInterfaces = [ "podman1" ];

  virtualisation.quadlet = {

    networks.media.networkConfig.dns = [ "true" ];

    containers.jellyfin = svc // {
      containerConfig = {
        image = "ghcr.io/jellyfin/jellyfin:10.11@sha256:45f648c382a0c8b552582fcea40e95cb17c5d475473a891cba0eb7523fb92112";
        user = user;
        publishPorts = [ "8096:8096" "8920:8920" "1900:1900/udp" "7359:7359/udp" ];
        volumes = [
          "${appdata}/jellyfin:/config"
          "${data}/media:/data/media"
        ];
        environments = {
          TZ = tz;
          JELLYFIN_DATA_DIR = "/config/data";
          JELLYFIN_CONFIG_DIR = "/config";
          JELLYFIN_LOG_DIR = "/config/log";
          JELLYFIN_CACHE_DIR = "/config/cache";
        };
        networks = [ "media" ];
        devices = [ "/dev/dri:/dev/dri" ];
        addGroups = [ "44" "107" ];
      };
    };

    containers.seerr = svc // {
      containerConfig = {
        image = "ghcr.io/seerr-team/seerr:latest@sha256:f4768de5f616248d723e05891f3345a1402123775d03bf0890dbfedc0831bda1";
        user = user;
        publishPorts = [ "5055:5055" ];
        volumes = [ "${appdata}/seerr:/app/config" ];
        environments.TZ = tz;
        networks = [ "media" ];
      };
    };

    containers.profilarr = svc // {
      containerConfig = {
        image = "ghcr.io/santiagosayshey/profilarr:latest@sha256:5c7203b8af08ee9105e60eb80cc2d558bb25dc5fc82e5aa00db4577c54c70d6a";
        user = user;
        publishPorts = [ "6868:6868" ];
        volumes = [ "${appdata}/profilarr:/config" ];
        environments.TZ = tz;
        networks = [ "media" ];
      };
    };

    containers.prowlarr = svc // {
      containerConfig = {
        image = "ghcr.io/home-operations/prowlarr:rolling@sha256:ce5d6bdd5be6529f503df77aa9d2bad20239031d7c660406e8fb1c6d621dd020";
        user = user;
        publishPorts = [ "9696:9696" ];
        volumes = [ "${appdata}/prowlarr:/config" ];
        environments.TZ = tz;
        networks = [ "media" ];
      };
    };

    containers.radarr = svc // {
      containerConfig = {
        image = "ghcr.io/home-operations/radarr:rolling@sha256:260469d707617f4b5be1cd11a40be7e4889c63c5e7cdbc6a429626dc05863b6b";
        user = user;
        publishPorts = [ "7878:7878" ];
        volumes = [
          "${appdata}/radarr:/config"
          "${data}:/data"
          "${downloads}:/data/downloads"
        ];
        environments.TZ = tz;
        networks = [ "media" ];
      };
    };

    containers.sonarr = svc // {
      containerConfig = {
        image = "ghcr.io/home-operations/sonarr:rolling@sha256:2fef93accb445aeb1773e454825ac903f7d66d9addfe045d56fff69ba8181c82";
        user = user;
        publishPorts = [ "8989:8989" ];
        volumes = [
          "${appdata}/sonarr:/config"
          "${data}:/data"
          "${downloads}:/data/downloads"
        ];
        environments.TZ = tz;
        networks = [ "media" ];
      };
    };

    containers.qui = svc // {
      containerConfig = {
        image = "ghcr.io/autobrr/qui:latest@sha256:9969375e7375194b89eebc490bd16586b6ff4ff403042f6c4f0585eb0e775eaf";
        user = user;
        publishPorts = [ "7476:7476" ];
        volumes = [
          "${appdata}/qui:/config"
          "${data}:/data"
          "${downloads}:/data/downloads"
        ];
        environments.TZ = tz;
        networks = [ "media" ];
      };
    };

    containers.qbittorrent = svc // {
      containerConfig = {
        image = "ghcr.io/hotio/qbittorrent:release@sha256:06388a2b7a2cb4450ffa94cc7a8714715f676340d1181673386b01aed0210944";
        publishPorts = [ "8080:8080" ];
        volumes = [
          "${appdata}/qbittorrent:/config"
          "${downloads}:/data/downloads"
          "${data}/torrents:/data/torrents"
        ];
        environments = {
          TZ = tz;
          PUID = "1000";
          PGID = "1000";
          UMASK = "002";
          VPN_ENABLED = "true";
          VPN_CONF = "wg0";
          VPN_PROVIDER = "protonvpn";
          VPN_LAN_NETWORK = "192.168.1.0/24";
          VPN_LAN_LEAK_ENABLED = "false";
          PRIVOXY_ENABLED = "false";
        };
        networks = [ "media" ];
        addCapabilities = [ "NET_ADMIN" ];
        devices = [ "/dev/net/tun:/dev/net/tun" ];
        sysctl = {
          "net.ipv4.conf.all.src_valid_mark" = "1";
          "net.ipv6.conf.all.disable_ipv6" = "1";
        };
      };
    };

  };

  networking.firewall.allowedTCPPorts = [ 8096 8920 5055 6868 9696 7878 8989 7476 8080 ];
  networking.firewall.allowedUDPPorts = [ 1900 7359 ];
}

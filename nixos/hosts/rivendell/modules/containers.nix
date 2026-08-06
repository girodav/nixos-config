{ ... }:

let
  appdata = "/mnt/fast/apps";
  downloads = "/mnt/fast/downloads";
  data = "/mnt/tank/data";
  tz = "Europe/Dublin";
  user = "1000:1000";
in
{
  virtualisation.docker.enable = true;

  virtualisation.oci-containers = {
    backend = "docker";

    containers = {

      dozzle = {
        image = "ghcr.io/amir20/dozzle:latest@sha256:1c1060cfb5402093c4e0f03f3534d7deaffeb0a6f6dd034e7c5f244603f35fb3";
        ports = [ "8888:8080" ];
        volumes = [ "/var/run/docker.sock:/var/run/docker.sock:ro" ];
      };

      jellyfin = {
        image = "ghcr.io/jellyfin/jellyfin:10.11@sha256:45f648c382a0c8b552582fcea40e95cb17c5d475473a891cba0eb7523fb92112";
        user = user;
        ports = [
          "8096:8096"
          "8920:8920"
          "1900:1900/udp"
          "7359:7359/udp"
        ];
        volumes = [
          "${appdata}/jellyfin:/config"
          "${data}/media:/data/media"
        ];
        environment = {
          TZ = tz;
          JELLYFIN_DATA_DIR = "/config/data";
          JELLYFIN_CONFIG_DIR = "/config";
          JELLYFIN_LOG_DIR = "/config/log";
          JELLYFIN_CACHE_DIR = "/config/cache";
        };
        extraOptions = [
          "--device=/dev/dri:/dev/dri"
          "--group-add=44"   # video
          "--group-add=107"  # render
        ];
      };

      seerr = {
        image = "ghcr.io/seerr-team/seerr:latest@sha256:f4768de5f616248d723e05891f3345a1402123775d03bf0890dbfedc0831bda1";
        user = user;
        ports = [ "5055:5055" ];
        volumes = [ "${appdata}/seerr:/app/config" ];
        environment.TZ = tz;
      };

      profilarr = {
        image = "ghcr.io/santiagosayshey/profilarr:latest@sha256:5c7203b8af08ee9105e60eb80cc2d558bb25dc5fc82e5aa00db4577c54c70d6a";
        user = user;
        ports = [ "6868:6868" ];
        volumes = [ "${appdata}/profilarr:/config" ];
        environment.TZ = tz;
      };

      prowlarr = {
        image = "ghcr.io/home-operations/prowlarr:rolling@sha256:ce5d6bdd5be6529f503df77aa9d2bad20239031d7c660406e8fb1c6d621dd020";
        user = user;
        ports = [ "9696:9696" ];
        volumes = [ "${appdata}/prowlarr:/config" ];
        environment.TZ = tz;
      };

      radarr = {
        image = "ghcr.io/home-operations/radarr:rolling@sha256:260469d707617f4b5be1cd11a40be7e4889c63c5e7cdbc6a429626dc05863b6b";
        user = user;
        ports = [ "7878:7878" ];
        volumes = [
          "${appdata}/radarr:/config"
          "${data}:/data"
          "${downloads}:/data/downloads"
        ];
        environment.TZ = tz;
      };

      sonarr = {
        image = "ghcr.io/home-operations/sonarr:rolling@sha256:01db3e6a923f6e0f3a217baa94b4660cf2f9b45d4166b2fc8c20c67c5221cb78";
        user = user;
        ports = [ "8989:8989" ];
        volumes = [
          "${appdata}/sonarr:/config"
          "${data}:/data"
          "${downloads}:/data/downloads"
        ];
        environment.TZ = tz;
      };

      qui = {
        image = "ghcr.io/autobrr/qui:latest@sha256:3285c52f0258645d1d5a1684e25596c7355ef525363f0f9464d1c7b2cad14be8";
        user = user;
        ports = [ "7476:7476" ];
        volumes = [
          "${appdata}/qui:/config"
          "${downloads}:/data/downloads"
        ];
        environment.TZ = tz;
      };

      qbittorrent = {
        image = "ghcr.io/hotio/qbittorrent:release@sha256:fbff489ebe410ad4be3e86294298f40ccefb2cb410ccf2847f7c5819171dfb56";
        ports = [ "8080:8080" ];
        volumes = [
          "${appdata}/qbittorrent:/config"
          "${downloads}:/data/downloads"
          "${data}/torrents:/data/torrents"
        ];
        environment = {
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
        extraOptions = [
          "--cap-add=NET_ADMIN"
          "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
          "--sysctl=net.ipv6.conf.all.disable_ipv6=1"
        ];
      };

    };
  };

  # Ports exposed by containers
  networking.firewall.allowedTCPPorts = [ 8888 8096 8920 5055 6868 9696 7878 8989 7476 8080 ];
  networking.firewall.allowedUDPPorts = [ 1900 7359 ];
}

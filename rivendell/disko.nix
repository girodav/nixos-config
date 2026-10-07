{ ... }:

{
  # Boot disk only. Data disks stay untouched so existing pools survive.
  disko.devices.disk.boot = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-WD_BLACK_SN7100_500GB_2448PF401348";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}

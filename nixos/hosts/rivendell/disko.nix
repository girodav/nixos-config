{ ... }:

# Only partitions the root NVMe — ZFS pools (fast, tank) are preserved as-is.
{
  disko.devices = {
    disk.root = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-WD_BLACK_SN7100_500GB_2448PF401348";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "fmask=0077" "dmask=0077" ];
            };
          };
          swap = {
            size = "8G";
            content = {
              type = "swap";
              discardPolicy = "both";
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
  };
}

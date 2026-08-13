{ modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_blk" "ahci" "xhci_pci" ];

  nixpkgs.hostPlatform = "x86_64-linux";
}

# NixOS config

NixOS config for `rivendell`, my all-in-one NAS, container and experiment home server.

## Install (kexec via nixos-anywhere)

1. Check the boot disk in `rivendell/disko.nix`. **This wipes that disk only.**
2. Boot any Linux with root SSH, then:

   ```bash
   just install root@<ip>
   ```

3. After first boot, import the existing pools once so the hostid matches: `sudo zpool import -f fast` and `sudo zpool import -f tank`.
4. Create the Incus dataset if it doesn't exist: `sudo zfs create fast/incus`.

## Day to day

Run `just` to list the commands (`dry`, `test`, `switch`, `status`).

Roll back from the boot menu, with `sudo nixos-rebuild switch --rollback`, or by reverting the commit on `main`.

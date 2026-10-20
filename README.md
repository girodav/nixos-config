# NixOS config

NixOS config for `rivendell`, my all-in-one NAS, container and experiment home server.

- **Storage:** ZFS pools `fast` (NVMe mirror) and `tank`, auto-imported at boot; snapshots via sanoid.
- **Workloads:** Docker, and Incus (storage on `fast/incus`, web UI on `:8443`, LAN instances via the `lan` profile on `br0`).
- **Updates:** weekly `system.autoUpgrade` from this repo's `main` (no automatic reboot). A weekly PR bumps `flake.lock`, and CI builds the system before merge.

## Install (kexec via nixos-anywhere)

1. Check the boot disk in `rivendell/disko.nix`. **This wipes that disk only.**
2. Boot any Linux with root SSH, then:

   ```bash
   just install root@<ip>
   ```

3. After first boot, import the existing pools once so the hostid matches: `sudo zpool import -f fast` and `sudo zpool import -f tank`.
4. Create the Incus dataset if it doesn't exist: `sudo zfs create fast/incus`.

## Day to day

| Command       | What it does                                                   |
| ------------- | -------------------------------------------------------------- |
| `just dry`    | Dry build, to catch errors                                     |
| `just test`   | Activate on the host without making it the boot default        |
| `just switch` | Build and activate on the host                                 |
| `just status` | Pool health, failed units, last auto-upgrade, drive SMART data |

Roll back from the boot menu, with `sudo nixos-rebuild switch --rollback`, or by reverting the commit on `main`.

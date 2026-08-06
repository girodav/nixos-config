# NixOS config

NixOS configurations for my home machines.

| Host | Hardware | Role |
|---|---|---|
| **edoras** | Intel N100, 8 GB RAM, 128 GB NVMe | Dev machine, Incus containers, k3s |
| **rivendell** | 500 GB NVMe root, 2× 2 TB NVMe (fast), 2× 20 TB HDD (tank) | Home server, media stack |

## Quick start

```bash
just dry                                  # dry-build edoras (default host)
just switch                               # deploy to edoras
just host=rivendell switch                # deploy to rivendell
just update                               # update flake inputs
just upgrade                              # update inputs + switch
```

## Fresh install via nixos-anywhere

nixos-anywhere installs NixOS over SSH, partitioning the disk according to the
host's `disko.nix`. **This wipes the root disk.**

1. Boot the target from a NixOS minimal ISO
2. On the console set a password:
   ```bash
   passwd nixos
   ```
3. From this machine:
   ```bash
   just host=<hostname> install nixos@<ip>
   ```

nixos-anywhere partitions the disk and installs the configuration. The machine
reboots into NixOS when done.

> **rivendell only:** ZFS pools (`fast`, `tank`) are on separate disks and are
> preserved. disko only touches the root NVMe.

## Structure

```
flake.nix                        # Flake entrypoint (edoras, rivendell)
justfile                         # Common tasks (deploy, install, update, gc, …)
nixos/
  modules/
    common.nix                   # Shared: boot, locale, SSH, Nix, users, packages
  hosts/
    edoras/
      configuration.nix
      hardware-configuration.nix
      disko.nix                  # 512 MB EFI + 8 GB swap + ext4 root
      modules/
        networking.nix
        incus.nix                # Incus containers + HTTPS API
        k3s.nix                  # Single-node k3s cluster
    rivendell/
      configuration.nix
      hardware-configuration.nix
      disko.nix                  # 512 MB EFI + 8 GB swap + ext4 root (root NVMe only)
      modules/
        networking.nix
        zfs.nix                  # ZFS pool imports (fast, tank) + scrub
        containers.nix           # Media stack as oci-containers
```

## Automation

- **Auto-upgrade** — each host upgrades itself nightly at 04:00 from `github:girodav/nixos-config`
- **Flake updates** — Renovate opens a weekly PR to update `flake.lock`
- **Container image updates** — Renovate tracks image digests in `.nix` files and opens PRs when new versions are available

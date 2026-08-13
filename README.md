# NixOS config

NixOS configurations for my home machines and VPS.

| Host | Where | Purpose |
|---|---|---|
| **edoras** | local | dev/test machine |
| **rivendell** | local | home server — media, storage, containers |
| **gondor** | VPS | general purpose |

## Quick start

```bash
just dry                                  # dry-build edoras (default host)
just switch                               # deploy to edoras
just host=rivendell switch                # deploy to rivendell
just update                               # update flake inputs
```

## Fresh install via nixos-anywhere

nixos-anywhere installs NixOS over SSH using kexec — no ISO needed. **This wipes the root disk.**

```bash
just host=<hostname> install root@<ip>
```

nixos-anywhere kexecs into a NixOS environment, partitions the disk via `disko.nix`, installs, and reboots.

> **rivendell only:** ZFS pools (`fast`, `tank`) are on separate disks and are preserved. disko only touches the root NVMe.

## Structure

```
flake.nix                        # Flake entrypoint
justfile                         # Common tasks (deploy, install, update, gc, …)
nixos/
  modules/
    common.nix                   # Shared: boot, locale, SSH, Nix, users, packages
  hosts/
    edoras/
      configuration.nix
      hardware-configuration.nix
      disko.nix                  # 512 MB EFI + 8 GB swap + ext4 root
    rivendell/
      configuration.nix
      hardware-configuration.nix
      disko.nix                  # 512 MB EFI + 8 GB swap + ext4 root (root NVMe only)
      modules/
        zfs.nix                  # ZFS pool imports, scrub, sanoid snapshots, syncoid replication
        containers.nix           # Media stack as Podman Quadlet containers
        beszel.nix               # Beszel hub + agent with SMART monitoring
        incus.nix                # Incus containers + HTTPS API
    gondor/
      configuration.nix
      hardware-configuration.nix
      disko.nix                  # 1 MB BIOS boot + 1 GB swap + ext4 root
```

## Monitoring

[Beszel](https://beszel.dev) — hub on rivendell (port 8090), agent on edoras and rivendell.

Covers system metrics (CPU, memory, disk, network), container stats, and SMART disk health.

### Agent key

The agent `KEY` in each host's config must match the hub's SSH public key:

1. Open `http://rivendell:8090` and complete hub setup
2. **Settings → Server → Copy Public Key**
3. Update `KEY` in `edoras/configuration.nix` and `rivendell/modules/beszel.nix`
4. Redeploy: `just switch && just host=rivendell switch`

## ZFS (rivendell)

- **Snapshots** — sanoid: `fast/apps` (24h/7d/4w), `tank/data` (7d/4w)
- **Replication** — syncoid: `fast/apps → tank/apps` daily
- **Scrub** — automatic via `services.zfs.autoScrub`
- **Events** — ZED logs to syslog

## Automation

- **Auto-upgrade** — each host upgrades itself nightly at 04:00 from `github:girodav/nixos-config`
- **Flake updates** — Renovate opens PRs to update `flake.lock`
- **Container image updates** — Renovate tracks image digests in `.nix` files and opens PRs when new versions are available

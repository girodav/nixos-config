# NixOS config

NixOS configurations for my home machines.

| Host | Hardware | Role |
|---|---|---|
| **edoras** | Intel N100, 8 GB RAM, 128 GB NVMe | Dev machine |
| **rivendell** | 500 GB NVMe root, 2× 2 TB NVMe (fast), 2× 20 TB HDD (tank) | Home server, media stack, Incus containers |

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
    monitoring.nix               # Shared: node_exporter (all hosts)
  hosts/
    edoras/
      configuration.nix
      hardware-configuration.nix
      disko.nix                  # 512 MB EFI + 8 GB swap + ext4 root
      modules/
        networking.nix
    rivendell/
      configuration.nix
      hardware-configuration.nix
      disko.nix                  # 512 MB EFI + 8 GB swap + ext4 root (root NVMe only)
      modules/
        networking.nix
        zfs.nix                  # ZFS pool imports (fast, tank) + scrub + ZED ntfy alerts
        containers.nix           # Media stack as Podman Quadlet containers
        incus.nix                # Incus containers + HTTPS API
```

## Monitoring

[Beszel](https://beszel.dev) — hub on edoras (port 8090), lightweight agent on every host.

Covers system metrics (CPU, memory, disk, network), container stats, and SMART disk health.

### Agent bootstrap

On first deploy the agent `KEY` is empty, so no hub can connect yet. After deploying:

1. Open `http://rivendell:8090` and complete hub setup
2. **Settings → Server → Copy Public Key**
3. Paste the key into `nixos/modules/monitoring.nix`:
   ```nix
   environment.KEY = "ssh-ed25519 AAAA...";
   ```
4. Redeploy all hosts: `just switch && just host=rivendell switch`

### ZFS alerting

ZFS pool/scrub events are sent to ntfy topic **`rivendell_alerts`** via ZED (configured in `zfs.nix`). Configure ntfy alerts for SMART and system metrics in the Beszel hub UI.

## Automation

- **Auto-upgrade** — each host upgrades itself nightly at 04:00 from `github:girodav/nixos-config`
- **Flake updates** — Renovate opens a weekly PR to update `flake.lock`
- **Container image updates** — Renovate tracks image digests in `.nix` files and opens PRs when new versions are available

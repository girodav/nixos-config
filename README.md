# NixOS config

NixOS configurations for my home machines and VPS.

| Host | Where | Purpose |
|---|---|---|
| **edoras** | local | dev/test machine |
| **gondor** | VPS | general purpose |

## Quick start

```bash
just dry                                  # dry-build edoras (default host)
just switch                               # deploy to edoras
just update                               # update flake inputs
```

## Fresh install via nixos-anywhere

nixos-anywhere installs NixOS over SSH using kexec — no ISO needed. **This wipes the root disk.**

```bash
just host=<hostname> install root@<ip>
```

nixos-anywhere kexecs into a NixOS environment, partitions the disk via `disko.nix`, installs, and reboots.

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
    gondor/
      configuration.nix
      hardware-configuration.nix
      disko.nix                  # 1 MB BIOS boot + 1 GB swap + ext4 root
```

## Automation

- **Auto-upgrade** — each host upgrades itself nightly at 04:00 from `github:girodav/nixos-config`
- **Flake updates** — Renovate opens PRs to update `flake.lock`
- **Container image updates** — Renovate tracks image digests in `.nix` files and opens PRs when new versions are available

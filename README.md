# NixOS — rivendell

NixOS configuration for my home server **rivendell**.

## Quick start

```bash
make        # dry-build (check for errors)
make switch # build and activate
make update # update flake inputs
make upgrade # update + switch
```

## Structure

```
flake.nix                  # Flake entrypoint
nixos/
  configuration.nix         # Host config (boot, locale, users, packages, etc.)
  hardware-configuration.nix # Auto-generated hardware config
  modules/
    incus.nix               # Incus (containers/VMs) — storage pools, networks, profiles
    networking.nix          # Bridged networking via systemd-networkd
    zfs.nix                 # ZFS scrub, snapshots, and drive health alerts via ntfy
```

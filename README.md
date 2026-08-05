# NixOS config

NixOS configuration for my minipc I use for development and experiments.

## Quick start

```bash
just dry       # dry-build (check for errors)
just switch    # build and deploy to remote host
just update    # update flake inputs
just upgrade   # update + switch
```

### Fresh install via nixos-anywhere

nixos-anywhere installs NixOS over SSH onto a target machine, partitioning the
disk according to `disko.nix`. **This wipes the target disk entirely.**

**Requirements:**
- Target machine booted into a NixOS live ISO (the minimal ISO works)
- SSH access to the live environment

**Steps:**

1. Boot the target from a NixOS minimal ISO
2. On the console, set a password so you can SSH in:
   ```bash
   passwd nixos
   ```
3. From this machine, run:
   ```bash
   just install nixos@<ip>
   ```

nixos-anywhere will kexec into the installer, partition the disk, and install
the configuration. The machine reboots into NixOS when done.

## Structure

```
flake.nix                   # Flake entrypoint
justfile                    # Common tasks (deploy, update, gc, …)
nixos/
  configuration.nix         # Main config (boot, locale, users, packages)
  hardware-configuration.nix # Hardware config (kernel modules, CPU microcode)
  disko.nix                 # Declarative disk partitioning (EFI + swap + ext4)
  modules/
    incus.nix               # Incus containers — HTTPS API, default pool and network
    networking.nix          # systemd-networkd, hostname, firewall
```

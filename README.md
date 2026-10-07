# NixOS config

Minimal NixOS config for the NAS that replaces TrueNAS: ZFS, Docker, git, SSH.

## Install (kexec via nixos-anywhere)

1. Check the boot disk in `rivendell/disko.nix`. **This wipes that disk only.**
2. Boot any Linux with root SSH, then:

```bash
just install root@<ip>
```

3. After first boot, import the existing TrueNAS pools: `sudo zpool import -f <pool>`.

Afterwards: `just switch` to deploy, `just dry` to check.

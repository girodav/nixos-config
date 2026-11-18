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

Run `just` to list the commands (`deploy`, `dry`, `status`).

Roll back from the boot menu, with `sudo nixos-rebuild switch --rollback`, or by reverting the commit on `main`.

## Alerts (Discord)

`rivendell/alerts.nix` posts drive problems (smartd), ZFS events and failed units (`nixos-upgrade`, `sanoid`, `zfs-scrub`, `smartd`) to a Discord webhook. The webhook URL is the secret and is not in this repo. Create it by hand on the host (lost on a fresh install):

```bash
sudo install -m 0400 -o root /dev/stdin /etc/discord-webhook   # paste the URL, then Ctrl-D
echo test | sudo alert-discord -s "alert test"                  # check it arrives
```

Without the file, alerts silently do nothing.

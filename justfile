host   := "rivendell"
target := "girodav@" + host

remote_flags := "--target-host " + target + " --build-host " + target + " --elevate=sudo"

# Install over SSH via kexec (WIPES the boot disk in rivendell/disko.nix): just install root@<ip>
install ip:
    nix run github:nix-community/nixos-anywhere -- --build-on-remote --flake .#{{host}} {{ip}}

# Build and activate on the remote host
switch:
    nix run nixpkgs#nixos-rebuild -- switch --flake .#{{host}} {{remote_flags}}

# Dry build (check for errors)
dry:
    nix run nixpkgs#nixos-rebuild -- dry-build --flake .#{{host}}

# Build and activate on the remote host without making it the boot default (reboot rolls back)
test:
    nix run nixpkgs#nixos-rebuild -- test --flake .#{{host}} {{remote_flags}}

# Quick health check: pools, failed units, auto-upgrade, pending reboot, drive SMART status
status:
    #!/usr/bin/env bash
    ssh {{target}} bash -s <<'EOF'
    echo "== pools"; zpool status -x
    echo "== failed units"; systemctl --failed --no-legend
    echo "== auto-upgrade"
    systemctl show nixos-upgrade -p Result
    systemctl list-timers nixos-upgrade --no-legend
    journalctl -u nixos-upgrade -n 6 --no-pager -o short-iso | grep -v Consumed
    echo "== generation"; readlink /run/current-system
    [ "$(readlink /run/booted-system/kernel)" = "$(readlink /run/current-system/kernel)" ] || echo "reboot needed: kernel changed since boot"
    echo "== smart"
    for d in $(sudo smartctl --scan | cut -d' ' -f1); do sudo smartctl -H $d | grep -E "overall|result" | sed "s|^|$d: |"; done
    EOF

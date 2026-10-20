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

# Quick health check: pools, failed units, last auto-upgrade, drive SMART status
status:
    ssh {{target}} 'zpool status -x; echo; systemctl --failed --no-legend; echo; systemctl status nixos-upgrade --no-pager -n 5 | head -12; echo; for d in /dev/nvme?n1 /dev/sd?; do [ -e $d ] && sudo smartctl -H $d | grep -E "overall|result" | sed "s|^|$d: |"; done'

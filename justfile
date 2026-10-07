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

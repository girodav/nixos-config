
# Override with: just host=rivendell target=girodav@rivendell <recipe>
host   := "edoras"
target := "girodav@" + host

remote_flags := "--target-host " + target + " --build-host " + target + " --elevate=sudo --ask-elevate-password"

# Install NixOS on a live ISO target via nixos-anywhere (WIPES root disk only)
install iso_target:
    nix run github:nix-community/nixos-anywhere -- --build-on-remote --flake .#{{host}} {{iso_target}}

# Build and switch configuration on the remote host
switch:
    nix run nixpkgs#nixos-rebuild -- switch --flake .#{{host}} {{remote_flags}}

# Build and set configuration for next boot
boot:
    nix run nixpkgs#nixos-rebuild -- boot --flake .#{{host}} {{remote_flags}}

# Activate configuration without making it the boot default
test:
    nix run nixpkgs#nixos-rebuild -- test --flake .#{{host}} {{remote_flags}}

# Dry build (check for errors)
dry:
    nix run nixpkgs#nixos-rebuild -- dry-build --flake .#{{host}}

# Run flake checks
check:
    nix flake check

# Update flake inputs
update:
    nix flake update

# Update inputs and switch
upgrade: update switch

# Delete old generations
gc:
    nix-collect-garbage -d

# Optimise nix store
optimise:
    nix store optimise

# gc + optimise
clean: gc optimise

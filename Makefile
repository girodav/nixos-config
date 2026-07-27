HOST ?= rivendell

# nixos-rebuild shortcuts
dry:
	nixos-rebuild dry-build --flake .#$(HOST)

switch:
	nixos-rebuild switch --flake .#$(HOST)

boot:
	nixos-rebuild boot --flake .#$(HOST)

test:
	nixos-rebuild test --flake .#$(HOST)

build:
	nixos-rebuild build --flake .#$(HOST)

# Flake management
check:
	nix flake check

update:
	nix flake update

upgrade: update switch

# Garbage collection
gc:
	nix-collect-garbage -d

optimise:
	nix store optimise

clean: gc optimise

# Show all targets
.PHONY: help
help:
	@echo "Usage: make <target> [HOST=hostname]"
	@echo ""
	@echo "Targets:"
	@echo "  dry       Dry build (check for errors) [default]"
	@echo "  switch    Rebuild and switch to new config"
	@echo "  boot      Rebuild and set for next boot"
	@echo "  test      Rebuild and activate immediately (no switch)"
	@echo "  build     Build but don't activate"
	@echo "  check     Run flake checks"
	@echo "  update    Update flake inputs"
	@echo "  upgrade   Update inputs + switch"
	@echo "  gc        Delete old generations"
	@echo "  optimise  Optimise nix store"
	@echo "  clean     gc + optimise"
	@echo "  help      Show this message"
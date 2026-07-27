{
  description = "NixOS configuration for rivendell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  };

  outputs = { nixpkgs, ... }: {
    nixosConfigurations = {
      rivendell = nixpkgs.lib.nixosSystem {
        modules = [
          ./nixos/configuration.nix
        ];
      };
    };
  };
}

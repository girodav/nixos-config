{
  description = "NixOS configuration for edoras";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, disko, ... }: {
    nixosConfigurations = {
      edoras = nixpkgs.lib.nixosSystem {
        modules = [
          disko.nixosModules.disko
          ./nixos/configuration.nix
        ];
      };
    };
  };
}

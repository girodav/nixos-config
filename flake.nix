{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
  };

  outputs = { nixpkgs, disko, quadlet-nix, ... }: {
    nixosConfigurations = {
      edoras = nixpkgs.lib.nixosSystem {
        modules = [
          disko.nixosModules.disko
          ./nixos/hosts/edoras/configuration.nix
        ];
      };

      rivendell = nixpkgs.lib.nixosSystem {
        modules = [
          disko.nixosModules.disko
          quadlet-nix.nixosModules.quadlet
          ./nixos/hosts/rivendell/configuration.nix
        ];
      };
    };
  };
}

{
  description = "NAS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, disko, ... }: {
    nixosConfigurations.rivendell = nixpkgs.lib.nixosSystem {
      modules = [
        disko.nixosModules.disko
        ./rivendell/configuration.nix
        ./rivendell/disko.nix
      ];
    };
  };
}

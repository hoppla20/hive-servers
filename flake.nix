{
  description = "Hive server configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-compat = {
      url = "github:inclyc/flake-compat";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    haumea.url = "github:nix-community/haumea/v0.2.2";
    hive = {
      url = "github:hoppla20/hive/implement-modules-and-profiles";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        haumea.follows = "haumea";
        paisano.follows = "std/paisano";
      };
    };
    std = {
      url = "github:divnix/std/release/0.23";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    incl = {
      url = "github:divnix/incl";
      inputs.nixlib.follows = "haumea/nixpkgs";
    };

    nixos-generators.url = "github:nix-community/nixos-generators";
    disko.url = "github:nix-community/disko";
  };

  outputs = {
    self,
    hive,
    std,
    incl,
    ...
  } @ inputs: let
    nixpkgsConfig = {
      allowUnfree = true;
    };

    lib = inputs.haumea.lib.load {
      src = ./local/lib;
      loader = inputs.haumea.lib.loaders.scoped;
      transformer = [inputs.haumea.lib.transformers.liftDefault];
      inputs = removeAttrs (inputs // {inherit inputs;}) ["self"];
    };
  in
    with std.blockTypes;
    with hive.blockTypes;
      hive.growOn {
        inherit nixpkgsConfig;
        inputs = inputs // {localLib = lib;};
        cellsFrom = incl ./local ["repo"];
        cellBlocks = [
          (nixago "configs")
          (devshells "shells")
        ];
      }
      (hive.grow {
        inherit nixpkgsConfig;
        inputs = inputs // {localLib = lib;};
        cellsFrom = ./nixos;
        cellBlocks = [
          nixosModules
          nixosProfiles
        ];
      })
      {
        nixosModules = hive.collect self "nixosModules";
        nixosProfiles = hive.collect self "nixosProfiles";
      }
      (hive.grow {
        inherit nixpkgsConfig;
        inputs =
          inputs
          // {
            inherit (self) nixosModules nixosProfiles;
            localLib = lib;
          };
        cellsFrom = ./servers;
        cellBlocks = [
          lib.blockTypes.nixosConfigurations
        ];
      })
      {
        nixosConfigurations = hive.collect self "nixosConfigurations";
      }
      {inherit lib;};

  /*
  Flake local nix config
  */

  nixConfig = {
    extra-experimental-features = "nix-command flakes";
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}

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

    devshell = {
      url = "github:numtide/devshell";
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
      inputs = {
        nixpkgs.follows = "nixpkgs";
        devshell.follows = "devshell";
      };
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

    l = inputs.unstable.lib // builtins;
    blockTypes = l.attrsets.mergeAttrsList [std.blockTypes hive.blockTypes lib.blockTypes];

    lib = inputs.haumea.lib.load {
      src = ./lib;
      loader = inputs.haumea.lib.loaders.scoped;
      transformer = [inputs.haumea.lib.transformers.liftDefault];
      inputs = removeAttrs (inputs // {inherit inputs;}) ["self"];
    };

    outputNixosModules = hive.collect self "nixosModules";
    outputNixosProfiles = hive.collect self "nixosProfiles";
    outputNixosConfigurations = hive.collect self "nixosConfigurations";
  in
    hive.growOn {
      inherit nixpkgsConfig;
      inputs =
        inputs
        // {
          nixosModules = outputNixosModules;
          nixosProfiles = outputNixosProfiles;
          localLib = lib;
        };
      cellsFrom = ./src;
      cellBlocks = with blockTypes; [
        (nixago "configs" {cli = false;})
        (devshells "shells" {cli = false;})
        nixosModules
        nixosProfiles
        nixosConfigurations
      ];
    }
    {
      inherit lib;
      nixosModules = outputNixosModules;
      nixosProfiles = outputNixosProfiles;
      nixosConfigurations = outputNixosConfigurations;
      apps = l.mapAttrs (_: shell: {default = shell.flakeApp;}) (hive.harvest self ["repo" "shells" "default"]);
    };

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

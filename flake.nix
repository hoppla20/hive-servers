{
  description = "Hive server configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-compat = {
      url = "github:inclyc/flake-compat";
      flake = false;
    };

    haumea.url = "github:nix-community/haumea/v0.2.2";
    hive = {
      url = "github:divnix/hive";
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

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
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
    l = inputs.unstable.lib // builtins;

    lib = inputs.haumea.lib.load {
      src = ./lib;
      loader = inputs.haumea.lib.loaders.scoped;
      transformer = [inputs.haumea.lib.transformers.liftDefault];
      inputs = removeAttrs (inputs // {inherit inputs;}) ["self"];
    };

    nixpkgsConfig = {
      allowUnfree = true;
    };

    blockTypes = l.attrsets.mergeAttrsList [std.blockTypes hive.blockTypes lib.blockTypes];

    output = {
      nixosModules = lib.helpers.pickAllByBlockName self "nixosModules";
      nixosProfiles = lib.helpers.pickAllByBlockName self "nixosProfiles";
      nixosConfigurations = hive.collect self "nixosConfigurations";
    };
  in
    hive.growOn
    {
      inherit nixpkgsConfig;
      inputs =
        inputs
        // {
          inherit (output) nixosModules nixosProfiles;
          localLib = lib;
        };
      cellsFrom = ./src;
      cellBlocks = with blockTypes; [
        (nixago "configs")
        (devshells "shells")
        ((functions "nixosModules") // {cli = false;})
        ((functions "nixosProfiles") // {cli = false;})
        nixosConfigurations
      ];
    }
    {
      inherit lib;
      inherit (output) nixosModules nixosProfiles nixosConfigurations;
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

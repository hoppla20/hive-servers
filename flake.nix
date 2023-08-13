{
  description = "Hive server configurations";

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
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      inputs =
        inputs
        // {
          inherit (output) nixosModules nixosProfiles nixosConfigurations;
          localLib = lib;
        };
      cellsFrom = ./src;
      cellBlocks = with blockTypes; [
        # repo
        (nixago "configs")
        (devshells "shells")

        # nixos
        ((functions "nixosModules") // {cli = false;})
        ((functions "nixosProfiles") // {cli = false;})
        nixosTests
        nixosConfigurations

        # services
        (arion "arion")
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

  /*
  Inputs
  */

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-compat = {
      url = "github:inclyc/flake-compat";
      flake = false;
    };

    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    paisano = {
      url = "github:paisano-nix/core";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hive = {
      url = "github:divnix/hive";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        haumea.follows = "haumea";
        paisano.follows = "paisano";
      };
    };
    std = {
      url = "github:divnix/std";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        devshell.follows = "devshell";
        arion.follows = "arion";
        nixago.follows = "nixago";
      };
    };
    incl = {
      url = "github:divnix/incl";
      inputs.nixlib.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    nosys.follows = "paisano/nosys";

    nixago = {
      url = "github:nix-community/nixago";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    arion = {
      url = "github:hercules-ci/arion/v0.2.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators.url = "github:nix-community/nixos-generators";
    disko.url = "github:nix-community/disko";
  };
}

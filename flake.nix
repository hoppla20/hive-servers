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

    localLib = inputs.haumea.lib.load {
      src = ./lib;
      loader = inputs.haumea.lib.loaders.scoped;
      transformer = [inputs.haumea.lib.transformers.liftDefault];
      inputs = removeAttrs (inputs // {inherit inputs;}) ["self"];
    };

    nixpkgsConfig = {
      allowUnfree = true;
    };
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    blockTypes = l.attrsets.mergeAttrsList [std.blockTypes hive.blockTypes localLib.blockTypes];
  in
    hive.growOn
    {
      inherit nixpkgsConfig systems;
      inputs = inputs // {inherit localLib;};
      cellsFrom = ./nix;
      cellBlocks = with blockTypes; [
        # repo
        (nixago "configs")
        (devshells "shells")

        # nixos
        ((anything "nixosModules") // {cli = false;})
        ((anything "nixosProfiles") // {cli = false;})
        nixosTests
        nixosConfigurations
      ];
    }
    {
      apps = l.mapAttrs (_: shell: {default = shell.flakeApp;}) (hive.harvest self ["repo" "shells" "default"]);
      packages = l.mapAttrs (_: shell: {inherit shell;}) (hive.harvest self ["repo" "shells" "default"]);

      nixosConfigurations = hive.collect self "nixosConfigurations";
      nixosTests = localLib.helpers.byBlockName.harvest self "nixosTests";

      lib = localLib;
      growOn = args:
        hive.growOn ({
            inherit nixpkgsConfig systems;
          }
          // args);

      checks = inputs.namaka.lib.load {
        src = ./tests;
        inputs = {
          inherit inputs;
          flake = self;
        };
      };
    };

  /*
  Flake local nix config
  */

  nixConfig = {
    extra-experimental-features = "nix-command flakes";
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://colmena.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
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
    namaka = {
      url = "github:nix-community/namaka/v0.2.0";
      inputs = {
        haumea.follows = "haumea";
        nixpkgs.follows = "nixpkgs";
      };
    };
    hive = {
      url = "github:divnix/hive";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        haumea.follows = "haumea";
        paisano.follows = "paisano";
        colmena.follows = "colmena";
      };
    };
    std = {
      url = "github:divnix/std";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        devshell.follows = "devshell";
        arion.follows = "arion";
        nixago.follows = "nixago";
        n2c.follows = "n2c";
        terranix.follows = "terranix";
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
    n2c = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    terraform-providers-bin = {
      url = "github:nix-community/nixpkgs-terraform-providers-bin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        stable.follows = "nixpkgs";
      };
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

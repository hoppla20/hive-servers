{
  inputs,
  cell,
}: moduleName: {
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) types;

  cfg = config.bee.modules.${moduleName};

  substituterOpts = types.submodule {
    options = {
      url = lib.mkOption {
        type = types.str;
      };
      key = lib.mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };
  };
in {
  options = {
    substituters = lib.mkOption {
      type = types.listOf substituterOpts;
      default = [
        {
          url = "https://cache.nixos.org";
        }
        {
          url = "https://nix-community.cachix.org";
          key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
        }
      ];
    };
  };

  config = {
    nix.settings.trusted-substituters = builtins.catAttrs "url" cfg.substituters;
    nix.settings.trusted-public-keys = builtins.filter (k: !isNull k) (builtins.catAttrs "key" cfg.substituters);
  };
}

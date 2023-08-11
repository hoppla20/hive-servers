{
  inputs,
  cell,
}: {
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) types;
  l = lib // builtins;

  cfg = config.hoppla.core;

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
  options.hoppla.core.substituters = lib.mkOption {
    type = types.listOf substituterOpts;
  };

  config = l.mkIf cfg.enable {
    hoppla.core.substituters = [
      {
        url = "https://cache.nixos.org";
      }
      {
        url = "https://nix-community.cachix.org";
        key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
      }
    ];

    nix.settings.trusted-substituters = builtins.catAttrs "url" cfg.substituters;
    nix.settings.trusted-public-keys = builtins.filter (k: !isNull k) (builtins.catAttrs "key" cfg.substituters);
  };
}

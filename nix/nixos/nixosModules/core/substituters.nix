{
  inputs,
  selfCfg,
  selfPath,
}: let
  inherit (inputs.nixpkgs) lib;
  inherit (lib) types;
  l = lib // builtins;

  substituterOpts = types.submodule {
    options = {
      url = l.mkOption {
        type = types.str;
      };
      key = l.mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };
  };
in {
  options = l.mkOption {
    type = types.listOf substituterOpts;
    default = [];
  };

  config = {
    hoppla.nixos.core.substituters = [
      {
        url = "https://cache.nixos.org";
      }
      {
        url = "https://nix-community.cachix.org";
        key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
      }
    ];
    nix.settings.trusted-substituters = builtins.catAttrs "url" selfCfg;
    nix.settings.trusted-public-keys = builtins.filter (k: k != null) (builtins.catAttrs "key" selfCfg);
  };
}

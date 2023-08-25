{
  inputs,
  super,
}: let
  inherit (inputs.nixpkgs) lib;
  l = lib // builtins;
in
  {
    inputs,
    cell,
    src,
    targetName,
  } @ args: let
    modules = super.utils.modules args;
    targetPath = ["hoppla" (super.utils.cellName cell) targetName];
    targetNixStorePath = super.utils.targetNixStorePath args;
  in {
    _file = targetNixStorePath;
    imports = l.collect l.isFunction modules;
    options = l.setAttrByPath targetPath {
      enable = l.mkOption {
        type = l.types.bool;
        description = "Global disable switch for nixosModule target '${targetNixStorePath}'";
        default = true;
      };
    };
  }

{
  inputs,
  super,
}: let
  l = inputs.nixpkgs.lib // builtins;
in
  {
    inputs,
    cell,
    block,
    type,
  }: let
    loader =
      if type == "default"
      then super.loaders.defaultLoader
      else if builtins.hasAttr type super.loaders
      then super.loaders.${type}
      else
        throw ''
          loadTargets: Could not find loader that supports type '${type}'.
        '';
  in
    builtins.mapAttrs
    (dir: _:
      loader {
        inherit inputs cell;
        src = block + "/${dir}";
        targetName = dir;
      })
    (l.filterAttrs (_: type: type == "directory") (builtins.readDir block))

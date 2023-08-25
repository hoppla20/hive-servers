{
  inputs,
  super,
  self,
}: let
  l = inputs.nixpkgs.lib // builtins;
in {
  cellName = cell: l.head cell.__cr;

  targetNixStorePath = {
    inputs,
    cell,
    targetName,
    ...
  }: "${inputs.self.outPath}/nix/${l.concatStringsSep "/" (cell.__cr ++ [targetName])}";

  modules = {
    inputs,
    cell,
    src,
    targetName,
    profiles ? false,
  }:
    inputs.haumea.lib.load {
      inherit src;
      loader = super.modulesLoader {
        inherit cell inputs profiles targetName;
        cellName = l.head cell.__cr;
      };
      inputs = (removeAttrs inputs ["self"]) // {inherit inputs cell;};
    };

  profiles = args: self.modules (args // {profiles = true;});
}

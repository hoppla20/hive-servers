_: {
  inputs,
  cell,
  src,
}: let
  inherit (inputs.nixpkgs) lib;
  l = lib // builtins;
  flakePath = inputs.self.outPath;
in
  inputs.haumea.lib.load {
    inherit src;
    loader = inputs: path: let
      f = l.toFunction (import path);
    in
      {
        config,
        options,
        ...
      }: (l.pipe f [
        l.functionArgs
        (l.mapAttrs (name: _: (inputs // {inherit config options;}).${name}))
        f
        (
          let
            cr = cell.__cr ++ [(l.baseNameOf path)];
            file = "${flakePath}/src/${l.concatStringsSep "/" cr}";
          in
            l.setDefaultModuleLocation file
        )
      ]);
    inputs = {inherit inputs cell;};
  }

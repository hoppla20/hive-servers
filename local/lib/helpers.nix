{
  inputs,
  cell,
}: let
  load = {
    inputs,
    cell,
    ...
  } @ args:
    inputs.haumea.lib.load (removeAttrs args ["cell" "inputs"]
      // {
        loader = inputs.haumea.lib.loaders.scoped;
        transformer = [inputs.haumea.lib.transformers.liftDefault];
        inputs = removeAttrs (inputs // {inherit inputs cell;}) ["self"];
      });
in
  (load {
    inherit inputs cell;
    src = ./helpers;
  })
  // {inherit load;}

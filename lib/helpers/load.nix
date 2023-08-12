_: {
  inputs,
  cell,
  ...
} @ args:
inputs.haumea.lib.load (removeAttrs args ["cell" "inputs"]
  // {
    loader = inputs.haumea.lib.loaders.scoped;
    inputs = removeAttrs (inputs // {inherit inputs cell;}) ["self"];
  })

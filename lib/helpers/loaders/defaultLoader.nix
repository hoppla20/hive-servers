{inputs}: {
  inputs,
  src,
  cell,
  ...
}:
inputs.haumea.lib.load {
  inherit src;
  loader = inputs.haumea.lib.loaders.scoped;
  transformer = inputs.haumea.lib.transformers.liftDefault;
  inputs = (removeAttrs inputs ["self"]) // {inherit inputs cell;};
}

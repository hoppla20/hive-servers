{
  inputs,
  cell,
  config,
  options,
}: let
  inherit (inputs.localLib) helpers;
in {
  options.hoppla.test = {
    enable = helpers.mkEnableOption false;
  };
}
{
  inputs,
  cell,
  config,
  options,
}: let
  inherit (inputs.localLib) helpers;
in {
  options.hoppla.services.postgresql = {
    enable = helpers.mkEnableOption false;
  };

  config = {
  };
}

{
  inputs,
  cell,
  localLib,
}: {
  lib,
  config,
  options,
  ...
}: let
  inherit (localLib) helpers;
in {
  options.hoppla.test = {
    enable = helpers.mkEnableOption false;
  };
}

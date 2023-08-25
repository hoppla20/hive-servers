{
  inputs,
  targetCfg,
  selfCfg,
}: let
  inherit (inputs.nixpkgs) lib;
  inherit (inputs.localLib) helpers;
  l = lib // builtins;
in {
  options = {
    enable = helpers.mkEnableOption targetCfg.enable;
    ports = l.mkOption {
      type = l.types.listOf l.types.ints.unsigned;
      default = [22];
    };
  };

  config = l.mkIf selfCfg.enable {
    services.openssh = {
      enable = true;
      inherit (selfCfg) ports;
      openFirewall = true;
    };
  };
}

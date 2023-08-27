{
  inputs,
  cell,
  selfCfg,
}: let
  inherit (inputs.nixpkgs) lib;
  inherit (lib) types;
  inherit (inputs.localLib) helpers;
  l = lib // builtins;
in {
  options = {
    build = {
      maxJobs = l.mkOption {
        type = types.ints.unsigned;
        default = 1;
      };
      cores = l.mkOption {
        type = types.ints.unsigned;
        default = 0;
      };
    };
  };

  config = {
    nix = {
      nixPath = [
        "nixpkgs=${inputs.nixpkgs.path}"
      ];
      settings = {
        sandbox = true;
        auto-optimise-store = true;
        allowed-users = ["@wheel"];
        trusted-users = ["@wheel"];
      };
      gc.automatic = true;
      optimise.automatic = true;
      extraOptions = ''
        experimental-features = nix-command flakes
        min-free = 5368709120 # 5 GB
        fallback = true

        cores = ${toString selfCfg.cores}
        max-jobs = ${toString selfCfg.maxJobs}
      '';
    };
  };
}

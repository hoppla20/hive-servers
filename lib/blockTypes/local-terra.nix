{
  inputs,
  root,
  super,
}:
/*
Use the Terra Blocktype for terraform configurations managed by terranix.

Available actions:
  - init
  - plan
  - apply
  - state
  - refresh
  - destroy
*/
let
  inherit (root.helpers) mkCommand;
in
  name: {
    inherit name;
    __functor = self: selectors: self // selectors;
    type = "terra";
    actions = {
      currentSystem,
      fragment,
      fragmentRelPath,
      target,
      inputs,
    }: let
      inherit (inputs) terranix;
      pkgs = inputs.nixpkgs.${currentSystem};

      repoFolder = with pkgs.lib;
        concatStringsSep "/" (["./nix"] ++ splitString "/" fragmentRelPath);

      terraEval = import (terranix + /core/default.nix);
      terraformConfiguration = inputs.nixpkgs.writeTextFile {
        name = "config.tf.json";
        text =
          builtins.toJSON
          (terraEval {
            inherit pkgs; # only effectively required for `pkgs.lib`
            terranix_config = {
              _file = fragmentRelPath;
              imports = [target];
            };
            strip_nulls = true;
          })
          .config;
      };

      setup = ''
        export TF_IN_AUTOMATION=1
        # export TF_INPUT=0
        export TF_DATA_DIR="$PRJ_DATA_HOME/${fragmentRelPath}"
        export TF_PLUGIN_CACHE_DIR="$PRJ_CACHE_HOME/tf-plugin-cache"
        mkdir -p "$TF_DATA_DIR"
        mkdir -p "$TF_PLUGIN_CACHE_DIR"
        dir="$PRJ_ROOT/${repoFolder}/.tf"
        mkdir -p "$PRJ_ROOT/${repoFolder}/.tf"
        cat << MESSAGE > "$PRJ_ROOT/${repoFolder}/.tf/readme.md"
        This is a tf staging area.
        It is motivated by the terraform CLI requiring to be executed in a staging area.
        MESSAGE

        if [[ -e "$dir/config.tf.json" ]]; then rm -f "$dir/config.tf.json"; fi
        cp ${terraformConfiguration} "$dir/config.tf.json"
      '';

      wrap = cmd: ''
        ${setup}
        pushd "$dir"
        terraform ${cmd} "$@";
      '';
    in [
      (mkCommand currentSystem "init" "tf init" [pkgs.terraform] (wrap "init") {})
      (mkCommand currentSystem "plan" "tf plan" [pkgs.terraform] (wrap "plan") {})
      (mkCommand currentSystem "apply" "tf apply" [pkgs.terraform] (wrap "apply") {})
      (mkCommand currentSystem "state" "tf state" [pkgs.terraform] (wrap "state") {})
      (mkCommand currentSystem "refresh" "tf refresh" [pkgs.terraform] (wrap "refresh") {})
      (mkCommand currentSystem "destroy" "tf destroy" [pkgs.terraform] (wrap "destroy") {})
      (mkCommand currentSystem "force-unlock" "tf force-unlock" [pkgs.terraform] (wrap "force-unlock") {})
    ];
  }

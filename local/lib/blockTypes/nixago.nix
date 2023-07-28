{
  inputs,
  root,
}: let
  inherit (root.helpers) mkCommand;
in
  name: {
    inherit name;
    type = "nixago";
    actions = {
      currentSystem,
      fragment,
      fragmentRelPath,
      target,
    }: [
      (mkCommand currentSystem "populate" "populate this nixago file into the repo" [] ''
        ${target.install}/bin/nixago_shell_hook
      '' {})
      (mkCommand currentSystem "explore" "interactively explore the nixago file" [] ''
        ${inputs.nixpkgs.legacyPackages.${currentSystem}.bat}/bin/bat "${target.configFile}"
      '' {})
    ];
  }

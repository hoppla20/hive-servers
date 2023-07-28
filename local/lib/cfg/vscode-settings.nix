{inputs}: let
  l = inputs.nixpkgs.lib // builtins;
in {
  data = {};
  output = ".vscode/settings.json";
  format = "json";
}

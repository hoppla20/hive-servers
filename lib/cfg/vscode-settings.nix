{ inputs }:
let
  l = inputs.nixpkgs.lib // builtins;
in
inputs.std.x86_64-linux.lib.dev.mkNixago {
  data = { };
  output = ".vscode/settings.json";
  format = "json";
}

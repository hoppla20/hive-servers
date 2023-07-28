{
  inputs,
  cell,
}: let
  l = inputs.nixpkgs.lib // builtins;
  stdLib = inputs.std.lib;
in
  l.mapAttrs (_: inputs.std.lib.dev.mkShell) {
    default = {
      name = "hive-servers";

      imports = [inputs.std.std.devshellProfiles.default];

      nixago = [
        stdLib.cfg.conform
        (stdLib.cfg.treefmt cell.configs.treefmt)
        (stdLib.cfg.editorconfig cell.configs.editorconfig)
        (stdLib.cfg.lefthook cell.configs.lefthook)
        (stdLib.cfg.mdbook cell.configs.mdbook)
        ((stdLib.dev.mkNixago inputs.localLib.cfg.vscode-settings) cell.configs.vscode-settings)
      ];

      packages = [
        inputs.unstable.legacyPackages.nixd
      ];

      commands = [
        {
          category = "rendering";
          package = inputs.nixpkgs.mdbook;
        }
      ];
    };
  }

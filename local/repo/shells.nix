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

      commands = [
        {
          category = "rendering";
          package = inputs.nixpkgs.mdbook;
        }
      ];

      devshell = {
        packages = [
          inputs.unstable.legacyPackages.nixd
        ];

        meta.description = "hive-servers shell environment";
      };

      nixago = [
        stdLib.cfg.conform
        cell.configs.treefmt
        cell.configs.editorconfig
        cell.configs.lefthook
        cell.configs.mdbook
        cell.configs.vscode-settings
      ];
    };
  }

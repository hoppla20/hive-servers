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

      packages = [
        inputs.nixpkgs.nil
        inputs.nixpkgs.alejandra
      ];

      commands = [
        {
          category = "rendering";
          package = inputs.nixpkgs.mdbook;
        }
      ];

      nixago = [
        stdLib.cfg.conform
        cell.configs.treefmt
        cell.configs.editorconfig
        cell.configs.lefthook
        cell.configs.mdbook
        cell.configs.vscode-settings
      ];

      devshell = {
        meta.description = "hive-servers shell environment";
      };
    };
  }

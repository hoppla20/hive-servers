{
  inputs,
  cell,
}: let
  l = inputs.nixpkgs.lib // builtins;
  stdLib = inputs.std.lib;

  terraform' = inputs.nixpkgs.terraform.withPlugins (_: [
    inputs.terraform-providers-bin.legacyPackages.providers.dmacvicar.libvirt
    inputs.terraform-providers-bin.legacyPackages.providers.Telmate.proxmox
  ]);
in
  l.mapAttrs (_: inputs.std.lib.dev.mkShell) {
    default = {
      name = "hive-servers";

      imports = [inputs.std.std.devshellProfiles.default];

      packages = [
        inputs.unstable.legacyPackages.nil
        inputs.unstable.legacyPackages.alejandra
        inputs.unstable.legacyPackages.nixos-generators
        inputs.unstable.legacyPackages.terranix
        inputs.unstable.legacyPackages.namaka
        inputs.unstable.legacyPackages.colmena
        terraform'
      ];

      commands = [
        {
          name = "nil-diagnostics";
          category = "dev";
          command = "find . -type f -name \"*.nix\" -exec nil diagnostics {} \\;";
        }
        {
          package = inputs.nixpkgs.statix;
          category = "dev";
          help = "statix {check,fix}";
        }
        {
          package = inputs.nixpkgs.sops;
        }
      ];

      nixago = [
        cell.configs.conform
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

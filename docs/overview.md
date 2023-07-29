# Hive Servers

## Docs

```bash
# build
mdbook build [--open]
# serve at http://localhost:3000 and rebuild on change
mdbook serve [--open]
```

## Flake

### Inputs

- <a href="https://github.com/NixOS/nixpkgs" target="_blank">nixos/nixpkgs</a>
- <a href="https://github.com/divnix/hive" target="_blank">hive</a>
- <a href="https://github.com/divnix/std" target="_blank">std</a>
- <a href="https://github.com/paisano-nix/core" target="_blank">paisano</a>
- <a href="https://github.com/nix-community/haumea" target="_blank">haumea</a>
- <a href="https://github.com/nix-community/disko" target="_blank">disko</a>
- <a href="https://github.com/nix-community/home-manager" target="_blank">home-manager</a>
- <a href="https://github.com/numtide/devshell" target="_blank">devshell</a>
- <a href="https://github.com/nix-community/nixos-generators" target="_blank">nixos-generators</a>

### Outputs

| Output                         | Description                                                                                                                                |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| \_\_std                        | Paisano registry see <a href="https://github.com/paisano-nix/core/blob/main/registry.schema.json" target="_blank">registry.schema.json</a> |
| apps.`{system}`.default        | Devshell <a href="https://github.com/numtide/devshell/blob/main/docs/flake-app.md" target="_blank">flakeApp</a> (currently broken)         |
| `{system}`.`{cell}`.`{target}` | Paisano output                                                                                                                             |
| lib                            | Nix library, documented at [lib](lib.md)                                                                                                   |
| nixosModules                   | NixOS modules                                                                                                                              |
| nixosProfiles                  | NixOS profiles                                                                                                                             |
| nixosConfigurations            | NixOS configurations                                                                                                                       |

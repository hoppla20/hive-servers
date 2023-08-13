{
  inputs,
  cell,
  config,
  options,
}: {
  imports =
    # core
    builtins.attrValues inputs.nixosModules.core
    ++ builtins.attrValues inputs.nixosProfiles.core
    # users
    ++ builtins.attrValues inputs.nixosModules.users
    # nextcloud
    ++ [cell.nixosModules.nextcloud];

  hoppla = {
    core.enable = true;
    users.vincentcui.enable = true;
    services = {
      nextcloud.enable = true;
    };
  };
}

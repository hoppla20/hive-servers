{
  inputs,
  root,
}: let
  inherit (root.helpers) mkCommand;
  l = inputs.nixpkgs.lib // builtins;
in {
  name = "nixosConfigurations";
  type = "nixosConfigurations";
  actions = {
    currentSystem,
    fragment,
    fragmentRelPath,
    target,
  }: let
    pkgs = inputs.nixpkgs.legacyPackages.${currentSystem};
    fragments = l.splitString "\/" fragmentRelPath;
    cellName = l.elemAt fragments 0;
    targetName = l.elemAt fragments 2;
    collectedTargetName = "${cellName}-${targetName}";

    sharedRunTestVm = ''
      set -x
      DATA_LOCATION="$PRJ_DATA_HOME/${fragmentRelPath}"
      export NIX_DISK_IMAGE="$DATA_LOCATION/nixos.qcow2"
      export NIX_EFI_VARS="$DATA_LOCATION/nixos-efi-vars.fd"
      rm -rf "$DATA_LOCATION" && mkdir -p "$DATA_LOCATION"
    '';
  in [
    (mkCommand
      currentSystem
      "runTestVm"
      "create and run a test vm using this configuration"
      [pkgs.nix-output-monitor]
      ''
        # fragment: ${fragment}

        ${sharedRunTestVm}

        RESULT=$(nom build --no-link --print-out-paths "$PRJ_ROOT#nixosConfigurations.${collectedTargetName}.config.formats.vm")
        exec "$RESULT"
      ''
      {})
    (mkCommand
      currentSystem
      "runTestVmGrub"
      "create and run a test vm (with grub) using this configuration"
      [pkgs.nix-output-monitor]
      ''
        # fragment: ${fragment}

        ${sharedRunTestVm}

        RESULT=$(nom build --no-link --print-out-paths "$PRJ_ROOT#nixosConfigurations.${collectedTargetName}.config.formats.vm-bootloader")
        exec "$RESULT"
      ''
      {})
    (mkCommand
      currentSystem
      "buildToplevel"
      "build the toplevel of the configuration"
      []
      ''
        # fragment: ${fragment}

        nix build \
          --show-trace \
          --system "${target.bee.system}" \
          "$PRJ_ROOT#nixosConfigurations.${collectedTargetName}.config.system.build.toplevel"
      ''
      {})
    (mkCommand
      currentSystem
      "showHopplaConfig"
      "Outputs a JSON with all hoppla module configurations"
      [inputs.nixpkgs.legacyPackages.${currentSystem}.jq]
      ''
        # fragment: ${fragment}

        nix eval --json "$PRJ_ROOT#nixosConfigurations.${collectedTargetName}.config.hoppla" | jq
      ''
      {})
  ];
}

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
    inputs,
    currentSystem,
    fragment,
    fragmentRelPath,
    target,
  }: let
    fragments = l.splitString "\/" fragmentRelPath;
    cellName = l.elemAt fragments 0;
    targetName = l.elemAt fragments 2;
    collectedTargetName = "${cellName}-${targetName}";

    sharedTestVm = ''
      set -x
      DATA_LOCATION="$PRJ_DATA_HOME/${fragmentRelPath}"
      export NIX_DISK_IMAGE="$DATA_LOCATION/nixos.qcow2"
      export NIX_EFI_VARS="$DATA_LOCATION/nixos-efi-vars.fd"
      rm -rf "$DATA_LOCATION" && mkdir -p "$DATA_LOCATION"
    '';
  in [
    (mkCommand
      currentSystem
      "build"
      "build the toplevel of the nixos configuration"
      []
      ''
        nix build "$PRJ_ROOT#nixosConfigurations.${collectedTargetName}.config.system.build.toplevel"
      ''
      {})
    (mkCommand
      currentSystem
      "runTestVm"
      "create and run a test vm using this configuration"
      [inputs.nixpkgs.nix-output-monitor]
      ''
        ${sharedTestVm}
        RESULT=$(nom build --no-link --print-out-paths "$PRJ_ROOT#nixosConfigurations.${collectedTargetName}.config.formats.vm")
        exec "$RESULT"
      ''
      {})
    (mkCommand
      currentSystem
      "runTestVmGrub"
      "create and run a test vm (with grub) using this configuration"
      [inputs.nixpkgs.nix-output-monitor]
      ''
        ${sharedTestVm}
        RESULT=$(nom build --no-link --print-out-paths "$PRJ_ROOT#nixosConfigurations.${collectedTargetName}.config.formats.vm-bootloader")
        exec "$RESULT"
      ''
      {})
    (mkCommand
      currentSystem
      "buildDiskImage"
      "builds disk image for configuration"
      [inputs.nixpkgs.nix-output-monitor]
      ''
        ${sharedTestVm}
        RESULT=$(nom build --no-link --print-out-paths "$PRJ_ROOT#nixosConfigurations.${collectedTargetName}.config.formats.qcow")
        cp "$RESULT" "$NIX_DISK_IMAGE"
      ''
      {})
    (mkCommand
      currentSystem
      "showHopplaConfig"
      "outputs a JSON with all hoppla module configurations"
      [inputs.nixpkgs.jq]
      ''
        nix eval --json "$PRJ_ROOT#nixosConfigurations.${collectedTargetName}.config.hoppla" | jq
      ''
      {})
  ];
}

{
  inputs,
  root,
}: let
  inherit (root.helpers) mkCommand;
in {
  name = "nixosConfigurations";
  type = "nixosConfigurations";
  actions = {
    currentSystem,
    fragment,
    fragmentRelPath,
    target,
  }: [
    (mkCommand
      currentSystem
      "runTestVm"
      "create and run a test vm using this configuration"
      [inputs.nixos-generators.packages.${currentSystem}.default] ''
        # ${target}
        echo "running test vm for ${target}"
        VM_NAME="${target}"
        VM_DIR="$PRJ_DATA_HOME/test-vms/$VM_NAME"

        rm -rf "$VM_DIR"
        mkdir -p "$VM_DIR"

        nixos-generators \
          --format vm \
          --flake "$PRJ_ROOT#${fragment}" \
          --system "${currentSystem}"
          --run
      '' {})
  ];
}

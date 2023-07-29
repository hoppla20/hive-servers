{ inputs
, root
,
}:
let
  l = inputs.nixpkgs.lib // builtins;

  inherit (root.helpers) mkCommand;
  inherit (inputs.hive) collectOps;
in
{
  name = "nixosConfigurations";
  type = "nixosConfigurations";
  actions =
    { currentSystem
    , fragment
    , fragmentRelPath
    , target
    ,
    }:
    let
      fragments = l.splitString "\/" fragmentRelPath;
      cellName = l.elemAt fragments 0;
      targetName = l.elemAt fragments 2;
      collectedTargetName = inputs.hive.renamers.cell-target cellName targetName;

      nixos-generators = inputs.nixos-generators.packages.${currentSystem}.default;
    in
    [
      (mkCommand
        currentSystem
        "runTestVm"
        "create and run a test vm using this configuration"
        [ nixos-generators ] ''
        # fragment: ${fragment}

        rm -rf "$PRJ_DATA_HOME/test-vms/${collectedTargetName}"
        mkdir -p "$PRJ_DATA_HOME/test-vms/${collectedTargetName}"

        nixos-generate \
          --format vm \
          --flake "$PRJ_ROOT#${collectedTargetName}" \
          --system "${target.bee.system}" \
          --run
      ''
        { })
    ];
}

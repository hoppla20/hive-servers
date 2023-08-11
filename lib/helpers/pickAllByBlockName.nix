/*
Inputs:
flakeRoot = {
  system1 = {
    cell1 = {
      block1 = {
        target1 = "cell1-block1-target1";
      };
    };
    cell2 = {
      block1 = {
        target1 = "cell2-block1-target1";
      };
      block2 = {
        target1 = "cell2-block2-target1";
        target2 = "cell2-block2-target2";
      };
    };
  };
}
blockName = "block1"

Outputs:
{
  cell1 = {
    target1 = "cell1-block1-target1";
  };
  cell2 = {
    target1 = "cell2-block1-target1";
    target2 = "cell2-block1-target2";
  };
}
*/
{inputs}: flakeRoot: blockName: let
  inherit (inputs.nixpkgs) lib;

  l = lib // builtins;

  cells = l.head (
    l.attrValues
    (l.getAttrs l.systems.doubles.all flakeRoot) # avoid infinite recursion
  );
in
  l.mapAttrs (cell: l.attrByPath [blockName] {}) cells

{
  inputs,
  cell,
}:
cell.helpers.load {
  inherit inputs cell;
  src = ./cfg;
}

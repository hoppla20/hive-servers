{
  inputs,
  cell,
}:
inputs.hive.load {
  inherit inputs cell;
  src = ./cfg;
}

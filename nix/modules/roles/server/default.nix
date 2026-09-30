{ inputs, lib, ... }:
{
  imports = [
    inputs.srvos.nixosModules.server
    ./..
    ./documentation.nix
    ./networking.nix
  ];

  time.timeZone = lib.mkForce "UTC";
}

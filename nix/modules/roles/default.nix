{ inputs, ... }:
{
  imports = [
    inputs.srvos.nixosModules.common
    ./boot.nix
    ./hardening.nix
    ./locale.nix
    ./networking.nix
    ./nix.nix
    ./openssh.nix
    ./packages.nix
  ];
}

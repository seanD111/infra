{
  self,
  inputs,
  lib,
  ...
}:
{
  perSystem =
    { system, ... }:
    lib.optionalAttrs
      (lib.elem system [
        "x86_64-linux"
        "aarch64-linux"
      ])
      {
        checks = {
          server = inputs.nixpkgs.lib.nixos.runTest {
            imports = [ ./server.nix ];
            hostPkgs = inputs.nixpkgs.legacyPackages.${system};
            node.specialArgs = { inherit inputs; };
            nodes.server.imports = [ self.nixosModules."roles/server" ];
          };

          workstation = inputs.nixpkgs.lib.nixos.runTest {
            imports = [ ./workstation.nix ];
            hostPkgs = inputs.nixpkgs.legacyPackages.${system};
            node.specialArgs = { inherit inputs; };
            nodes.workstation.imports = [
              self.nixosModules."roles/workstation"
              self.nixosModules."apps/firefox"
            ];
          };

          workstation-sway = inputs.nixpkgs.lib.nixos.runTest {
            imports = [ ./sway.nix ];
            hostPkgs = inputs.nixpkgs.legacyPackages.${system};
            node.specialArgs = { inherit inputs; };
            nodes.workstation.imports = [
              self.nixosModules."roles/workstation/sway"
              self.nixosModules."hardware/bluetooth"
            ];
          };
        };
      };
}

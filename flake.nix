{
  description = "seanD111's flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      imports = [
        inputs.flake-parts.flakeModules.flakeModules
        ./nix/checks
        ./nix/devshells
        ./nix/formatters
        ./nix/nixosmodules
        ./nix/tests
      ];
      flake.flakeModules = {
        checks = ./nix/checks;
        devshells = ./nix/devshells;
        formatters = ./nix/formatters;
        nixos-modules = ./nix/nixosmodules;
        tests = ./nix/tests;
        default = {
          imports = [
            ./nix/checks
            ./nix/devshells
            ./nix/formatters
            ./nix/nixosmodules
            ./nix/tests
          ];
        };
      };
    };
}

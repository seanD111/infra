{ inputs, ... }: {
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem = _: {
    treefmt.config = {
      projectRootFile = "flake.nix";
      programs.nixfmt.enable = true;
    };
  };
}

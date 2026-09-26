_: {
  perSystem = _: {
    treefmt.config = {
      projectRootFile = "flake.nix";
      programs.nixfmt.enable = true;
    };
  };
}

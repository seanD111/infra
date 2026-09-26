{ self, ... }: {
  perSystem = { pkgs, ... }: {
    checks = {
      # Linting with statix
      lint = pkgs.stdenv.mkDerivation {
        name = "lint";
        src = self;
        buildInputs = [ pkgs.statix ];
        buildPhase = ''
          statix check .
        '';
        installPhase = "touch $out";
      };
    };
  };
}

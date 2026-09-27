_: {
  perSystem = { pkgs, system, ... }: {
    defaultShell = "nix";
    devshells.nix = {
      packages = with pkgs; [
        git
        nix
        nixd
        nixfmt
        statix
      ];
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
      ];
      settings = {
        "editor.tokenColorCustomizations".strings = "#ce9178";
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.formatterPath" = "nixfmt";
        "editor.formatOnSave" = true;
        "nix.serverSettings".nixd.nixpkgs.expr =
          "(builtins.getFlake (toString ./.)).inputs.nixpkgs.legacyPackages.${system}";
      };
    };
  };
}

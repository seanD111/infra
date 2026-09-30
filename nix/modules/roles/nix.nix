{ lib, ... }:
{
  nixpkgs.config.allowUnfree = true;

  nix = {
    gc = {
      automatic = true;
      randomizedDelaySec = "14m";
      options = "--delete-older-than 10d";
    };
    settings.log-lines = lib.mkDefault 25;
  };
}

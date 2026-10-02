{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # minecraft test
    prismlauncher
  ];
}

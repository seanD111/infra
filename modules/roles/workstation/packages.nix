{ pkgs, ... }:
{
  programs = {
    direnv.enable = true;
  };
  environment.systemPackages = with pkgs; [
    bitwarden-cli
    discord
    gimp

    keepassxc
    libarchive
    nmap
    obsidian
    signal-desktop
    thunderbird-latest
    remmina
    restic
    vlc
  ];
}

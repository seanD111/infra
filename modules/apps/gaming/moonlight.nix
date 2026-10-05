{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # gamestreaming
    moonlight-qt
  ];
}

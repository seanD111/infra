{ lib, pkgs, ... }:
{
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      AllowAgentForwarding = false;
      PermitRootLogin = lib.mkForce "no";
      PasswordAuthentication = false;
      X11Forwarding = false;
      PermitTTY = false;
      PrintMotd = false;
      PermitTunnel = "no";
      ForceCommand = "${pkgs.coreutils}/bin/false";
      MaxSessions = 2;
      MaxStartups = "3:30";
    };
  };
}

{ lib, ... }:
{
  programs.ssh.extraConfig = ''
    Host *
      IdentitiesOnly yes
  '';

  services.openssh = {
    enable = lib.mkDefault true;
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
    startWhenNeeded = false;
    openFirewall = lib.mkDefault false;
    settings.PermitRootLogin = lib.mkDefault "no";
  };
}

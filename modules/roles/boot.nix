{ lib, ... }:
{
  boot.loader = {
    grub.configurationLimit = lib.mkForce 5;
    systemd-boot.configurationLimit = lib.mkForce 5;
  };
}

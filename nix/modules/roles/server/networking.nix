{ lib, ... }:
{
  # servers put on the internet should stop scanning/ssh attempts
  services.fail2ban.enable = lib.mkDefault true;
  # we also don't want our servers trying multicast dns / service discovery
  services.avahi.enable = lib.mkForce false;
}

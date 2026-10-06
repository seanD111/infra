{
  # disable TTYs entirely
  systemd.services."getty@tty1".enable = false;
}

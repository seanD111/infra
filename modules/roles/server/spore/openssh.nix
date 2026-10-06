{
  # this is one of the few places we want ssh firewall rules open;
  # spore hosts will immediately be converted to another configuration with more thoughtful firewalling
  services.openssh = {
    openFirewall = true;
  };
}

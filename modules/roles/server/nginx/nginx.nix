{ inputs, ... }:
{
  imports = [ inputs.srvos.nixosModules.mixins-nginx ];

  services.nginx.recommendedUwsgiSettings = true;

  # nothing sets  security.acme.email  — add it before any vhost requests its first cert
  security.acme.acceptTerms = true;
}

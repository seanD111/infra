{ lib, ... }:
let
  modulesRoot = ../modules;

  collect =
    prefix: dir:
    let
      entries = builtins.readDir dir;
      subdirs = lib.filterAttrs (_: type: type == "directory") entries;
      hasDefault = (entries."default.nix" or null) == "regular";
      childPrefixes = builtins.mapAttrs (
        name: _: (if prefix == "" then name else "${prefix}/${name}")
      ) subdirs;
    in
    (lib.optionalAttrs hasDefault { ${prefix} = dir + "/default.nix"; })
    // builtins.foldl' (acc: name: acc // (collect childPrefixes.${name} (dir + "/${name}"))) { } (
      builtins.attrNames childPrefixes
    );

  exposed = collect "" modulesRoot;
in
{
  flake.nixosModules =
    exposed
    // lib.optionalAttrs (exposed ? "roles") {
      "default" = exposed."roles";
    };
}

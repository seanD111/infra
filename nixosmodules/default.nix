let
  modulesRoot = ../modules;

  collect =
    prefix: dir:
    let
      entries = builtins.readDir dir;
      subdirs = builtins.filter (name: entries.${name} == "directory") (builtins.attrNames entries);
      hasDefault = (entries."default.nix" or null) == "regular";
      childPrefix = name: if prefix == "" then name else "${prefix}/${name}";
    in
    (if hasDefault then { ${prefix} = dir + "/default.nix"; } else { })
    // builtins.foldl' (acc: name: acc // (collect (childPrefix name) (dir + "/${name}"))) { } subdirs;

  exposed = collect "" modulesRoot;
in
exposed // (if exposed ? "roles" then { "default" = exposed."roles"; } else { })

{
  name = "infra-workstation-sway";
  defaults.system.stateVersion = "26.05";
  defaults.users.allowNoPasswordLogin = true;

  nodes.workstation = {
    users.users.alice = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "video"
        "audio"
        "input"
      ];
    };

    services.getty.autologinUser = "alice";

    programs.bash.loginShellInit = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        mkdir -p ~/.config/sway
        cat /etc/sway/config > ~/.config/sway/config
        echo 'bar { command "waybar" }' >> ~/.config/sway/config
        echo 'output * bg "#101010" solid_color' >> ~/.config/sway/config
        sway --validate
        sway
      fi
    '';

    environment.variables = {
      SWAYSOCK = "/tmp/sway-ipc.sock";
      WLR_RENDERER = "pixman";
    };

    virtualisation.qemu.options = [ "-vga none -device virtio-gpu-pci" ];
  };

  testScript = ''
    import json
    import shlex

    q = shlex.quote

    def swaymsg(command="", type="command"):
        shell = q(f"swaymsg -t {q(type)} -- {q(command)}")
        return json.loads(workstation.succeed(f"su - alice -c {shell}"))

    def walk(tree):
        yield tree
        for group in ("nodes", "floating_nodes"):
            for node in tree.get(group, []):
                yield from walk(node)

    def wait_for_window(pattern):
        def check(_):
            return any(
                pattern in (node.get("name") or "")
                or pattern in (node.get("app_id") or "")
                for node in walk(swaymsg(type="get_tree"))
            )

        retry(check)

    workstation.start()
    workstation.succeed("systemctl is-enabled bluetooth.service")
    workstation.succeed("grep -q 'AutoEnable=false' /etc/bluetooth/main.conf")
    workstation.succeed("grep -q 'PairableTimeout=30' /etc/bluetooth/main.conf")
    workstation.wait_for_unit("multi-user.target")
    workstation.wait_for_file("/run/user/1000/wayland-1")
    workstation.wait_for_file("/tmp/sway-ipc.sock")

    tree = swaymsg(type="get_tree")
    assert tree["type"] == "root", "sway IPC is not a root tree"
    workstation.wait_until_succeeds("pgrep waybar")


    swaymsg("exec foot")
    wait_for_window("foot")
    workstation.sleep(2)

    # Capture the compositor framebuffer from inside the guest: this shows
    # the real desktop (background, bar, windows) regardless of the emulated
    # display state.
    workstation.succeed(
        "su - alice -c 'XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-1 grim /tmp/sway-desktop.png'"
    )
    workstation.copy_from_machine("/tmp/sway-desktop.png", "")
    workstation.screenshot("display")
  '';
}

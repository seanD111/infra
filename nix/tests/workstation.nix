{
  name = "infra-workstation";
  defaults.system.stateVersion = "26.05";
  defaults.users.allowNoPasswordLogin = true;

  enableOCR = true;

  nodes.workstation = {
    virtualisation.graphics = true;
    services.pipewire.systemWide = true;
    systemd.services.pipewire.wantedBy = [ "multi-user.target" ];
  };

  testScript = ''
    workstation.start()

    workstation.succeed("systemctl is-enabled bluetooth.service")
    workstation.succeed("bluetoothctl --version")
    workstation.succeed("grep -q 'AutoEnable=false' /etc/bluetooth/main.conf")
    workstation.succeed("grep -q 'PairableTimeout=30' /etc/bluetooth/main.conf")

    workstation.wait_for_unit("pipewire.service")
    workstation.succeed("systemctl cat rtkit-daemon.service | grep -q Realtime")

    workstation.succeed("test -f /etc/firefox/policies/policies.json")
    workstation.succeed("grep -q bitwarden /etc/firefox/policies/policies.json")
    workstation.succeed("grep -q 'uBlock0@raymondhill.net' /etc/firefox/policies/policies.json")

    workstation.succeed("grep -q 'symlinks = false' /etc/gitconfig")
    workstation.succeed("grep -q 'fsckobjects = true' /etc/gitconfig")

    workstation.succeed("[[ $(cat /proc/sys/kernel/yama/ptrace_scope) == 2 ]]")

    workstation.wait_for_unit("getty@tty1.service")
    workstation.wait_for_text("login")
    workstation.screenshot("console")
  '';
}

{ config, lib, ... }:
{
  boot = {
    consoleLogLevel = lib.mkDefault 0;
    loader.systemd-boot.editor = lib.mkDefault false;

    kernelModules = lib.mkIf (!config.boot.isContainer) (lib.mkDefault [ "jitterentropy_rng" ]);

    kernelParams = [
      "mitigations=auto,nosmt"
      "pti=on"
      "amd_iommu=force_isolation"
      "intel_iommu=on"
      "iommu=force"
      "iommu.strict=1"
      "iommu.passthrough=0"
      "vsyscall=none"
      "vdso32=0"
      "slab_nomerge"
      "slab_debug=FZ"
      "init_on_alloc=1"
      "init_on_free=1"
      "page_alloc.shuffle=1"
      "randomize_kstack_offset=on"
      "bdev_allow_write_mounted=0"
      "kfence.sample_interval=100"
      "hash_pointers=always"
      "hardened_usercopy=1"
      "proc_mem.force_override=ptrace"
      "random.trust_cpu=off"
      "random.trust_bootloader=off"
      "debugfs=off"
      "efi_pstore.pstore_disable=1"
      "erst_disable"
      "quiet"
      "udev.log_level=3"
    ];

    kernel.sysctl = {
      "kernel.dmesg_restrict" = lib.mkDefault 1;
      "kernel.kptr_restrict" = 2;
      "kernel.randomize_va_space" = lib.mkDefault 2;
      "kernel.sysrq" = lib.mkDefault 0;
      "kernel.unprivileged_bpf_disabled" = lib.mkDefault 1;
      "kernel.yama.ptrace_scope" = lib.mkDefault 2;
      "kernel.io_uring_disabled" = lib.mkDefault 2;
      "kernel.kexec_load_disabled" = lib.mkDefault 1;
      "kernel.perf_event_paranoid" = lib.mkDefault 3;
      "kernel.perf_cpu_time_max_percent" = lib.mkDefault 1;
      "kernel.perf_event_max_sample_rate" = lib.mkDefault 1;
      "kernel.core_pattern" = lib.mkDefault "|/bin/false";
      "kernel.core_uses_pid" = lib.mkDefault 1;
      "kernel.printk" = lib.mkOverride 900 "3 3 3 3";
      "fs.protected_fifos" = lib.mkDefault 2;
      "fs.protected_hardlinks" = lib.mkDefault 1;
      "fs.protected_regular" = lib.mkDefault 2;
      "fs.protected_symlinks" = lib.mkDefault 1;
      "fs.suid_dumpable" = lib.mkDefault 0;
      "vm.unprivileged_userfaultfd" = lib.mkDefault 0;
      "abi.vsyscall32" = lib.mkDefault 0;
      "dev.tty.ldisc_autoload" = lib.mkDefault 0;
      "dev.tty.legacy_tiocsti" = lib.mkDefault 0;
      "net.core.bpf_jit_harden" = lib.mkDefault 2;
      "net.ipv4.ip_forward" = lib.mkDefault 0;
      "net.ipv4.tcp_syncookies" = lib.mkDefault 1;
      "net.ipv4.tcp_timestamps" = lib.mkDefault 1;
      "net.ipv4.tcp_rfc1337" = lib.mkDefault 1;
      "net.ipv4.icmp_echo_ignore_broadcasts" = lib.mkDefault 1;
      "net.ipv4.icmp_ignore_bogus_error_responses" = lib.mkDefault 1;
      "net.ipv4.conf.all.accept_redirects" = lib.mkDefault 0;
      "net.ipv4.conf.default.accept_redirects" = lib.mkDefault 0;
      "net.ipv4.conf.all.accept_source_route" = lib.mkDefault 0;
      "net.ipv4.conf.default.accept_source_route" = lib.mkDefault 0;
      "net.ipv4.conf.all.send_redirects" = lib.mkDefault 0;
      "net.ipv4.conf.default.send_redirects" = lib.mkDefault 0;
      "net.ipv4.conf.all.secure_redirects" = lib.mkDefault 1;
      "net.ipv4.conf.default.secure_redirects" = lib.mkDefault 1;
      "net.ipv4.conf.all.shared_media" = lib.mkDefault 0;
      "net.ipv4.conf.default.shared_media" = lib.mkDefault 0;
      "net.ipv4.conf.all.log_martians" = lib.mkDefault 1;
      "net.ipv4.conf.default.log_martians" = lib.mkDefault 1;
      "net.ipv4.conf.all.arp_announce" = lib.mkDefault 2;
      "net.ipv4.conf.default.arp_announce" = lib.mkDefault 2;
      "net.ipv4.conf.all.arp_ignore" = lib.mkDefault 2;
      "net.ipv4.conf.default.arp_ignore" = lib.mkDefault 2;
      "net.ipv4.conf.all.arp_filter" = lib.mkDefault 1;
      "net.ipv4.conf.default.arp_filter" = lib.mkDefault 1;
      "net.ipv4.conf.all.forwarding" = lib.mkDefault 0;
      "net.ipv4.conf.default.forwarding" = lib.mkDefault 0;
      "net.ipv6.conf.all.accept_redirects" = lib.mkDefault 0;
      "net.ipv6.conf.default.accept_redirects" = lib.mkDefault 0;
      "net.ipv6.conf.all.accept_source_route" = lib.mkDefault 0;
      "net.ipv6.conf.default.accept_source_route" = lib.mkDefault 0;
      "net.ipv6.conf.all.forwarding" = lib.mkDefault 0;
      "net.ipv6.conf.default.forwarding" = lib.mkDefault 0;
      "net.ipv6.conf.all.use_tempaddr" = lib.mkDefault 2;
      "net.ipv6.conf.default.use_tempaddr" = lib.mkDefault 2;
      "net.ipv6.conf.all.max_addresses" = lib.mkDefault 1;
      "net.ipv6.conf.default.max_addresses" = lib.mkDefault 1;
      "net.ipv6.conf.all.router_solicitations" = lib.mkDefault 0;
      "net.ipv6.conf.default.router_solicitations" = lib.mkDefault 0;
      "net.ipv6.conf.all.dad_transmits" = lib.mkDefault 0;
      "net.ipv6.conf.default.dad_transmits" = lib.mkDefault 0;
      "net.ipv6.icmp.echo_ignore_multicast" = lib.mkDefault 1;
      "net.ipv6.icmp.echo_ignore_anycast" = lib.mkDefault 1;
    };
  };

  services.jitterentropy-rngd.enable = lib.mkIf (!config.boot.isContainer) (lib.mkDefault true);

  systemd.coredump.settings.Coredump.Storage = "none";

  security.pam = {
    loginLimits = [
      {
        domain = "*";
        item = "core";
        type = "hard";
        value = "0";
      }
    ];
    services = {
      login.failDelay = {
        enable = lib.mkDefault true;
        delay = lib.mkDefault 4000000;
      };
      su.requireWheel = lib.mkDefault true;
      su-l.requireWheel = lib.mkDefault true;
      passwd.rules.password."unix".settings.rounds = lib.mkDefault "8";
    };
  };

  programs.git = {
    enable = true;
    config = {
      core.symlinks = false;
      transfer.fsckobjects = true;
      fetch.fsckobjects = true;
      receive.fsckobjects = true;
    };
  };
}

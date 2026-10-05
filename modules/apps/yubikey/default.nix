# YubiKey support: pcscd, udev rules, PAM challenge-response, GPG agent SSH support.
#
# Program the YubiKey for challenge-response on slot 2 and set up the current
# user for logon:
#   1) nix-shell -p yubico-pam -p yubikey-manager
#   2) ykman otp chalresp --touch --generate 2
#   3) ykpamcfg -2 -v
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.apps.yubikey;

  lockRules = lib.concatMapStrings (
    { vendorId, modelId }:
    let
      lockScript = pkgs.writeShellScript "yubikey-lock" ''
        sleep 1
        # Check if Yubikey is still present
        if ! ${pkgs.usbutils}/bin/lsusb -d ${vendorId}:${modelId} > /dev/null 2>&1; then
          ${pkgs.systemd}/bin/loginctl lock-sessions
        fi
      '';
    in
    ''
      ACTION=="remove",\
      ENV{ID_BUS}=="usb",\
      ENV{ID_MODEL_ID}=="${modelId}",\
      ENV{ID_VENDOR_ID}=="${vendorId}",\
      ENV{ID_VENDOR}=="Yubico",\
      RUN+="${lockScript}"
    ''
  ) cfg.lockDevices;
in
{
  options.apps.yubikey = {
    enable = lib.mkEnableOption "YubiKey support (pcscd, udev rules, PAM, GPG agent)";

    ids = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "30401752" ];
      description = ''
        YubiKey token IDs (decimal form) passed to `pam_yubico`.

        Only used with `mode = "client"` (Yubico cloud OTP validation); in
        `challenge-response` mode authentication relies on the per-user
        `~/.yubico/challenge-*` files created by `ykpamcfg`.
      '';
    };

    mode = lib.mkOption {
      type = lib.types.enum [
        "challenge-response"
        "client"
      ];
      default = "challenge-response";
      description = ''
        PAM mode: `challenge-response` (offline, slot 2 via `ykpamcfg`) or
        `client` (online OTP validation against the Yubico API).
      '';
    };

    control = lib.mkOption {
      type = lib.types.enum [
        "required"
        "requisite"
        "sufficient"
        "optional"
      ];
      default = "sufficient";
      description = ''
        PAM control flag. Use `required` for multi-factor (password *and*
        YubiKey); `sufficient` allows the YubiKey to replace the password.
      '';
    };

    lockOnRemoval = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Lock all sessions (`loginctl lock-sessions`) when a YubiKey is unplugged.";
    };

    lockDevices = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            vendorId = lib.mkOption {
              type = lib.types.str;
              default = "1050";
              description = "Yubico USB vendor ID.";
            };
            modelId = lib.mkOption {
              type = lib.types.str;
              description = "USB model/product ID of the YubiKey (e.g. `0407`).";
            };
          };
        }
      );
      default = [
        {
          vendorId = "1050";
          modelId = "0407";
        }
      ];
      example = [
        {
          vendorId = "1050";
          modelId = "0407";
        }
        {
          vendorId = "1050";
          modelId = "0404";
        }
      ];
      description = ''
        USB device IDs that trigger the auto-lock rule on removal
        (`lsusb -d vendor:model` must match the plugged-in key). `0407`
        covers YubiKey 5 CCID composite devices; check with `lsusb`.
      '';
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional YubiKey-related packages to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [
        age-plugin-yubikey
        yubikey-manager
        yubico-pam
        yubihsm-connector
        # yubihsm-shell #this is broken in 25.11 / nixpkgs-unstable
      ]
      ++ cfg.extraPackages;

    services = {
      pcscd.enable = true;
      udev = {
        packages = [ pkgs.yubikey-personalization ];
        extraRules = lib.mkIf cfg.lockOnRemoval lockRules;
      };
    };

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    security.pam.yubico = {
      enable = true;
      inherit (cfg) control mode;
      id = cfg.ids;
    };
  };
}

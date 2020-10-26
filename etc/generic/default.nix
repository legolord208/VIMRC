# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, options, pkgs, shared, ... }:

{
  options.setup = {
    name = lib.mkOption {
      type = lib.types.str;
      description = "The name of this deployment, same as the folder's name in /etc.";
    };
    networkId = lib.mkOption {
      type = lib.types.str;
      description = "Same as network.hostId, obtain using `head -c8 /etc/machine-id`";
    };
  };

  imports = [
    # Files
    ./containers.nix
    ./fonts.nix
    ./gui.nix
    ./meta.nix
    ./packages.nix
    ./services.nix
    ./sudo.nix
  ];

  config = {
    boot = {
      supportedFilesystems = [ "btrfs" "zfs" ];

      # These systems will be able to be emulated transparently. Enabling
      # aarch64 will allow me to run aarch64 executables (using
      # qemu-aarch64 behind the scenes). If I were to enable windows here,
      # all .exe files will be handled using WINE.
      binfmt.emulatedSystems = [ "aarch64-linux" ];

      # systemd-boot
      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot = {
          enable = true;
          configurationLimit = 5;
          editor = false;
        };
      };
    };

    # Add some extra drivers
    hardware.enableRedistributableFirmware = true;

    # Misc. settings
    documentation.dev.enable  = true;
    hardware.bluetooth.enable = true;
    time.hardwareClockInLocalTime = true; # fuck windows

    # Networking
    networking.hostId = config.setup.networkId;
    networking.hostName = "samuel-${config.setup.name}";
    networking.networkmanager.enable = true;
    networking.firewall.enable = false;

    # Mime type for wasm, see https://github.com/mdn/webassembly-examples/issues/5
    environment.etc."mime.types".text = ''
      application/wasm  wasm
    '';

    # User settings
    users.users."${shared.consts.user}" = {
      initialPassword = "nixos";
      isNormalUser    = true;
      extraGroups     = [ "libvirtd" "adbusers" ];
    };

    # This value determines the NixOS release with which your system is to be
    # compatible, in order to avoid breaking some software such as database
    # servers. You should change this only after NixOS release notes say you
    # should.
    system.stateVersion = "18.03"; # Did you read the comment?
  };
}

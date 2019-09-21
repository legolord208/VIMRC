{ pkgs, lib, ... }:

let
  shared = pkgs.callPackage <dotfiles/shared> {};
  generators = import <dotfiles/shared/generators.nix>;

  # Packages
  abottomod = shared.builders.buildPypiPackage {
    name = "abottomod";
    src = ~/Coding/Python/abottomod;
  };
in
{
  deployment = {
    targetEnv = "none";
    targetHost = "192.168.2.42";
  };

  nixpkgs.localSystem = (import <nixpkgs/lib>).systems.examples.aarch64-multiplatform;

  imports = [
    # Shared base settings
    ../base.nix

    # Generated hardware configuration
    ./hardware-configuration.nix

    (generators.serviceUser { name = "abottomod"; script = "${abottomod}/bin/start"; })
  ];

  # Bootloader - need sd-image-aarch64 to create new generations?
  boot.loader.grub.enable = false;
  boot.loader.raspberryPi = {
    enable = true;
    uboot.enable = true;
    version = 3;
  };

  # Enable NetworkManager
  networking.wireless.enable = false; # disable default wireless support
  networking.networkmanager.enable = true;
}

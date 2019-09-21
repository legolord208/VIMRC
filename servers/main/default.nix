{ pkgs, ... }:

let
  shared = pkgs.callPackage <dotfiles/shared> {};
  generators = import <dotfiles/shared/generators.nix>;

  #  ____            _
  # |  _ \ __ _  ___| | ____ _  __ _  ___  ___
  # | |_) / _` |/ __| |/ / _` |/ _` |/ _ \/ __|
  # |  __/ (_| | (__|   < (_| | (_| |  __/\__ \
  # |_|   \__,_|\___|_|\_\__,_|\__, |\___||___/
  #                            |___/

  timeywimey = shared.builders.buildPypiPackage {
    name = "timeywimey";
    src = ~/Coding/Python/timeywimey;
  };
  redox-world-map = shared.builders.buildRustPackage {
    name = "redox-world-map";
    src = ~/Coding/Web/redox-world-map;
    buildInputs = with pkgs; [ pkgconfig openssl sqlite ];
    wrapperHook = ''
      ln -sf $out/src/Rocket.toml .
    '';
  };

  #  _   _      _
  # | | | | ___| |_ __   ___ _ __ ___
  # | |_| |/ _ \ | '_ \ / _ \ '__/ __|
  # |  _  |  __/ | |_) |  __/ |  \__ \
  # |_| |_|\___|_| .__/ \___|_|  |___/
  #              |_|

  createZncServers = servers: builtins.listToAttrs (map (server: let
      url = builtins.getAttr server servers;
    in {
      name = server;
      value = {
        server = url;
        modules = [ "simple_away" "sasl" ];
      };
    }) (builtins.attrNames servers));
in {
  #  __  __      _            _       _
  # |  \/  | ___| |_ __ _  __| | __ _| |_ __ _
  # | |\/| |/ _ \ __/ _` |/ _` |/ _` | __/ _` |
  # | |  | |  __/ || (_| | (_| | (_| | || (_| |
  # |_|  |_|\___|\__\__,_|\__,_|\__,_|\__\__,_|

  deployment = {
    targetEnv = "digitalOcean";
    digitalOcean = {
      region = "ams3";
      size = "s-1vcpu-1gb";
    };
  };

  disabledModules = [ "services/networking/syncthing.nix" ];
  imports = [
    # Shared base settings
    ../base.nix

    # Files
    ./email.nix
    ./web.nix

    # Generated services
    (generators.serviceUser { name = "timeywimey"; script = "${timeywimey}/bin/start"; })
    (generators.serviceUser { name = "redox-world-map"; script = "${redox-world-map}/bin/start"; })

    # Unstable modules
    <nixos-unstable/nixos/modules/services/networking/syncthing.nix>
  ];

  #  ____                  _
  # / ___|  ___ _ ____   _(_) ___ ___  ___
  # \___ \ / _ \ '__\ \ / / |/ __/ _ \/ __|
  #  ___) |  __/ |   \ V /| | (_|  __/\__ \
  # |____/ \___|_|    \_/ |_|\___\___||___/

  services.syncthing = {
    enable = true;
    declarative = {
      overrideDevices = true;
      devices = {
        computer = {
          id = "ILTIRMY-JT4SGSQ-AWETWCV-SLQYHE6-CY2YGAS-P3EGWY6-LSP7H4Z-F7ZQIAN";
          introducer = true;
        };
        phone = {
          id = "O7H6BPC-PKQPTT4-T4SEA7K-VI7HJ4K-J7ZJO5K-NWLNAK5-RBVCSBU-EXDHSA3";
        };
      };
      overrideFolders = false;
    };
    relay = {
      enable = true;
      providedBy = "krake.one on DigitalOcean";
    };
  };
  services.znc = {
    enable = true;
    confOptions = {
      userName = shared.consts.name;
      nick = shared.consts.name;
      passBlock = shared.consts.secret.zncPassBlock;
      networks = createZncServers {
        freenode = "chat.freenode.net";
        mozilla = "irc.mozilla.org";
      };
    };
  };
}

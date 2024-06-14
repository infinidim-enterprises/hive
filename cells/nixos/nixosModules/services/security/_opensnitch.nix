{ config, lib, pkgs, ... }:

with lib;
let
  name = "opensnitch";
  cfg = config.services.opensnitch;
  cfgEtc = config.environment.etc;
  hmCfgUsers = config.home-manager.users;
  isHm = config ? home-manager;
  isHmCfg = (length (attrNames config.home-manager.users)) > 0;
  allUserRules = unique (flatten (map (r: r.services.opensnitch.allow) (attrValues hmCfgUsers)));

  tmpl8 = { data }: {
    action = "allow";
    created = "1980-01-01T01:01:01.01+01:00";
    duration = "always";
    enabled = true;
    name = "${baseNameOf data}_allow-always";
    operator = {
      inherit data;
      list = [ ];
      operand = "process.path";
      sensitive = false;
      type = "simple";
    };
    precedence = false;
    updated = "1980-01-01T01:01:01.01+01:00";
  };

  mkRules = with builtins; map (r: if isString r then tmpl8 { data = r; } else tmpl8 { data = "${r}/bin/${(parseDrvName r.name).name}"; });
  mkEtcDir = with builtins;
    rules:
    listToAttrs (map
      (r: nameValuePair
        "${removePrefix "/etc/" cfg.rules-path}/${hashString "sha256" r.name}.json"
        { text = toJSON r; })
      (mkRules rules));

  /*
    [Desktop Entry]
    Type=Application
    Name=OpenSnitch
    Exec=/bin/sh -c 'pkill -15 opensnitch-ui; opensnitch-ui'
    Icon=opensnitch-ui
    GenericName=OpenSnitch Firewall
    GenericName[hu]=OpenSnitch-tűzfal
    Comment=Application firewall
    Comment[es]=Firewall de aplicaciones
    Comment[hu]=Alkalmazási tűzfal
    Terminal=false
    NoDisplay=false
    Categories=System;Security;Monitor;Network;
    Keywords=system;firewall;policies;security;polkit;policykit;
    X-GNOME-Autostart-Delay=3
    X-GNOME-Autostart-enabled=true
  */

  opensnitch-ui-desktop-item = pkgs.makeDesktopItem {
    name = "opensnitch_ui";
    # fileValidation = false;
    desktopName = "OpenSnitch";
    genericName = "OpenSnitch Firewall";
    noDisplay = false;
    terminal = false;
    exec =
      let
        socket = last (splitString ":" config.services.opensnitch.default-config.Server.Address);
        # cmdPre = with pkgs; "${procps}/bin/pkill -15 opensnitch-ui;";
      in
      "opensnitch-ui --socket \"[::]:${socket}\"";
    type = "Application";
    icon = "opensnitch-ui";
    comment = "Application firewall";
    categories = [ "System" "Security" "Monitor" "Network" ];
    extraDesktopEntries.X-GNOME-Autostart-Delay = "3";
    extraDesktopEntries.X-GNOME-Autostart-enabled = "true";
    extraDesktopEntries.Keywords = "system;firewall;policies;security;polkit;policykit;";
  };

  opensnitch-ui-desktop-startup-item = pkgs.makeAutostartItem { name = "opensnitch_ui"; package = opensnitch-ui-desktop-item; };

in
{
  options.services.opensnitch = {
    enable = mkEnableOption "Opensnitch application firewall";
    # FIXME: opensnitch service: refactor to only use single var everywhere!
    rules-path = with types; mkOption { type = str; default = "/etc/opensnitchd/rules"; };
    allRules = mkOption { internal = true; default = allUserRules ++ cfg.defaultRules; };
    extraRules = with types; mkOption {
      type = listOf str;
      default = [ ];
    };

    # TODO: opensnitch defaultRules: file -e ascii -s ${pkgs.systemd}/lib/systemd/*
    # runCommandNoCC "name" {buildInputs = with pkgs; [file gnugrep];} ''for i in $(find ${pkgs.systemd} -type f -executable);do file $i | grep -v ASCII;done > $out''

    defaultRules = with types; mkOption {
      type = listOf str;
      internal = true;
      default = [
        (optionalString config.services.openssh.enable "${pkgs.openssh}/bin/sshd")
        "${pkgs.systemd}/lib/systemd/systemd-resolved"
        "${pkgs.systemd}/lib/systemd/systemd-timesyncd"
        "${pkgs.systemd}lib/systemd/systemd-networkd"
        "${config.nix.package}/bin/nix"
      ];
    };

    # https://github.com/evilsocket/opensnitch/wiki/Configurations

    system-fw = with types; mkOption {
      type = attrs;
      default = {
        SystemRules = [
          {
            Rule.Chain = "OUTPUT";
            Rule.Description = "Default allow icmp";
            Rule.Parameters = "-p icmp";
            Rule.Table = "mangle";
            Rule.Target = "ACCEPT";
            Rule.TargetParameters = "";
          }

          {
            # ISSUE: https://github.com/evilsocket/opensnitch/issues/510#issuecomment-920710522
            Rule.Chain = "OUTPUT";
            Rule.Description = "Allow nfs";
            Rule.Parameters = "-p tcp --dport 2049";
            Rule.Table = "mangle";
            Rule.Target = "ACCEPT";
            Rule.TargetParameters = "";
          }

          {
            Rule.Chain = "OUTPUT";
            Rule.Description = "Allow nebula network";
            Rule.Parameters = "-p udp --dport 65242";
            Rule.Table = "mangle";
            Rule.Target = "ACCEPT";
            Rule.TargetParameters = "";
          }

          {
            Rule.Chain = "OUTPUT";
            Rule.Description = "Allow nebula.admin network";
            Rule.Parameters = "-d 10.22.1.0/24";
            Rule.Table = "mangle";
            Rule.Target = "ACCEPT";
            Rule.TargetParameters = "";
          }

          {
            Rule.Chain = "OUTPUT";
            Rule.Description = "Allow zerotierone network";
            Rule.Parameters = "-d 10.22.0.0/24";
            Rule.Table = "mangle";
            Rule.Target = "ACCEPT";
            Rule.TargetParameters = "";
          }

        ];
      };
    };

    default-config = with types; mkOption {
      type = attrs;
      default = {
        DefaultAction = "allow";
        DefaultDuration = "always";
        Firewall = "iptables";
        InterceptUnknown = false;
        LogLevel = 5;
        # TODO: opensnitch ebpf: https://github.com/evilsocket/opensnitch/tree/master/ebpf_prog
        ProcMonitorMethod = "proc";
        Server = {
          Address = "127.0.0.1:4444";
          # Address = "unix:///tmp/osui.sock";
          # TODO: make opensnitchd serve to multiple ui Address = "127.0.0.1:4444";
          LogFile = "/dev/stdout";
        };
        Stats = { MaxEvents = 150; MaxStats = 25; };
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      environment.systemPackages = [
        pkgs.opensnitch-ui
        (hiPrio opensnitch-ui-desktop-item)
        opensnitch-ui-desktop-startup-item
      ];

      environment.etc = {
        "opensnitchd/default-config.json".text = builtins.toJSON cfg.default-config;
        "opensnitchd/system-fw.json".text = builtins.toJSON cfg.system-fw;
      } // (mkEtcDir (cfg.defaultRules ++ cfg.extraRules));

      systemd.services.opensnitchd = {
        description = "OpenSnitch is a GNU/Linux port of the Little Snitch application firewall.";
        documentation = [ "https://github.com/gustavo-iniguez-goya/opensnitch/wiki" ];
        after = [ "network.target" "systemd-tmpfiles-setup.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig.ExecStart = "${pkgs.opensnitch}/bin/opensnitchd -rules-path ${cfg.rules-path} -error";
        serviceConfig.Restart = "always";
        serviceConfig.RestartSec = 30;
        serviceConfig.PermissionsStartOnly = true;
        restartTriggers = [
          cfgEtc."opensnitchd/default-config.json".source
          cfgEtc."opensnitchd/system-fw.json".source
        ];
      };

      # NOTE: theme/gtk and other settings aren't getting picked up here.
      # systemd.user.services.openswitch-ui = {
      #   description = "Opensnitch ui";
      #   after = [ "graphical-session-pre.target" ];
      #   partOf = [ "graphical-session.target" ];
      #   wantedBy = [ "graphical-session.target" ];
      #   serviceConfig.ExecStart = "${pkgs.opensnitch-ui}/bin/opensnitch-ui";
      # };

    })

    (mkIf (cfg.enable && ((length allUserRules) < 1)) {
      # NOTE: https://www.freedesktop.org/software/systemd/man/tmpfiles.d.html
      systemd.tmpfiles.rules = [ "d ${cfg.rules-path} 0755 root root - -" ];
    })

    (mkIf isHm {
      home-manager.sharedModules = [
        ({ config, lib, ... }: {
          # options.services.opensnitch.enable = mkEnableOption "Enable nixos opensnitch module integration.";
          options.services.opensnitch.allow = with types; mkOption {
            type = listOf anything;
            default = [ ];
          };
        })
      ];
    })

    (mkIf (cfg.enable && isHm && isHmCfg && ((length allUserRules) > 0)) {
      environment.etc = mkEtcDir allUserRules;
    })

  ];
}

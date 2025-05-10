/*
  NOTE:
  actual size (applicable to all folfangas as well): 218x136 mm. http://www.screen-size.info/
  i'm working with 0.75 / 1.25 scale factors
  panning example here: https://blog.summercat.com/configuring-mixed-dpi-monitors-with-xrandr.html
  to allow mouse to pan, the resolution should be multiplied by scale factor and hence the panning area.
  also, apparently the mode changes as well, so investigate!
  TODO: I want to eschew using x11vncGeometry in favor of maybe doing xrandr scaling on clients instead, this would be neater!

  xrandr --output VIRTUAL5 \
  --pos 1920x3360 \
  --mode  X[mode]  x Y[mode] \
  --scale X[scale] x Y[scale] \
  --panning (X[mode] * X[scale]) x (Y[mode] * Y[scale]) + pos
*/

{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.xserver.remote-display;
  cfgHost = cfg.host;
  cfgClient = cfg.client;

  reqPkgs = with pkgs; [
    remote-display-xscreensaver-chvt
    xscreensaver
    toggle-decorations
    dbus.lib
    dbus
    systemd
    openssh
    gawk
    libressl.nc
    coreutils
    inetutils
    wmctrl
    gnugrep
    xdotool
    utillinux
    tigervnc
    x11vnc
    procps
    xorg.xorgserver
    xorg.xbacklight
    xorg.xrandr
    xorg.xwininfo
  ];

  remote-display-xscreensaver-chvt =
    pkgs.writeShellScriptBin
      "remote-display-xscreensaver-chvt"
      (fileContents ./dbus-screensaver.sh);

  # _remote-display-xscreensaver-chvt = pkgs.stdenv.mkDerivation rec {
  #   name = "remote-display-xscreensaver-chvt";
  #   version = "1.0";
  #   buildInputs = [ pkgs.ruby ];
  #   src = ./remote_chvt.rb;
  #   unpackPhase = ''
  #     cp $src ${name}
  #   '';
  #   buildPhase = ''
  #     substituteInPlace ${name} --replace "#!/usr/bin/env nix-shell" "#!ruby"
  #   '';
  #   installPhase = ''
  #     mkdir -p $out/bin
  #     install -Dm0755 ${name} -t $out/bin
  #   '';
  # };

  toggle-decorations = pkgs.stdenv.mkDerivation rec {
    pname = "toggle-decorations";
    version = "1.0";
    nativeBuildInputs = [ pkgs.pkgconfig ];
    buildInputs = with pkgs; [ xorg.libX11 xorg.libXmu glib ];
    src = pkgs.fetchurl {
      url = "https://gist.githubusercontent.com/muktupavels/d03bb14ea6042b779df89b4c87df975d/raw/2b7073ca8e61cf90b367e1e343eaa3808fd40be0/toggle-decorations.c";
      sha256 = "1jrm4k2pca8dx1z83kx9a4477nlpi90nkg7m49ncydsx2sfmw62k";
    };
    unpackPhase = ''
      cp $src toggle-decorations.c
    '';
    buildPhase = ''
      gcc toggle-decorations.c -Wall -o toggle-decorations `pkg-config --cflags --libs x11`
    '';
    installPhase = ''
      mkdir -p $out/bin
      install -Dm0755 toggle-decorations -t $out/bin
    '';
  };

  fbSize = scrs:
    let
      # TODO: refactor this shit!
      all_x = sort (a: b: a < b) (unique (map (x: toInt x.pos.x) scrs));
      xList = filter (x: x.pos.x == (toString (last all_x))) scrs;
      all_y = sort (a: b: a < b) (unique (map (x: toInt x.pos.y) scrs));
      yList = filter (x: x.pos.y == (toString (last all_y))) scrs;
      max_x =
        let
          scrAttrs = last (sort (a: b: (toInt a.size.x) < (toInt b.size.x)) xList);
        in
        toString ((toInt scrAttrs.pos.x) + (toInt scrAttrs.size.x));
      max_y =
        let
          scrAttrs = last (sort (a: b: (toInt a.size.y) < (toInt b.size.y)) yList);
        in
        toString ((toInt scrAttrs.pos.y) + (toInt scrAttrs.size.y));
    in
    max_x + "x" + max_y;

  mkXrandrStr = scr:
    let
      # TODO: xrandr --dpi 96 for host screens
      hasOpts = hasAttr "xrandrExtraOpts" scr && isString scr.xrandrExtraOpts;
      rotate = hasOpts && isList (builtins.match ".*rotate.*" scr.xrandrExtraOpts);
      posStr = "${scr.pos.x}x${scr.pos.y}";
      mList = [ scr.size.x scr.size.y ];
      ml = if rotate then (reverseList mList) else mList;
      modeStr = {
        xr = concatStringsSep "x" ml;
        cvt = concatStringsSep " " ml;
      };
      # TODO: bin/gtf - the modern alternative to cvt
      newMode = "xrandr --newmode $(${pkgs.xorg_cvt}/bin/cvt -r ${modeStr.cvt} | grep -v '\"' | cut -d' ' -f 2) $(${pkgs.xorg_cvt}/bin/cvt -r  ${modeStr.cvt} | grep -v '^#' | cut -d' ' -f 3-) || true";
      addMode = "xrandr --addmode ${scr.id.xrandr} ${modeStr.xr} || true";
      applyMode = "xrandr --output ${scr.id.xrandr} --mode ${modeStr.xr} --pos ${posStr} ${optionalString hasOpts scr.xrandrExtraOpts}";
    in
    concatStringsSep "\n" [ newMode addMode applyMode ];

  systemd_user_services =
    mapAttrs'
      (cfgName: cfgScreens:
        let
          svc_pref = "remote-display";
          remotes = filter (x: hasAttr "hostName" x && x.hostName != null) cfgScreens;
          isRemote = (length remotes) > 0;
          x11vnc =
            if isRemote then
              listToAttrs
                (imap0
                  (i: x:
                    nameValuePair "${svc_pref}-${cfgName}-${x.id.vnc}" {
                      description = "${cfgName} - x11vnc ${x.id.vnc}@${x.hostName}:${x.port}";
                      serviceConfig.TimeoutSec = "7";
                      serviceConfig.Restart = "always";
                      serviceConfig.RestartSec = "1";
                      unitConfig.StartLimitIntervalSec = "5";
                      unitConfig.StartLimitBurst = "1";
                      path = reqPkgs;
                      preStart = ''
                        until nc -d -z ${x.hostName} 22;do sleep 1;done
                      '';
                      script = ''
                        x11vnc \
                          -ping 3 \
                          -noipv6 \
                          -xdamage \
                          -nocursorshape \
                          -nocursorpos \
                          -viewonly \
                          -blackout noptr \
                          -once \
                          -sleepin 1-5 \
                          -repeat \
                          -rfbport 0 \
                          -nopw \
                          -norc \
                          -nosel \
                          -nonc \
                          -nonap \
                          -nodpms \
                          -xrandr resize \
                          -display $DISPLAY \
                          -desktop ${x.id.vnc} \
                          ${optionalString (! isNull x.x11vncExtraOpts) "${x.x11vncExtraOpts} \\"}
                          ${optionalString (! isNull x.x11vncGeometry) "-geometry ${x.x11vncGeometry} \\"}
                          -clip "${x.size.x}x${x.size.y}+${x.pos.x}+${x.pos.y}" \
                          --connect_or_exit ${x.hostName}:${x.port}
                      '';
                      after =
                        let
                          notFirst = i > 0;
                          prev = mkIf notFirst "${svc_pref}-${cfgName}-${(elemAt remotes (i - 1)).id.vnc}.service";
                        in
                        [ "remote-display-${cfgName}.service" ] ++ (optional notFirst prev);
                    }
                  )
                  remotes
                ) else null;

          xrandr = rec {
            serviceConfig.Type = "oneshot";
            serviceConfig.RemainAfterExit = true;
            description = "Remote Display - ${cfgName}";
            path = reqPkgs;
            script = ''
              # An unknown bug/feature in xrandr and/or/with intel driver is handled in this loop.
              xrandr --fb ${fbSize cfgScreens}
              for i in 1 2 3
              do
                ${concatStringsSep "\n" (map (x: mkXrandrStr x) cfgScreens)}
                [[ "$i" -lt "3" ]] && (${removeSuffix "\n" postStop.content}) || true
              done
            '';

            postStop = mkIf isRemote ''
              for i in $(xrandr | grep -E '${concatStringsSep "|" (map (x: x.id.xrandr) remotes)}[[:space:]]{1}' | cut -d ' ' -f1);do xrandr --output $i --off; done
            '';

            after = [ "graphical-session.target" ];
            wants = (map (x: "${svc_pref}-${cfgName}-${x.id.vnc}.service") remotes) ++ [ "remote-display-${cfgName}-xscreensaver-chvt.service" ];
            requiredBy = (map (x: "${svc_pref}-${cfgName}-${x.id.vnc}.service") remotes) ++ [ "remote-display-${cfgName}-xscreensaver-chvt.service" ];
            conflicts = map (x: "remote-display-${x}.service") (remove cfgName (attrNames cfgHost.screens));
          };

          # FIXME/TODO: xset dpms force on
          xscreensaver-chvt = {
            after = [ "remote-display-${cfgName}.service" "xscreensaver.service" ];
            description = "Switch remote displays VT to save power and take advantage of acpi screen blanking";
            path = reqPkgs;
            script = ''
              remote-display-xscreensaver-chvt ${concatStringsSep " " (unique (map (r: r.hostName) remotes))}
            '';
          };
        in
        nameValuePair cfgName ({ "remote-display-${cfgName}" = xrandr; } // (optionalAttrs isRemote x11vnc) // { "remote-display-${cfgName}-xscreensaver-chvt" = xscreensaver-chvt; }))
      cfgHost.screens;

  display-setup-script-client = pkgs.writeShellScript "display-setup-script-client" ''
    set -e
    export PATH=${makeBinPath reqPkgs}:$PATH
    ${optionalString cfgClient.enable ''
      ${optionalString (! isNull cfgClient.brightness) "xbacklight -set ${cfgClient.brightness} || true\n"}
      ${concatStringsSep "\n" (map (x: mkXrandrStr x) cfgClient.screens)}
    ''}

    ${optionalString cfgClient.dbg.enable ''
      logger -t DM-SESSION 'x11vnc'
        x11vnc -ping 3 \
               -noipv6 \
               -cursorpos \
               -repeat \
               -noxdamage \
               -shared \
               -forever \
               -nolookup \
               -nopw \
               -norc \
               -nonc \
               -display $DISPLAY \
               -desktop DEBUG \
               -rfbport ${cfgClient.dbg.port} & x11vncPID=$!
        logger -t DM-SESSION "x11vnc with PID $x11vncPID"
    ''}
  '';

  remote-display-script-client = pkgs.writeShellScriptBin "remote-display-client" ''
    set -e
    export PATH=${makeBinPath reqPkgs}:$PATH
    [[ "$#" = "6" ]] || (echo "Usage: $0 name port size_x size_y pos_x pos_y" && exit 1)
    name=$1
    port=$2
    size_x=$3
    size_y=$4
    pos_x=$5
    pos_y=$6
    geom="''${size_x}x''${size_y}+''${pos_x}+''${pos_y}"

    while true
    do
      vncviewer ${optionalString cfgClient.dbg.enable "-Log \*:stdout:100"} -AutoSelect=0 \
                -AlertOnFatalError=${if cfgClient.dbg.enable then "1" else "0"} \
                -geometry $geom \
                -PreferredEncoding=Tight \
                -FullColor=1 \
                -NoJPEG=1 \
                -CompressLevel=6 \
                -QualityLevel=9 \
                -SendClipboard=0 \
                -ViewOnly \
                -UseIPv6=0 \
                -listen $port & vncViewer=$!

      until wmctrl -lx | grep -E "$name" | grep -oE '^0x?[[:xdigit:]]{5,20}';do sleep 1;done
      window_id=$(wmctrl -lx | grep -E "$name" | grep -oE '^0x?[[:xdigit:]]{5,20}')
      toggle-decorations $window_id
      xdotool windowsize $window_id $size_x $size_y
      xdotool windowmove $window_id $pos_x $pos_y

      wait $vncViewer
    done
  '';

  mkXdgPkgs = scr:
    let
      name = strings.toLower scr.id.vnc;
      di = pkgs.makeDesktopItem {
        inherit name;
        desktopName = name;
        noDisplay = true;
        exec = "${remote-display-script-client}/bin/remote-display-client ${scr.id.vnc} ${scr.port} ${scr.size.x} ${scr.size.y} ${scr.pos.x} ${scr.pos.y}";
        # extraEntries = ''
        #   NoDisplay=true
        # '';
      };

      si = pkgs.makeAutostartItem {
        inherit name;
        package = di;
      };
    in
    [ di si ];

  dconf = rec {
    customDconf = pkgs.writeTextFile {
      name = "rd-dconf";
      destination = "/dconf/rd-custom";
      text = ''
        [org/mate/desktop/session]
        required-components-list=['windowmanager']

        [org/mate/marco/general]
        num-workspaces=1

        [org/mate/power-manager]
        action-sleep-type-ac='nothing'
        action-sleep-type-battery='nothing'
        action-critical-battery='shutdown'
        sleep-display-ac=0
        sleep-display-battery=0
        backlight-enable=false
        brightness-ac=${if (! isNull cfgClient.brightness) then cfgClient.brightness else "12.0"}
        button-lid-ac='nothing'
        button-lid-battery='nothing'
        button-power='shutdown'
        button-suspend='nothing'
        idle-dim-time=0
        idle-dim-ac=false
        idle-dim-battery=false
        dpms-method-ac='off'
        dpms-method-battery='off'
        notify-discharging=false
        notify-fully-charged=false
        notify-discharging=false

        [org/mate/screensaver]
        idle-activation-enabled=false
        lock-enabled=false

        [org/mate/desktop/background]
        color-shading-type='solid'
        picture-options='wallpaper'
        primary-color='rgb(85,87,83)'
        secondary-color='rgb(60,143,37)'
      '';
    };

    customDconfDb =
      pkgs.runCommandNoCC "customDconfDb"
        {
          buildInputs = [ pkgs.dconf ];
        } ''
        iDir=$out/etc/dconf/db
        mkdir -p $iDir
        dconf compile $iDir/remote-display ${customDconf}/dconf
      '';

    dconf_profile = pkgs.writeText "dconf_profile" ''
      user-db:user
      system-db:remote-display
    '';

  };

  commonOpts = with types; {
    default = null;
    type = nullOr (oneOf [ str int ]);
    apply = v: if (! isNull v) then builtins.toString v else v;
  };

  geometryOptions = with types; { ... }: {
    options = {
      x = mkOption commonOpts;
      y = mkOption commonOpts;
    };
  };

  screenOptions = with types; { ... }: {
    options = {
      port = mkOption commonOpts;
      hostName = mkOption commonOpts;
      xrandrExtraOpts = mkOption commonOpts;
      x11vncGeometry = mkOption commonOpts;
      x11vncExtraOpts = mkOption commonOpts;
      id = {
        vnc = mkOption commonOpts;
        xrandr = mkOption commonOpts;
      };

      size = mkOption {
        type = submodule geometryOptions;
      };

      pos = mkOption {
        type = submodule geometryOptions;
      };
    };
  };

  screens = with types; mkOption {
    description = ''
    '';
    default = null;
    type = nullOr (listOf (submodule [ screenOptions ]));
  };

  dbg = {
    enable = mkEnableOption "Enable debugging";
    vncExtraArgs = mkOption commonOpts;
    port = mkOption commonOpts;
  };
in
{
  ###### interface
  options.services.xserver.remote-display = with types; {
    host = {
      enable = mkEnableOption "Remote display Host";
      inherit dbg;

      screens = mkOption {
        default = { };
        type = nullOr (loaOf (listOf (submodule [ screenOptions ])));
        example = {
          local-only = [{
            id.xrandr = "eDP1";
            xrandrExtraOpts = "--primary";
            x11vncGeometry = "2560x1600";
            x11vncExtraOpts = "-scale_cursor 1";
            size.x = "2560";
            size.y = "1600";
            pos.x = "0";
            pos.y = "0";
          }];
        };
      };
    };

    client = {
      enable = mkEnableOption "Remote display Client";
      brightness = mkOption commonOpts;
      inherit dbg screens;
    };
  };

  ###### implementation
  # TODO: services.xserver.displayManager.session
  # + lightdm on seat1 to autologin, leaving defaults for seat0
  config = mkMerge [
    # Common settings
    (mkIf (cfgHost.enable || cfgClient.enable) {
      services.xserver.enable = true;
    }
    )

    # Client settings
    (mkIf cfgClient.enable {
      users.groups.remote-display = { };
      users.users.remote-display = {
        packages = reqPkgs ++ (flatten (map (x: mkXdgPkgs x) cfgClient.screens));
        hashedPassword = null;
        description = "Remote Display user";
        isNormalUser = true;
        group = "remote-display";
      };

      programs.dconf.enable = true;
      programs.dconf.profiles.user = dconf.dconf_profile;
      programs.dconf.packages = [ dconf.customDconfDb ];
      # environment.etc."dconf/db/remote-display".source = dconf.customDconfDb;

      services.redshift.enable = true;
      services.redshift.extraOptions = [ "-m randr" ];
      services.redshift.brightness.day = mkDefault "0.75";
      services.redshift.temperature.day = mkDefault 4200;
      services.redshift.brightness.night = mkDefault "0.75";
      services.redshift.temperature.night = mkDefault 3800;

      services.logind.lidSwitch = mkDefault "ignore";
      services.xserver.desktopManager.mate.enable = true;
      environment.mate.excludePackages = with pkgs.mate; [
        mate-terminal
        mate-user-guide
        mate-netbook
        mate-power-manager
        mate-screensaver
        mate-media
        mate-calc
        mate-backgrounds
      ];

      services.xserver.serverLayoutSection = ''
        Option "StandbyTime" "0"
        Option "SuspendTime" "0"
        Option "OffTime"     "0"
        Option "BlankTime"   "0"
      '';

      services.xserver.displayManager.xserverArgs = [ "-nocursor" ];
      services.xserver.displayManager.defaultSession = "mate"; # TODO: mate+vncviewer
      services.xserver.displayManager.lightdm.enable = true;
      services.xserver.displayManager.autoLogin.user = "remote-display";
      services.xserver.displayManager.autoLogin.enable = true;
      services.xserver.displayManager.lightdm.autoLogin.timeout = 0;
      services.xserver.displayManager.lightdm.extraSeatDefaults = ''
        display-setup-script=${display-setup-script-client}
      '';

    })

    # Host settings
    (mkIf cfgHost.enable {
      # environment.systemPackages = [ pkgs.xss-lock ];
      systemd.user.services = foldAttrs (n: v: n // v) { } (attrValues systemd_user_services);
    })

    # Extras
  ];

}


/*
  https://flak.tedunangst.com/post/sct-set-color-temperature
  TODO: package this and use it https://flak.tedunangst.com/files/sct.c
  cc -std=c99 -O2 -I /usr/X11R6/include -o sct sct.c -L /usr/X11R6/lib -lm -lX11 -lXrandr

  TODO: https://github.com/philippnormann/xrandr-brightness-script
  TODO: https://mikescodeoddities.blogspot.com/2015/04/android-tablet-as-second-ubuntu-screen.html
  xrandr --output HDMI-1 --mode 1920x1080 --set "Broadcast RGB" "Full" --scale 1.53x1.53 --panning 2938x1653+0+0

  xset -dpms
  xset s off
  xset s noblank
  xset s noexpose
  xset s 0 0

  # getcap $(which ping)
  # serviceConfig.AmbientCapabilities = [ "CAP_NET_RAW" "CAP_SETPCAP" ];
*/

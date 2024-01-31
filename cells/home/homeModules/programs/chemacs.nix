{ config, lib, pkgs, modulesPath, osConfig, ... }:
with lib;
let
  cfg = config.programs.chemacs;
  xdg = config.xdg;
  otherOptions = (config._module.args.extendModules { }).options;
  defaultSession = filterAttrs (_: v: v.default) cfg.profiles;
  defaultProfile = head (attrNames defaultSession);

  mkLinks = kind: foldl' (n: v: n // v) { } (map
    (p: mapAttrs'
      (n: v:
        let
          links = nameValuePair "chemacs/${p}/${n}" ({ recursive = true; source = cfg.profiles.${p}.${kind} + "/" + n; });
          keepDir = nameValuePair "chemacs/${p}/.keep" { text = ""; };
          onChange = cfg.profiles.${p}.onCfgChangePerFile;
          condCfg = kind == "cfgDir";
          condNoLink = !cfg.profiles.${p}.linkCfg;
          condOnChange = ! isNull cfg.profiles.${p}.onCfgChangePerFile;
        in
        (if (condNoLink && condCfg) then keepDir else links //
          (optionalAttrs (condOnChange && condCfg) { inherit onChange; })))
      (builtins.readDir cfg.profiles.${p}.${kind}))
    (attrNames cfg.profiles));

  wrapperFor = i:
    let
      profile = cfg.profiles.${i}.emacsOpts;
      emacsPackages = (pkgs.emacsPackagesFor profile.package).overrideScope' profile.overrides;
      emacsWithPackages = emacsPackages.emacsWithPackages;
      finalPackage = emacsWithPackages profile.extraPackages;
      isBin = ''[[ -d ${xdg.dataHome}/chemacs/${i}/bin ]]'';
      addPath = ''PATH="${xdg.dataHome}/chemacs/${i}/bin:$PATH"'';
      execLine = ''exec ${finalPackage}/bin/emacs --with-profile ${i} "$@"'';
      execLine-client = ''exec ${finalPackage}/bin/emacsclient --socket-name ${i} "''${@:---create-frame}"'';
      # -create-frame  --alternate-editor="" --no-wait
    in
    {
      emacs = pkgs.writeShellScript "wrapper-${i}" ''
        ${isBin} && ${addPath} ${execLine} || ${execLine}
      '';

      emacs-client = pkgs.writeShellScriptBin "emacsclient-${i}" ''
        ${isBin} && ${addPath} ${execLine-client} || ${execLine-client}
      '';

      emacs-client-default = pkgs.writeShellScriptBin "emacsclient" ''
        ${isBin} && ${addPath} ${execLine-client} || ${execLine-client}
      '';

    };

  desktopItemFor = name:
    pkgs.makeDesktopItem {
      inherit name;
      icon = "emacs";
      comment = "${name} emacs profile";
      desktopName = "Emacs - ${name} profile";
      genericName = "Text Editor";
      exec = "${(wrapperFor name).emacs} %F";
      type = "Application";
      categories = [ "Development" "TextEditor" ];
      # TODO: extraEntries.StartupWMClass = "";
      mimeTypes = [
        "text/english"
        "text/plain"
        "text/x-makefile"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
        "application/x-shellscript"
        "text/x-c"
        "text/x-c++"
      ];
    };

  confOptions = with types;
    { ... }: {
      options = {
        package = mkOption {
          type = nullOr package;
        };
        cfgDir = mkOption { type = nullOr str; description = "location of config.org"; };
        linkCfg = mkEnableOption "Link config dir from /nix/store, if false config dir becomes writable" // { default = true; };
        envName = mkOption { type = nullOr str; };
        updateCmd = mkOption { type = nullOr str; };
        binInPath = mkOption { type = bool; default = false; };
        onCfgChangePerFile = mkOption { type = nullOr str; default = null; };
        default = mkEnableOption "default profile";
        extraSessionVariables = mkOption { type = nullOr attrs; default = null; };
        emacsOpts = filterAttrs (n: _: !elem n [ "finalPackage" "enable" "extraConfig" ]) otherOptions.programs.emacs;
      };
    };
in

{
  options.programs.chemacs = with types; {
    enable = mkEnableOption "Multi-Emacs install";
    defaultProfile = mkOption {
      internal = true;
      visible = false;
      readOnly = true;
      default = cfg.profiles.${defaultProfile};
    };

    profiles = mkOption {
      default = null;
      type = nullOr (attrsOf (submodule [ confOptions ]));
    };
  };

  config = mkMerge [
    (mkIf (! isNull cfg.profiles) {
      assertions = [{
        assertion = (
          count
            (x: x.default)
            (filter (x: hasAttr "default" x && x.default) (attrValues cfg.profiles))
        ) == 1;
        message = "Only a single default emacs profile permitted!";
      }];

      home.packages =
        map desktopItemFor (attrNames cfg.profiles) ++
        map (e: (wrapperFor e).emacs-client) (attrNames cfg.profiles) ++
        [ (hiPrio (wrapperFor defaultProfile).emacs-client-default) ] ++
        (with pkgs; [ xclip scrot shellcheck editorconfig-checker editorconfig-core-c graphviz ]);

      xdg.dataFile = mkLinks "package";
      xdg.configFile = (mkLinks "cfgDir") //
        {
          "emacs" = {
            source = pkgs.sources.chemacs.src;
            recursive = true;
          };
        };

      home.file.".emacs-profiles.el".text =
        let
          elProfiles =
            map
              # FIXME: emacsclient with correct --server string  and onCfgChangePerFile onChnage bin/doom
              (p:
                ''
                  ("${p}" . ((user-emacs-directory . "${xdg.dataHome}/chemacs/${p}")
                  (server-name . "${p}")
                  (custom-file . "${xdg.configHome}/chemacs/${p}_custom.el")
                  (env . (${optionalString (! isNull cfg.profiles.${p}.extraSessionVariables)
                    (concatStringsSep "\n" (mapAttrsToList (n: v: "(\"${n}\" . \"${v}\")" )
                      cfg.profiles.${p}.extraSessionVariables))}
                  ("${cfg.profiles."${p}".envName}" . "${xdg.configHome}/chemacs/${p}")))))

                '' + optionalString cfg.profiles."${p}".default ''
                  ("default" . ((user-emacs-directory . "${xdg.dataHome}/chemacs/${p}")
                  (server-name . "${p}")
                  (custom-file . "${xdg.configHome}/chemacs/${p}_custom.el")
                  (env . (${optionalString (! isNull cfg.profiles.${p}.extraSessionVariables)
                  (concatStringsSep "\n" (mapAttrsToList (n: v: "(\"${n}\" . \"${v}\")" )
                   cfg.profiles.${p}.extraSessionVariables))}
                  ("${cfg.profiles."${p}".envName}" . "${xdg.configHome}/chemacs/${p}")))))
                '')
              (attrNames cfg.profiles);
        in
        ''
          (${removeSuffix "\n" (concatStrings elProfiles)})
        '';

      # TODO: refactor for cfg.defaultProfile
      home.sessionVariables =
        with builtins;
        let
          withVars = filterAttrs (n: v: ! isNull v.extraSessionVariables) defaultSession;
          extraVars = map (v: cfg.profiles.${v}.extraSessionVariables);
          mkVars = foldl' (f: s: f // s) { };
        in
        mkIf ((length (attrNames withVars)) > 0)
          (mkVars (extraVars (attrNames withVars))) //
        { ${defaultSession.${defaultProfile}.envName} = "${xdg.configHome}/chemacs/${defaultProfile}"; };

      home.sessionPath = [ "${xdg.dataHome}/chemacs/${defaultProfile}/bin" ];

      # let withBins = filterAttrs (n: v: v.binInPath && v.default) cfg.profiles; in
      # mkIf (length (attrNames withBins) > 0)
      #   (map (p: "${xdg.dataHome}/chemacs/${p}/bin") (attrNames withBins));
    })

    (mkIf cfg.enable {
      programs.emacs = {
        enable = true;
        extraConfig = ''
          (setq plantuml-jar-path "${pkgs.plantuml}/lib/plantuml.jar")
        '';
        inherit (cfg.profiles.${defaultProfile}.emacsOpts)
          extraPackages
          overrides
          package;
      };

      services.emacs.enable = true;
      services.emacs.extraOptions = [ "--with-profile" defaultProfile ];
      services.emacs.defaultEditor = false;

      home.sessionVariables.EDITOR = ''${(wrapperFor defaultProfile).emacs-client}/bin/emacsclient-${defaultProfile}'';
      services.emacs.client.enable = true;
      services.emacs.client.arguments = [ "--socket-name" defaultProfile "-c" ];

      # ConditionPathExists ConditionPathExistsGlob

      # systemd.user.services.emacs-ready = {
      #   # ConditionPathExistsGlob = "${xdg.configHome}/chemacs/${defaultProfile}/init.el";
      #   Unit.ConditionPathExists = "!${xdg.configHome}/chemacs/${defaultProfile}/init.el";
      #   Service = {
      #     TimeoutStartSec = "infinity";
      #     ExecStart = "${pkgs.coreutils}/bin/sleep 10";
      #     RemainAfterExit = "yes";
      #   };
      # };

      # systemd.user.services.emacs.Unit.ConditionPathExistsGlob = "${xdg.configHome}/chemacs/${defaultProfile}/init.el";
      # systemd.user.services.emacs.Unit.After = [ "emacs-ready.service" ];

      # FIXME: systemd.user.services.emacs.Unit.ConditionPathExists = "${xdg.configHome}/chemacs/${defaultProfile}/init.el";
      systemd.user.services.emacs.Service.TimeoutStartSec = 300;
      systemd.user.services.emacs.Service.ExecStartPre = mkIf (! isNull cfg.defaultProfile.updateCmd)
        (
          let
            updatescript = pkgs.writeScript "${defaultProfile}-updateCmd" ''
              #!${pkgs.runtimeShell} -l
              set -e
              # Deprecated: systemctl --user import-environment
              ${cfg.defaultProfile.updateCmd}
            '';
          in
          "${updatescript}"
        );

    })
  ];
}

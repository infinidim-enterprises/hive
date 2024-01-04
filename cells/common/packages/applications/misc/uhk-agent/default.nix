{ appimageTools, makeDesktopItem, sources }:

let
  inherit (sources.uhk-agent) src version pname;
  name = pname;

  desktopItem = makeDesktopItem {
    name = "uhk-config";
    exec = name;
    comment = "Ultimate Hacking Keyboard configuration agent";
    desktopName = "UHK Agent";
    categories = [ "System" ];
  };
in

appimageTools.wrapType2 {
  inherit src version name;

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/* $out/share/applications
  '';

}

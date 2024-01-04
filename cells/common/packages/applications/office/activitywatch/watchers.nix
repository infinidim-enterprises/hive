{ lib, python3, version, sources }:

{
  aw-watcher-afk = python3.pkgs.buildPythonApplication {
    pname = "aw-watcher-afk";
    inherit version;

    format = "pyproject";

    src = "${sources}/aw-watcher-afk";

    nativeBuildInputs = [
      python3.pkgs.poetry
    ];

    propagatedBuildInputs = with python3.pkgs; [
      aw-client
      xlib
      pynput
    ];

    meta = with lib; {
      description = "Watches keyboard and mouse activity to determine if you are AFK or not (for use with ActivityWatch)";
      homepage = "https://github.com/ActivityWatch/aw-watcher-afk";
      maintainers = with maintainers; [ jtojnar ];
      license = licenses.mpl20;
    };
  };

  aw-watcher-window = python3.pkgs.buildPythonApplication {
    pname = "aw-watcher-window";
    inherit version;

    format = "pyproject";

    src = "${sources}/aw-watcher-window";

    nativeBuildInputs = [
      python3.pkgs.poetry
    ];

    propagatedBuildInputs = with python3.pkgs; [
      aw-client
      xlib
    ];

    meta = with lib; {
      description = "Cross-platform window watcher (for use with ActivityWatch)";
      homepage = "https://github.com/ActivityWatch/aw-watcher-window";
      maintainers = with maintainers; [ jtojnar ];
      license = licenses.mpl20;
    };
  };
}

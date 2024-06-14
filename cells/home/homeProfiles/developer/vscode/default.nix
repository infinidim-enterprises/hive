{ pkgs, lib, config, ... }:
with lib;
mkMerge [
  # (mkIf (hasAttr "opensnitch" config.services) {
  #   services.opensnitch.allow = [ "${config.programs.vscode.package}/lib/vscode/code" ];
  # })

  {
    programs.vscode.enable = true;
    programs.vscode.package = pkgs.vscode;
    programs.vscode.extensions = with pkgs.vscode-extensions; [
      readable-indent

      remote-ssh-edit
      vscode-docker

      emacs-mcx
      vscode-emacs-tab
      multi-cursor-case-preserve

      haml
      # even-better-toml
      vscode-markdownlint
      markdown-preview-enhanced

      # copilot
      # NOTE: pdf <- needs some kind of js lib probably
      activitywatch
    ];

    programs.vscode.keybindings = [
      {
        key = "tab";
        command = "emacs-tab.reindentCurrentLine";
        when = "editorTextFocus";
      }
    ];

    programs.vscode.userSettings = {
      "emacs-mcx.strictEmacsMove" = false;
      "emacs-mcx.killRingMax" = 100;
      "emacs-mcx.cursorMoveOnFindWidget" = true;

      "editor.quickSuggestions".strings = true;
      "editor.formatOnPaste" = true;

      # "github.copilot.enable" = {
      #   "*" = true;
      #   "plaintext" = false;
      #   "markdown" = false;
      #   "Nix" = true;
      # };

      # FIXME/TODO: https://beta.openai.com/docs/api-reference/completions/create#classifications/create-temperature
      # "github.copilot.advanced" = {
      #   temperature = 0.8;
      #   # top_p = 0.1;
      # };
    };

    # NOTE: Otherwise inode/directory will open with vscode
    xdg.desktopEntries.code = {
      name = "Visual Studio Code";
      genericName = "Text Editor";
      exec = "code %F";
      terminal = false;
      startupNotify = true;
      icon = "code";
      type = "Application";
      comment = "redmond Code Editing.";
      categories = [ "Utility" "TextEditor" "Development" "IDE" ];
      mimeType = [ "" "text/plain" ];

      settings.StartupWMClass = "Code";
      settings.Keywords = "vscode;";

      actions."new-empty-window".name = "New Empty Window";
      actions."new-empty-window".exec = "code --new-window %F";
      actions."new-empty-window".icon = "code";
    };

  }
]

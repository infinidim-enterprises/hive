{ inputs, pkgs, ... }:
{
  imports = [ inputs.cells.emacs.homeProfiles.emacs.nix-doom-emacs-unstraightened ];
  programs.doom-emacs.doomDir = pkgs.callPackage ../dotfiles/doom.d.nix/default.nix { };
  home.packages = with pkgs; [
    openai-whisper-cpp
    ffmpeg-full
    d2
  ];
}

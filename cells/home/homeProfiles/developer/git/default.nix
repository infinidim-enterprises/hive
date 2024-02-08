{ lib, pkgs, config, ... }:
with lib;
let
  gat = with pkgs.gitAndTools; [
    git-hub # Git command line interface to GitHub
    hub # Command-line wrapper for git that makes you better at GitHub
    gitflow # Extend git with the Gitflow branching model
    gh # GitHub CLI tool
    ghq # Remote repository management made easy
  ];
  inherit (lib) mkDefault;
in
mkMerge [
  (mkIf (hasAttrByPath [ "opensnitch" ] config.services) {
    services.opensnitch.allow =
      (remove pkgs.gitflow gat) ++
      [ "${config.programs.git.package}/libexec/git-core/git-remote-http" ];
  })

  ### General settings
  {
    programs.gh.enable = true;
    programs.gh.settings.git_protocol = "ssh";

    programs.git.enable = true;
    programs.git.lfs.enable = true;
    programs.git.delta.enable = true;
    programs.git.delta.options = mkDefault {
      plus-style = "syntax #012800";
      minus-style = "syntax #340001";
      syntax-theme = "Monokai Extended"; # TODO: change theme!
      navigate = true;
    };

    programs.git.signing.signByDefault = true;
    programs.git.extraConfig = {
      init.defaultBranch = "master";
      branch.autoSetupRebase = "always";
      checkout.defaultRemote = "origin";
      # pull.rebase = true;
      # pull.ff = "only";
      push.default = "current";
      format.signoff = true;
      # rebase.autosquash = true;
      merge.conflictStyle = "diff3";
      credential.helper = "cache";
      core.autocrlf = "input";
      rebase.autosquash = true;
      rerere.enabled = true;
    };
    programs.git.ignores = [
      "*~"
      "*.swp"
      "target"
      "result"
      ".projectile"
      ".indium.json"
      ".ccls-cache"
      ".Rhistory"
      ".notdeft*"
      "eaf"
      ".cache"
      ".org-src-babel"
      ".auctex-auto"
      "vast.db"
      ".ipynb_checkpoints"
      "__pycache__"
      "*.org.organice-bak"
      ".direnv"
      ".direnv/"
      ".direnv.d"
      ".secrets"
      ".cargo"
    ];
  }

  {
    home.packages = with pkgs; [
      delta
      tea
      github-release # Commandline app to create and edit releases on Github (and upload artifacts)
      gist # Upload code to
      git-lfs # Git extension for versioning large files
      git-crypt # Transparent file encryption in gi
      gitless # A version control system built on top of Git
    ] ++ gat;

    programs.git.enable = mkDefault true;
    programs.git.delta.enable = mkDefault true;
    programs.git.lfs.enable = mkDefault true;
    programs.git.extraConfig.pull.rebase = mkDefault false;
    programs.git.extraConfig.safe.directory = "*";

    programs.git.aliases = {
      a = "add -p";
      co = "checkout";
      cob = "checkout -b";
      f = "fetch -p";
      c = "commit";
      p = "push";
      ba = "branch -a";
      bd = "branch -d";
      bD = "branch -D";
      d = "diff";
      dc = "diff --cached";
      ds = "diff --staged";
      r = "restore";
      rs = "restore --staged";
      st = "status -sb";

      # reset
      soft = "reset --soft";
      hard = "reset --hard";
      s1ft = "soft HEAD~1";
      h1rd = "hard HEAD~1";

      # logging
      lg =
        "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      plog =
        "log --graph --pretty='format:%C(red)%d%C(reset) %C(yellow)%h%C(reset) %ar %C(green)%aN%C(reset) %s'";
      tlog =
        "log --stat --since='1 Day Ago' --graph --pretty=oneline --abbrev-commit --date=relative";
      rank = "shortlog -sn --no-merges";

      # delete merged branches
      bdm = "!git branch --merged | grep -v '*' | xargs -n 1 git branch -d";

      # squash-all commit right from HEAD, without rebase at all
      # NOTE: git squash-all -m "a brand new start"
      squash-all = "!f(){ git reset $(git commit-tree HEAD^{tree} \"$@\");};f";
    };
  }
]

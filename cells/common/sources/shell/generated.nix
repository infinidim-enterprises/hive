# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  atuin = {
    pname = "atuin";
    version = "v18.7.1";
    src = fetchFromGitHub {
      owner = "atuinsh";
      repo = "atuin";
      rev = "v18.7.1";
      fetchSubmodules = false;
      sha256 = "sha256-KHATm505ysJAIGCd2UvkMEIFhp7huPYW5ly+jq1HLdc=";
    };
    flake = "true";
  };
  console-solarized = {
    pname = "console-solarized";
    version = "26929b5e303703ec527b6f6e4569f351d9831e52";
    src = fetchFromGitHub {
      owner = "adeverteuil";
      repo = "console-solarized";
      rev = "26929b5e303703ec527b6f6e4569f351d9831e52";
      fetchSubmodules = false;
      sha256 = "sha256-QMxhuDuVHgw8+DpQAavtC3Dyg4rBmbrYoA8tKtamy3Y=";
    };
    date = "2018-10-28";
  };
  dircolors-solarized = {
    pname = "dircolors-solarized";
    version = "52bfa164e4388ee232f6a9235f62e8482e1f1767";
    src = fetchgit {
      url = "https://github.com/seebi/dircolors-solarized";
      rev = "52bfa164e4388ee232f6a9235f62e8482e1f1767";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-+2t9OsyD9QkamsFbgmgehBrfszBQmv1Y0C94T4g16GI=";
    };
    date = "2025-02-03";
  };
  getoptions = {
    pname = "getoptions";
    version = "139d121807db67f632b412b2a00ece851df73203";
    src = fetchFromGitHub {
      owner = "ko1nksm";
      repo = "getoptions";
      rev = "139d121807db67f632b412b2a00ece851df73203";
      fetchSubmodules = false;
      sha256 = "sha256-hapOGPibqt2Mm6k73v63gHxrX+lifZ8xcwzj8vWbtgo=";
    };
    date = "2024-08-18";
  };
  rainbowsh = {
    pname = "rainbowsh";
    version = "1bcf6e44a0d9694da4d3fa637644e5da5a7250ca";
    src = fetchFromGitHub {
      owner = "xr09";
      repo = "rainbow.sh";
      rev = "1bcf6e44a0d9694da4d3fa637644e5da5a7250ca";
      fetchSubmodules = false;
      sha256 = "sha256-F+Nabc/Fe5ET6lSkdll5YH/mEpKp3OlpaGk+u0rQpPQ=";
    };
    date = "2022-08-24";
  };
  shellspec = {
    pname = "shellspec";
    version = "f2d13f991885ef44e6b54e571e0842222251b111";
    src = fetchFromGitHub {
      owner = "shellspec";
      repo = "shellspec";
      rev = "f2d13f991885ef44e6b54e571e0842222251b111";
      fetchSubmodules = false;
      sha256 = "sha256-8iXC+geSeYaAmrBbxiSKZFxmmmosiKemqAcM78owYas=";
    };
    date = "2024-09-12";
  };
  shflags = {
    pname = "shflags";
    version = "96694d58ce92065fdd8f8761d930765cb9a8d066";
    src = fetchFromGitHub {
      owner = "kward";
      repo = "shflags";
      rev = "96694d58ce92065fdd8f8761d930765cb9a8d066";
      fetchSubmodules = false;
      sha256 = "sha256-IJJEi8xmIco/IuN9LSf6qMacsG6jHQek9F0dPKEwviI=";
    };
    date = "2023-08-24";
  };
  wofi-pass = {
    pname = "wofi-pass";
    version = "aa29a8a6278589ea441bc38b8e561f5feee44dd1";
    src = fetchgit {
      url = "https://github.com/njkli/wofi-pass";
      rev = "aa29a8a6278589ea441bc38b8e561f5feee44dd1";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-Z2eHs8APoKYxS73l68M9XeguatSgAcyKTUjPTVksUQM=";
    };
    date = "2025-05-16";
  };
  zsh-plugin_any-nix-shell = {
    pname = "zsh-plugin_any-nix-shell";
    version = "b0223ee9cd187853b44e74cd8ebd418a14651eaa";
    src = fetchFromGitHub {
      owner = "haslersn";
      repo = "any-nix-shell";
      rev = "b0223ee9cd187853b44e74cd8ebd418a14651eaa";
      fetchSubmodules = false;
      sha256 = "sha256-S5BNTvRinYJdgwjHH09D4T26WJmU/27vMPyYCXmHnCk=";
    };
    date = "2024-09-02";
  };
  zsh-plugin_aw-watcher-shell = {
    pname = "zsh-plugin_aw-watcher-shell";
    version = "9915c40ba472f3c50c944bcc0e2fa96f982defb9";
    src = fetchgit {
      url = "https://github.com/voobscout/aw-watcher-shell";
      rev = "9915c40ba472f3c50c944bcc0e2fa96f982defb9";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-72aQ5N5L14mwJ8RB50p/swi6wXhPGYRYJ/Q8CUdP4wE=";
    };
    date = "2023-12-06";
  };
  zsh-plugin_clipboard = {
    pname = "zsh-plugin_clipboard";
    version = "546752e48b8c776d19a1ac42b34b1cb5c206397c";
    src = fetchgit {
      url = "https://github.com/zpm-zsh/clipboard";
      rev = "546752e48b8c776d19a1ac42b34b1cb5c206397c";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-FMwQza1WjMShV30uRR6rqmQtoRcwzZ7FwyniatvTGXQ=";
    };
    date = "2024-07-10";
  };
  zsh-plugin_fast-syntax-highlighting = {
    pname = "zsh-plugin_fast-syntax-highlighting";
    version = "f5af74afe220ea139a32506a57711cf085ca49ff";
    src = fetchFromGitHub {
      owner = "z-shell";
      repo = "F-Sy-H";
      rev = "f5af74afe220ea139a32506a57711cf085ca49ff";
      fetchSubmodules = false;
      sha256 = "sha256-rcbJM5TXMODxo6bpmTPM0LRHn4E/aOpXY72n2srSWfs=";
    };
    date = "2025-07-18";
  };
  zsh-plugin_k = {
    pname = "zsh-plugin_k";
    version = "e2bfbaf3b8ca92d6ffc4280211805ce4b8a8c19e";
    src = fetchgit {
      url = "https://github.com/supercrabtree/k";
      rev = "e2bfbaf3b8ca92d6ffc4280211805ce4b8a8c19e";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-32rJjBzqS2e6w/L78KMNwQRg4E3sqqdAmb87XEhqbRQ=";
    };
    date = "2018-09-09";
  };
  zsh-plugin_nix-zsh-completions = {
    pname = "zsh-plugin_nix-zsh-completions";
    version = "8a188a73a1be7932fae12efc74b2b812d09fdba7";
    src = fetchFromGitHub {
      owner = "spwhitt";
      repo = "nix-zsh-completions";
      rev = "8a188a73a1be7932fae12efc74b2b812d09fdba7";
      fetchSubmodules = false;
      sha256 = "sha256-MZlu9aZ13g9dj540OX0MXSZpeMYl6t0QNkRMCglSLVY=";
    };
    date = "2025-06-09";
  };
  zsh-plugin_oh-my-zsh = {
    pname = "zsh-plugin_oh-my-zsh";
    version = "70f0e5285f802ce6eb7feea4588ff8917246233e";
    src = fetchgit {
      url = "https://github.com/robbyrussell/oh-my-zsh";
      rev = "70f0e5285f802ce6eb7feea4588ff8917246233e";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-rvvzSV4K6CCJKQH7ynMosAjfe0N5FwYwbCUvrC/c4eQ=";
    };
    date = "2025-07-25";
  };
  zsh-plugin_tipz = {
    pname = "zsh-plugin_tipz";
    version = "594eab4642cc6dcfe063ecd51d76478bd84e2878";
    src = fetchgit {
      url = "https://github.com/molovo/tipz";
      rev = "594eab4642cc6dcfe063ecd51d76478bd84e2878";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-oFZJwHYDfK4f53lhcZg6PCw2AgHxFC0CRiqiinKZz8k=";
    };
    date = "2018-05-03";
  };
  zsh-plugin_zsh-256color = {
    pname = "zsh-plugin_zsh-256color";
    version = "559fee48bb74b75cec8b9887f8f3e046f01d5d8f";
    src = fetchgit {
      url = "https://github.com/chrissicool/zsh-256color";
      rev = "559fee48bb74b75cec8b9887f8f3e046f01d5d8f";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-P/pbpDJmsMSZkNi5GjVTDy7R+OxaIVZhb/bEnYQlaLo=";
    };
    date = "2022-09-13";
  };
  zsh-plugin_zsh-autoenv = {
    pname = "zsh-plugin_zsh-autoenv";
    version = "f5951dd0cfeb37eb18fd62e14edc902a2c308c1e";
    src = fetchgit {
      url = "https://github.com/Tarrasch/zsh-autoenv";
      rev = "f5951dd0cfeb37eb18fd62e14edc902a2c308c1e";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-8HznSWSBj1baetvDOIZ+H9mWg5gbbzF52nIEG+u9Di8=";
    };
    date = "2024-06-04";
  };
  zsh-plugin_zsh-autopair = {
    pname = "zsh-plugin_zsh-autopair";
    version = "449a7c3d095bc8f3d78cf37b9549f8bb4c383f3d";
    src = fetchgit {
      url = "https://github.com/hlissner/zsh-autopair";
      rev = "449a7c3d095bc8f3d78cf37b9549f8bb4c383f3d";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-3zvOgIi+q7+sTXrT+r/4v98qjeiEL4Wh64rxBYnwJvQ=";
    };
    date = "2024-07-14";
  };
  zsh-plugin_zsh-completions = {
    pname = "zsh-plugin_zsh-completions";
    version = "fb87bc486f57fc04d4403e20855d6790e2b66e6f";
    src = fetchgit {
      url = "https://github.com/zsh-users/zsh-completions";
      rev = "fb87bc486f57fc04d4403e20855d6790e2b66e6f";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-GpFxLKBy7GQPlClF9Dy+hfJNxD2P6uMxSGSdr9+8Ca4=";
    };
    date = "2025-07-20";
  };
  zsh-plugin_zsh-history-substring-search = {
    pname = "zsh-plugin_zsh-history-substring-search";
    version = "87ce96b1862928d84b1afe7c173316614b30e301";
    src = fetchgit {
      url = "https://github.com/zsh-users/zsh-history-substring-search";
      rev = "87ce96b1862928d84b1afe7c173316614b30e301";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-1+w0AeVJtu1EK5iNVwk3loenFuIyVlQmlw8TWliHZGI=";
    };
    date = "2024-06-05";
  };
  zsh-plugin_zsh-syntax-highlighting = {
    pname = "zsh-plugin_zsh-syntax-highlighting";
    version = "5eb677bb0fa9a3e60f0eff031dc13926e093df92";
    src = fetchgit {
      url = "https://github.com/zsh-users/zsh-syntax-highlighting";
      rev = "5eb677bb0fa9a3e60f0eff031dc13926e093df92";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-IIcGYa0pXdll/XDPA15zDBkLUuLhTdrqwS9sn06ce0Y=";
    };
    date = "2024-11-21";
  };
}

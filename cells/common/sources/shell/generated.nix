# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  zsh-plugin_aw-watcher-shell = {
    pname = "zsh-plugin_aw-watcher-shell";
    version = "7dd9771d5c202b671d1ba111af520a30917639f9";
    src = fetchgit {
      url = "https://github.com/voobscout/aw-watcher-shell";
      rev = "7dd9771d5c202b671d1ba111af520a30917639f9";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-xDgr/e2wuFsMl6vJsvszgrKuEOO97dds9un3BWvqQIw=";
    };
    date = "2023-11-19";
  };
  zsh-plugin_clipboard = {
    pname = "zsh-plugin_clipboard";
    version = "354a4e493da5736d19d14e7769d98f357eff7323";
    src = fetchgit {
      url = "https://github.com/zpm-zsh/clipboard";
      rev = "354a4e493da5736d19d14e7769d98f357eff7323";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-GDWxib4k2vwfSZ/R5fyXRx6piOYPzJ1hyzCNOg7QqxU=";
    };
    date = "2023-11-05";
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
      sha256 = "sha256-32rJjBzqS2e6w/L78KMNwQRg4E3sqqdAmb87XEhqbRQ=";
    };
    date = "2018-09-09";
  };
  zsh-plugin_oh-my-zsh = {
    pname = "zsh-plugin_oh-my-zsh";
    version = "0a9d82780e20e24b6fafc5b2aaefedb0957986c9";
    src = fetchgit {
      url = "https://github.com/robbyrussell/oh-my-zsh";
      rev = "0a9d82780e20e24b6fafc5b2aaefedb0957986c9";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-qShatGQ0lJLjDIrzhnUa9amq0i5RHx1vTJ6jW3k22E0=";
    };
    date = "2023-12-01";
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
      sha256 = "sha256-P/pbpDJmsMSZkNi5GjVTDy7R+OxaIVZhb/bEnYQlaLo=";
    };
    date = "2022-09-13";
  };
  zsh-plugin_zsh-autoenv = {
    pname = "zsh-plugin_zsh-autoenv";
    version = "e9809c1bd28496e025ca05576f574e08e93e12e8";
    src = fetchgit {
      url = "https://github.com/Tarrasch/zsh-autoenv";
      rev = "e9809c1bd28496e025ca05576f574e08e93e12e8";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-SxDRldr9eqRtPQ3IWFKX0Q+vEG8Ry34PNRZ/I16aju0=";
    };
    date = "2018-09-14";
  };
  zsh-plugin_zsh-autopair = {
    pname = "zsh-plugin_zsh-autopair";
    version = "396c38a7468458ba29011f2ad4112e4fd35f78e6";
    src = fetchgit {
      url = "https://github.com/hlissner/zsh-autopair";
      rev = "396c38a7468458ba29011f2ad4112e4fd35f78e6";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-PXHxPxFeoYXYMOC29YQKDdMnqTO0toyA7eJTSCV6PGE=";
    };
    date = "2022-10-03";
  };
  zsh-plugin_zsh-completions = {
    pname = "zsh-plugin_zsh-completions";
    version = "f7c3173886f4f56bf97d622677c6d46ab005831f";
    src = fetchgit {
      url = "https://github.com/zsh-users/zsh-completions";
      rev = "f7c3173886f4f56bf97d622677c6d46ab005831f";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-sZCHI4ZFfRjcG1XF/3ABf9+zv7f2Di8Xrh4Dr+qt4Us=";
    };
    date = "2023-12-01";
  };
  zsh-plugin_zsh-history-substring-search = {
    pname = "zsh-plugin_zsh-history-substring-search";
    version = "8dd05bfcc12b0cd1ee9ea64be725b3d9f713cf64";
    src = fetchgit {
      url = "https://github.com/zsh-users/zsh-history-substring-search";
      rev = "8dd05bfcc12b0cd1ee9ea64be725b3d9f713cf64";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-houujb1CrRTjhCc+dp3PRHALvres1YylgxXwjjK6VZA=";
    };
    date = "2023-11-23";
  };
  zsh-plugin_zsh-syntax-highlighting = {
    pname = "zsh-plugin_zsh-syntax-highlighting";
    version = "bb27265aeeb0a22fb77f1275118a5edba260ec47";
    src = fetchgit {
      url = "https://github.com/zsh-users/zsh-syntax-highlighting";
      rev = "bb27265aeeb0a22fb77f1275118a5edba260ec47";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-psIOBZnrANu1Gzce5oc0T1IO2vuIhHIFTyl/wJUGsm0=";
    };
    date = "2023-10-29";
  };
}
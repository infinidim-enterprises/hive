# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  acl-compat = {
    pname = "acl-compat";
    version = "cac1d6920998ddcbee8310a873414732e707d8e5";
    src = fetchgit {
      url = "https://git.code.sf.net/p/portableaserve/git";
      rev = "cac1d6920998ddcbee8310a873414732e707d8e5";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-CvfiudyBNYQsyPFy05kjbhGVtwl56wKPAllqgi6uZio=";
    };
    date = "2019-07-20";
  };
  adguard-filters_adguardteam = {
    pname = "adguard-filters_adguardteam";
    version = "09fc8e44449bc75e24078dc1be32cc5afa220ad0";
    src = fetchgit {
      url = "https://github.com/AdguardTeam/AdguardFilters";
      rev = "09fc8e44449bc75e24078dc1be32cc5afa220ad0";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-zBbIKpcDNY0kiT4rnR79q1fbyHVsQygP6MCPWh/dIxw=";
    };
    date = "2025-03-17";
  };
  adguard-filters_romania = {
    pname = "adguard-filters_romania";
    version = "b46d105f484768e3a48bae47f81de86ad42b6cb0";
    src = fetchgit {
      url = "https://github.com/tcptomato/ROad-Block";
      rev = "b46d105f484768e3a48bae47f81de86ad42b6cb0";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-4dmbHCmX7HdQiDeDoL9ourJxmHzsb1fcy2vfB32EzUQ=";
    };
    date = "2025-03-11";
  };
  base16-schemes = {
    pname = "base16-schemes";
    version = "4ff7fe1cf77217393ed0981a1de314f418c28b49";
    src = fetchgit {
      url = "https://github.com/tinted-theming/schemes";
      rev = "4ff7fe1cf77217393ed0981a1de314f418c28b49";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-PX66lrB/aqFnr6sCQUBzpTSCbsLbC7CEt4q02D0fJ3M=";
    };
    date = "2025-03-14";
  };
  chatgpt-wrapper = {
    pname = "chatgpt-wrapper";
    version = "c099ade21ec4b8763ab1213d3370d9cd6e93e05c";
    src = fetchFromGitHub {
      owner = "llm-workflow-engine";
      repo = "llm-workflow-engine";
      rev = "c099ade21ec4b8763ab1213d3370d9cd6e93e05c";
      fetchSubmodules = false;
      sha256 = "sha256-q307dOhn3SA0ejS9pzECUCjqyMH2gkQoWMP2epgP174=";
    };
    date = "2025-02-28";
  };
  cl-hash-util = {
    pname = "cl-hash-util";
    version = "7f88cb7579b2af8c21022554f46dddd6ce6a5fc2";
    src = fetchFromGitHub {
      owner = "orthecreedence";
      repo = "cl-hash-util";
      rev = "7f88cb7579b2af8c21022554f46dddd6ce6a5fc2";
      fetchSubmodules = false;
      sha256 = "sha256-Neg1WUxhMVAtk3AwlW05jryCyKsYGY50DkRsVcU+S/U=";
    };
    date = "2024-06-17";
  };
  cl-mount-info = {
    pname = "cl-mount-info";
    version = "5a7fbdbfe4ac3810c7f00434d3d6dc7555891705";
    src = fetchgit {
      url = "https://codeberg.org/cage/cl-mount-info";
      rev = "5a7fbdbfe4ac3810c7f00434d3d6dc7555891705";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-nFEecXmStgu/ePtNretaCgC1huBr4kKnzvgdoUG+u0Q=";
    };
    date = "2023-06-20";
  };
  cl-shellwords = {
    pname = "cl-shellwords";
    version = "313576b9f6b925cbbc3dcf5e49e8f47c9c1b46bc";
    src = fetchFromGitHub {
      owner = "jorams";
      repo = "cl-shellwords";
      rev = "313576b9f6b925cbbc3dcf5e49e8f47c9c1b46bc";
      fetchSubmodules = false;
      sha256 = "sha256-9hKq54YOOEE3Vc/9LVUnqvcw/1G1rpcUVL+8GKJlqEY=";
    };
    date = "2015-09-20";
  };
  cl-strings = {
    pname = "cl-strings";
    version = "93ec4177fc51f403a9f1ef0a8933f36d917f2140";
    src = fetchFromGitHub {
      owner = "diogoalexandrefranco";
      repo = "cl-strings";
      rev = "93ec4177fc51f403a9f1ef0a8933f36d917f2140";
      fetchSubmodules = false;
      sha256 = "sha256-UpXjI9KsWvOhsjGSo1zVMNlD1I4Pwu9+cZoD60jREMk=";
    };
    date = "2021-03-08";
  };
  cl-syslog = {
    pname = "cl-syslog";
    version = "f62d524874616383650e30f7f23320005fd310c1";
    src = fetchFromGitHub {
      owner = "lhope";
      repo = "cl-syslog";
      rev = "f62d524874616383650e30f7f23320005fd310c1";
      fetchSubmodules = false;
      sha256 = "sha256-rH0zOgXR3BixtVaqcYPhIfZBjqYgWnqrORQfr1mBqFM=";
    };
    date = "2006-11-28";
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
  crystalline = {
    pname = "crystalline";
    version = "v0.16.0";
    src = fetchFromGitHub {
      owner = "elbywan";
      repo = "crystalline";
      rev = "v0.16.0";
      fetchSubmodules = false;
      sha256 = "sha256-C93slG9nEufJ7KsZ5td4rjGgT9EiYVIu5D5NmOBIeSQ=";
    };
  };
  dbus = {
    pname = "dbus";
    version = "8bba6a0942232e9d7fa915b33bbe32dfedc5abb9";
    src = fetchgit {
      url = "https://github.com/death/dbus";
      rev = "8bba6a0942232e9d7fa915b33bbe32dfedc5abb9";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-xbg3tPYfRNGJo+9F/58w2bDeZqV33Z871+ClSg4ACPk=";
    };
    date = "2023-11-04";
  };
  dbus-listen = {
    pname = "dbus-listen";
    version = "e7aeedfbcdc18e3ea2d45cf6931e38d350096f2f";
    src = fetchgit {
      url = "https://github.com/voobscout/dbus-listen";
      rev = "e7aeedfbcdc18e3ea2d45cf6931e38d350096f2f";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-WU3e7F0iNrxiS7WXzNbxnBp4oIru2pLihKbVIR236J4=";
    };
    date = "2022-09-09";
  };
  git-get = {
    pname = "git-get";
    version = "8cd27a8f629317bd27432f2e9a4bd00561b3b21e";
    src = fetchFromGitHub {
      owner = "grdl";
      repo = "git-get";
      rev = "8cd27a8f629317bd27432f2e9a4bd00561b3b21e";
      fetchSubmodules = false;
      sha256 = "sha256-dBZNrhg4df7NDECq8B333dY/7OXEyPIByD7YHdV9moo=";
    };
    vendorHash = "05k6w4knk7fdjm9qm272nlrk47rzjr18g0fp4j57f5ncq26cxr8b";
    date = "2021-08-07";
  };
  git-pull-request-mirror = {
    pname = "git-pull-request-mirror";
    version = "3d342363b0e1f2da4e59ac01baf4601bcf233bf9";
    src = fetchFromGitHub {
      owner = "google";
      repo = "git-pull-request-mirror";
      rev = "3d342363b0e1f2da4e59ac01baf4601bcf233bf9";
      fetchSubmodules = false;
      sha256 = "sha256-OMtRSGRB1xRk3L3sIfEpagDQHNWNJBBOE5tuW7ic4Y4=";
    };
    vendorSha256 = "0789v1r6my256pncs0105yji28ifchj6ppfiy8gavglgclq3cgvn";
    date = "2020-05-13";
  };
  git-remote-ipfs = {
    pname = "git-remote-ipfs";
    version = "12b3f421c19eb5548ae76b8c79c9581a428329e0";
    src = fetchFromGitHub {
      owner = "bqv";
      repo = "git-remote-ipfs";
      rev = "12b3f421c19eb5548ae76b8c79c9581a428329e0";
      fetchSubmodules = false;
      sha256 = "sha256-59zv362KfuW1Lki9vfwe9fJfdm6o0+DTPDbI/L+Ugsk=";
    };
    vendorSha256 = "hkenInaS6PFnu/Z0oz32Y4B4BmM5+l5AB2/K1f/LxqA=";
    date = "2021-01-24";
  };
  ipxe = {
    pname = "ipxe";
    version = "829e2d1f299c7c0b15a5e9e07479f6e3aec121cf";
    src = fetchgit {
      url = "https://github.com/ipxe/ipxe";
      rev = "829e2d1f299c7c0b15a5e9e07479f6e3aec121cf";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-lU2P4Xs+KSYgdxw/PdsGwT11DcxIXp2chzEKlqe7n9U=";
    };
    date = "2025-03-14";
  };
  iterable-io = {
    pname = "iterable-io";
    version = "1.0.0";
    src = fetchurl {
      url = "https://pypi.org/packages/source/i/iterable-io/iterable-io-1.0.0.tar.gz";
      sha256 = "sha256-+54bc5WHqboNXGCj4etxJGdhWDvJ8Ys8NbsRK0SxjDw=";
    };
  };
  langchain = {
    pname = "langchain";
    version = "langchain-core==0.3.45";
    src = fetchFromGitHub {
      owner = "langchain-ai";
      repo = "langchain";
      rev = "langchain-core==0.3.45";
      fetchSubmodules = false;
      sha256 = "sha256-9aAA5HGjZADBppNFd9viIJcIh5RUtPYL8FmdqF0QqX8=";
    };
  };
  listopia = {
    pname = "listopia";
    version = "2d2a1a3c35580252ca0085e15ebf625f73230d60";
    src = fetchFromGitHub {
      owner = "Dimercel";
      repo = "listopia";
      rev = "2d2a1a3c35580252ca0085e15ebf625f73230d60";
      fetchSubmodules = false;
      sha256 = "sha256-IEoPmF0QC1S6xF/enlqy1rDX8qi/2bvacxWpCHaro0k=";
    };
    date = "2021-03-17";
  };
  logseq = {
    pname = "logseq";
    version = "0.10.9";
    src = fetchurl {
      url = "https://github.com/logseq/logseq/releases/download/0.10.9/logseq-linux-x64-0.10.9.AppImage";
      sha256 = "sha256-XROuY2RlKnGvK1VNvzauHuLJiveXVKrIYPppoz8fCmc=";
    };
  };
  masterpdfeditor = {
    pname = "masterpdfeditor";
    version = "5.9.85";
    src = fetchurl {
      url = "https://code-industry.net/public/master-pdf-editor-5.9.85-qt5.x86_64-qt_include.tar.gz";
      sha256 = "sha256-cQLGWwlqZxOO1RWdxGWEBkSLeuD6ljC354mjvnffVLk=";
    };
  };
  numix-solarized-gtk-theme-git = {
    pname = "numix-solarized-gtk-theme-git";
    version = "2c5a85bd79c7b7d509ec14dd00d310cfe9f9afd2";
    src = fetchgit {
      url = "https://github.com/Ferdi265/numix-solarized-gtk-theme";
      rev = "2c5a85bd79c7b7d509ec14dd00d310cfe9f9afd2";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-r5xCe8Ew+/SuCUaZ0yjlumORTy/y1VwbQQjQ6uEyGsY=";
    };
    date = "2023-03-05";
  };
  pam_usb = {
    pname = "pam_usb";
    version = "ce3999d92d8de59ed4c5bbd6ad56df416aa2d42c";
    src = fetchgit {
      url = "https://github.com/mcdope/pam_usb";
      rev = "ce3999d92d8de59ed4c5bbd6ad56df416aa2d42c";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-aU6sf0t/872Qw+k5oOv5uANnTGl3yzgEy2utZuWmm3M=";
    };
    date = "2025-03-15";
  };
  paper-store = {
    pname = "paper-store";
    version = "f369e81f8723123d89b8ac527f955e4d4c60b7fd";
    src = fetchgit {
      url = "https://github.com/nurupo/paper-store";
      rev = "f369e81f8723123d89b8ac527f955e4d4c60b7fd";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-StmpmszWHzmi8pMd+y3f6+1s2vjW8HM5O6maJiE6Ajc=";
    };
    date = "2024-04-06";
  };
  pgp-key-generation = {
    pname = "pgp-key-generation";
    version = "e4549972b1ed686b38da9e2a663106669edddb9b";
    src = fetchFromGitHub {
      owner = "summitto";
      repo = "pgp-key-generation";
      rev = "e4549972b1ed686b38da9e2a663106669edddb9b";
      fetchSubmodules = false;
      sha256 = "sha256-FR6I4jwrF9t+pur0E/z54cgQ8acwtsAsKIp4pO0Ulng=";
    };
    date = "2022-12-02";
  };
  pgp-packet-library = {
    pname = "pgp-packet-library";
    version = "42b4d08c0cb4b8ee527f729c1674e982eca409a7";
    src = fetchFromGitHub {
      owner = "summitto";
      repo = "pgp-packet-library";
      rev = "42b4d08c0cb4b8ee527f729c1674e982eca409a7";
      fetchSubmodules = true;
      sha256 = "sha256-DI0vxfbewqlXocrvzPgCM66IuSVxHjFdL3hIPxzFou8=";
    };
    date = "2022-07-26";
  };
  prowlarr = {
    pname = "prowlarr";
    version = "1.32.2.4987";
    src = fetchurl {
      url = "https://github.com/Prowlarr/Prowlarr/releases/download/v1.32.2.4987/Prowlarr.master.1.32.2.4987.linux-core-arm64.tar.gz";
      sha256 = "sha256-4bqK+fEkYk9LK3suWgqoSzf9vKtPpbYGuEL62M/KHR4=";
    };
  };
  python-pass = {
    pname = "python-pass";
    version = "6f51145a3bc12ee79d2881204b88a82d149f3228";
    src = fetchFromGitHub {
      owner = "aviau";
      repo = "python-pass";
      rev = "6f51145a3bc12ee79d2881204b88a82d149f3228";
      fetchSubmodules = false;
      sha256 = "sha256-iJZe/Ljae9igkpfz9WJQK48wZZJWcOt4Z3kdp5VILqE=";
    };
  };
  quicklisp = {
    pname = "quicklisp";
    version = "latest";
    src = fetchurl {
      url = "https://beta.quicklisp.org/quicklisp.lisp";
      sha256 = "sha256-SnpcKuvgcWQXBHhUJnOX4kpE0MzglhJ0EenOnM/rLBc=";
    };
  };
  radarr = {
    pname = "radarr";
    version = "5.19.3.9730";
    src = fetchurl {
      url = "https://github.com/Radarr/Radarr/releases/download/v5.19.3.9730/Radarr.master.5.19.3.9730.linux-core-arm64.tar.gz";
      sha256 = "sha256-4JgtHmNoJv9zURdFzRQaO0og07HpbVVOkBf+jViuM7E=";
    };
  };
  s5cmd = {
    pname = "s5cmd";
    version = "7e56e29c6e7fbf511729bab3a8685274b5c41713";
    src = fetchFromGitHub {
      owner = "peak";
      repo = "s5cmd";
      rev = "7e56e29c6e7fbf511729bab3a8685274b5c41713";
      fetchSubmodules = false;
      sha256 = "sha256-JuBNlIw2w2EwVNkuDTlULDqSCwdGMDKUA/iiHykyMK8=";
    };
    date = "2025-01-17";
  };
  solarized-dark-gnome-shell-2020 = {
    pname = "solarized-dark-gnome-shell-2020";
    version = "fa0ce0fe63ae314938e11843074fe0955f89e9ac";
    src = fetchgit {
      url = "https://github.com/rtlewis88/rtl88-Themes";
      rev = "fa0ce0fe63ae314938e11843074fe0955f89e9ac";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-Rtaf0LRcWJ/a3yTFPMSPk6vlK0UW6dyStnAVJ24jREg=";
    };
    date = "2020-10-20";
  };
  solarized-darkarc = {
    pname = "solarized-darkarc";
    version = "ab0a4d325b6c3bc34293850abcacc924b2ee2933";
    src = fetchgit {
      url = "https://github.com/rtlewis1/GTK";
      rev = "ab0a4d325b6c3bc34293850abcacc924b2ee2933";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-rBNlEgMyjPqt/e68pYery+puBAbiy0CskBjeKx0Tq/0=";
    };
    date = "2023-11-19";
  };
  solarized-material = {
    pname = "solarized-material";
    version = "93ab6a4b7683795ee9da42f39c1ad28a23ac8b3c";
    src = fetchgit {
      url = "https://github.com/rtlewis1/GTK";
      rev = "93ab6a4b7683795ee9da42f39c1ad28a23ac8b3c";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-MDAewKv1DRoCxWfSCj6+EEtkFFYjm9z5iPZQ3xCjpqM=";
    };
    date = "2023-11-26";
  };
  solarized-sddm = {
    pname = "solarized-sddm";
    version = "2b5bdf1045f2a5c8b880b482840be8983ca06191";
    src = fetchgit {
      url = "https://github.com/MalditoBarbudo/solarized_sddm_theme";
      rev = "2b5bdf1045f2a5c8b880b482840be8983ca06191";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-uVNYmpPM2o9Fq3A1gP04ffXeWdc7y2HP1g7vkiuJZtg=";
    };
    date = "2019-01-03";
  };
  sublimeSolarized = {
    pname = "sublimeSolarized";
    version = "3.0.2";
    src = fetchFromGitHub {
      owner = "braver";
      repo = "Solarized";
      rev = "3.0.2";
      fetchSubmodules = false;
      sha256 = "sha256-tqqYXxKO9/8IRtFk5G4wU0ipObuTwARi9qiBy0K3IPA=";
    };
  };
  tfenv = {
    pname = "tfenv";
    version = "39d8c27ad9862ffdec57989b66fd2720cb72e76c";
    src = fetchFromGitHub {
      owner = "tfutils";
      repo = "tfenv";
      rev = "39d8c27ad9862ffdec57989b66fd2720cb72e76c";
      fetchSubmodules = false;
      sha256 = "sha256-h5ZHT4u7oAdwuWpUrL35G8bIAMasx6E81h15lTJSHhQ=";
    };
    date = "2023-12-19";
  };
  transmissionic = {
    pname = "transmissionic";
    version = "v1.8.0";
    src = fetchurl {
      url = "https://github.com/6c65726f79/Transmissionic/releases/download/v1.8.0/Transmissionic-webui-v1.8.0.zip";
      sha256 = "sha256-IhbJCv9SWjLspJYv6dBKrooGk+vA7sq1N3WzMne6PEw=";
    };
  };
  zerotierone = {
    pname = "zerotierone";
    version = "1.14.2";
    src = fetchurl {
      url = "https://github.com/zerotier/ZeroTierOne/archive/refs/tags/1.14.2.tar.gz";
      sha256 = "sha256-wvZDOfzPUUinrwibiWZ41lX7/MrFLdzncUMUpZ173bs=";
    };
  };
}

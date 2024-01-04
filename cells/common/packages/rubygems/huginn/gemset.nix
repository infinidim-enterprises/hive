{
  ace-rails-ap = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "082n12rkd9j7d89030nhmi4fx1gqaf13knps6cknsyvwix7fryvv";
      type = "gem";
    };
    version = "2.0.1";
  };
  actioncable = {
    dependencies = [ "actionpack" "nio4r" "websocket-driver" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fdc5ir58g05qkf3l55c0jxhajbkh9jw9v4n80a2nfcshhza6qhv";
      type = "gem";
    };
    version = "6.0.5";
  };
  actionmailbox = {
    dependencies = [ "actionpack" "activejob" "activerecord" "activestorage" "activesupport" "mail" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mh1mcr2fbi4b8w0lhrnnr8rwyfxjdvfyjiwxxvyrzqkp9xbzzbm";
      type = "gem";
    };
    version = "6.0.5";
  };
  actionmailer = {
    dependencies = [ "actionpack" "actionview" "activejob" "mail" "rails-dom-testing" ];
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gis9d3xz207c67nnb89gm7adfjpwgs1al5d319gv7fz753ahpxd";
      type = "gem";
    };
    version = "6.0.5";
  };
  actionpack = {
    dependencies = [ "actionview" "activesupport" "rack" "rack-test" "rails-dom-testing" "rails-html-sanitizer" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qhby1sp80n8yvdlap7sb7k1m8k9w3xjfbn256ccrhqwjcbhcmzm";
      type = "gem";
    };
    version = "6.0.5";
  };
  actiontext = {
    dependencies = [ "actionpack" "activerecord" "activestorage" "activesupport" "nokogiri" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0msagm0a4k8xc8iw9b47qr455w28pa0kmryx92hsmr1rgrrr98cc";
      type = "gem";
    };
    version = "6.0.5";
  };
  actionview = {
    dependencies = [ "activesupport" "builder" "erubi" "rails-dom-testing" "rails-html-sanitizer" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19j92w3v9qbvlznzwnssjja9g5z2jkzprrhgx6k6bxmp81gkh8an";
      type = "gem";
    };
    version = "6.0.5";
  };
  activejob = {
    dependencies = [ "activesupport" "globalid" ];
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mqhl5kdr89nz2gj7gjva9dry4cvk29vsmnxn49s3wn0h47wpcw6";
      type = "gem";
    };
    version = "6.0.5";
  };
  activemodel = {
    dependencies = [ "activesupport" ];
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12fpk76q2ha4322qqfg83ny9ycs6p6cx8p6riq6nvzvcgdgp9y6a";
      type = "gem";
    };
    version = "6.0.5";
  };
  activerecord = {
    dependencies = [ "activemodel" "activesupport" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1g39pdwn1y7mjybpa3gyg13rwd9j89ija6w6y6bzsb733la8bbs0";
      type = "gem";
    };
    version = "6.0.5";
  };
  activestorage = {
    dependencies = [ "actionpack" "activejob" "activerecord" "marcel" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xyc2ppcp78yk374m3ka1hnicpn6bibynbhwqn7rphr790b1d1gh";
      type = "gem";
    };
    version = "6.0.5";
  };
  activesupport = {
    dependencies = [ "concurrent-ruby" "i18n" "minitest" "tzinfo" "zeitwerk" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0yqr0k878n4s70myxr36n7sz3y5faydy173vqlq98bhqf70zjp8g";
      type = "gem";
    };
    version = "6.0.5";
  };
  addressable = {
    dependencies = [ "public_suffix" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "022r3m9wdxljpbya69y2i3h9g3dhhfaqzidf95m6qjzms792jvgp";
      type = "gem";
    };
    version = "2.8.0";
  };
  airbrussh = {
    dependencies = [ "sshkit" ];
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16lmd6173gvhcpzj1blracx6hhlqjmmmmi4rh5y4lz6c87vg51lp";
      type = "gem";
    };
    version = "1.4.0";
  };
  aws-eventstream = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pyis1nvnbjxk12a43xvgj2gv0mvp4cnkc1gzw0v1018r61399gz";
      type = "gem";
    };
    version = "1.2.0";
  };
  aws-partitions = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fi4irlxam3bmvafm6iiqj0vlzqg10vc4bzznl4c5w6zmg0lzp6b";
      type = "gem";
    };
    version = "1.547.0";
  };
  aws-sdk-core = {
    dependencies = [ "aws-eventstream" "aws-partitions" "aws-sigv4" "jmespath" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jp8nz18r9skri118haqy0slqmr5bwjw7xvrghcmj9lx409f0m6p";
      type = "gem";
    };
    version = "3.125.2";
  };
  aws-sdk-kms = {
    dependencies = [ "aws-sdk-core" "aws-sigv4" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "044nzbh16x4vx7kbjv1hfh553sp126kcdk2x99apr52j506sk87c";
      type = "gem";
    };
    version = "1.53.0";
  };
  aws-sdk-s3 = {
    dependencies = [ "aws-sdk-core" "aws-sdk-kms" "aws-sigv4" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pgh6zd07r9sfzkdz4bf6piq4n8gzl0f76h68l2zxchc1g9z4lqw";
      type = "gem";
    };
    version = "1.111.1";
  };
  aws-sigv4 = {
    dependencies = [ "aws-eventstream" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wh1y79v0s4zgby2m79bnifk65hwf5pvk2yyrxzn2jkjjq8f8fqa";
      type = "gem";
    };
    version = "1.4.0";
  };
  bcrypt = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02r1c3isfchs5fxivbq99gc3aq4vfyn8snhcy707dal1p8qz12qb";
      type = "gem";
    };
    version = "3.1.16";
  };
  better_errors = {
    dependencies = [ "coderay" "erubi" "rack" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11220lfzhsyf5fcril3qd689kgg46qlpiiaj00hc9mh4mcbc3vrr";
      type = "gem";
    };
    version = "2.9.1";
  };
  binding_of_caller = {
    dependencies = [ "debug_inspector" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "078n2dkpgsivcf0pr50981w95nfc2bsrp3wpf9wnxz1qsp8jbb9s";
      type = "gem";
    };
    version = "1.0.0";
  };
  bootsnap = {
    dependencies = [ "msgpack" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18prmylz53gsw651f0sibb2mvdxgd2zzdzh6a9a1idpqhyxcnbg7";
      type = "gem";
    };
    version = "1.9.3";
  };
  bootstrap-kaminari-views = {
    dependencies = [ "kaminari" "rails" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17j28cs1z1lv31hv04dnhsscj526wz4mwr0b5vkwl6dbv57ynsxf";
      type = "gem";
    };
    version = "0.0.5";
  };
  buftok = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1rzsy1vy50v55x9z0nivf23y0r9jkmq6i130xa75pq9i8qrn1mxs";
      type = "gem";
    };
    version = "0.2.0";
  };
  builder = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "045wzckxpwcqzrjr353cxnyaxgf0qg22jh00dcx7z38cys5g1jlr";
      type = "gem";
    };
    version = "3.2.4";
  };
  byebug = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nx3yjf4xzdgb8jkmk2344081gqr22pgjqnmjg2q64mj5d6r9194";
      type = "gem";
    };
    version = "11.1.3";
  };
  capistrano = {
    dependencies = [ "airbrussh" "i18n" "rake" "sshkit" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jw01z2rawipnkprxy4c2sbdna3k9pxl3gzq3y92l3i1xy5x7ax3";
      type = "gem";
    };
    version = "3.16.0";
  };
  capistrano-bundler = {
    dependencies = [ "capistrano" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "168kyi0gv2s84jm533m8rg0dii50flr06n6s2ci6kzsib3n9n8dr";
      type = "gem";
    };
    version = "2.0.1";
  };
  capistrano-rails = {
    dependencies = [ "capistrano" "capistrano-bundler" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "13fnicx9fkilgvlapjmdglcs3yjll0brx3bp4mbi3sixxcm6vy9r";
      type = "gem";
    };
    version = "1.6.1";
  };
  capybara = {
    dependencies = [ "addressable" "mini_mime" "nokogiri" "rack" "rack-test" "xpath" ];
    groups = [ "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0yv77rnsjlvs8qpfn9n5vf1h6b9agxwhxw09gssbiw9zn9j20jh8";
      type = "gem";
    };
    version = "2.18.0";
  };
  capybara-screenshot = {
    dependencies = [ "capybara" "launchy" ];
    groups = [ "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03jp17z1y2afh5s3alsxxy74i5csxiyk751qp8b49kbzva0b16wk";
      type = "gem";
    };
    version = "1.0.17";
  };
  capybara-select-2 = {
    groups = [ "development" "test" ];
    platforms = [ ];
    source = {
      fetchSubmodules = false;
      rev = "fbf22fb74dec10fa0edcd26da7c5184ba8fa2c76";
      sha256 = "0n5f3isz6ncj1jd5faqyqc7bmhrnzb2ba1mhdwfkmfkdsyg7x6v2";
      type = "git";
      url = "https://github.com/Hirurg103/capybara_select2.git";
    };
    version = "0.3.2";
  };
  cliver = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "096f4rj7virwvqxhkavy0v55rax10r4jqf8cymbvn4n631948xc7";
      type = "gem";
    };
    version = "0.3.2";
  };
  coderay = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jvxqxzply1lwp7ysn94zjhh57vc14mcshw1ygw14ib8lhc00lyw";
      type = "gem";
    };
    version = "1.1.3";
  };
  coffee-rails = {
    dependencies = [ "coffee-script" "railties" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "170sp4y82bf6nsczkkkzypzv368sgjg6lfrkib4hfjgxa6xa3ajx";
      type = "gem";
    };
    version = "5.0.0";
  };
  coffee-script = {
    dependencies = [ "coffee-script-source" "execjs" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rc7scyk7mnpfxqv5yy4y5q1hx3i7q3ahplcp4bq2g5r24g2izl2";
      type = "gem";
    };
    version = "2.4.1";
  };
  coffee-script-source = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1907v9q1zcqmmyqzhzych5l7qifgls2rlbnbhy5vzyr7i7yicaz1";
      type = "gem";
    };
    version = "1.12.2";
  };
  concurrent-ruby = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0s4fpn3mqiizpmpy2a24k4v365pv75y50292r8ajrv4i1p5b2k14";
      type = "gem";
    };
    version = "1.1.10";
  };
  cookiejar = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04icmz2pwn3iq10g7chahm98hx33d217nxw37idgkm9a28g7r1vz";
      type = "gem";
    };
    version = "0.3.2";
  };
  coveralls = {
    dependencies = [ "json" "simplecov" "term-ansicolor" "thor" "tins" ];
    groups = [ "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mv4fn5lfxhy7bc2f1lpnc5yp9mvv97az77j4r7jgrxcqwn8fqxc";
      type = "gem";
    };
    version = "0.8.23";
  };
  crack = {
    dependencies = [ "safe_yaml" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0abb0fvgw00akyik1zxnq7yv391va148151qxdghnzngv66bl62k";
      type = "gem";
    };
    version = "0.4.3";
  };
  crass = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pfl5c0pyqaparxaqxi6s4gfl21bdldwiawrc0aknyvflli60lfw";
      type = "gem";
    };
    version = "1.0.6";
  };
  daemons = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1j1m64pirsldhic6x6sg4lcrmp1bs1ihpd49xm8m1b2rc1c3irzy";
      type = "gem";
    };
    version = "1.1.9";
  };
  debug_inspector = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01l678ng12rby6660pmwagmyg8nccvjfgs3487xna7ay378a59ga";
      type = "gem";
    };
    version = "1.1.0";
  };
  declarative = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1yczgnqrbls7shrg63y88g7wand2yp9h6sf56c9bdcksn5nds8c0";
      type = "gem";
    };
    version = "0.0.20";
  };
  delayed_job = {
    dependencies = [ "activesupport" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19ym3jw2jj1pxm6p22x2mpf69sdxiw07ddr69v92ccgg6d7q87rh";
      type = "gem";
    };
    version = "4.1.9";
  };
  delayed_job_active_record = {
    dependencies = [ "activerecord" "delayed_job" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      fetchSubmodules = false;
      rev = "ac2dfef97be39ae0fee2de8006158878ed65a719";
      sha256 = "0lrpzksxm3q0ambhd8kr91ac3f9g7jk59hs30vvnhczv3w26farq";
      type = "git";
      url = "https://github.com/dsander/delayed_job_active_record.git";
    };
    version = "4.1.4";
  };
  devise = {
    dependencies = [ "bcrypt" "orm_adapter" "railties" "responders" "warden" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gl0b4jqf7ysv3rg99sgxa5y9va2k13p0si3a88pr7m8g6z8pm7x";
      type = "gem";
    };
    version = "4.8.1";
  };
  diff-lcs = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rwvjahnp7cpmracd8x732rjgnilqv2sx7d1gfrysslc3h039fa9";
      type = "gem";
    };
    version = "1.5.0";
  };
  docile = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lxqxgq71rqwj1lpl9q1mbhhhhhhdkkj7my341f2889pwayk85sz";
      type = "gem";
    };
    version = "1.4.0";
  };
  domain_name = {
    dependencies = [ "unf" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12hs8yijhak7p2hf1xkh98g0mnp5phq3mrrhywzaxpwz1gw5r3kf";
      type = "gem";
    };
    version = "0.5.20170404";
  };

  dotenv = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      path = vendor/gems/dotenv-2.0.1;
      type = "path";
    };
    version = "2.0.1";
  };
  dotenv-rails = {
    dependencies = [ "dotenv" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      path = vendor/gems/dotenv-2.0.1;
      type = "path";
    };
    version = "2.0.1";
  };

  # dotenv = {
  #   groups = [ "default" ];
  #   platforms = [ ];
  #   source = {
  #     remotes = [ "https://rubygems.org" ];
  #     sha256 = "0iym172c5337sm1x2ykc2i3f961vj3wdclbyg1x6sxs3irgfsl94";
  #     type = "gem";
  #   };
  #   version = "2.7.6";
  # };

  # dotenv-rails = {
  #   groups = [ "default" ];
  #   platforms = [ ];
  #   source = {
  #     remotes = [ "https://rubygems.org" ];
  #     sha256 = "0iym172c5337sm1x2ykc2i3f961vj3wdclbyg1x6sxs3irgfsl94";
  #     type = "gem";
  #   };
  #   version = "2.7.6";
  # };

  dropbox-api = {
    dependencies = [ "hashie" "multi_json" "oauth2" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      fetchSubmodules = false;
      rev = "86cb7b5a1254dc5b054de7263835713c4c1018c7";
      sha256 = "1q43z7pa961k28ichyan10aaf8wjaqnyss0xmn2rm6026lm9lmzx";
      type = "git";
      url = "https://github.com/dsander/dropbox-api.git";
    };
    version = "0.5.0";
  };
  em-http-request = {
    dependencies = [ "addressable" "cookiejar" "em-socksify" "eventmachine" "http_parser.rb" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vbshzj03w09j7ffh8i5dywm4kgjy3a15fp87sxgy95jv00234w0";
      type = "gem";
    };
    version = "1.1.2";
  };
  em-socksify = {
    dependencies = [ "eventmachine" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12bbi4s02h1c1akdv552l6d1zqc0kpd9vs88811qkz2ywq9yp7ra";
      type = "gem";
    };
    version = "0.3.0";
  };
  em-websocket = {
    dependencies = [ "eventmachine" "http_parser.rb" ];
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1a66b0kjk6jx7pai9gc7i27zd0a128gy73nmas98gjz6wjyr4spm";
      type = "gem";
    };
    version = "0.5.3";
  };
  equalizer = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kjmx3fygx8njxfrwcmn7clfhjhb6bvv3scy2lyyi0wqyi3brra4";
      type = "gem";
    };
    version = "0.0.11";
  };
  erector = {
    dependencies = [ "treetop" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      fetchSubmodules = false;
      rev = "821c2fa9174b56cc39e203883d83b18b60912a36";
      sha256 = "0skz65mfja37i66668riqsy3148cyszkz3dag7pml26d7fjv6xxl";
      type = "git";
      url = "https://github.com/dsander/erector.git";
    };
    version = "0.10.0";
  };
  erubi = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09l8lz3j00m898li0yfsnb6ihc63rdvhw3k5xczna5zrjk104f2l";
      type = "gem";
    };
    version = "1.10.0";
  };
  et-orbi = {
    dependencies = [ "tzinfo" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xsfa02hin2ymfcf0bdvsw6wk8w706rrfdqpy6b4f439zbqmn05m";
      type = "gem";
    };
    version = "1.2.6";
  };
  ethon = {
    dependencies = [ "ffi" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gggrgkcq839mamx7a8jbnp2h7x2ykfn34ixwskwb0lzx2ak17g9";
      type = "gem";
    };
    version = "0.12.0";
  };
  eventmachine = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wh9aqb0skz80fhfn66lbpr4f86ya2z5rx6gm5xlfhd05bj1ch4r";
      type = "gem";
    };
    version = "1.2.7";
  };
  evernote-thrift = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vkjpzd3lrh0cnv6hq8nc6n2284nypi7zij2zb21yg62fknckpzr";
      type = "gem";
    };
    version = "1.25.1";
  };
  evernote_oauth = {
    dependencies = [ "evernote-thrift" "oauth" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06i0lbx3s9rhc10nbbq52vggxm6jvmpq9f8y6nk4an7fq1z5673n";
      type = "gem";
    };
    version = "0.2.3";
  };
  execjs = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "121h6af4i6wr3wxvv84y53jcyw2sk71j5wsncm6wq6yqrwcrk4vd";
      type = "gem";
    };
    version = "2.8.1";
  };
  faraday = {
    dependencies = [ "multipart-post" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "172dirvq89zk57rv42n00rhbc2qwv1w20w4zjm6zvfqz4rdpnrqi";
      type = "gem";
    };
    version = "0.17.4";
  };
  faraday_middleware = {
    dependencies = [ "faraday" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1p7icfl28nvl8qqdsngryz1snqic9l8x6bk0dxd7ygn230y0k41d";
      type = "gem";
    };
    version = "0.12.2";
  };
  feedjira = {
    dependencies = [ "loofah" "sax-machine" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0yl57p9z2wgajd1wdq344dvb4jk71r56rk99x0m05md9mragx1gs";
      type = "gem";
    };
    version = "3.2.0";
  };
  ffi = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1862ydmclzy1a0cjbvm8dz7847d9rch495ib0zb64y84d3xd4bkg";
      type = "gem";
    };
    version = "1.15.5";
  };
  font-awesome-sass = {
    dependencies = [ "sass" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bi4fi8fn41wbmd44q1cs49xwdxqn14198211qk2p37g3h3mkwj6";
      type = "gem";
    };
    version = "4.7.0";
  };
  forecast_io = {
    dependencies = [ "faraday" "hashie" "multi_json" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wg69wdri5v12a48xwbmk9i8f57fdf43s3s6j8222065m47326bg";
      type = "gem";
    };
    version = "2.0.1";
  };
  foreman = {
    dependencies = [ "dotenv" "thor" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0yqyjix9jm4iwyc4f3wc32vxr28rpjcw1c9ni5brs4s2a24inzlk";
      type = "gem";
    };
    version = "0.63.0";
  };
  formatador = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mprf1dwznz5ld0q1jpbyl59fwnwk6azspnd0am7zz7kfg3pxhv5";
      type = "gem";
    };
    version = "0.3.0";
  };
  fugit = {
    dependencies = [ "et-orbi" "raabro" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0l8878iqg85zmpifjfnidpp17swgh103a0br68nqakflnn0zwcka";
      type = "gem";
    };
    version = "1.5.2";
  };
  gems = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1w26k4db8yj6x1gpxvh1rma4p36hz61xkk7kjf0z61nrajyp8g9l";
      type = "gem";
    };
    version = "1.2.0";
  };
  geokit = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mvdpbx88wflqqrcrfa54a5sckvj2sqzm304p7ji3c06frbhmxw8";
      type = "gem";
    };
    version = "1.13.1";
  };
  geokit-rails = {
    dependencies = [ "geokit" "rails" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09v3v0gm19a2cp2qz2w2095y0fc8fz4i8py8zjkrrc00i2lgg69j";
      type = "gem";
    };
    version = "2.3.2";
  };
  globalid = {
    dependencies = [ "activesupport" ];
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1n5yc058i8xhi1fwcp1w7mfi6xaxfmrifdb4r4hjfff33ldn8lqj";
      type = "gem";
    };
    version = "1.0.0";
  };
  gmail_xoauth = {
    dependencies = [ "oauth" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dslnb1kffcygcbs8sqw58w6ba0maq4w7k1i7kjrqpq0kxx6wklq";
      type = "gem";
    };
    version = "0.4.2";
  };
  google-api-client = {
    dependencies = [ "google-apis-core" "google-apis-generator" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zypv7qz37ql5fqnlmk39krbazzshjzsw44syg7p0ap03zr6w021";
      type = "gem";
    };
    version = "0.53.0";
  };
  google-apis-core = {
    dependencies = [ "addressable" "googleauth" "httpclient" "mini_mime" "representable" "retriable" "rexml" "webrick" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nzzj66clgr9ldmbjqkzgpvqmd6bjjmbw6khpgq80mp3gks4ycqy";
      type = "gem";
    };
    version = "0.4.1";
  };
  google-apis-discovery_v1 = {
    dependencies = [ "google-apis-core" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0asjh21r5yasi8ffp8ry824l6nim9hpspmzfzim5ssrihyxwzimq";
      type = "gem";
    };
    version = "0.7.0";
  };
  google-apis-generator = {
    dependencies = [ "activesupport" "gems" "google-apis-core" "google-apis-discovery_v1" "thor" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jyw10x64yw2fwiqcnxxik2d016546icp2aa3ynz55x9v12yqpvx";
      type = "gem";
    };
    version = "0.4.0";
  };
  google-cloud-core = {
    dependencies = [ "google-cloud-env" "google-cloud-errors" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0amp8vd16pzbdrfbp7k0k38rqxpwd88bkyp35l3x719hbb6l85za";
      type = "gem";
    };
    version = "1.6.0";
  };
  google-cloud-env = {
    dependencies = [ "faraday" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ajc3w4wqg46ywcbmb5fz1q6gfm6g7874s9h31i1r038kz2bzfag";
      type = "gem";
    };
    version = "1.5.0";
  };
  google-cloud-errors = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nakfswnck6grjpyhckzl40qccyys3sy999h5axk0rldx96fnivd";
      type = "gem";
    };
    version = "1.2.0";
  };
  google-cloud-translate = {
    dependencies = [ "faraday" "google-cloud-core" "google-gax" "googleapis-common-protos" "googleapis-common-protos-types" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02p4srvj0vq5cpvwvq11v63xbqz1h9vi3njm13sv4lb3gaf8gx01";
      type = "gem";
    };
    version = "2.3.0";
  };
  google-gax = {
    dependencies = [ "google-protobuf" "googleapis-common-protos" "googleapis-common-protos-types" "googleauth" "grpc" "rly" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qin4b52gchch1frs0hkzsv27839068g91df1hcn2c5a9qihfvdn";
      type = "gem";
    };
    version = "1.8.2";
  };
  google-protobuf = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14ncdzyfdr7f6v6wx4bym5j58jqs6lms2wmd93jzfr7miifw2d1d";
      type = "gem";
    };
    version = "3.19.2";
  };
  googleapis-common-protos = {
    dependencies = [ "google-protobuf" "googleapis-common-protos-types" "grpc" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1a254ywfyanylr53vmi4zj93l3bi60sv7nbx8n8rgwavq3fiqkf8";
      type = "gem";
    };
    version = "1.3.12";
  };
  googleapis-common-protos-types = {
    dependencies = [ "google-protobuf" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0w860lqs5j6n58a8qn4wr16hp0qz7cq5h67dgma04gncjwqiyhf5";
      type = "gem";
    };
    version = "1.3.0";
  };
  googleauth = {
    dependencies = [ "faraday" "jwt" "memoist" "multi_json" "os" "signet" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08l9qb2an7a60r3xjlkrfna8b8sfnj5c2hlfdygbnpvb1p7cpafl";
      type = "gem";
    };
    version = "0.17.1";
  };
  grpc = {
    dependencies = [ "google-protobuf" "googleapis-common-protos-types" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jjq2ing7px4zvdrg9xcq5a9qsciq6g3v14n95a3d9n6cyg69lmk";
      type = "gem";
    };
    version = "1.42.0";
  };
  guard = {
    dependencies = [ "formatador" "listen" "lumberjack" "nenv" "notiffany" "pry" "shellany" "thor" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zqy994fr0pf3pda0x3mmkhgnfg4hd12qp5bh1s1xm68l00viwhj";
      type = "gem";
    };
    version = "2.18.0";
  };
  guard-compat = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zj6sr1k8w59mmi27rsii0v8xyy2rnsi09nqvwpgj1q10yq1mlis";
      type = "gem";
    };
    version = "1.2.1";
  };
  guard-livereload = {
    dependencies = [ "em-websocket" "guard" "guard-compat" "multi_json" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0yd74gdbbv2yz2caqwpsavzw8d5fd5y446wp8rdjw8wan0yd6k8j";
      type = "gem";
    };
    version = "2.5.2";
  };
  guard-rspec = {
    dependencies = [ "guard" "guard-compat" "rspec" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jkm5xp90gm4c5s51pmf92i9hc10gslwwic6mvk72g0yplya0yx4";
      type = "gem";
    };
    version = "4.7.3";
  };
  hashdiff = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19ykg5pax8798nh1yv71adkx0zzs7gn2rxjj86v7nsw0jba5lask";
      type = "gem";
    };
    version = "0.3.8";
  };
  hashie = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hh5lybf8hm7d7xs4xm8hxvm8xqrs2flc8fnwkrclaj746izw6xb";
      type = "gem";
    };
    version = "3.5.7";
  };
  haversine = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qz7qbd2kcccr6sy2plz78gfxlif1przda2qn35skdbfwj62ibsw";
      type = "gem";
    };
    version = "0.3.0";
  };
  hipchat = {
    dependencies = [ "httparty" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "076jphfai4xzl5znbb256d8aqijx82an4zappjv3gxg5h9gc5cxk";
      type = "gem";
    };
    version = "1.2.0";
  };
  httmultiparty = {
    dependencies = [ "httparty" "mimemagic" "multipart-post" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0v5wj3n9d6gk7427jfd876mbkhkwfnxzh46cf5bnxwpr7x0ga2sv";
      type = "gem";
    };
    version = "0.3.16";
  };
  http = {
    dependencies = [ "addressable" "http-cookie" "http-form_data" "http_parser.rb" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vbz8r894v2dvgf7xh91yz8hjb14g3rh448crbw7kqqi320s5hb4";
      type = "gem";
    };
    version = "2.1.0";
  };
  http-cookie = {
    dependencies = [ "domain_name" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "004cgs4xg5n6byjs7qld0xhsjq3n6ydfh897myr2mibvh6fjc49g";
      type = "gem";
    };
    version = "1.0.3";
  };
  http-form_data = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10r6hy8wcf8n4nbdmdz9hrm8mg45lncfc7anaycpzrhfp3949xh9";
      type = "gem";
    };
    version = "1.0.1";
  };
  "http_parser.rb" = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15nidriy0v5yqfjsgsra51wmknxci2n2grliz78sf9pga3n0l7gi";
      type = "gem";
    };
    version = "0.6.0";
  };
  httparty = {
    dependencies = [ "multi_xml" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1msa213hclsv14ijh49i1wggf9avhnj2j4xr58m9jx6fixlbggw6";
      type = "gem";
    };
    version = "0.14.0";
  };
  httpclient = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19mxmvghp7ki3klsxwrlwr431li7hm1lczhhj8z4qihl2acy8l99";
      type = "gem";
    };
    version = "2.8.3";
  };
  huginn_agent = {
    dependencies = [ "thor" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12qxm6fblbjrcj2r25kz15lc9fkd4cvdakn7ymagiifsf3i1f238";
      type = "gem";
    };
    version = "0.6.1";
  };
  hypdf = {
    dependencies = [ "httmultiparty" "httparty" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gkyk77yiypz46s8x5sm5p2cynxy36jskqnc5yv20nhh17kgwr80";
      type = "gem";
    };
    version = "1.0.10";
  };
  i18n = {
    dependencies = [ "concurrent-ruby" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0b2qyvnk4yynlg17ymkq4g5xgr275637fhl1mjh0valw3cb1fhhg";
      type = "gem";
    };
    version = "1.10.0";
  };
  jmespath = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ylph158dc3ql6cvkik00ab6gf2k1rv2dii63m196xclhkzwfyan";
      type = "gem";
    };
    version = "1.5.0";
  };
  jquery-rails = {
    dependencies = [ "rails-dom-testing" "railties" "thor" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hfz6ppxl6dys56nmrcpy6q1ddjf3q7zjaprylxw8lraja1l7ky2";
      type = "gem";
    };
    version = "4.2.2";
  };
  json = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1z9grvjyfz16ag55hg522d3q4dh07hf391sf9s96npc0vfi85xkz";
      type = "gem";
    };
    version = "2.6.1";
  };
  jsonpath = {
    dependencies = [ "multi_json" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12hjsr0plnx6v0bh1rhhimfi7z3rqm19xb47ybdkc1h9yhynnmdq";
      type = "gem";
    };
    version = "1.1.0";
  };
  jwt = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bg8pjx0mpvl10k6d8a6gc8dzlv2z5jkqcjbjcirnk032iriq838";
      type = "gem";
    };
    version = "2.3.0";
  };
  kaminari = {
    dependencies = [ "activesupport" "kaminari-actionview" "kaminari-activerecord" "kaminari-core" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gia8irryvfhcr6bsr64kpisbgdbqjsqfgrk12a11incmpwny1y4";
      type = "gem";
    };
    version = "1.2.2";
  };
  kaminari-actionview = {
    dependencies = [ "actionview" "kaminari-core" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02f9ghl3a9b5q7l079d3yzmqjwkr4jigi7sldbps992rigygcc0k";
      type = "gem";
    };
    version = "1.2.2";
  };
  kaminari-activerecord = {
    dependencies = [ "activerecord" "kaminari-core" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0c148z97s1cqivzbwrak149z7kl1rdmj7dxk6rpkasimmdxsdlqd";
      type = "gem";
    };
    version = "1.2.2";
  };
  kaminari-core = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zw3pg6kj39y7jxakbx7if59pl28lhk98fx71ks5lr3hfgn6zliv";
      type = "gem";
    };
    version = "1.2.2";
  };
  kgio = {
    groups = [ "default" "production" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ipzvw7n0kz1w8rkqybyxvf3hb601a770khm0xdqm68mc4aa59xx";
      type = "gem";
    };
    version = "2.11.4";
  };
  kramdown = {
    dependencies = [ "rexml" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jdbcjv4v7sj888bv3vc6d1dg4ackkh7ywlmn9ln2g9alk7kisar";
      type = "gem";
    };
    version = "2.3.1";
  };
  launchy = {
    dependencies = [ "addressable" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xdyvr5j0gjj7b10kgvh8ylxnwk3wx19my42wqn9h82r4p246hlm";
      type = "gem";
    };
    version = "2.5.0";
  };
  letter_opener = {
    dependencies = [ "launchy" ];
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09a7kgsmr10a0hrc9bwxglgqvppjxij9w8bxx91mnvh0ivaw0nq9";
      type = "gem";
    };
    version = "1.7.0";
  };
  letter_opener_web = {
    dependencies = [ "actionmailer" "letter_opener" "railties" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0kgz2n0cyw3m8ipvijlikb6bldmzhnq451b9d7w5l74gw2fhqckg";
      type = "gem";
    };
    version = "1.4.1";
  };

  libv8-node = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "102ixp1626b4zjh98h3jxhwv0sdbkgijz38wyb1ffgxqr47c7s0w";
      type = "gem";
    };
    version = "16.10.0.0";
  };

  liquid = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0b3nmab5vvn48mr0yrp5cryvdi1xw749jrkca0wwciv0wcb8y50v";
      type = "gem";
    };
    version = "5.3.0";
  };

  listen = {
    dependencies = [ "rb-fsevent" "rb-inotify" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1l0y7hbyfiwpvk172r28hsdqsifq1ls39hsfmzi1vy4ll0smd14i";
      type = "gem";
    };
    version = "3.0.8";
  };

  loofah = {
    dependencies = [ "crass" "nokogiri" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18ymp6l3bv7abz07k6qbbi9c9vsiahq30d2smh4qzsvag8j5m5v1";
      type = "gem";
    };
    version = "2.18.0";
  };
  lumberjack = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06pybb23hypc9gvs2p839ildhn26q68drb6431ng3s39i3fkkba8";
      type = "gem";
    };
    version = "1.2.8";
  };
  macaddr = {
    dependencies = [ "systemu" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1clii8mvhmh5lmnm95ljnjygyiyhdpja85c5vy487rhxn52scn0b";
      type = "gem";
    };
    version = "1.7.1";
  };
  mail = {
    dependencies = [ "mini_mime" ];
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00wwz6ys0502dpk8xprwcqfwyf3hmnx6lgxaiq6vj43mkx43sapc";
      type = "gem";
    };
    version = "2.7.1";
  };
  marcel = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0kky3yiwagsk8gfbzn3mvl2fxlh3b39v6nawzm4wpjs6xxvvc4x0";
      type = "gem";
    };
    version = "1.0.2";
  };
  memoist = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0i9wpzix3sjhf6d9zw60dm4371iq8kyz7ckh2qapan2vyaim6b55";
      type = "gem";
    };
    version = "0.16.2";
  };
  memoizable = {
    dependencies = [ "thread_safe" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0v42bvghsvfpzybfazl14qhkrjvx0xlmxz0wwqc960ga1wld5x5c";
      type = "gem";
    };
    version = "0.4.2";
  };
  method_source = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pnyh44qycnf9mzi1j6fywd5fkskv3x7nmsqrrws0rjn5dd4ayfp";
      type = "gem";
    };
    version = "1.0.0";
  };
  mime-types = {
    dependencies = [ "mime-types-data" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ipw892jbksbxxcrlx9g5ljq60qx47pm24ywgfbyjskbcl78pkvb";
      type = "gem";
    };
    version = "3.4.1";
  };
  mime-types-data = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03m3fkix2haah20kvh1jgv262yg9jlzn6wq0y31kafxk8fysfy27";
      type = "gem";
    };
    version = "3.2021.1115";
  };
  mimemagic = {
    dependencies = [ "nokogiri" "rake" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17ycgsmz2229jh224ws77yg974cz326flgc401xrdkfpw90jvb08";
      type = "gem";
    };
    version = "0.4.3";
  };
  mini_magick = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1aj604x11d9pksbljh0l38f70b558rhdgji1s9i763hiagvvx2hs";
      type = "gem";
    };
    version = "4.11.0";
  };
  mini_mime = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0lbim375gw2dk6383qirz13hgdmxlan0vc5da2l072j3qw6fqjm5";
      type = "gem";
    };
    version = "1.1.2";
  };
  mini_portile2 = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rapl1sfmfi3bfr68da4ca16yhc0pp93vjwkj7y3rdqrzy3b41hy";
      type = "gem";
    };
    version = "2.8.0";
  };
  mini_racer = {
    dependencies = [ "libv8-node" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jf9qjz3r06asz14b6f3z7f2y437a1viqfp52sdi71ipj7dk70bs";
      type = "gem";
    };
    version = "0.6.2";
  };
  minitest = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06xf558gid4w8lwx13jwfdafsch9maz8m0g85wnfymqj63x5nbbd";
      type = "gem";
    };
    version = "5.15.0";
  };
  mqtt = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hf23hv1aq9164nx5kirhw99zm3dkwgkg48l4kl1sb2zaqlzv8p1";
      type = "gem";
    };
    version = "0.3.1";
  };
  msgpack = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06iajjyhx0rvpn4yr3h1hc4w4w3k59bdmfhxnjzzh76wsrdxxrc6";
      type = "gem";
    };
    version = "1.4.2";
  };
  multi_json = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pb1g1y3dsiahavspyzkdy39j4q377009f6ix0bh1ag4nqw43l0z";
      type = "gem";
    };
    version = "1.15.0";
  };
  multi_xml = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0lmd4f401mvravi1i1yq7b2qjjli0yq7dfc4p1nj5nwajp7r6hyj";
      type = "gem";
    };
    version = "0.6.0";
  };
  multipart-post = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zgw9zlwh2a6i1yvhhc4a84ry1hv824d6g2iw2chs3k5aylpmpfj";
      type = "gem";
    };
    version = "2.1.1";
  };
  mysql2 = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d14pcy5m4hjig0zdxnl9in5f4izszc7v9zcczf2gyi5kiyxk8jw";
      type = "gem";
    };
    version = "0.5.3";
  };
  naught = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wwjx35zgbc0nplp8a866iafk4zsrbhwwz4pav5gydr2wm26nksg";
      type = "gem";
    };
    version = "1.1.0";
  };
  nenv = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0r97jzknll9bhd8yyg2bngnnkj8rjhal667n7d32h8h7ny7nvpnr";
      type = "gem";
    };
    version = "0.3.0";
  };
  net-ftp-list = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1a3cy694w2aj6g3gh90bpxhby1r4z84wg8s5ffwjjs40s2r1vri9";
      type = "gem";
    };
    version = "3.2.8";
  };
  net-scp = {
    dependencies = [ "net-ssh" ];
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0b4h3ip8d1gkrc0znnw54hbxillk73mdnaf5pz330lmrcl1wiilg";
      type = "gem";
    };
    version = "3.0.0";
  };
  net-ssh = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jp3jgcn8cij407xx9ldb5h9c6jv13jc4cf6kk2idclz43ww21c9";
      type = "gem";
    };
    version = "6.1.0";
  };
  netrc = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gzfmcywp1da8nzfqsql2zqi648mfnx6qwkig3cv36n9m0yy676y";
      type = "gem";
    };
    version = "0.11.0";
  };
  nio4r = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xk64wghkscs6bv2n22853k2nh39d131c6rfpnlw12mbjnnv9v1v";
      type = "gem";
    };
    version = "2.5.8";
  };
  nokogiri = {
    dependencies = [ "mini_portile2" "racc" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11w59ga9324yx6339dgsflz3dsqq2mky1qqdwcg6wi5s1bf2yldi";
      type = "gem";
    };
    version = "1.13.6";
  };
  notiffany = {
    dependencies = [ "nenv" "shellany" ];
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0f47h3bmg1apr4x51szqfv3rh2vq58z3grh4w02cp3bzbdh6jxnk";
      type = "gem";
    };
    version = "0.1.3";
  };
  oauth = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0h6nfg2pibc17fch0795d4bcy41a92im5zrsrgs31zdhrl6zf4w0";
      type = "gem";
    };
    version = "0.5.8";
  };
  oauth2 = {
    dependencies = [ "faraday" "jwt" "multi_json" "multi_xml" "rack" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1q6q2kgpxmygk8kmxqn54zkw8cs57a34zzz5cxpsh1bj3ag06rk3";
      type = "gem";
    };
    version = "1.4.7";
  };
  omniauth = {
    dependencies = [ "hashie" "rack" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "002vi9gwamkmhf0dsj2im1d47xw2n1jfhnzl18shxf3ampkqfmyz";
      type = "gem";
    };
    version = "1.9.1";
  };
  omniauth-dropbox-oauth2 = {
    dependencies = [ "omniauth-oauth2" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      fetchSubmodules = false;
      rev = "9468fb33af0af2bad880dcfb42236fde474017a2";
      sha256 = "0zsfd0gi9wkliiz7639pjdkvif2z17pxgd5ahz8z4xjqpp4xp4hz";
      type = "git";
      url = "https://github.com/huginn/omniauth-dropbox-oauth2.git";
    };
    version = "0.3.0";
  };
  omniauth-evernote = {
    dependencies = [ "evernote-thrift" "multi_json" "omniauth-oauth" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ywpwc187dwlh7270b15y2kl4pn3f3n2m9ycvphp3kkw19q3vdwv";
      type = "gem";
    };
    version = "1.2.1";
  };
  omniauth-google-oauth2 = {
    dependencies = [ "jwt" "oauth2" "omniauth" "omniauth-oauth2" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10pnxvb6wpnf58dja3yz4ja527443x3q13hzhcbays4amnnp8i4a";
      type = "gem";
    };
    version = "0.8.2";
  };
  omniauth-oauth = {
    dependencies = [ "oauth" "omniauth" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1n5vk4by7hkyc09d9blrw2argry5awpw4gbw1l4n2s9b3j4qz037";
      type = "gem";
    };
    version = "1.1.0";
  };
  omniauth-oauth2 = {
    dependencies = [ "oauth2" "omniauth" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ry65f309rnzhgdjvqybkd5i4qp9rpk1gbp4dz02h4l6bkk6ya10";
      type = "gem";
    };
    version = "1.7.2";
  };
  omniauth-tumblr = {
    dependencies = [ "multi_json" "omniauth-oauth" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10ncmfym4l6k6aqp402g7mqxahbggcj5xkpsjxgngs746s82y97w";
      type = "gem";
    };
    version = "1.2";
  };
  omniauth-twitter = {
    dependencies = [ "omniauth-oauth" "rack" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1w1qfkdx74z8asb8nhr0fyianb9hr4fp2fr9k3jsvldmmlp46zcz";
      type = "gem";
    };
    version = "1.3.0";
  };
  orm_adapter = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fg9jpjlzf5y49qs9mlpdrgs5rpcyihq1s4k79nv9js0spjhnpda";
      type = "gem";
    };
    version = "0.5.0";
  };
  os = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gwd20smyhxbm687vdikfh1gpi96h8qb1x28s2pdcysf6dm6v0ap";
      type = "gem";
    };
    version = "1.1.4";
  };
  pg = {
    groups = [ "default" ];
    platforms = [{
      engine = "maglev";
      version = "1.8";
    }
      {
        engine = "rbx";
        version = "1.8";
      }
      {
        engine = "ruby";
        version = "1.8";
      }];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pnjw3rspdfjssxyf42jnbsdlgri8ylysimp0s28wxb93k6ff2qb";
      type = "gem";
    };
    version = "1.1.3";
  };
  poltergeist = {
    dependencies = [ "capybara" "cliver" "multi_json" "websocket-driver" ];
    groups = [ "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ppm4isvbxm739508yjhvisq1iwp1q6h8dx4hkndj2krskavz4i9";
      type = "gem";
    };
    version = "1.8.1";
  };
  polyglot = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1bqnxwyip623d8pr29rg6m8r0hdg08fpr2yb74f46rn1wgsnxmjr";
      type = "gem";
    };
    version = "0.3.5";
  };
  pry = {
    dependencies = [ "coderay" "method_source" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0iyw4q4an2wmk8v5rn2ghfy2jaz9vmw2nk8415nnpx2s866934qk";
      type = "gem";
    };
    version = "0.13.1";
  };
  pry-byebug = {
    dependencies = [ "byebug" "pry" ];
    groups = [ "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "096y5vmzpyy4x9h4ky4cs4y7d19vdq9vbwwrqafbh5gagzwhifiv";
      type = "gem";
    };
    version = "3.9.0";
  };
  pry-rails = {
    dependencies = [ "pry" ];
    groups = [ "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cf4ii53w2hdh7fn8vhqpzkymmchjbwij4l3m7s6fsxvb9bn51j6";
      type = "gem";
    };
    version = "0.3.9";
  };
  public_suffix = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xqcgkl7bwws1qrlnmxgh8g4g9m10vg60bhlw40fplninb3ng6d9";
      type = "gem";
    };
    version = "4.0.6";
  };
  raabro = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10m8bln9d00dwzjil1k42i5r7l82x25ysbi45fwyv4932zsrzynl";
      type = "gem";
    };
    version = "1.4.0";
  };
  racc = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0la56m0z26j3mfn1a9lf2l03qx1xifanndf9p3vx1azf6sqy7v9d";
      type = "gem";
    };
    version = "1.6.0";
  };
  rack = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0i5vs0dph9i5jn8dfc6aqd6njcafmb20rwqngrf759c9cvmyff16";
      type = "gem";
    };
    version = "2.2.3";
  };
  rack-livereload = {
    dependencies = [ "rack" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1slzlmvlapgp2pc7389i0zndq3nka0s6sh445vf21cxpz7vz3p5i";
      type = "gem";
    };
    version = "0.3.17";
  };
  rack-test = {
    dependencies = [ "rack" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rh8h376mx71ci5yklnpqqn118z3bl67nnv5k801qaqn1zs62h8m";
      type = "gem";
    };
    version = "1.1.0";
  };
  rails = {
    dependencies = [ "actioncable" "actionmailbox" "actionmailer" "actionpack" "actiontext" "actionview" "activejob" "activemodel" "activerecord" "activestorage" "activesupport" "railties" "sprockets-rails" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mvfancjjk3w4zcls8j8lwyshgg937nldr57znlrracbsm0ay478";
      type = "gem";
    };
    version = "6.0.5";
  };
  rails-controller-testing = {
    dependencies = [ "actionpack" "actionview" "activesupport" ];
    groups = [ "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1m1rklj6pvzi4fydxcmcv4q0xd7913hhhw1hw530nfz1wkl7vjlf";
      type = "gem";
    };
    version = "1.0.4";
  };
  rails-dom-testing = {
    dependencies = [ "activesupport" "nokogiri" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lfq2a7kp2x64dzzi5p4cjcbiv62vxh9lyqk2f0rqq3fkzrw8h5i";
      type = "gem";
    };
    version = "2.0.3";
  };
  rails-html-sanitizer = {
    dependencies = [ "loofah" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09qrfi3pgllxb08r024lln9k0qzxs57v0slsj8616xf9c0cwnwbk";
      type = "gem";
    };
    version = "1.4.2";
  };
  railties = {
    dependencies = [ "actionpack" "activesupport" "method_source" "rake" "thor" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qyxj74hm6yqc8ly8qc2bbya18r7qms2mifjcdbag10nk6rfrm8p";
      type = "gem";
    };
    version = "6.0.5";
  };
  raindrops = {
    groups = [ "default" "production" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wb2x51parf6v78w0cic90m33bdc92y5h8rj4wqs75dhw1b69hc7";
      type = "gem";
    };
    version = "0.20.0";
  };
  rake = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15whn7p9nrkxangbs9hh75q585yfn66lv0v2mhj6q6dl6x8bzr2w";
      type = "gem";
    };
    version = "13.0.6";
  };
  # rb-fsevent = {
  #   groups = [ "default" "development" ];
  #   platforms = [{
  #     engine = "maglev";
  #     version = "1.8";
  #   }
  #     {
  #       engine = "rbx";
  #       version = "1.8";
  #     }
  #     {
  #       engine = "ruby";
  #       version = "1.8";
  #     }];
  #   source = {
  #     remotes = [ "https://rubygems.org" ];
  #     sha256 = "1qsx9c4jr11vr3a9s5j83avczx9qn9rjaf32gxpc2v451hvbc0is";
  #     type = "gem";
  #   };
  #   version = "0.11.0";
  # };

  rb-fsevent = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06c50pvxib7wqnv6q0f3n7gzfcrp5chi3sa48hxpkfxc3hhy11fm";
      type = "gem";
    };
    version = "0.11.1";
  };

  # rb-inotify = {
  #   dependencies = [ "ffi" ];
  #   groups = [ "default" "development" ];
  #   platforms = [{
  #     engine = "maglev";
  #     version = "1.8";
  #   }
  #     {
  #       engine = "rbx";
  #       version = "1.8";
  #     }
  #     {
  #       engine = "ruby";
  #       version = "1.8";
  #     }];
  #   source = {
  #     remotes = [ "https://rubygems.org" ];
  #     sha256 = "1jm76h8f8hji38z3ggf4bzi8vps6p7sagxn3ab57qc0xyga64005";
  #     type = "gem";
  #   };
  #   version = "0.10.1";
  # };

  rb-inotify = {
    dependencies = [ "ffi" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jm76h8f8hji38z3ggf4bzi8vps6p7sagxn3ab57qc0xyga64005";
      type = "gem";
    };
    version = "0.10.1";
  };

  rb-kqueue = {
    dependencies = [ "ffi" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vhnyhqz37d1myiaj9sb2g2q0qmh13ls2w19add4ndp929n8kvj5";
      type = "gem";
    };
    version = "0.2.4";
  };
  representable = {
    dependencies = [ "declarative" "trailblazer-option" "uber" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09xwzz94ryp57wyjrqysiz1sslnxd4r4m9wayy63jb7f8qfx1kys";
      type = "gem";
    };
    version = "3.1.1";
  };
  responders = {
    dependencies = [ "actionpack" "railties" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14kjykc6rpdh24sshg9savqdajya2dislc1jmbzg91w9967f4gv1";
      type = "gem";
    };
    version = "3.0.1";
  };
  rest-client = {
    dependencies = [ "http-cookie" "mime-types" "netrc" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hzcs2r7b5bjkf2x2z3n8z6082maz0j8vqjiciwgg3hzb63f958j";
      type = "gem";
    };
    version = "2.0.2";
  };
  retriable = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1q48hqws2dy1vws9schc0kmina40gy7sn5qsndpsfqdslh65snha";
      type = "gem";
    };
    version = "3.1.2";
  };
  rexml = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08ximcyfjy94pm1rhcx04ny1vx2sk0x4y185gzn86yfsbzwkng53";
      type = "gem";
    };
    version = "3.2.5";
  };
  rly = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1sj2j7ggnkqh922x1f19dfzcpjxny7hggdh4b3ydgrb35v9c7gki";
      type = "gem";
    };
    version = "0.2.3";
  };
  rr = {
    groups = [ "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0n3q1ih34bskwki58ispi1yrnfhkgx6fcynq6cgpc37jj039cnr0";
      type = "gem";
    };
    version = "3.0.9";
  };
  rspec = {
    dependencies = [ "rspec-core" "rspec-expectations" "rspec-mocks" ];
    groups = [ "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15ppasvb9qrscwlyjz67ppw1lnxiqnkzx5vkx1bd8x5n3dhikxc3";
      type = "gem";
    };
    version = "3.8.0";
  };
  rspec-collection_matchers = {
    dependencies = [ "rspec-expectations" ];
    groups = [ "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1864xlxl7mi6mvjyp85a0gc10cyvpf6bj8lc86sf8737wlzn12ks";
      type = "gem";
    };
    version = "1.2.0";
  };
  rspec-core = {
    dependencies = [ "rspec-support" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0spjgmd3yx6q28q950r32bi0cs8h2si53zn6rq8s7n1i4zp4zwbf";
      type = "gem";
    };
    version = "3.8.2";
  };
  rspec-expectations = {
    dependencies = [ "diff-lcs" "rspec-support" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1x3rjrg1c6h785d0pns42x3cphf87r3d38xpzkxvqadvd3hszbl7";
      type = "gem";
    };
    version = "3.8.6";
  };
  rspec-html-matchers = {
    dependencies = [ "nokogiri" "rspec" ];
    groups = [ "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0883rqv77n2wawnk5lp3la48l7pckyz8l013qddngzmksi5p1v3f";
      type = "gem";
    };
    version = "0.9.4";
  };
  rspec-mocks = {
    dependencies = [ "diff-lcs" "rspec-support" ];
    groups = [ "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15fpk318zprizgwp08j6lqbj2npx0s3say9ixyiwfyhcj71di17v";
      type = "gem";
    };
    version = "3.8.2";
  };
  rspec-rails = {
    dependencies = [ "actionpack" "activesupport" "railties" "rspec-core" "rspec-expectations" "rspec-mocks" "rspec-support" ];
    groups = [ "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pf6n9l4sw1arlax1bdbm1znsvl8cgna2n6k6yk1bi8vz2n73ls1";
      type = "gem";
    };
    version = "3.8.2";
  };
  rspec-support = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0v4r8x3h6p0rs8n2g9ima89bbdji8cas5qz23flsx3wi7f8cq0f6";
      type = "gem";
    };
    version = "3.8.3";
  };
  rturk = {
    dependencies = [ "erector" "nokogiri" "rest-client" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mbdic5y0y4knjbib9dngyff72p1rblnirl7wphcpz5f3c7amff2";
      type = "gem";
    };
    version = "2.12.1";
  };
  ruby-growl = {
    dependencies = [ "uuid" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09jw4yvigp4rx7qy6ni9njvlm4wnyz4f6z6ngzac5qi3sshspzd0";
      type = "gem";
    };
    version = "4.1";
  };
  rufus-scheduler = {
    dependencies = [ "fugit" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jvxcvsqhalndc1wh7zfdqfg78j5sx57vrgsh54pjsm1d73q79hc";
      type = "gem";
    };
    version = "3.8.1";
  };
  safe_yaml = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hly915584hyi9q9vgd968x2nsi5yag9jyf5kq60lwzi5scr7094";
      type = "gem";
    };
    version = "1.0.4";
  };
  sass = {
    dependencies = [ "sass-listen" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0p95lhs0jza5l7hqci1isflxakz83xkj97lkvxl919is0lwhv2w0";
      type = "gem";
    };
    version = "3.7.4";
  };
  sass-listen = {
    dependencies = [ "rb-fsevent" "rb-inotify" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xw3q46cmahkgyldid5hwyiwacp590zj2vmswlll68ryvmvcp7df";
      type = "gem";
    };
    version = "4.0.0";
  };
  sass-rails = {
    dependencies = [ "sassc-rails" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lqhb0fgmls9l9jhgz42ri25w13q5pmsiiwzjbarz4n7l6749dp0";
      type = "gem";
    };
    version = "6.0.0";
  };
  sassc = {
    dependencies = [ "ffi" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qzfnvb8khvc6w2sn3k91mndc2w50xxx5c84jkr6xdxlmaq1a3kg";
      type = "gem";
    };
    version = "2.3.0";
  };
  sassc-rails = {
    dependencies = [ "railties" "sassc" "sprockets" "sprockets-rails" "tilt" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1d9djmwn36a5m8a83bpycs48g8kh1n2xkyvghn7dr6zwh4wdyksz";
      type = "gem";
    };
    version = "2.1.2";
  };
  sax-machine = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fhdflwdj8q0gfgz51k3zn1giq24fwvhvji75104rsly0dw2c4d1";
      type = "gem";
    };
    version = "1.3.2";
  };
  select2-rails = {
    dependencies = [ "thor" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ni2k74n73y3gv56gs37gkjlh912szjf6k9j483wz41m3xvlz7fj";
      type = "gem";
    };
    version = "3.5.9.3";
  };
  shellany = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ryyzrj1kxmnpdzhlv4ys3dnl2r5r3d2rs2jwzbnd1v96a8pl4hf";
      type = "gem";
    };
    version = "0.0.1";
  };
  shoulda-matchers = {
    dependencies = [ "activesupport" ];
    groups = [ "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1s6a2i39lsqq8rrkk2pddqcb10bsihxy3v5gpnc2gk8xakj1brdq";
      type = "gem";
    };
    version = "4.0.1";
  };
  signet = {
    dependencies = [ "addressable" "faraday" "jwt" "multi_json" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cgmadrpgkpcklvvm2cga9mnrfqwqlydwpask1wx617h5ha6954k";
      type = "gem";
    };
    version = "0.16.0";
  };
  simple_oauth = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dw9ii6m7wckml100xhjc6vxpjcry174lbi9jz5v7ibjr3i94y8l";
      type = "gem";
    };
    version = "0.3.1";
  };
  simplecov = {
    dependencies = [ "docile" "json" "simplecov-html" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1sfyfgf7zrp2n42v7rswkqgk3bbwk1bnsphm24y7laxv3f8z0947";
      type = "gem";
    };
    version = "0.16.1";
  };
  simplecov-html = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lihraa4rgxk8wbfl77fy9sf0ypk31iivly8vl3w04srd7i0clzn";
      type = "gem";
    };
    version = "0.10.2";
  };
  slack-notifier = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0v4kd0l83shmk17qb35lighxjq9j7g3slnkrsyiy36kaqcfrjm97";
      type = "gem";
    };
    version = "1.0.0";
  };
  spectrum-rails = {
    dependencies = [ "railties" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "195012aakp5xw29djnbqw7qmj4z28hxgpalz8dypg9kv9a8zcld9";
      type = "gem";
    };
    version = "1.3.4";
  };
  spring = {
    groups = [ "development" ];
    platforms = [{
      engine = "maglev";
      version = "1.8";
    }
      {
        engine = "rbx";
        version = "1.8";
      }
      {
        engine = "ruby";
        version = "1.8";
      }];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1x2wz1y2b0kp7mlk9k8zkl39rddk2l3x34b7dar3bh3axd1cs30d";
      type = "gem";
    };
    version = "2.1.1";
  };
  spring-commands-rspec = {
    dependencies = [ "spring" ];
    groups = [ "development" ];
    platforms = [{
      engine = "maglev";
      version = "1.8";
    }
      {
        engine = "rbx";
        version = "1.8";
      }
      {
        engine = "ruby";
        version = "1.8";
      }];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0b0svpq3md1pjz5drpa5pxwg8nk48wrshq8lckim4x3nli7ya0k2";
      type = "gem";
    };
    version = "1.0.4";
  };
  spring-watcher-listen = {
    dependencies = [ "listen" "spring" ];
    groups = [ "development" ];
    platforms = [{
      engine = "maglev";
      version = "1.8";
    }
      {
        engine = "rbx";
        version = "1.8";
      }
      {
        engine = "ruby";
        version = "1.8";
      }];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ybz9nsngfz4psvgnbr3gdk5ibqqhq47lsjkwh5yq4f8brpr10yz";
      type = "gem";
    };
    version = "2.0.1";
  };
  sprockets = {
    dependencies = [ "concurrent-ruby" "rack" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "182jw5a0fbqah5w9jancvfmjbk88h8bxdbwnl4d3q809rpxdg8ay";
      type = "gem";
    };
    version = "3.7.2";
  };
  sprockets-rails = {
    dependencies = [ "actionpack" "activesupport" "sprockets" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1b9i14qb27zs56hlcc2hf139l0ghbqnjpmfi0054dxycaxvk5min";
      type = "gem";
    };
    version = "3.4.2";
  };
  sshkit = {
    dependencies = [ "net-scp" "net-ssh" ];
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1szshiw7bzizi380z1hkdbwhjdaixb5bgbx7c3wf7970mjdashkd";
      type = "gem";
    };
    version = "1.21.2";
  };
  sync = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1z9qlq4icyiv3hz1znvsq1wz2ccqjb1zwd6gkvnwg6n50z65d0v6";
      type = "gem";
    };
    version = "0.5.0";
  };
  systemu = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16k94azpsy1r958r6ysk4ksnpp54rqmh5hyamad9kwc3lk83i32z";
      type = "gem";
    };
    version = "2.6.4";
  };
  term-ansicolor = {
    dependencies = [ "tins" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xq5kci9215skdh27npyd3y55p812v4qb4x2hv3xsjvwqzz9ycwj";
      type = "gem";
    };
    version = "1.7.1";
  };
  thor = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1yhrnp9x8qcy5vc7g438amd5j9sw83ih7c30dr6g6slgw9zj3g29";
      type = "gem";
    };
    version = "0.20.3";
  };
  thread_safe = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nmhcgq6cgz44srylra07bmaw99f5271l0dpsvl5f75m44l0gmwy";
      type = "gem";
    };
    version = "0.3.6";
  };
  tilt = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rn8z8hda4h41a64l0zhkiwz2vxw9b1nb70gl37h1dg2k874yrlv";
      type = "gem";
    };
    version = "2.0.10";
  };
  tins = {
    dependencies = [ "sync" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "153q7j2nj7y43iscbfcihmwlcydx6sbd65azs27kain0gncymd90";
      type = "gem";
    };
    version = "1.31.0";
  };
  trailblazer-option = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18s48fndi2kfvrfzmq6rxvjfwad347548yby0341ixz1lhpg3r10";
      type = "gem";
    };
    version = "0.1.2";
  };
  treetop = {
    dependencies = [ "polyglot" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0g31pijhnv7z960sd09lckmw9h8rs3wmc8g4ihmppszxqm99zpv7";
      type = "gem";
    };
    version = "1.6.10";
  };
  tumblr_client = {
    dependencies = [ "faraday" "faraday_middleware" "json" "mime-types" "oauth" "simple_oauth" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      fetchSubmodules = false;
      rev = "e046fe6e39291c173add0a49081630c7b60a36c7";
      sha256 = "1d8s7j6dr98vr3acf712nysh1j6kpz9lx2cqr2msa0z8amqmr5v5";
      type = "git";
      url = "https://github.com/albertsun/tumblr_client.git";
    };
    version = "0.8.5";
  };
  twilio-ruby = {
    dependencies = [ "faraday" "jwt" "nokogiri" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10sfbvn9fl7n403fpdv2hv74nn4qd8zip17rm3snwy12w35d13pv";
      type = "gem";
    };
    version = "5.62.0";
  };
  twitter = {
    dependencies = [ "addressable" "buftok" "equalizer" "http" "http-form_data" "http_parser.rb" "memoizable" "multipart-post" "naught" "simple_oauth" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      fetchSubmodules = false;
      rev = "d11707edf4abd13f7ada0eef57fc1eaa1062d75b";
      sha256 = "0cw39ni1mvkgbf2g9pk058hk20ikf64zxbjd7ba4hfqjigndks7b";
      type = "git";
      url = "https://github.com/sferik/twitter.git";
    };
    version = "5.15.0";
  };
  twitter-stream = {
    dependencies = [ "eventmachine" "http_parser.rb" "simple_oauth" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      fetchSubmodules = false;
      rev = "a80822d579509802124d4e219bb771eb663efdb7";
      sha256 = "020924jhh3xgkq0pq9vq3z0gjq2sknhcv5c9vhr6fl7gbpiqsv09";
      type = "git";
      url = "https://github.com/cantino/twitter-stream.git";
    };
    version = "0.1.15";
  };
  typhoeus = {
    dependencies = [ "ethon" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cni8b1idcp0dk8kybmxydadhfpaj3lbs99w5kjibv8bsmip2zi5";
      type = "gem";
    };
    version = "1.3.1";
  };
  tzinfo = {
    dependencies = [ "thread_safe" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0zwqqh6138s8b321fwvfbywxy00lw1azw4ql3zr0xh1aqxf8cnvj";
      type = "gem";
    };
    version = "1.2.9";
  };
  uber = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1p1mm7mngg40x05z52md3mbamkng0zpajbzqjjwmsyw0zw3v9vjv";
      type = "gem";
    };
    version = "0.1.0";
  };
  uglifier = {
    dependencies = [ "execjs" "json" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mzs64z3m1b98rh6ssxpqfz9sc87f6ml6906b0m57vydzfgrh1cz";
      type = "gem";
    };
    version = "2.7.2";
  };
  unf = {
    dependencies = [ "unf_ext" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bh2cf73i2ffh4fcpdn9ir4mhq8zi50ik0zqa1braahzadx536a9";
      type = "gem";
    };
    version = "0.1.4";
  };
  unf_ext = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14hr2dzqh33kqc0xchs8l05pf3kjcayvad4z1ip5rdjxrkfk8glb";
      type = "gem";
    };
    version = "0.0.7.4";
  };
  unicorn = {
    dependencies = [ "kgio" "raindrops" ];
    groups = [ "production" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1h0gma14jjxiz6piyi6p99q7lya2mxrq79l03160hascvmx9ipa5";
      type = "gem";
    };
    version = "6.1.0";
  };
  uuid = {
    dependencies = [ "macaddr" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04q10an3v40zwjihvdwm23fw6vl39fbkhdiwfw78a51ym9airnlp";
      type = "gem";
    };
    version = "2.3.7";
  };
  vcr = {
    groups = [ "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1y19gb8vz1rbhx1qhim6kpp0fzksqhd7grb50hmrbjx5h4hc3y0y";
      type = "gem";
    };
    version = "3.0.3";
  };
  warden = {
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1l7gl7vms023w4clg02pm4ky9j12la2vzsixi2xrv9imbn44ys26";
      type = "gem";
    };
    version = "1.2.9";
  };
  web-console = {
    dependencies = [ "actionview" "activemodel" "debug_inspector" "railties" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gcasyydiinr8nmkjc0n63dgbx875rdkxxbcq82yz6z8qp5bwwh7";
      type = "gem";
    };
    version = "3.3.1";
  };
  webmock = {
    dependencies = [ "addressable" "crack" "hashdiff" ];
    groups = [ "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gg0c2sxq7rni0b93w47h7p7cn590xdhf5va7ska48inpipwlgxp";
      type = "gem";
    };
    version = "3.5.1";
  };
  webrick = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1d4cvgmxhfczxiq5fr534lmizkhigd15bsx5719r5ds7k7ivisc7";
      type = "gem";
    };
    version = "1.7.0";
  };
  websocket-driver = {
    dependencies = [ "websocket-extensions" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0a3bwxd9v3ghrxzjc4vxmf4xa18c6m4xqy5wb0yk5c6b9psc7052";
      type = "gem";
    };
    version = "0.7.5";
  };
  websocket-extensions = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hc2g9qps8lmhibl5baa91b4qx8wqw872rgwagml78ydj8qacsqw";
      type = "gem";
    };
    version = "0.1.5";
  };
  weibo_2 = {
    dependencies = [ "hashie" "multi_json" "oauth2" "rest-client" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      fetchSubmodules = false;
      rev = "ac38d04434747c4b88e86c5337cd436d00c34349";
      sha256 = "05zss3s5nysgs7immil320kfasb10kqnwmyfagznysx43d7w30rj";
      type = "git";
      url = "https://github.com/albertsun/weibo_2.git";
    };
    version = "0.1.7";
  };
  xmpp4r = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15ls2yqjvflxrc8chv5pcdh2p1p9fjsky74yc8y7wvw90wz0izrb";
      type = "gem";
    };
    version = "0.5.6";
  };
  xpath = {
    dependencies = [ "nokogiri" ];
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12xlddg1hpmxvdzlynrr3akwwaarz1xgdpmv7bhvh1xgzajkcidi";
      type = "gem";
    };
    version = "3.0.0";
  };
  zeitwerk = {
    groups = [ "default" "development" "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09bq7j2p6mkbxnsg71s253dm2463kg51xc7bmjcxgyblqbh4ln7m";
      type = "gem";
    };
    version = "2.5.4";
  };
}

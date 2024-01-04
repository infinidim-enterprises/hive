{ lib
, sources
, libxml2
, libxslt
, runCommand
, bundix
, zlib
, buildRubyGem
, defaultGemConfig
, bundlerApp
, bundlerEnv
, git
, ruby_3_0
}:
let
  inherit (sources.rubygems-lita) src pname;
  version = lib.removePrefix "v" sources.rubygems-lita.version;
  gemName = lib.removePrefix "rubygems-" pname;
  ruby = ruby_3_0;

  deps = bundlerEnv rec {
    inherit ruby;
    name = "${gemName}-${version}-bundlerEnv";
    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset = ./gemset.nix;
  };


  gem = buildRubyGem rec {
    inherit src version pname gemName ruby;
    # gemspec = "lita.gemspec";
    # passthru = { inherit ruby deps; };

    propagatedBuildInputs = [ git deps (lib.lowPrio deps.wrappedRuby) ];
    # dontBuild = false;
  };


  solargraph = bundlerApp rec {
    inherit ruby;
    pname = "solargraph";
    gemdir = runCommand "gemdir" { buildInputs = [ bundix ruby ]; } ''
      mkdir -p $out
      export HOME=$(mktemp -d)
      cat > $out/Gemfile <<EOS
      source "https://rubygems.org"
      gem 'solargraph'
      EOS
      cd $out
      bundle lock
      bundix -l
    '';
    exes = [ "solargraph" ];
  };

  app = bundlerApp rec {
    inherit ruby;
    pname = gemName;
    gemdir = ./.;
    exes = [ "lita" ];
  };

  deps_new = bundlerEnv rec {
    inherit ruby;
    name = "${gemName}-${version}-bundlerEnv";
    gemdir = ./.;

    gemConfig = defaultGemConfig // {
      nokogiri = attrs: {
        dependencies = [ "racc" "mini_portile2" ];
        groups = [ "default" "development" ];
        platforms = [ ];
        version = "1.12.5";
        source = {
          remotes = [ "https://rubygems.org" ];
          sha256 = "sha256-KyCQWUKsxYBpfIxJbQ0Wcqthf6y50w0Vazx2duZ5Auw=";
          type = "gem";
        };

        # defaultGemConfig.nokogiri
        buildFlags = [
          "--use-system-libraries"
          "--with-zlib-lib=${zlib.out}/lib"
          "--with-zlib-include=${zlib.dev}/include"
          "--with-xml2-lib=${libxml2.out}/lib"
          "--with-xml2-include=${libxml2.dev}/include/libxml2"
          "--with-xslt-lib=${libxslt.out}/lib"
          "--with-xslt-include=${libxslt.dev}/include"
          "--with-exslt-lib=${libxslt.out}/lib"
          "--with-exslt-include=${libxslt.dev}/include"
        ];

      };
    };

  };

in
#solargraph
deps_new

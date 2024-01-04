{ lib
, sources
, bundlerEnv
  # , bundlerApp
  # , bundlerUpdateScript
, stdenv
, writeShellScript
, defaultGemConfig
, ruby
, nodejs-16_x
, runCommand
  # , env ? null
, bundler
, curl
, postgresql
}:
let
  inherit (sources.rubygems-huginn) src pname version;

  nodejs = nodejs-16_x.overrideAttrs (_: { inherit (sources.rubygems-nodejs-16-10-0) src version; });

  gemdir = runCommand "gemdir" { } ''
    mkdir -p $out/lib
    cp ${src}/lib/gemfile_helper.rb $out/lib
    cp -r ${src}/vendor $out
    cp ${./Gemfile} $out/Gemfile
    substituteInPlace $out/Gemfile \
      --replace "require File.join(File.dirname(__FILE__)" "require File.join('${src}'"

    cp ${./Gemfile.lock} $out/Gemfile.lock
    cp ${./gemset.nix} $out/gemset.nix
  '';

  gemConfig = defaultGemConfig // {
    libv8-node = _:
      let
        noopScript = writeShellScript "noop" "exit 0";
        linkFiles = writeShellScript "link-files" ''
          cd ../..
          mkdir -p vendor/v8/${stdenv.hostPlatform.system}/libv8/obj/
          ln -s "${nodejs.libv8}/lib/libv8.a" vendor/v8/${stdenv.hostPlatform.system}/libv8/obj/libv8_monolith.a
          ln -s ${nodejs.libv8}/include vendor/v8/include
          mkdir -p ext/libv8-node
          echo '--- !ruby/object:Libv8::Node::Location::Vendor {}' >ext/libv8-node/.location.yml
        '';
      in
      {
        dontBuild = false;
        postPatch = ''
          cp ${noopScript} libexec/build-libv8
          cp ${noopScript} libexec/build-monolith
          cp ${noopScript} libexec/download-node
          cp ${noopScript} libexec/extract-node
          cp ${linkFiles} libexec/inject-libv8
        '';
      };
  };

  env = bundlerEnv rec {
    inherit ruby gemConfig gemdir;
    name = "${lib.removePrefix "rubygems-" pname}-${version}-bundlerEnv";
    postBuild = ''
      cp ${src}/.env.example $out/.env
    '';
  };

  huginn = stdenv.mkDerivation rec {
    inherit src version pname gemdir;
    buildInputs = [ env (lib.lowPrio env.wrappedRuby) curl postgresql ];

    buildPhase = ''
      mkdir -p $out/share
      cp -r . $out/share/huginn

      cp $src/.env.example $out/share/huginn/.env

      mkdir -p $out/share/huginn/tmp/
      mkdir -p $out/share/huginn/tmp/cache
      mkdir -p $out/share/huginn/tmp/pids
      mkdir -p $out/share/huginn/tmp/sessions
      mkdir -p $out/share/huginn/tmp/sockets
    '';

    installPhase = ''

      export LD_LIBRARY_PATH=${curl.out}/lib:${postgresql}/lib

      # RAILS_ENV=production \
      #   APP_SECRET_TOKEN=REPLACE_ME_NOW! \
      #   DATABASE_ADAPTER=nulldb \
      #   RAILS_LOG_TO_STDOUT=true \
      #   HUGINN_STATE_PATH=tmp/ \
      #   SKIP_STORAGE_VALIDATION=true \

      bundle exec rake assets:precompile
      cp -r public/assets $out/share/huginn/public/
    '';

    # gemfile = ./Gemfile;
    # lockfile = ./Gemfile.lock;
    # cp ${gemfile} $out/share/huginn/Gemfile
    # cp ${lockfile} $out/share/huginn/Gemfile.lock

    passthru = {
      inherit env;
      inherit ruby;
    };
  };
in
huginn
# huginnEnv

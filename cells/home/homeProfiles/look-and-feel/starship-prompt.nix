{ lib, config, ... }:
lib.mkMerge [
  (lib.mkIf config.programs.nushell.enable {
    programs.nushell.settings.prompt = "starship prompt";
    programs.nushell.settings.startup = [
      "mkdir ~/.cache/starship"
      "starship init nu | save ~/.cache/starship/init.nu"
      "source ~/.cache/starship/init.nu"
    ];
  })

  (lib.mkIf config.programs.starship.enable {
    programs.starship.settings = {
      # NOTE: for unicode icons https://www.nerdfonts.com/cheat-sheet
      add_newline = false;
      line_break.disabled = true;
      scan_timeout = 30;

      format = lib.concatStrings [ "$all" "\${custom.screen_detached}" "\${custom.screen}" "$character" ];

      status.disabled = false;
      status.pipestatus = true;
      status.format = "[$status]($style) ";
      status.style = "white";

      custom.screen.symbol = "§ ";
      custom.screen.style = "blue";
      custom.screen.format = "[$symbol]($style)";
      custom.screen.when = "! test -z $STY";

      custom.screen_detached.symbol = " ";
      custom.screen_detached.style = "bold white";
      custom.screen_detached.format = "\\[[$symbol $output]($style)\\]";
      custom.screen_detached.when = "screen -ls | rg Detached";
      custom.screen_detached.command = "screen -ls | rg Detached | wc -l";

      cmd_duration.format = "\\[[⏱ $duration]($style)\\]";
      cmd_duration.style = "yellow"; # "fg:#cb4b16";

      character.format = "$symbol ";
      character.success_symbol = "[»](red)";
      character.vicmd_symbol = "[](bold red)";
      character.error_symbol = "[✗](red)";

      directory.style = "blue";
      directory.read_only = " 🔒";

      battery.full_symbol = "";
      battery.charging_symbol = "";
      battery.discharging_symbol = "";

      time.format = "\\[[$time]($style)\\]";

      username.format = "\\[[$user]($style)\\]";

      memory_usage.symbol = " ";
      memory_usage.format = "\\[$symbol[$ram( | $swap)]($style)\\]";
      memory_usage.disabled = false;

      nix_shell.format = "\\[[$symbol$state( \\($name\\))]($style)\\]";
      nix_shell.symbol = "❄ ";
      nix_shell.pure_msg = "λ";
      nix_shell.impure_msg = "⎔";

      # git_branch.format = "[$symbol$branch]($style) ";
      git_branch.format = "\\[[$symbol$branch]($style)\\]";
      git_branch.symbol = " ";
      git_branch.style = "bold dimmed white";

      # git_status.format = "'([「$all_status$ahead_behind」]($style) )'";
      git_status.format = "([\\[$all_status$ahead_behind\\]]($style))";
      git_status.conflicted = "⚠️";
      git_status.ahead = "⟫\${count} ";
      git_status.behind = "⟪\${count}";
      git_status.diverged = "🔀 ";
      git_status.untracked = "📁 ";
      git_status.stashed = "↪ ";
      git_status.modified = "𝚫 ";
      git_status.staged = "✔ ";
      git_status.renamed = "⇆ ";
      git_status.deleted = "✘ ";
      git_status.style = "bold bright-white";

      aws.symbol = " ";
      aws.format = "\\[[$symbol($profile)(\\($region\\))(\\[$duration\\])]($style)\\]";

      gcloud.symbol = " ";
      gcloud.format = "\\[[$symbol$account(@$domain)(\\($region\\))]($style)\\]";
      gcloud.detect_env_vars = [ "GOOGLE_CLOUD" ];

      terraform.symbol = " ";
      terraform.format = "\\[[$symbol$workspace]($style)\\]";

      helm.symbol = " ";
      helm.format = "\\[[$symbol($version)]($style)\\]";

      kubernetes.symbol = "ﴱ ";
      kubernetes.format = "\\[[$symbol$context( \\($namespace\\))]($style)\\]";

      openstack.format = "\\[[$symbol$cloud(\\($project\\))]($style)\\]";
      vagrant.format = "\\[[$symbol($version)]($style)\\]";

      docker_context.symbol = " ";
      docker_context.format = "\\[[$symbol$context]($style)\\]";

      conda.symbol = " ";
      conda.format = "\\[[$symbol$environment]($style)\\]";

      elixir.symbol = " ";
      elixir.format = "\\[[$symbol($version \\(OTP $otp_version\\))]($style)\\]";

      elm.symbol = " ";
      elm.format = "\\[[$symbol($version)]($style)\\]";

      golang.symbol = " ";
      golang.format = "\\[[$symbol($version)]($style)\\]";

      # haskell.symbol = " ";

      java.symbol = " ";
      java.format = "\\[[$symbol($version)]($style)\\]";

      julia.symbol = " ";
      julia.format = "\\[[$symbol($version)]($style)\\]";

      nim.symbol = " ";
      nim.format = "\\[[$symbol($version)]($style)\\]";

      nodejs.symbol = " ";
      nodejs.format = "\\[[$symbol($version)]($style)\\]";

      package.symbol = " ";
      package.format = "\\[[$symbol$version]($style)\\]";

      php.symbol = " ";
      php.format = "\\[[$symbol($version)]($style)\\]";

      python.symbol = " ";
      python.format = "\\[[\${symbol}\${pyenv_prefix}(\${version})(\\($virtualenv\\))]($style)\\]";

      ruby.symbol = " ";
      ruby.format = "\\[[$symbol($version)]($style)\\]";

      rust.symbol = " ";
      rust.format = "\\[[$symbol($version)]($style)\\]";

      hg_branch.symbol = " ";
      hg_branch.format = "\\[[$symbol$branch]($style)\\]";

      crystal.format = "\\[[$symbol($version)]($style)\\]";
      crystal.symbol = " ";

      erlang.format = "\\[[$symbol($version)]($style)\\]";
      erlang.symbol = " ";

      # cmake.symbol = "ﭱ ";
      cmake.format = "\\[[$symbol($version)]($style)\\]";

      cobol.format = "\\[[$symbol($version)]($style)\\]";
      dart.format = "\\[[$symbol($version)]($style)\\]";
      deno.format = "\\[[$symbol($version)]($style)\\]";
      dotnet.format = "\\[[$symbol($version)(🎯 $tfm)]($style)\\]";
      kotlin.format = "\\[[$symbol($version)]($style)\\]";
      lua.format = "\\[[$symbol($version)]($style)\\]";
      ocaml.format = "\\[[$symbol($version)(\\($switch_indicator$switch_name\\))]($style)\\]";
      perl.format = "\\[[$symbol($version)]($style)\\]";
      pulumi.format = "\\[[$symbol$stack]($style)\\]";
      purescript.format = "\\[[$symbol($version)]($style)\\]";
      red.format = "\\[[$symbol($version)]($style)\\]";
      scala.format = "\\[[$symbol($version)]($style)\\]";
      swift.format = "\\[[$symbol($version)]($style)\\]";
      vlang.format = "\\[[$symbol($version)]($style)\\]";
      zig.format = "\\[[$symbol($version)]($style)\\]";
    };
  })
]

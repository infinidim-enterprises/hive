#!/usr/bin/env nix-shell
#! nix-shell -p ruby -i ruby
require 'open3'
Open3.popen2e 'xscreensaver-command -watch' do |stdin, stdout_stderr, wait_thread|
  while l = stdout_stderr.readline
    case l
    when /^(LOCK|BLANK)/
      pp 'DISPLAY was locked'
      ARGV.each do |h|
        Process.spawn "ssh admin@#{h} 'sudo chvt 1'"
      end
    when /^UNBLANK/
      pp 'DISPLAY was unlocked'
      ARGV.each do |h|
        Process.spawn "ssh admin@#{h} 'sudo chvt 7'"
      end
    end
  end
  stdin.close
  wait_thread.value
end

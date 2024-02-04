{ pkgs, config, lib, ... }:
let
  inherit (config.home.sessionVariables) HM_FONT_NAME HM_FONT_SIZE;
  inherit (lib) toInt;
  inherit (builtins) toString;
in
{
  home.packages = [ pkgs.conky ];
  xdg.configFile."conky/conky.conf".text = ''
    conky.config = {
      temperature_unit = 'celsius',
      alignment = 'top_left',
      background = false,
      border_width = 0,
      default_color = '839496',
      default_outline_color = '839496',
      default_shade_color = '839496',
      double_buffer = true,
      draw_borders = false,
      draw_graph_borders = true,
      draw_outline = false,
      draw_shades = false,
      extra_newline = false,
      font = '${HM_FONT_NAME}:pixelsize=${toString ((toInt HM_FONT_SIZE) + 10)}',
      gap_x = 60,
      gap_y = 60,
      minimum_height = 5,
      minimum_width = 5,
      net_avg_samples = 2,
      no_buffers = true,
      out_to_console = false,
      out_to_ncurses = false,
      out_to_stderr = false,
      out_to_x = true,
      own_window = true,
      own_window_colour = '002b36',
      own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
      own_window_class = 'Conky',
      own_window_type = 'desktop',
      show_graph_range = false,
      show_graph_scale = false,
      stippled_borders = 0,
      update_interval = 1.0,
      uppercase = false,
      use_spacer = 'none',
      use_xft = true,
    }

    conky.text = [[
    ''${voffset 5}''${color 839496}[$nodename $kernel $machine]''${color 839496}[''${color b58900}$loadavg''${color 839496}] ''${color 2aa198}@''${freq_g}GHz ''${voffset 5}''${alignc}''${cpugraph 32,120 859900 dc322f -t -l}''${downspeedgraph lan 32,120 00B706 FF0000 -t}''${upspeedgraph lan 32,120 00AFB7 FF0000 -t}
    $hr

    $hr
    ''${color grey}RAM Usage:$color $mem/$memmax - $memperc% ''${membar 4}
    ''${color grey}Swap Usage:$color $swap/$swapmax - $swapperc% ''${swapbar 4}
    ''${color grey}CPU Usage:$color $cpu% ''${cpubar 4}
    ''${color grey}Processes:$color $processes  ''${color grey}Running:$color $running_processes
    $hr
    ''${color grey}File systems:
     / $color''${fs_used /}/''${fs_size /} ''${fs_bar 6 /}
    ''${color grey}Networking:
    Up:$color ''${upspeed} ''${color grey} - Down:$color ''${downspeed}
    $hr
    ''${color grey}Name              PID     CPU%   MEM%
    ''${color lightgrey} ''${top name 1} ''${top pid 1} ''${top cpu 1} ''${top mem 1}
    ''${color lightgrey} ''${top name 2} ''${top pid 2} ''${top cpu 2} ''${top mem 2}
    ''${color lightgrey} ''${top name 3} ''${top pid 3} ''${top cpu 3} ''${top mem 3}
    ''${color lightgrey} ''${top name 4} ''${top pid 4} ''${top cpu 4} ''${top mem 4}
    ]]
  '';
}

{ inputs, cell, ... }:

final: prev: {
  minidlna = prev.minidlna.override { ffmpeg = prev.ffmpeg-headless; };
}

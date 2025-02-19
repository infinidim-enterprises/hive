{ inputs, cell, ... }:

final: prev:
{
  n8n = prev.n8n.overrideAttrs (oldAttrs: {
    inherit (final.sources.llm.n8n) src pname version;
  });
}

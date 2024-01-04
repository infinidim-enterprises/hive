{ lib, ... }:
let
  inherit (lib // builtins)
    const
    filterAttrs
    typeOf
    getAttr
    mapAttrs;

  sanitize = {
    __functor = _self: cfgChunk:
      getAttr (typeOf cfgChunk) {
        bool = cfgChunk;
        int = cfgChunk;
        string = cfgChunk;
        list = map sanitize cfgChunk;
        set =
          mapAttrs
            (const sanitize)
            (filterAttrs
              (name: value:
                name
                != "_module"
                && name != "mutable"
                && name != "members"
                && name != "apply"
                && value != null)
              cfgChunk);
      };
    doc = ''
      Sanitize module config for remarshalling, removing nix specific keys
    '';
  };
in
sanitize

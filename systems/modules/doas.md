---
title: Doas
---
I personally prefer using Doas over Sudo. However, I also like to create an alias such that any script which calls Sudo will instead prefer Doas. I also ususally enable persist, since not using it proves annoying.

# Implementation
```nix systems/modules/doas.nix
<<<license>>>
{ config, lib, pkgs, ... }:

let cfg = config.security.doas;
in {
  options.security.doas = {
    <<<systems/modules/doas/options>>>
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    <<<systems/modules/doas/persist>>>
    <<<systems/modules/doas/sudoAlias>>>
  ]);
}
```

## Options
- `persist` Enable persist for the `wheel` group.
- `sudoAlias` Enable an alias of `sudo` to `doas`.

```nix "systems/modules/doas/options"
# systems/modules/doas/options
persist = lib.mkEnableOption "persistent doas login";
sudoAlias = lib.mkEnableOption "alias Sudo to Doas";
```

## Persistence
Here, we simply set an extra rule to enable persistence if desired for the `wheel` group.
```nix "systems/modules/doas/persist"
# systems/modules/doas/persist
(lib.mkIf cfg.persist {
  security.doas.extraRules = [{
    groups = [ "wheel" ];
    persist = true;
  }];
})
```

## Sudo Alias
Here, we add a `security.wrapper` of `sudo` to `doas`, in order to ensure scripts don't break.
```nix "systems/modules/doas/sudoAlias"
# systems/modules/doas/sudoAlias
(lib.mkIf cfg.sudoAlias {
  assertions = [
    { assertion = !config.security.sudo.enable;
      message = "Cannot alias Sudo: Sudo is enabled";
    }
  ];

  security.wrappers.sudo.source = "${pkgs.doas}/bin/doas";
})
```

# Module List
```nix "systems/modules" +=
# systems/modules.doas
./systems/modules/doas.nix
```

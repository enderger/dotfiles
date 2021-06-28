---
title: Doas
---
I personally prefer using Doas over Sudo. However, I also like to create an alias such that any script which calls Sudo will instead prefer Doas. I also ususally enable persist, since not using it proves annoying.
```nix modules/doas.nix
<<<license>>>
{ config, lib, pkgs, ... }:

let cfg = config.security.doas;
in {
  options.security.doas = {
    <<<modules/doas/options>>>
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    <<<modules/doas/persist>>>
    <<<modules/doas/sudoAlias>>>
  ]);
}
```

# Options
## Persistence
This enables persistent logins via Doas.
```nix "modules/doas/options" +=
# modules/doas/options.persist
persist = lib.mkEnableOption "persistent doas login";
```

## Sudo Alias
This makes `sudo` an alias to `doas`. Requires `sudo` to be disabled.
```nix "modules/doas/options" +=
# modules/doas/options.sudoAlias
sudoAlias = lib.mkEnableOption "alias Sudo to Doas";
```

# Implementation
## Persistence
Here, we simply set an extra rule to enable persistence if desired for the `wheel` group.
```nix "modules/doas/persist"
# modules/doas/persist
(lib.mkIf cfg.persist {
  security.doas.extraRules = [{
    groups = [ "wheel" ];
    persist = true;
  }];
})
```

## Sudo Alias
Here, we add a `security.wrapper` of `sudo` to `doas`, in order to ensure scripts don't break.
```nix "modules/doas/sudoAlias"
# modules/doas/sudoAlias
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
Finally, we need to add this file to the module list
```nix "modules/module-list" +=
# modules/module-list.doas
./modules/doas.nix
```

---
title: Users :: Enderger
---
This is my primary user, not much more to say.

```nix users/enderger.nix
<<<license>>>
{ pkgs, inputs, ... }:
let 
  secrets = import ./enderger.secret.nix;
  # HACK: This section allows me to get theme colors without having to use the elemAt function constantly.
  theme = builtins.elemAt [
    <<<users/enderger/colors>>>
  ];
  font = "FiraCode Nerd Font";
in {
  users.users.enderger = {
    <<<users/enderger/userOptions>>>
  };

  services.xserver.windowManager = {
    <<<users/enderger/windowManagers>>>
  };

  home-manager.users.enderger = { config, ... }: {
    # CLI setup
    <<<users/enderger/nushell>>>
    <<<users/enderger/starship>>>
    <<<users/enderger/alacritty>>>
    <<<users/enderger/man>>>
    <<<users/enderger/bat>>>
    <<<users/enderger/neovim>>>
    <<<users/enderger/git>>>

    # GUI Setup
    <<<users/enderger/xmonad>>>
    <<<users/enderger/xmobar>>>
    <<<users/enderger/rofi>>>
    <<<users/enderger/qutebrowser>>>

    # Packages
    home.packages = [
      <<<users/enderger/packages>>>
    ];
  };
}
```

# CLI Setup
## Shell / Environment
### Nushell
This is my preferred shell, mainly for it's novel approach to information presentation.
```nix "users/enderger/nushell"
# users/enderger/nushell
programs.nushell = {
  enable = true;
  settings = {
    complete_from_path = true;
    ctrlc_exit = false;
    disable_table_indexes = false;
    filesize_format = "GiB";
    nonzero_exit_errors = true;
    pivot_mode = "auto";
    prompt = "starship prompt";
    rm_always_trash = true;
    skip_welcome_message = true;
    table_mode = "rounded";

    line_editor = {
      bell_style = "none";
      completion_type = "circular";
      edit_mode = "vi";
      history_duplicates = "ignoreconsecutive";
      history_ignore_space = true;
    };

    textview = {
      tab_width = 2;
      theme = "base16";
    };

    startup = lib.splitString "\n" ''
      <<<users/enderger/nushell/startup>>>
    '';
  };
};
```

#### Startup
```nu "users/enderger/nushell/startup"
# users/enderger/nushell/startup
pfetch
```

### Starship
This is my preferred prompt. It is written in Rust and configured in TOML.
```nix "users/enderger/starship"
# users/enderger/starship
programs.starship = {
  enable = true;
  settings = let
    git_color = "bold magenta";
    hg_color = "bold yellow";
  in {
    format = ''
      \[$username$hostname\]$nix_shell$hg_branch$git_status$git_branch$git_commit$git_state
      $character 
    '';
    add_newline = false;

    username = {
      style_root = "bold red";
      style_user = "bold cyan";
      format = "[$user]($style)";

      show_always = true;
    };

    hostname = {
      style = "bold yellow";
      format = "@[$hostname]($style)";

      ssh_only = true;
    };

    nix_shell = {
      style = "bold blue";
      format = " \\([$symbol$state \\($name\\)]($style)\\)";
    };

    hg_branch = {
      style = hg_color;
      format = " [$symbol$branch]($style)";
    };

    git_status = {
      style = git_color;
      format = " [$all_status$ahead_behind]($style)";
    };

    git_branch = {
      style = git_color;
      format = " [$symbol$branch]($style)";
    };

    git_commit = {
      style = git_color;
      format = " \\(commit [$hash( $tag)]($style)\\)";
    };

    git_state = {
      style = git_color;
      format = " [$state( $progress_current/$progress_total)]($style)";
    };

    character = let
      symbol = "λ";
    in {
      success_symbol = "[${symbol}](bold green)";
      error_symbol = "[${symbol}](bold red)";
      vicmd_symbol = "[${symbol}](bold yellow)";
    };
  };
};
```

### Alacritty
Currently, I'm using Alacritty. At some point, I hope to write my own to avoid certain political issues with this one, but until then I'm using it.
```nix "users/enderger/alacritty"
# users/enderger/alacritty
programs.alacritty = {
  enable = true;
  settings = {
    env.TERM = "alacritty";
    font.normal.family = font;

    window = {
      decorations = "none";
      title = "Terminal Emulator (Alacritty)";
      dynamic_title = false;
    };

    colors = let
      mkColor = id: "0x${colors id}";
    in {
      primary.background = mkColor 0;
      primary.foreground = mkColor 5;

      cursor.text = mkColor 0;
      cursor.cursor = mkColor 5;

      normal = {
        black = mkColor 0;
        red = mkColor 8;
        green = mkColor 11;
        yellow = mkColor 10;
        blue = mkColor 13;
        magenta = mkColor 14;
        cyan = mkColor 12;
        white = mkColor 5;
      };

      bright = {
        black = mkColor 3;
        red = mkColor 8;
        green = mkColor 1;
        yellow = mkColor 2;
        blue = mkColor 4;
        magenta = mkColor 6;
        cyan = mkColor 15;
        white = mkColor 7;
      };
    };
    background_opacity = 0.95;
  };
};
```

## Text Viewing
### Man
This sets up manual pages (shortened to `manpages`).
```nix "users/enderger/man"
# users/enderger/man
programs.man.enable = true;
```

### Bat
This sets up `bat`, which is basically `cat` on Red Bull.
```nix "users/enderger/bat"
programs.bat = {
  enable = true;
  config = {
    pager = "less -FR";
    theme = "base16";
  };
};
```

### Neovim

## Other
### Git
```nix "users/enderger/git"
# users/enderger/git
programs.git = {
  enable = true;
  userEmail = "endergeryt@gmail.com";
  userName = "Enderger";
};
```

# GUI Setup
## Window Managers
Here, we enable all window managers this user has configs for. This is done here, since I want to use multiple window managers per user, when convenient.
```nix "users/enderger/windowManagers"
# users/enderger/windowManagers
xmonad.enable = true;
xmonad.enableContribAndExtras = true;
```

### XMonad

## Bars
### Xmobar

## Apps
### Qutebrowser

### Rofi

# User Configuration
## Metadata
Some basic options for how the user should be seen by the system.
```nix "users/enderger/userOptions"
# users/enderger/userOptions
isNormalUser = true;
shell = pkgs.nushell;
group = "wheel";
extraGroups = [ "docker" ];
inherit (secrets) hashedPassword;
```

## Colors
This section is used to define the Base16 version of my preferred color scheme, [Nord](https://nordtheme.com). The version I use is available [here](https://github.com/ada-lovecraft/base16-nord-scheme/blob/6e83e1d56216762b4f250443af277a000f9d3c0b/nord.yaml).
```nix "users/enderger/colors"
# users/enderger/colors
"2E3440" # base00
"3B4252" # base01
"434C5E" # base02
"4C566A" # base03
"D8DEE9" # base04
"E5E9F0" # base05
"ECEFF4" # base06
"8FBCBB" # base07
"BF616A" # base08
"D08770" # base09
"EBCB8B" # base0A
"A3BE8C" # base0B
"88C0D0" # base0C
"81A1C1" # base0D
"B48EAD" # base0E
"5E81AC" # base0F
```

## Packages
The packages to install for this user. 

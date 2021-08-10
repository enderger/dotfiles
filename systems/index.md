---
title: Systems
---

The system configuration is used to define system-wide configurations based on available hardware. 

# Naming
I've named these configurations after the different space programs of world history, with the idea that each "mission" consists of a "rocket" to launch on, a "program" to work on, and a "crew" to perform. The system thusly should be a minimal, hardware-independent base upon which users can build an environment to use.

# Modules
- [Doas](./systems/modules/doas.md) : Extends Doas with a Sudo alias
- [Home Manager](./systems/modules/home-manager.md) : Gives [home-manager](https://github.com/nix-community/home-manager) more Flake-friendly defaults

# Systems
- [Sputnik](./systems/sputnik.md) : My main system configuration

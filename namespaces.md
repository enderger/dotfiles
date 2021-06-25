# Namespaces
Where each top level name is kept. Do not redefine!
- `README.md` -> `flake`

# Accumulators
These macros may be appended to by any file within it's defining directory.
- `modules/` -> `modules/module-list` : Add to the list of NixOS modules exposed via `self`

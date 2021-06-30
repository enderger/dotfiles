# System Composition
This repository uses 3 types of NixOS module to provide the ability to combine user profiles, hardware setup, and system configurations into different systems depending on the need.

# Communication
Each module will set values for the corresponding interface module.
- The hardware module reads feature flags from the system (e.g. to set up networking if the system requires) and writes availability flags for what the system can expect to see (e.g. networking support).
- The users read information from the system to create user accounts tailored to it.

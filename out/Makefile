MEMORY := 8192
TESTBED := ./result\#testbed

build: clean
	./bootstrap.nix

# VM
build-vm: build
	nixos-rebuild build-vm --flake $(TESTBED)

start-vm: build-vm
	./result/bin/run-*-vm -m $(MEMORY)

# SYSTEM
build-system: build
	nixos-rebuild build --flake "./result#$(ATTR)"

switch-to-system: build
	sudo nixos-rebuild switch --flake "./result#$(ATTR)"

# OTHER
.PHONY: clean
clean:
	@rm -f result

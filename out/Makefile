MEMORY := 8192
TESTBED := "$(shell readlink ./result)#testbed"

build: clean
	./bootstrap.nix

# VM
build-vm: build
	nixos-rebuild build-vm --flake $(TESTBED)

start-vm: build-vm
	./result/bin/run-*-vm -m $(MEMORY)

# SYSTEM
build-system: build
	nixos-rebuild build --flake "$(shell readlink ./result)#$(ATTR)"

switch-to-system: build
	sudo nixos-rebuild switch --flake "$(shell readlink ./result)#$(ATTR)"

# OTHER
.PHONY: clean
clean:
	@rm -f result

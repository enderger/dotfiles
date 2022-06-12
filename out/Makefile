MEMORY := 8192
TESTBED := "$(shell readlink ./result)#testbed"
BUILDFLAGS := 

build: clean
	nix build -f ./bootstrap.nix $(BUILDFLAGS)

# VM
build-vm: build
	nixos-rebuild build-vm --flake $(TESTBED)

start-vm: build-vm
	./result/bin/run-*-vm -m $(MEMORY)

# SYSTEM
build-system-upgrade: build
	nixos-rebuild build $(BUILDFLAGS) --upgrade --flake "$(shell readlink ./result)#$(ATTR)"

build-system: build
	nixos-rebuild build $(BUILDFLAGS) --flake "$(shell readlink ./result)#$(ATTR)"

switch-to-system: build
	sudo nixos-rebuild switch $(BUILDFLAGS) --flake "$(shell readlink ./result)#$(ATTR)"

# OTHER
.PHONY: clean
clean:
	@rm -f result

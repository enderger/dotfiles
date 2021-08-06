MEMORY := 8192
TESTBED := ./result\#testbed

build: clean
	./bootstrap.nix

build-vm: build
	nixos-rebuild build-vm --flake $(TESTBED)

start-vm: build-vm
	./result/bin/run-*-vm -m $(MEMORY)

.PHONY: clean
clean:
	@rm -f result

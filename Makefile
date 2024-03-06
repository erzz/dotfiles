deploy:
	nix build .#darwinConfigurations.system \
	   --extra-experimental-features 'nix-command flakes'

	./result/sw/bin/darwin-rebuild switch --flake

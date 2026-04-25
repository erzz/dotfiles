.PHONY: apply diff test update tools drift status

# Apply chezmoi state (idempotent)
apply:
	@chezmoi apply

# Show pending changes
diff:
	@chezmoi diff

# Run the test suite
test:
	@./tests/run.sh

# Pull latest from git and apply
update:
	@chezmoi update

# Show chezmoi status
status:
	@chezmoi status

# Run drift detection
drift:
	@./drift/detect.sh

# Install optional/ad-hoc tools (driven by .chezmoidata.toml install.* flags)
tools:
	@chezmoi apply --force

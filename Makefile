.PHONY: apply diff test update tools drift status

apply:
	@mise run sync

diff:
	@mise bootstrap status --missing

# Run the test suite
test:
	@./tests/run.sh

update:
	@git pull --rebase
	@mise run sync

status:
	@mise bootstrap status --missing

drift:
	@printf '%s\n' 'Drift detection is provided by: mise bootstrap status --missing'
	@mise bootstrap status --missing

tools:
	@mise run install

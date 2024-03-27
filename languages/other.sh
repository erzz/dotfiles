#!/usr/bin/env bash
set -ex

echo "Attempting latest languages installs..."

# Latest go
if ! go version; then
	echo "Installing latest go with goenv"
	goenv install latest --skip-existing
	LATEST=$(goenv versions | tail -1 | tr -d '[:blank:]')
	goenv global "$LATEST"
	go version
fi

# Latest node
if ! node --version; then
	echo "Installing latest node with nvm"
	LATEST=$(nvm ls-remote | tail -1 | tr -d '[:blank:]')
	nvm install "$LATEST"
	nvm use "$LATEST"
	node --version
fi

# Latest python
if ! python --version; then
	echo "Installing recent python with pyenv"
	pyenv install 3.12 --skip-existing
	pyenv global 3.12
	python --version
fi

# Latest terraform
if ! terraform --version; then
	echo "Installing recent terraform with tfenv"
	tfenv install
	tfenv use 1.7.5
fi

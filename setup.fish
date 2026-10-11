#!/usr/bin/env fish

# Packages come from https://github.com/tymoyato/arch (packages.sh) — run that first

# Installs everything in fish/fish_plugins (fisher list is empty on a fresh machine)
fisher update
rbenv install 3.3.0
rbenv global 3.3.0
gem install bundler
nvm install latest
nvm use latest
npm install --global yarn fast-cli

exec fish

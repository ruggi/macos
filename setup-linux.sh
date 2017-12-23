#!/bin/bash

################################################################################
# \o\ macOS setup /o/                                                          #
################################################################################

source scripts/functions.sh

echo
echo "This script will setup your macOS computer."
echo "It will install some utilities and tweak the system, prompting you when needed."
echo

shell="zsh"

source scripts/dotfiles.sh
source scripts/go.sh
source scripts/vim.sh

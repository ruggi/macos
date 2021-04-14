#!/bin/bash

################################################################################
# \o\ macOS setup /o/                                                          #
################################################################################

source scripts/functions.sh

echo
echo "This script will setup your macOS computer."
echo "It will install some utilities and tweak the system, prompting you when needed."
echo

pp1=`ps -p $$ -o ppid=`
pp2=`ps -p $pp1 -o ppid=`
term=`ps -p $pp2 -o args=`
shell=`ps -p $pp1 -o args=`

osascript -e 'tell application "System Preferences" to quit'

source scripts/dotfiles.sh
source scripts/homebrew.sh
source scripts/ruby.sh
source scripts/apps.sh
source scripts/python.sh
source scripts/vim.sh
source scripts/fonts.sh
source scripts/tweak.sh

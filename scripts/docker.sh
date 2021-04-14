#!/bin/bash
################################################################################
# Docker                                                                       #
################################################################################

info "Downloading Docker..."
wget https://desktop.docker.com/mac/stable/Docker.dmg

open Docker.dmg

ask "Finished installing Docker?"

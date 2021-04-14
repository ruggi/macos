################################################################################
# Homebrew                                                                     #
################################################################################
info "Installing Homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
success "Done"

for tap in `cat brew/taps.list` ; do
  info "Tapping formulas for $tap"
  brew tap $tap
  success "Done"
done

for package in `cat brew/install.list` ; do
  info "Installing $package"
  brew install $package
  success "Done"
done

for package in `cat brew/cask.list` ; do
  info "Installing cask $package"
  brew cask install $package
  success "Done"
done

brew upgrade

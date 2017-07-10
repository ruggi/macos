################################################################################
# Homebrew                                                                     #
################################################################################
info "Installing Homebrew"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
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

brew upgrade

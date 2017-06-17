################################################################################
# Go                                                                           #
################################################################################
for package in `cat go/install.list` ; do
  info "Installing $package"
  go get -u $package
  success "Done"
done

################################################################################
# Ruby                                                                         #
################################################################################
info "Installing ruby"
rbenv install 2.3.3
rbenv global 2.3.3
success "Done"

info "Starting postgres"
brew services start postgresql
success "Done"

info "Installing pow"
curl get.pow.cx | sh
success "Done"

for gem in `cat gems/install.list` ; do
  info "Installing gem $gem"
  gem install $gem
  success "Done"
done

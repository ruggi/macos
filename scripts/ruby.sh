################################################################################
# Ruby                                                                         #
################################################################################
info "Installing ruby"
rbenv install 2.7.1
rbenv global 2.7.1
success "Done"

for gem in `cat gems/install.list` ; do
  info "Installing gem $gem"
  gem install $gem
  success "Done"
done

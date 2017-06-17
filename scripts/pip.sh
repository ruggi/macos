################################################################################
# PIP                                                                          #
################################################################################
for package in `cat pip/install.list` ; do
	info "Installing $package"
	pip install $package
	success "Done"
done

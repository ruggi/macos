################################################################################
# Python                                                                       #
################################################################################

PYTHON_VERSION="3.9.1"

info "Installing Python ${PYTHON_VERSION}..."
pyenv install ${PYTHON_VERSION}
pyenv global ${PYTHON_VERSION}

for package in `cat pip/install.list` ; do
	info "Installing $package"
	pip install $package
	success "Done"
done

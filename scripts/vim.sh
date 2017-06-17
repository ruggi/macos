################################################################################
# VIM (wip)                                                                    #
################################################################################
info "Setting up VIM"
mkdir -p $HOME/.vim/autoload
mkdir -p $HOME/.vim/bundle
mkdir -p $HOME/.vim/tmp

curl -fLo ~/.vim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall
vim +GoInstallBinaries +qall

success "Done"

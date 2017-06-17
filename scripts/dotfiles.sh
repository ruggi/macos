################################################################################
# Dotfiles                                                                     #
################################################################################
if `ask "Set up dotfiles?"` ; then
  info "Setting up dotfiles"

  backup_dir="$HOME/.dotfiles-`date +%s`.backup"
  # Move old dotfiles folder if exists
  if [[ -e $HOME/.dotfiles ]] ; then
    mv $HOME/.dotfiles $backup_dir
  else
    mkdir $backup_dir
  fi

  # Move dotfiles folder to home
  cp -r dotfiles $HOME/.dotfiles

  # Symlink
  for file in `ls $HOME/.dotfiles/rc` ; do
    name=".$file"

    echo Symlinking $name
    if [[ -e "$HOME/$name" ]] ; then
      mv $HOME/$name $backup_dir/$name
    fi

    ln -s $HOME/.dotfiles/rc/$file $HOME/$name
  done

  success "Done"
fi

if echo $shell | grep zsh > /dev/null ; then
  source $HOME/.zshrc > /dev/null 2>&1
else
  source $HOME/.bashrc > /dev/null 2>&1
fi

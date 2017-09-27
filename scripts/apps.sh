################################################################################
# Utility apps                                                                 #
################################################################################
if `ask "Install utility apps? (You need to login in the Mac App Store)"` ; then
  info "Installing utility apps"
  for package in `cat mas/install.list | awk '{print $1}'` ; do
    mas install $package
  done
  success "Done"
fi

if `ask "Set zsh as the default shell?"` ; then
  chsh -s `which zsh`
  sudo mv /etc/zshenv /etc/zprofile
fi

if `ask "Install iTerm?"` ; then
  if ! echo "$term" | grep iTerm2 > /dev/null ; then
    info "Installing iTerm"
    killall iTerm2
    wget https://iterm2.com/downloads/stable/iTerm2-3_0_15.zip
    unzip iTerm2-3_0_15.zip
    sudo mv iTerm2.app /Applications
    rm iTerm2-3_0_15.zip
  fi
fi

echo
info "Open iTerm2, open Preferences (Cmd-,), check 'Load preferences from a custom folder or URL', select `pwd`, then quit iTerm2."
ask "Done?"

success "Done installing!"

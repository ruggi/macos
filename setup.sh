#!/bin/bash

################################################################################
# \o\ macOS setup /o/                                                          #
################################################################################

source scripts/functions.sh

echo
echo "This script will setup your macOS computer."
echo "It will install some utilities and tweak the system, prompting you when needed."
echo

pp1=`ps -p $$ -o ppid=`
pp2=`ps -p $pp1 -o ppid=`
term=`ps -p $pp2 -o args=`
shell=`ps -p $pp1 -o args=`

osascript -e 'tell application "System Preferences" to quit'

cwd=`pwd`

rm -rf temp
mkdir temp
cd temp

# Brew -------------------------------------------------------------------------
if `ask "Install Homebrew?"` ; then
    info "Installing Homebrew…"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    success "Done"
fi

if `ask "Install Homebrew formulas?"` ; then
    brew install \
        git \
        go \
        ag \
        watch \
        nvim \
        tree \
        wget \
        zsh \
        zsh-completions \
        git-town \
        thefuck \
        snappy \
        lz4 \
        mosh \
        yarn \
        jq \
        git-extras \
        fzf \
        rectangle \
        espanso \
        orbstack \
        mas \
        direnv
    success "Done"
fi

# Fonts ------------------------------------------------------------------------
if `ask "Install fonts?"` ; then
    open 'https://www.monolisa.dev/orders'
    ask "Done?"
fi

# iTerm2 -----------------------------------------------------------------------
if `ask "Install iTerm2?"` ; then
    info "Downloading iTerm2…"
    wget https://iterm2.com/downloads/stable/iTerm2-3_4_20.zip
    unzip iTerm2-3_4_4.zip
    sudo mv iTerm2.app /Applications
    success "Done"
    cd ..
    info "Open iTerm2, open Preferences (Cmd-,), check 'Load preferences from a custom folder or URL', select `pwd`/iterm2, then quit iTerm2."
    ask "Done?"
    cd tmp
fi

# oh-my-zsh --------------------------------------------------------------------
if `ask "Install oh-my-zsh?"` ; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    success "Done"
fi

# spaceship --------------------------------------------------------------------
if `ask "Install spaceship prompt?"` ; then
    git clone https://github.com/spaceship-prompt/spaceship-prompt.git
    cp ./spaceship-prompt/spaceship.zsh-theme ~/.oh-my-zsh/themes
    success "Done"
fi

# dotfiles ---------------------------------------------------------------------
if `ask "Setup dotfiles?"` ; then
    rm ~/.zshrc

    ln -s ${cwd}/zshrc ~/.zshrc
    ln -s ${cwd}/dotfiles/vimrc ~/.vimrc
    ln -s ${cwd}/dotfiles/direnvrc ~/.direnvrc

    success "Done"
fi

# 1password --------------------------------------------------------------------
if `ask "Install 1password?"` ; then
    wget https://downloads.1password.com/mac/1Password.zip
    unzip 1Password.zip
    open 1Password\ Installer.app
    ask "Done?"
fi

# VSCode -----------------------------------------------------------------------
if `ask "Install VSCode?"` ; then
    open https://code.visualstudio.com/docs/?dv=osx
    ask "Done?"
fi

# Alfred -----------------------------------------------------------------------
if `ask "Install Alfred?"` ; then
    wget https://cachefly.alfredapp.com/Alfred_5.1.2_2145.dmg
    open Alfred_5.1.2_2145.dmg
    ask "Done?"
fi

# Discord ----------------------------------------------------------------------
if `ask "Install Discord?"` ; then
    wget https://dl.discordapp.net/apps/osx/0.0.276/Discord.dmg
    open Discord.dmg
    ask "Done?"
fi

# Rectangle --------------------------------------------------------------------
if `ask "Set Rectangle config?"` ; then
    open -a Rectangle
    info "Go to Preferences, click Import and select ${cwd}/rectangle/RectangleConfig.json"
    ask "Done?"
fi

# Obsidian ---------------------------------------------------------------------
if `ask "Install Obsidian?"` ; then
    wget https://github.com/obsidianmd/obsidian-releases/releases/download/v1.3.7/Obsidian-1.3.7-universal.dmg
    open Obsidian-1.3.7-universal.dmg
    ask "Done?"
fi

# Rocket -----------------------------------------------------------------------
if `ask "Install Rocket?"` ; then
    wget https://macrelease.matthewpalmer.net/Rocket.dmg
    open Rocket.dmg
    ask "Done?"
    open -a Rocket
fi

# iStat Menus ------------------------------------------------------------------
if `ask "Install iStat Menus?"` ; then
    wget https://cdn.bjango.com/files/istatmenus6/istatmenus6.71.zip
    unzip istatmenus6.71.zip
    sudo mv iStat\ Menus.app /Applications
    open -a iStat\ Menus
    ask "Done?"
fi

# Bartender --------------------------------------------------------------------
if `ask "Install Bartender?"` ; then
    wget https://www.macbartender.com/B2/updates/B4Latest/Bartender%204.dmg
    open Bartender\ 4.dmg
    ask "Done?"
    open -a Bartender\ 4
fi

# MAS --------------------------------------------------------------------------
if `ask "Install MAS apps?"` ; then
    info "- The Unarchiver…"
    mas install 425424353

    info "- Hand Mirror…"
    mas install 1502839586

    info "- Wipr…"
    mas install 1320666476
fi

# Git --------------------------------------------------------------------------
if `ask "Configure Git?"` ; then
    read -p "Enter your git name (e.g. John Doe): " git_user_name
    read -p "Enter your git email: " git_user_email
    git config --global user.name "${git_user_name}"
    git config --global user.email "${git_user_email}"
fi

# SSH --------------------------------------------------------------------------
if `ask "Generate a new SSH key?"` ; then
    ssh-keygen -t ed25519 -C "${git_user_email}"
    eval "$(ssh-agent -s)"
    cat ${cwd}/ssh/config > ~/.ssh/config
    ssh-add --apple-use-keychain ~/.ssh/id_ed25519
    success "Done"
fi

if `ask "Add the new key to Github?"` ; then
    pbcopy < ~/.ssh/id_ed25519.pub
    info "The key has been copied to the clipboard, just paste it in the Github window, which will open in 5 seconds."
    sleep 5
    open https://github.com/settings/ssh/new
    ask "Done?"
fi

# Nix --------------------------------------------------------------------------
if `ask "Install Nix?"` ; then
    sh <(curl -L https://nixos.org/nix/install) --daemon
    success "Done"
fi

# Tweaks -----------------------------------------------------------------------
if `ask "Start tweaking?"` ; then
    xcode-select --install
    softwareupdate --install-rosetta --agree-to-license

    read -p "Computer name: " computer_name
    sudo scutil --set ComputerName "$computer_name"
    sudo scutil --set HostName "$computer_name"
    sudo scutil --set LocalHostName "$computer_name"
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$computer_name"

    # Set standby delay to 24 hours (default is 1 hour)
    sudo pmset -a standbydelay 86400

    # Fix Mojave font rendering
    defaults write -g CGFontRenderingFontSmoothingDisabled -bool NO

    # Set sidebar icon size to medium
    defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

    # Disable the over-the-top focus ring animation
    defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false

    # Increase window resize speed for Cocoa applications
    defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

    # Expand save panel by default
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

    # Expand print panel by default
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

    # Automatically quit printer app once the print jobs complete
    defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

    # Disable the “Are you sure you want to open this application?” dialog
    defaults write com.apple.LaunchServices LSQuarantine -bool false

    # Remove duplicates in the “Open With” menu (also see `lscleanup` alias)
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

    # Display ASCII control characters using caret notation in standard text views
    # Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
    defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

    # Disable automatic termination of inactive apps
    defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

    # Set Help Viewer windows to non-floating mode
    defaults write com.apple.helpviewer DevMode -bool true

    # Restart automatically if the computer freezes
    sudo systemsetup -setrestartfreeze on

    # Disable automatic capitalization as it’s annoying when typing code
    defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

    # Disable smart dashes as they’re annoying when typing code
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

    # Disable automatic period substitution as it’s annoying when typing code
    defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

    # Disable smart quotes as they’re annoying when typing code
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

    # Disable auto-correct
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

    # Drag windows with Cmd+Ctrl
    defaults write -g NSWindowShouldDragOnGesture -bool true

    # Increase sound quality for Bluetooth headphones/headsets
    defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

    # Enable full keyboard access for all controls
    # (e.g. enable Tab in modal dialogs)
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

    # Use scroll gesture with the Ctrl (^) modifier key to zoom
    defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
    defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
    # Follow the keyboard focus while zoomed in
    defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

    # Disable press-and-hold for keys in favor of key repeat
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

    # Set a blazingly fast keyboard repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 10

    # Set language and text formats
    defaults write NSGlobalDomain AppleLanguages -array "en" "us"
    defaults write NSGlobalDomain AppleLocale -string "en_US@currency=EUR"
    defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
    defaults write NSGlobalDomain AppleMetricUnits -bool true

    echo
    read -p "What is your timezone? " timezone

    # Set the timezone; see `sudo systemsetup -listtimezones` for other values
    sudo systemsetup -settimezone "$timezone" > /dev/null

    # Require password immediately after sleep or screen saver begins
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0

    # Save screenshots to the desktop
    defaults write com.apple.screencapture location -string "${HOME}/Desktop"

    # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
    defaults write com.apple.screencapture type -string "png"

    # Disable shadow in screenshots
    defaults write com.apple.screencapture disable-shadow -bool true

    # Finder: disable window animations and Get Info animations
    defaults write com.apple.finder DisableAllAnimations -bool true

    # Set Desktop as the default location for new Finder windows
    defaults write com.apple.finder NewWindowTarget -string "PfDe"
    defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

    # Show icons for hard drives, servers, and removable media on the desktop
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
    defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
    defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

    # Finder: show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Finder: show path bar
    defaults write com.apple.finder ShowPathbar -bool true

    # Display full POSIX path as Finder window title
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true

    # When performing a search, search the current folder by default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

    # Disable the warning when changing a file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    # Enable spring loading for directories
    defaults write NSGlobalDomain com.apple.springing.enabled -bool true

    # Remove the spring loading delay for directories
    defaults write NSGlobalDomain com.apple.springing.delay -float 0

    # Avoid creating .DS_Store files on network or USB volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    # Disable disk image verification
    defaults write com.apple.frameworks.diskimages skip-verify -bool true
    defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
    defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

    # Automatically open a new Finder window when a volume is mounted
    defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
    defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
    defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

    # Show item info near icons on the desktop and in other icon views
    /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" $HOME/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" $HOME/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" $HOME/Library/Preferences/com.apple.finder.plist

    # Show item info to the right of the icons on the desktop
    /usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" $HOME/Library/Preferences/com.apple.finder.plist

    # Enable snap-to-grid for icons on the desktop and in other icon views
    /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" $HOME/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" $HOME/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" $HOME/Library/Preferences/com.apple.finder.plist

    # Increase grid spacing for icons on the desktop and in other icon views
    /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" $HOME/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100" $HOME/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 100" $HOME/Library/Preferences/com.apple.finder.plist

    # Increase the size of icons on the desktop and in other icon views
    /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 80" $HOME/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 80" $HOME/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 80" $HOME/Library/Preferences/com.apple.finder.plist

    # Use list view in all Finder windows by default
    # Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
    defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

    # Disable the warning before emptying the Trash
    defaults write com.apple.finder WarnOnEmptyTrash -bool false

    # Show the $HOME/Library folder
    chflags nohidden $HOME/Library

    # Show the /Volumes folder
    sudo chflags nohidden /Volumes

    # Expand the following File Info panes:
    # “General”, “Open with”, and “Sharing & Permissions”
    defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true

    # Enable highlight hover effect for the grid view of a stack (Dock)
    defaults write com.apple.dock mouse-over-hilite-stack -bool true

    # Set the icon size of Dock items to 48 pixels
    defaults write com.apple.dock tilesize -int 48

    # Enable spring loading for all Dock items
    defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

    # Show indicator lights for open applications in the Dock
    defaults write com.apple.dock show-process-indicators -bool true

    # Wipe all (default) app icons from the Dock
    defaults write com.apple.dock persistent-apps -array

    # Speed up Mission Control animations
    defaults write com.apple.dock expose-animation-duration -float 0.1

    # Don’t group windows by application in Mission Control
    # (i.e. use the old Exposé behavior instead)
    defaults write com.apple.dock expose-group-by-app -bool false

    # Don’t automatically rearrange Spaces based on most recent use
    defaults write com.apple.dock mru-spaces -bool false

    # Remove the auto-hiding Dock delay
    defaults write com.apple.dock autohide-delay -float 0
    # Remove the animation when hiding/showing the Dock
    defaults write com.apple.dock autohide-time-modifier -float 0

    # Automatically hide and show the Dock
    defaults write com.apple.dock autohide -bool true

    # Make Dock icons of hidden applications translucent
    defaults write com.apple.dock showhidden -bool true

    # Disable the Launchpad gesture (pinch with thumb and three fingers)
    defaults write com.apple.dock showLaunchpadGestureEnabled -int 0

    # Privacy: don’t send search queries to Apple
    defaults write com.apple.Safari UniversalSearchEnabled -bool false
    defaults write com.apple.Safari SuppressSearchSuggestions -bool true

    # Press Tab to highlight each item on a web page
    defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

    # Show the full URL in the address bar (note: this still hides the scheme)
    defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

    # Set Safari’s home page to `about:blank` for faster loading
    defaults write com.apple.Safari HomePage -string "about:blank"

    # Prevent Safari from opening ‘safe’ files automatically after downloading
    defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

    # Allow hitting the Backspace key to go to the previous page in history
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true

    # Hide Safari’s bookmarks bar by default
    defaults write com.apple.Safari ShowFavoritesBar -bool false

    # Hide Safari’s sidebar in Top Sites
    defaults write com.apple.Safari ShowSidebarInTopSites -bool false

    # Enable Safari’s debug menu
    defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

    # Make Safari’s search banners default to Contains instead of Starts With
    defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

    # Enable the Develop menu and the Web Inspector in Safari
    defaults write com.apple.Safari IncludeDevelopMenu -bool true
    defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

    # Add a context menu item for showing the Web Inspector in web views
    defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

    # Enable continuous spellchecking
    defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true
    # Disable auto-correct
    defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false

    # Disable AutoFill
    defaults write com.apple.Safari AutoFillFromAddressBook -bool false
    defaults write com.apple.Safari AutoFillPasswords -bool false
    defaults write com.apple.Safari AutoFillCreditCardData -bool false
    defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false

    # Warn about fraudulent websites
    defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

    # Disable Java
    defaults write com.apple.Safari WebKitJavaEnabled -bool false
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false

    # Block pop-up windows
    defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

    # Enable “Do Not Track”
    defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

    # Update extensions automatically
    defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

    # Disable Spotlight indexing for any volume that gets mounted and has not yet
    # been indexed before.
    # Use `sudo mdutil -i off "/Volumes/foo"` to stop indexing any volume.
    sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"
    # Load new settings before rebuilding the index
    killall mds > /dev/null 2>&1
    # Make sure indexing is enabled for the main volume
    sudo mdutil -i on / > /dev/null
    # Rebuild the index from scratch
    sudo mdutil -E / > /dev/null

    # Prevent Time Machine from prompting to use new hard drives as backup volume
    defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

    # Show the main window when launching Activity Monitor
    defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

    # Visualize CPU usage in the Activity Monitor Dock icon
    defaults write com.apple.ActivityMonitor IconType -int 5

    # Show all processes in Activity Monitor
    defaults write com.apple.ActivityMonitor ShowCategory -int 0

    # Sort Activity Monitor results by CPU usage
    defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
    defaults write com.apple.ActivityMonitor SortDirection -int 0

    # Use plain text mode for new TextEdit documents
    defaults write com.apple.TextEdit RichText -int 0

    # Open and save files as UTF-8 in TextEdit
    defaults write com.apple.TextEdit PlainTextEncoding -int 4
    defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

    # Enable the debug menu in Disk Utility
    defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
    defaults write com.apple.DiskUtility advanced-image-options -bool true

    # Auto-play videos when opened with QuickTime Player
    defaults write com.apple.QuickTimePlayerX MGPlayMovieOnOpen -bool true

    # Prevent Photos from opening automatically when devices are plugged in
    defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true
fi

success 'All done! 🎉'
rm -rf ${cwd}/temp

if `ask 'Reboot now?'` ; then
  success "Ok, bye (rebooting)."
  sudo reboot
else
  success "Ok, bye (remember to reboot)"
fi

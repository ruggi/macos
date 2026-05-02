#!/usr/bin/env bash
# macOS preferences. Idempotent — safe to re-run.
set -euo pipefail

# Full Disk Access is required to write Safari prefs (sandboxed) and a few
# other settings. Probe by reading the TCC database, which is FDA-protected.
if ! /bin/cat ~/Library/Application\ Support/com.apple.TCC/TCC.db >/dev/null 2>&1; then
  cat <<'EOF' >&2
This script needs Full Disk Access for the terminal it's running in.

  System Settings → Privacy & Security → Full Disk Access
  → enable your terminal app (Ghostty / iTerm / Terminal)
  → quit and reopen the terminal, then re-run.
EOF
  exit 1
fi

read -rp "Computer name (blank to skip): " COMPUTER_NAME

osascript -e 'tell application "System Settings" to quit' >/dev/null 2>&1 || true

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# --- Identity -----------------------------------------------------------------

if [[ -n "${COMPUTER_NAME:-}" ]]; then
  # Set computer name (visible in About This Mac and shared on the network)
  sudo scutil --set ComputerName "$COMPUTER_NAME"
  # Set hostname (used by command line tools)
  sudo scutil --set HostName "$COMPUTER_NAME"
  # Set local Bonjour hostname (used as <name>.local)
  sudo scutil --set LocalHostName "$COMPUTER_NAME"
  # Set NetBIOS name (used by SMB / Windows file sharing)
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$COMPUTER_NAME"
fi

# --- Locale -------------------------------------------------------------------

# UI language: US English
defaults write NSGlobalDomain AppleLanguages -array "en-US"
# Region formats: US English, currency in EUR
defaults write NSGlobalDomain AppleLocale -string "en_US@currency=EUR"
# Use centimeters for length
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
# Use the metric system
defaults write NSGlobalDomain AppleMetricUnits -bool true

# --- Keyboard / typing --------------------------------------------------------

# Fastest possible key repeat rate
defaults write NSGlobalDomain KeyRepeat -int 1
# Shortest delay before key repeat kicks in
defaults write NSGlobalDomain InitialKeyRepeat -int 10
# Full keyboard access — Tab cycles through every control, not just text fields
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
# Disable press-and-hold accent menu, get key repeat instead
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# No auto-capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
# No smart dashes (-- → —)
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
# No automatic period on double-space
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
# No smart quotes ("" → "")
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
# No autocorrect
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# --- UI / windows -------------------------------------------------------------

# Auto switch between light and dark mode based on time of day.
# AppleInterfaceStyle pins to Dark when set, so it must be removed for Auto to win.
defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true
defaults delete NSGlobalDomain AppleInterfaceStyle 2>/dev/null || true

# Medium-sized sidebar icons
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2
# Disable the animated focus ring
defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false
# Near-instant window resize animations
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
# Save dialogs default to expanded view
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
# Print dialogs default to expanded view
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
# Show all filename extensions in Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Drag windows by Ctrl+Cmd+dragging anywhere on them
defaults write -g NSWindowShouldDragOnGesture -bool true

# --- Screen / screenshots -----------------------------------------------------

# Require a password after sleep / screen saver
defaults write com.apple.screensaver askForPassword -int 1
# ...with no grace period
defaults write com.apple.screensaver askForPasswordDelay -int 0
# Save screenshots to ~/Desktop
defaults write com.apple.screencapture location -string "${HOME}/Desktop"
# Use PNG (alternatives: bmp, gif, jpg, pdf, tiff)
defaults write com.apple.screencapture type -string "png"
# No drop shadow around window screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# --- Finder -------------------------------------------------------------------

# Disable Finder window/info animations
defaults write com.apple.finder DisableAllAnimations -bool true
# New Finder windows open at a specified path...
defaults write com.apple.finder NewWindowTarget -string "PfDe"
# ...which is the Desktop
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"
# Show external drives on the Desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
# Show internal drives on the Desktop
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
# Show mounted network servers on the Desktop
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
# Show USB / SD / other removable media on the Desktop
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
# Show the path bar at the bottom of Finder windows
defaults write com.apple.finder ShowPathbar -bool true
# Show the full POSIX path in the Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
# Sort folders before files when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# Search the current folder by default (not the whole Mac)
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# No warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# Use column view in all Finder windows
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
# No "are you sure" before emptying the trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false
# Expand General / Open With / Sharing & Permissions panes in Get Info
defaults write com.apple.finder FXInfoPanesExpanded -dict General -bool true OpenWith -bool true Privileges -bool true
# Don't write .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
# Don't write .DS_Store files on USB volumes
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
# Enable spring-loaded folders (hover while dragging to open)
defaults write NSGlobalDomain com.apple.springing.enabled -bool true
# ...with zero delay
defaults write NSGlobalDomain com.apple.springing.delay -float 0
# Show ~/Library in Finder
chflags nohidden "$HOME/Library"

# --- Disk images --------------------------------------------------------------

# Skip checksum verification on disk images (faster mounts)
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# --- Dock & Mission Control ---------------------------------------------------

# Dock icon size
defaults write com.apple.dock tilesize -int 48
# Highlight hovered item in Dock stack grids
defaults write com.apple.dock mouse-over-hilite-stack -bool true
# Spring loading on Dock items (drag-hover to activate)
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true
# Indicator dots under running apps in the Dock
defaults write com.apple.dock show-process-indicators -bool true
# Wipe all default apps from the Dock
defaults write com.apple.dock persistent-apps -array
# Faster Mission Control animation
defaults write com.apple.dock expose-animation-duration -float 0.1
# Don't group windows by app in Mission Control (old Exposé behavior)
defaults write com.apple.dock expose-group-by-app -bool false
# Don't auto-rearrange Spaces by most recent use
defaults write com.apple.dock mru-spaces -bool false
# Auto-hide the Dock
defaults write com.apple.dock autohide -bool true
# No delay before the Dock hides
defaults write com.apple.dock autohide-delay -float 0
# No animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0
# Make hidden apps' Dock icons translucent
defaults write com.apple.dock showhidden -bool true

# --- Time Machine -------------------------------------------------------------

# Don't prompt to use newly-attached drives as a Time Machine backup
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# --- Activity Monitor ---------------------------------------------------------

# Open the main window on launch
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
# Show CPU history graph in the Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5
# Show all processes (not just current user)
defaults write com.apple.ActivityMonitor ShowCategory -int 0
# Sort by CPU usage...
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
# ...descending
defaults write com.apple.ActivityMonitor SortDirection -int 0

# --- TextEdit -----------------------------------------------------------------

# Plain text mode by default for new docs
defaults write com.apple.TextEdit RichText -int 0
# Open files as UTF-8
defaults write com.apple.TextEdit PlainTextEncoding -int 4
# Save files as UTF-8
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# --- Photos -------------------------------------------------------------------

# Don't auto-open Photos when a camera/phone is plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

# --- Safari -------------------------------------------------------------------

# Don't send search queries to Apple
defaults write com.apple.Safari UniversalSearchEnabled -bool false
# Tab highlights every element on a page (not just links/form fields)
defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true
# Compact tab layout (merge address bar and tab bar)
defaults write com.apple.Safari ShowStandaloneTabBar -bool false
# Show the full URL in the address bar (not just the domain)
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true
# Show the URL status bar (link preview at bottom-left on hover; toggled by Cmd+/)
defaults write com.apple.Safari ShowOverlayStatusBar -bool true
# Empty home page for fast new-window load
defaults write com.apple.Safari HomePage -string "about:blank"
# Don't auto-open "safe" files after downloading
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
# Find-on-page matches anywhere in a word, not just word-starts
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false
# Show the Develop menu
defaults write com.apple.Safari IncludeDevelopMenu -bool true
# Enable the Web Inspector
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
# "Inspect Element" in the right-click menu of any web view
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
# Spellcheck while typing
defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true
# ...but no autocorrect
defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false
# Disable Safari's AutoFill — 1Password handles all of this
defaults write com.apple.Safari AutoFillFromAddressBook -bool false
defaults write com.apple.Safari AutoFillPasswords -bool false
defaults write com.apple.Safari AutoFillCreditCardData -bool false
defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false
# Block JavaScript-opened popup windows
defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false
# Auto-update Safari extensions
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

# --- Restart affected apps ----------------------------------------------------

for app in "Activity Monitor" "Dock" "Finder" "SystemUIServer" "cfprefsd"; do
  killall "$app" >/dev/null 2>&1 || true
done

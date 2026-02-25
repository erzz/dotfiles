#!/usr/bin/env bash

echo "Configuring macOS..."
echo "NOTE: Some settings require sudo — you may be prompted for your password."
echo ""

# <------------------ ACTIVITY MONITOR ------------------->
echo "Configuring Activity Monitor"
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
defaults write com.apple.ActivityMonitor IconType -int 5
defaults write com.apple.ActivityMonitor ShowCategory -int 100
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0
defaults write com.apple.ActivityMonitor "UserColumnsPerTab v5.0" -dict \
	'0' '( Command, CPUUsage, CPUTime, Threads, PID, UID, Ports )' \
	'1' '( Command, ResidentSize, Threads, Ports, PID, UID,  )' \
	'2' '( Command, PowerScore, 12HRPower, AppSleep, UID, powerAssertion )' \
	'3' '( Command, bytesWritten, bytesRead, Architecture, PID, UID, CPUUsage )' \
	'4' '( Command, txBytes, rxBytes, PID, UID, txPackets, rxPackets, CPUUsage )'
defaults write com.apple.ActivityMonitor UserColumnSortPerTab -dict \
	'0' '{ direction = 0; sort = CPUUsage; }' \
	'1' '{ direction = 0; sort = ResidentSize; }' \
	'2' '{ direction = 0; sort = 12HRPower; }' \
	'3' '{ direction = 0; sort = bytesWritten; }' \
	'4' '{ direction = 0; sort = txBytes; }'
defaults write com.apple.ActivityMonitor UpdatePeriod -int 2

# <-------------- DIRECTORY SPRING LOADING --------------->
echo "Directory Spring Loading"
defaults write NSGlobalDomain com.apple.springing.enabled -bool true
defaults write NSGlobalDomain com.apple.springing.delay -float 0

# <------------------------ DOCK ------------------------->
echo "Configuring Dock"
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock show-process-indicators -bool true

# <---------------------- DS_STORE ----------------------->
# Avoid creating .DS_Store files on network or USB volumes
echo "Configuring DS_STORE"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# <----------------------- FINDER ------------------------>
# Finder: open everything in list view.
echo "Configuring Finder"
defaults write com.apple.finder FXPreferredViewStyle Nlsv

# Finder: show the ~/Library folder.
chflags nohidden ~/Library

# Finder: show the /Volumes folder
sudo chflags nohidden /Volumes

# Finder: set prefs for showing a few different volumes on the Desktop.
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true

# Finder: show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Finder: display full POSIX path as window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Finder: keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Finder: default new window location to home
defaults write com.apple.finder NewWindowTarget -string "PfHm"

# Finder: set default search scope to "this mac"
defaults write com.apple.finder FXDefaultSearchScope -string "SCev"

# Finder: disable warning when changing file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# <----------------- IMAGE VERIFICATION ------------------>
echo "Configuring image verification"
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# <----------------------- LOGIN ------------------------->
echo "Configuring Login"
# Disable remote login
sudo systemsetup -f -setremotelogin off

# Use old-school login
defaults write com.apple.loginwindow SHOWFULLNAME -bool true

# <------------------ NETWORK BROWSING ------------------->
echo "Configuring Network Browsing"
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# <-------------------- SCREENSHOTS ---------------------->
echo "Configuring Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Pictures"
defaults write com.apple.screencapture type -string "png"

# <---------------------- TERMINAL ----------------------->
echo "Configuring Terminal"
defaults write com.apple.terminal StringEncodings -array 4

# <-------------------- TIME MACHINE --------------------->
echo "Configuring Time Machine"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# <----------------------- OTHER ------------------------->
echo "Configuring Other Stuff"

echo "Disable the 'Are you sure you want to open this application?' dialog"
defaults write com.apple.LaunchServices LSQuarantine -bool false

echo "Disable smart quotes as they’re annoying when typing code"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

echo "Disable smart dashes as they’re annoying when typing code"
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

echo "Fix the scrolling direction"
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

echo "Repeating keystrokes config"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# <----------------- RESTART AFFECTED APPS ----------------->
echo ""
echo "Restarting Dock and Finder to apply changes..."
killall Dock
killall Finder

echo ""
echo "Done! Some settings may still require a logout or reboot to take effect."

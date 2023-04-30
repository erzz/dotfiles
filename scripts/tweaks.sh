#!/bin/bash

source scripts/outputFormat.sh

title "Configuring Activity Monitor"
###################### ACTIVITY MONITOR ###################
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

################ DIRECTORY SPRING LOADING #################
title "Directory Spring Loading"
defaults write NSGlobalDomain com.apple.springing.enabled -bool true
defaults write NSGlobalDomain com.apple.springing.delay -float 0

####################### DOCK ##############################
title "Configuring Dock"
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock show-process-indicators -bool true
defaults write com.apple.dock hide-mirror -bool true

######################## DS_STORE #########################
# Avoid creating .DS_Store files on network or USB volumes
title "Configuring DS_STORE"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

######################### FINDER ##########################
# Finder: open everything in list view.
title "Configuring Finder"
defaults write com.apple.Finder FXPreferredViewStyle Nlsv

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

# Finder: enable copy/select text in quick look
defaults write com.apple.finder QLEnableTextSelection -bool true

# Finder: set default search scope to "this mac"
defaults write com.apple.finder FXDefaultSearchScope -string "SCev"

# Finder: disable warning when changing file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

################### IMAGE VERIFICATION ####################
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

######################## LOGIN ############################
title "Configuring Login"
# Disable remote login
sudo systemsetup -f -setremotelogin off

# Use old-school login
defaults write com.apple.loginwindow SHOWFULLNAME -bool true

#################### NETWORK BROWSING #####################
title "Configuring Network Browsing"
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

####################### SCREENSHOTS ########################
title "Configuring Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Pictures"
defaults write com.apple.screencapture type -string "png"

################### SECURE TRASH EMPTY ####################
title "Configuring Secure Trash Empty"
defaults write com.apple.finder EmptyTrashSecurely -bool true

###################### TERMINAL ###########################
title "Configuring Terminal"
defaults write com.apple.terminal StringEncodings -array 4

###################### TIME MACHINE #######################
title "Configuring Time Machine"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

######################### MISC ############################
title "Configuring Other Stuff"
# Disable Sudden Motion Sensor
sudo pmset -a sms 0
# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false
# Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
# Disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
# Fix the scrolling direction
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
# Better bluetooth sound
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40
# Repeating keystrokes config
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

defaults write NSGlobalDomain AppleFontSmoothing -int 2
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

###################### KILL APPS ##########################
for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
  "Dock" "Finder" "Mail" "Messages" "Safari" "SizeUp" "SystemUIServer" \
  "iCal" "Terminal"; do
  killall "${app}" > /dev/null 2>&1
done

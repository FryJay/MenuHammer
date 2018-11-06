----------------------------------------------------------------------------------------------------
--------------------------------------- General Config ---------------------------------------------
----------------------------------------------------------------------------------------------------

-- If enabled, the menus will appear over full screen applications.
-- However, the Hammerspoon dock icon will also be disabled (required for fullscreen).
menuShowInFullscreen = true

-- The number of seconds that a hotkey alert will stay on screen.
-- 0 = alerts are disabled.
hs.hotkey.alertDuration = 0

-- Show no titles for Hammerspoon windows.
hs.hints.showTitleThresh = 0

-- Disable animations
hs.window.animationDuration = 0

-- Editor path
menuTextEditor = "/usr/local/bin/emacsclient -c"

-- Location of the askpass executable.  Required for running script with admin privs.
askpassLocation = "/usr/local/bin/ssh-askpass"

----------------------------------------------------------------------------------------------------
----------------------------------------- Menu options ---------------------------------------------
----------------------------------------------------------------------------------------------------

-- The number of columns to display in the menus.  Setting this too high or too low will
-- probably have odd results.
menuNumberOfColumns = 5

-- The minimum number of rows to show in menus
menuMinNumberOfRows = 4

-- The height of menu rows in pixels
menuRowHeight = 20

-- The padding to apply to each side of the menu
menuOuterPadding = 50

----------------------------------------------------------------------------------------------------
----------------------------------------- Font options ---------------------------------------------
----------------------------------------------------------------------------------------------------

-- The font to apply to menu items.
menuItemFont = "Courier-Bold"

-- The font size to apply to menu items.
menuItemFontSize = 16

-- The text alignment to apply to menu items.
menuItemTextAlign = "left"

----------------------------------------------------------------------------------------------------
---------------------------------------- Color options ---------------------------------------------
----------------------------------------------------------------------------------------------------

menuItemColors = {
    -- The default colors to use.
    default = {
        background = "#000000",
        text = "#aaaaaa"
    },
    -- The colors to use for the Exit menu item
    exit = {
        background = "#444444",
        text = "#ff0000"
    },
    -- The colors to use for the Back menu items
    back = {
        background = "#444444",
        text = "#00ffff"
    },
    -- The colors to use for blank menu items
    blank = {
        background = "#000000",
        text = "#000000"
    },
    -- The colors to use for menu menu items
    menu = {
        background = "#000000",
        text = "#ee00ee"
    },
    -- The colors to use for navigation menu items
    navigation = {
        background = "#444444",
        text = "#ffffff"
    },
    -- The colors to use for action menu items
    action = {
        background = "#000000",
        text = "#2390ff"
    },
    menuBarActive = {
        background = "#ff0000",
        text = "#000000"
    },
    menuBarIdle = {
        background = "#00ff00",
        text = "#000000"
    }
}

----------------------------------------------------------------------------------------------------
-------------------------------------- Menu bar options --------------------------------------------
----------------------------------------------------------------------------------------------------

-- Key bindings

-- The hotkey that will enable/disable MenuHammer
menuHammerToggleKey = {{"cmd", "shift", "ctrl"}, "Q"}

-- Menu Prefixes
menuItemPrefix = {
    action = '↩',
    menu = '→',
    back = '←',
    exit = 'x',
    navigation = '⎋',
}

-- Menu item separator
menuKeyItemSeparator = ": "

----------------------------------------------------------------------------------------------------
--------------------------------------- Default Menus ----------------------------------------------
----------------------------------------------------------------------------------------------------

-- Check if the custom config file exists.

menuHammerMenuList = menuhammerMenuList

if menuHammerMenuList then
    print("Using custom menu list.")
else
    print("Menu list not set.  Using default.")

    -- Menus
    local mainMenu = "mainMenu"
    local applicationMenu = "applicationMenu"
    local utilitiesMenu = "utilitiesMenu"
    local finderMenu = "finderMenu"
    local hammerspoonMenu = "hammerspoonMenu"
    local mediaMenu = "mediaMenu"
    local resolutionMenu = "resolutionMenu"
    local systemMenu = "systemMenu"

    menuHammerMenuList = {
        mainMenu = {
            parentMenu = nil,
            menuHotkey = {{'alt'}, 'space'},
            menuItems =  {
                {mhConstants.category.menu, '', 'A', 'Applications', {
                     {mhConstants.bind.menu, applicationMenu}
                }},
                {mhConstants.category.menu, '', 'F', 'Finder',
                 {{mhConstants.bind.menu, finderMenu}}},
                {mhConstants.category.menu, '', 'H', 'Hammerspoon',
                 {{mhConstants.bind.menu, hammerspoonMenu}}},
                {mhConstants.category.menu, '', 'M', 'Media Controls',
                 {{mhConstants.bind.menu, mediaMenu}}},
                {mhConstants.category.action, '', 'S', "Spotlight", {
                     {mhConstants.bind.keycombo, {'cmd'}, 'space'}
                }},
                {mhConstants.category.menu, '', 'R', 'Resolution',
                 {{mhConstants.bind.menu, resolutionMenu}}},
                {mhConstants.category.menu, '', 'X', 'System Commands',
                 {{mhConstants.bind.menu, systemMenu}}},
            }
        },
        applicationMenu = {
            parentMenu = mainMenu,
            menuHotkey = nil,
            menuItems = {
                {mhConstants.category.action, '', 'A', "App Store", {
                     {mhConstants.bind.launcher, 'App Store'}
                }},
                {mhConstants.category.action, '', 'F', "Finder", {
                     {mhConstants.bind.launcher, 'Finder'}
                }},
                {mhConstants.category.action, '', 'S', "Safari", {
                     {mhConstants.bind.launcher, 'Safari'}
                }},
                {mhConstants.category.action, '', 'T', "Terminal", {
                     {mhConstants.bind.launcher, 'Terminal'}
                }},
                {mhConstants.category.action, 'shift', 'T', "TextEdit", {
                     {mhConstants.bind.launcher, 'Terminal'}
                }},
                {mhConstants.category.menu, '', 'U', 'Utilities', {
                     {mhConstants.bind.menu, utilitiesMenu}
                }},
                {mhConstants.category.action, '', 'X', "Xcode", {
                     {mhConstants.bind.launcher, 'Xcode'}
                }},
            }
        },
        utilitiesMenu = {
            parentMenu = applicationMenu,
            menuHotkey = nil,
            menuItems = {
                {mhConstants.category.action, '', 'A', "Activity Monitor", {
                     {mhConstants.bind.launcher, 'Activity Monitor'}
                }},
                {mhConstants.category.action, 'shift', 'A', "Airport Utility", {
                     {mhConstants.bind.launcher, 'Airport Utility'}
                }},
                {mhConstants.category.action, '', 'C', "Console", {
                     {mhConstants.bind.launcher, 'Console'}
                }},
                {mhConstants.category.action, '', 'D', "Disk Utility", {
                     {mhConstants.bind.launcher, 'Disk Utility'}
                }},
                {mhConstants.category.action, '', 'K', "Keychain Access", {
                     {mhConstants.bind.launcher, 'Keychain Access'}
                }},
                {mhConstants.category.action, '', 'S', "System Information", {
                     {mhConstants.bind.launcher, 'System Information'}
                }},
                {mhConstants.category.action, '', 'T', "Terminal", {
                     {mhConstants.bind.launcher, 'Terminal'}
                }},
            }
        },
        finderMenu = {
            parentMenu = mainMenu,
            menuHotkey = nil,
            menuItems = {
                {mhConstants.category.action, '', 'A', 'Applications Folder', {
                     {mhConstants.bind.launcher, 'Finder'},
                     {mhConstants.bind.keycombo, {'cmd', 'shift'}, 'a'},
                }},
                {mhConstants.category.action, 'shift', 'A', 'Airdrop', {
                     {mhConstants.bind.launcher, 'Finder'},
                     {mhConstants.bind.keycombo, {'cmd', 'shift'}, 'r'},
                }},
                {mhConstants.category.action, '', 'C', 'Computer', {
                     {mhConstants.bind.launcher, 'Finder'},
                     {mhConstants.bind.keycombo, {'cmd', 'shift'}, 'c'},
                }},
                {mhConstants.category.action, '', 'D', 'Desktop', {
                     {mhConstants.bind.launcher, 'Finder'},
                     {mhConstants.bind.keycombo, {'cmd', 'shift'}, 'd'},
                }},
                {mhConstants.category.action, 'shift', 'D', 'Downloads', {
                     {mhConstants.bind.launcher, 'Finder'},
                     {mhConstants.bind.keycombo, {'cmd', 'alt'}, 'l'},
                }},
                {mhConstants.category.action, '', 'F', "Finder", {
                     {mhConstants.bind.launcher, 'Finder'}
                }},
                {mhConstants.category.action, '', 'G', 'Go to Folder...', {
                     {mhConstants.bind.launcher, 'Finder'},
                     {mhConstants.bind.keycombo, {'cmd', 'shift'}, 'g'},
                }},
                {mhConstants.category.action, '', 'H', 'Home', {
                     {mhConstants.bind.launcher, 'Finder'},
                     {mhConstants.bind.keycombo, {'cmd', 'shift'}, 'h'},
                }},
                {mhConstants.category.action, 'shift', 'H', 'Hammerspoon', {
                     {mhConstants.bind.launcher, 'Finder'},
                     {mhConstants.bind.keycombo, {'cmd', 'shift'}, 'g'},
                     {mhConstants.bind.keycombo, {'type'}, '~/.hammerspoon\n'},
                }},
                {mhConstants.category.action, '', 'I', 'iCloud Drive', {
                     {mhConstants.bind.launcher, 'Finder'},
                     {mhConstants.bind.keycombo, {'cmd', 'shift'}, 'i'},
                }},
                {mhConstants.category.action, '', 'K', 'Connect to Server...', {
                     {mhConstants.bind.launcher, 'Finder'},
                     {mhConstants.bind.keycombo, {'cmd'}, 'K'},
                }},
                {mhConstants.category.action, '', 'L', 'Library', {
                     {mhConstants.bind.launcher, 'Finder'},
                     {mhConstants.bind.keycombo, {'cmd', 'shift'}, 'l'},
                }},
                {mhConstants.category.action, '', 'N', 'Network', {
                     {mhConstants.bind.launcher, 'Finder'},
                     {mhConstants.bind.keycombo, {'cmd', 'shift'}, 'k'},
                }},
                {mhConstants.category.action, '', 'O', 'Documents', {
                     {mhConstants.bind.launcher, 'Finder'},
                     {mhConstants.bind.keycombo, {'cmd', 'shift'}, 'o'},
                }},
                {mhConstants.category.action, '', 'R', 'Recent', {
                     {mhConstants.bind.launcher, 'Finder'},
                     {mhConstants.bind.keycombo, {'cmd', 'shift'}, 'f'},
                }},
                {mhConstants.category.action, '', 'U', 'Utilities', {
                     {mhConstants.bind.launcher, 'Finder'},
                     {mhConstants.bind.keycombo, {'cmd', 'shift'}, 'u'},
                }},
            }
        },
        hammerspoonMenu = {
            parentMenu = mainMenu,
            menuHotkey = nil,
            menuItems = {
                {mhConstants.category.action, '', 'C', "Hammerspoon Console", {
                     {mhConstants.bind.func, function() hs.toggleConsole() end }
                }},
                {mhConstants.category.action, '', 'H', "Hammerspoon Manual", {
                     {mhConstants.bind.func, function()
                          hs.doc.hsdocs.forceExternalBrowser(true)
                          hs.doc.hsdocs.moduleEntitiesInSidebar(true)
                          hs.doc.hsdocs.help()
                     end }
                }},
                {mhConstants.category.action, '', 'R', "Reload Hammerspoon", {
                     {mhConstants.bind.func, function() hs.reload() end }
                }},
                {mhConstants.category.action, '', 'Q', "Quit Hammerspoon", {
                     {mhConstants.bind.func, function() os.exit() end }
                }},
            }
        },
        mediaMenu = {
            parentMenu = mainMenu,
            menuHotkey = nil,
            menuItems = {
                {mhConstants.category.action, '', 'A', "iTunes", {
                     {mhConstants.bind.launcher, "iTunes"}
                }},
                {mhConstants.category.action, '', 'H', "Previous Track", {
                     {mhConstants.bind.mediakey, "previous"}
                }},
                {mhConstants.category.action, '', 'J', "Volume Down", {
                     {mhConstants.bind.mediakey, "volume", -10}
                }},
                {mhConstants.category.action, '', 'K', "Volume Up", {
                     {mhConstants.bind.mediakey, "volume", 10}
                }},
                {mhConstants.category.action, '', 'L', "Next Track", {
                     {mhConstants.bind.mediakey, "next"}
                }},
                {mhConstants.category.action, '', 'X', "Mute/Unmute", {
                     {mhConstants.bind.mediakey, "mute"}
                }},
                {mhConstants.category.action, '', 'S', "Play/Pause", {
                     {mhConstants.bind.mediakey, "mute"}
                }},
                {mhConstants.category.action, '', 'I', "Brightness Down", {
                     {mhConstants.bind.mediakey, "brightness", -10}
                }},
                {mhConstants.category.action, '', 'O', "Brightness Up", {
                     {mhConstants.bind.mediakey, "brightness", 10}
                }},
            }
        },
        resolutionMenu = {
            parentMenu = mainMenu,
            menuHotkey = nil,
            menuItems = resolutionMenuItems,
        },
        systemMenu = {
            parentMenu = mainMenu,
            menuHotkey = nil,
            menuItems = {
                {mhConstants.category.action, 'shift', 'F', "Force Quit Frontmost App", {
                     {mhConstants.bind.func, function() hs.application.frontmostApplication():kill9() end }
                }},
                {mhConstants.category.action, '', 'L', "Lock Screen", {
                     {mhConstants.bind.func, function() hs.caffeinate.systemSleep() end }
                }},
                {mhConstants.category.action, 'shift', 'R', "Restart System", {
                     {mhConstants.bind.func, function() hs.caffeinate.restartSystem() end }
                }},
                {mhConstants.category.action, 'cmd', 'R', "Shutdown System", {
                     {mhConstants.bind.func, function() hs.caffeinate.shutdownSystem() end }
                }},
                {mhConstants.category.action, '', 'S', "Start Screensaver", {
                     {mhConstants.bind.func, function() hs.caffeinate.startScreensaver() end }
                }},
                {mhConstants.category.action, 'shift', 'Q', 'Logout', {
                     {mhConstants.bind.keycombo, {'cmd', 'shift'}, 'Q'},
                }},
                {mhConstants.category.action, 'cmd', 'Q', 'Logout Immediately', {
                     {mhConstants.bind.keycombo, {'cmd', 'alt', 'shift'}, 'Q'},
                }},
                {mhConstants.category.action, '', 'U', "Change User", {
                     {mhConstants.bind.func, function() hs.caffeinate.lockScreen() end }
                }},
                {mhConstants.category.action, '', 'V', 'Activity Monitor', {
                     {mhConstants.bind.launcher, 'Activity Monitor'},
                }},
                {mhConstants.category.action, '', 'X', 'System Preferences', {
                     {mhConstants.bind.launcher, 'System Preferences'},
                }},
            }
        },
    }
end

----------------------------------------------------------------------------------------------------
--------------------------------------- General Config ---------------------------------------------
----------------------------------------------------------------------------------------------------

-- If enabled, the menus will appear over full screen applications.
-- However, the Hammerspoon dock icon will also be disabled (required for fullscreen).
menuShowInFullscreen = true

showMenuBarItem = false

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
                     {mhConstants.action.menu, applicationMenu}
                }},
                {mhConstants.category.menu, '', 'F', 'Finder',
                 {{mhConstants.action.menu, finderMenu}}},
                {mhConstants.category.menu, '', 'H', 'Hammerspoon',
                 {{mhConstants.action.menu, hammerspoonMenu}}},
                {mhConstants.category.menu, '', 'M', 'Media Controls',
                 {{mhConstants.action.menu, mediaMenu}}},
                {mhConstants.category.action, '', 'S', "Spotlight", {
                     {mhConstants.action.keycombo, {'cmd'}, 'space'}
                }},
                {mhConstants.category.menu, '', 'R', 'Resolution',
                 {{mhConstants.action.menu, resolutionMenu}}},
                {mhConstants.category.menu, '', 'X', 'System Commands',
                 {{mhConstants.action.menu, systemMenu}}},
            }
        },
        applicationMenu = {
            parentMenu = mainMenu,
            menuHotkey = nil,
            menuItems = {
                {mhConstants.category.action, '', 'A', "App Store", {
                     {mhConstants.action.launcher, 'App Store'}
                }},
                {mhConstants.category.action, '', 'F', "Finder", {
                     {mhConstants.action.launcher, 'Finder'}
                }},
                {mhConstants.category.action, '', 'S', "Safari", {
                     {mhConstants.action.launcher, 'Safari'}
                }},
                {mhConstants.category.action, '', 'T', "Terminal", {
                     {mhConstants.action.launcher, 'Terminal'}
                }},
                {mhConstants.category.action, 'shift', 'T', "TextEdit", {
                     {mhConstants.action.launcher, 'Terminal'}
                }},
                {mhConstants.category.menu, '', 'U', 'Utilities', {
                     {mhConstants.action.menu, utilitiesMenu}
                }},
                {mhConstants.category.action, '', 'X', "Xcode", {
                     {mhConstants.action.launcher, 'Xcode'}
                }},
            }
        },
        utilitiesMenu = {
            parentMenu = applicationMenu,
            menuHotkey = nil,
            menuItems = {
                {mhConstants.category.action, '', 'A', "Activity Monitor", {
                     {mhConstants.action.launcher, 'Activity Monitor'}
                }},
                {mhConstants.category.action, 'shift', 'A', "Airport Utility", {
                     {mhConstants.action.launcher, 'Airport Utility'}
                }},
                {mhConstants.category.action, '', 'C', "Console", {
                     {mhConstants.action.launcher, 'Console'}
                }},
                {mhConstants.category.action, '', 'D', "Disk Utility", {
                     {mhConstants.action.launcher, 'Disk Utility'}
                }},
                {mhConstants.category.action, '', 'K', "Keychain Access", {
                     {mhConstants.action.launcher, 'Keychain Access'}
                }},
                {mhConstants.category.action, '', 'S', "System Information", {
                     {mhConstants.action.launcher, 'System Information'}
                }},
                {mhConstants.category.action, '', 'T', "Terminal", {
                     {mhConstants.action.launcher, 'Terminal'}
                }},
            }
        },
        finderMenu = {
            parentMenu = mainMenu,
            menuHotkey = nil,
            menuItems = {
                {mhConstants.category.action, '', 'A', 'Applications Folder', {
                     {mhConstants.action.launcher, 'Finder'},
                     {mhConstants.action.keycombo, {'cmd', 'shift'}, 'a'},
                }},
                {mhConstants.category.action, 'shift', 'A', 'Airdrop', {
                     {mhConstants.action.launcher, 'Finder'},
                     {mhConstants.action.keycombo, {'cmd', 'shift'}, 'r'},
                }},
                {mhConstants.category.action, '', 'C', 'Computer', {
                     {mhConstants.action.launcher, 'Finder'},
                     {mhConstants.action.keycombo, {'cmd', 'shift'}, 'c'},
                }},
                {mhConstants.category.action, '', 'D', 'Desktop', {
                     {mhConstants.action.launcher, 'Finder'},
                     {mhConstants.action.keycombo, {'cmd', 'shift'}, 'd'},
                }},
                {mhConstants.category.action, 'shift', 'D', 'Downloads', {
                     {mhConstants.action.launcher, 'Finder'},
                     {mhConstants.action.keycombo, {'cmd', 'alt'}, 'l'},
                }},
                {mhConstants.category.action, '', 'F', "Finder", {
                     {mhConstants.action.launcher, 'Finder'}
                }},
                {mhConstants.category.action, '', 'G', 'Go to Folder...', {
                     {mhConstants.action.launcher, 'Finder'},
                     {mhConstants.action.keycombo, {'cmd', 'shift'}, 'g'},
                }},
                {mhConstants.category.action, '', 'H', 'Home', {
                     {mhConstants.action.launcher, 'Finder'},
                     {mhConstants.action.keycombo, {'cmd', 'shift'}, 'h'},
                }},
                {mhConstants.category.action, 'shift', 'H', 'Hammerspoon', {
                     {mhConstants.action.launcher, 'Finder'},
                     {mhConstants.action.keycombo, {'cmd', 'shift'}, 'g'},
                     {mhConstants.action.keycombo, {'type'}, '~/.hammerspoon\n'},
                }},
                {mhConstants.category.action, '', 'I', 'iCloud Drive', {
                     {mhConstants.action.launcher, 'Finder'},
                     {mhConstants.action.keycombo, {'cmd', 'shift'}, 'i'},
                }},
                {mhConstants.category.action, '', 'K', 'Connect to Server...', {
                     {mhConstants.action.launcher, 'Finder'},
                     {mhConstants.action.keycombo, {'cmd'}, 'K'},
                }},
                {mhConstants.category.action, '', 'L', 'Library', {
                     {mhConstants.action.launcher, 'Finder'},
                     {mhConstants.action.keycombo, {'cmd', 'shift'}, 'l'},
                }},
                {mhConstants.category.action, '', 'N', 'Network', {
                     {mhConstants.action.launcher, 'Finder'},
                     {mhConstants.action.keycombo, {'cmd', 'shift'}, 'k'},
                }},
                {mhConstants.category.action, '', 'O', 'Documents', {
                     {mhConstants.action.launcher, 'Finder'},
                     {mhConstants.action.keycombo, {'cmd', 'shift'}, 'o'},
                }},
                {mhConstants.category.action, '', 'R', 'Recent', {
                     {mhConstants.action.launcher, 'Finder'},
                     {mhConstants.action.keycombo, {'cmd', 'shift'}, 'f'},
                }},
                {mhConstants.category.action, '', 'U', 'Utilities', {
                     {mhConstants.action.launcher, 'Finder'},
                     {mhConstants.action.keycombo, {'cmd', 'shift'}, 'u'},
                }},
            }
        },
        hammerspoonMenu = {
            parentMenu = mainMenu,
            menuHotkey = nil,
            menuItems = {
                {mhConstants.category.action, '', 'C', "Hammerspoon Console", {
                     {mhConstants.action.func, function() hs.toggleConsole() end }
                }},
                {mhConstants.category.action, '', 'H', "Hammerspoon Manual", {
                     {mhConstants.action.func, function()
                          hs.doc.hsdocs.forceExternalBrowser(true)
                          hs.doc.hsdocs.moduleEntitiesInSidebar(true)
                          hs.doc.hsdocs.help()
                     end }
                }},
                {mhConstants.category.action, '', 'R', "Reload Hammerspoon", {
                     {mhConstants.action.func, function() hs.reload() end }
                }},
                {mhConstants.category.action, '', 'Q', "Quit Hammerspoon", {
                     {mhConstants.action.func, function() os.exit() end }
                }},
            }
        },
        mediaMenu = {
            parentMenu = mainMenu,
            menuHotkey = nil,
            menuItems = {
                {mhConstants.category.action, '', 'A', "iTunes", {
                     {mhConstants.action.launcher, "iTunes"}
                }},
                {mhConstants.category.action, '', 'H', "Previous Track", {
                     {mhConstants.action.mediakey, "previous"}
                }},
                {mhConstants.category.action, '', 'J', "Volume Down", {
                     {mhConstants.action.mediakey, "volume", -10}
                }},
                {mhConstants.category.action, '', 'K', "Volume Up", {
                     {mhConstants.action.mediakey, "volume", 10}
                }},
                {mhConstants.category.action, '', 'L', "Next Track", {
                     {mhConstants.action.mediakey, "next"}
                }},
                {mhConstants.category.action, '', 'X', "Mute/Unmute", {
                     {mhConstants.action.mediakey, "mute"}
                }},
                {mhConstants.category.action, '', 'S', "Play/Pause", {
                     {mhConstants.action.mediakey, "mute"}
                }},
                {mhConstants.category.action, '', 'I', "Brightness Down", {
                     {mhConstants.action.mediakey, "brightness", -10}
                }},
                {mhConstants.category.action, '', 'O', "Brightness Up", {
                     {mhConstants.action.mediakey, "brightness", 10}
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
                     {mhConstants.action.func, function() hs.application.frontmostApplication():kill9() end }
                }},
                {mhConstants.category.action, '', 'L', "Lock Screen", {
                     {mhConstants.action.func, function() hs.caffeinate.systemSleep() end }
                }},
                {mhConstants.category.action, 'shift', 'R', "Restart System", {
                     {mhConstants.action.func, function() hs.caffeinate.restartSystem() end }
                }},
                {mhConstants.category.action, 'cmd', 'R', "Shutdown System", {
                     {mhConstants.action.func, function() hs.caffeinate.shutdownSystem() end }
                }},
                {mhConstants.category.action, '', 'S', "Start Screensaver", {
                     {mhConstants.action.func, function() hs.caffeinate.startScreensaver() end }
                }},
                {mhConstants.category.action, 'shift', 'Q', 'Logout', {
                     {mhConstants.action.keycombo, {'cmd', 'shift'}, 'Q'},
                }},
                {mhConstants.category.action, 'cmd', 'Q', 'Logout Immediately', {
                     {mhConstants.action.keycombo, {'cmd', 'alt', 'shift'}, 'Q'},
                }},
                {mhConstants.category.action, '', 'U', "Change User", {
                     {mhConstants.action.func, function() hs.caffeinate.lockScreen() end }
                }},
                {mhConstants.category.action, '', 'V', 'Activity Monitor', {
                     {mhConstants.action.launcher, 'Activity Monitor'},
                }},
                {mhConstants.category.action, '', 'X', 'System Preferences', {
                     {mhConstants.action.launcher, 'System Preferences'},
                }},
            }
        },
    }
end

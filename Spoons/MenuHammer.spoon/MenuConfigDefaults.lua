----------------------------------------------------------------------------------------------------
--------------------------------------- General Config ---------------------------------------------
----------------------------------------------------------------------------------------------------

-- If enabled, the menus will appear over full screen applications.
-- However, the Hammerspoon dock icon will also be disabled (required for fullscreen).
menuShowInFullscreen = false

-- If enabled, a menu bar item will appear that shows what menu is currently being displayed or
-- "idle" if no menu is open.
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
    submenu = {
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
    submenu = '→',
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

    -- Help menu
    local helpMenu = "helpMenu"

    -- Applications Menus
    local applicationMenu = "applicationMenu"
    local utilitiesMenu = "utilitiesMenu"

    -- Browser menus
    local browserMenu = "browserMenu"

    -- Finder menu
    local finderMenu = "finderMenu"

    -- Hammerspoon menu
    local hammerspoonMenu = "hammerspoonMenu"

    -- Media menu
    local mediaMenu = "mediaMenu"

    -- Open files menus
    local openFilesMenu = "openFilesMenu"

    -- Resolution menu
    local resolutionMenu = "resolutionMenu"

    -- System menus
    local systemMenu = "systemMenu"

    menuHammerMenuList = {

        ------------------------------------------------------------------------------------------------
        -- Main Menu
        ------------------------------------------------------------------------------------------------
        mainMenu = {
            parentMenu = nil,
            menuHotkey = {{'alt'}, 'space'},
            menuItems = {
                {cons.cat.submenu, 'shift', '/', 'Help', {
                    {cons.act.menu, helpMenu}
                }},
                {cons.cat.submenu, '', 'A', 'Applications', {
                    {cons.act.menu, applicationMenu}
                }},
                {cons.cat.submenu, '', 'B', 'Browser', {
                    {cons.act.menu, browserMenu}
                }},
                {cons.cat.submenu, '', 'F', 'Finder', {
                    {cons.act.menu, finderMenu}
                }},
                {cons.cat.submenu, '', 'H', 'Hammerspoon', {
                    {cons.act.menu, hammerspoonMenu}
                }},
                {cons.cat.submenu, '', 'M', 'Media Controls', {
                    {cons.act.menu, mediaMenu}
                }},
                {cons.cat.submenu, '', 'O', 'Open Files', {
                    {cons.act.menu, openFilesMenu}
                }},
                {cons.cat.submenu, '', 'R', 'Resolution', {
                    {cons.act.menu, resolutionMenu}
                }},
                {cons.cat.submenu, '', 'S', 'System Preferences', {
                    {cons.act.menu, systemMenu}
                }},
                {cons.cat.action, '', 'space', "Spotlight", {
                    {cons.act.keycombo, {'cmd'}, 'space'}
                }},
            }
        },

        ------------------------------------------------------------------------------------------------
        -- Help Menu
        ------------------------------------------------------------------------------------------------
        helpMenu = {
            parentMenu = mainMenu,
            menuHotkey = nil,
            menuItems = {
                {cons.cat.action, '', 'H', "Hammerspoon Manual", {
                    {cons.act.func, function()
                          hs.doc.hsdocs.forceExternalBrowser(true)
                          hs.doc.hsdocs.moduleEntitiesInSidebar(true)
                          hs.doc.hsdocs.help()
                    end }
                }},
                {cons.cat.action, '', 'M', "MenuHammer Documentation", {
                    {cons.act.openurl, 'https://github.com/FryJay/MenuHammer'},
                }},
            }
        },

        ------------------------------------------------------------------------------------------------
        -- Application Menu
        ------------------------------------------------------------------------------------------------
        applicationMenu = {
            parentMenu = mainMenu,
            menuHotkey = {{'cmd', 'alt', 'ctrl'}, 'a'},
            menuItems = {
                {cons.cat.action, '', 'A', "App Store", {
                    {cons.act.launcher, 'App Store'}
                }},
                {cons.cat.action, '', 'C', "Chrome", {
                    {cons.act.launcher, 'Google Chrome'}
                }},
                {cons.cat.action, '', 'D', "Microsoft Remote Desktop", {
                    {cons.act.launcher, 'Microsoft Remote Desktop'}
                }},
                {cons.cat.action, '', 'F', "Finder", {
                    {cons.act.launcher, 'Finder'}
                }},
                {cons.cat.action, '', 'H', "Firefox", {
                    {cons.act.launcher, 'Firefox'}
                }},
                {cons.cat.action, '', 'I', "iTerm", {
                    {cons.act.launcher, 'iTerm'}
                }},
                {cons.cat.action, '', 'K', "Karabiner", {
                    {cons.act.launcher, 'Karabiner-Elements'}
                }},
                {cons.cat.action, '', 'L', "Sublime Text", {
                    {cons.act.launcher, 'Sublime Text'}
                }},
                {cons.cat.action, '', 'M', "MacVim", {
                    {cons.act.launcher, 'MacVim'}
                }},
                {cons.cat.action, '', 'S', "Safari", {
                    {cons.act.launcher, 'Safari'}
                }},
                {cons.cat.action, '', 'T', "Terminal", {
                    {cons.act.launcher, 'Terminal'}
                }},
                {cons.cat.submenu, '', 'U', 'Utilities', {
                    {cons.act.menu, utilitiesMenu}
                }},
                {cons.cat.action, '', 'X', "Xcode", {
                    {cons.act.launcher, 'Xcode'}
                }},
            }
        },

        ------------------------------------------------------------------------------------------------
        -- Utilities Menu
        ------------------------------------------------------------------------------------------------
        utilitiesMenu = {
            parentMenu = applicationMenu,
            menuHotkey = nil,
            menuItems = {
                {cons.cat.action, '', 'A', "Activity Monitor", {
                    {cons.act.launcher, 'Activity Monitor'}
                }},
                {cons.cat.action, 'shift', 'A', "Airport Utility", {
                    {cons.act.launcher, 'Airport Utility'}
                }},
                {cons.cat.action, '', 'C', "Console", {
                    {cons.act.launcher, 'Console'}
                }},
                {cons.cat.action, '', 'D', "Disk Utility", {
                    {cons.act.launcher, 'Disk Utility'}
                }},
                {cons.cat.action, '', 'K', "Keychain Access", {
                    {cons.act.launcher, 'Keychain Access'}
                }},
                {cons.cat.action, '', 'S', "System Information", {
                    {cons.act.launcher, 'System Information'}
                }},
                {cons.cat.action, '', 'T', "Terminal", {
                    {cons.act.launcher, 'Terminal'}
                }},
            }
        },

        ------------------------------------------------------------------------------------------------
        -- Browser Menu
        ------------------------------------------------------------------------------------------------
        browserMenu = {
            parentMenu = mainMenu,
            meunHotkey = nil,
            menuItems = {
                {cons.cat.action, '', 'C', "Chrome", {
                    {cons.act.launcher, 'Google Chrome'}
                }},
                {cons.cat.action, '', 'F', "Firefox", {
                    {cons.act.launcher, 'Firefox'}
                }},
                {cons.cat.action, '', 'S', "Safari", {
                    {cons.act.launcher, 'Safari'}
                }},
            }
        },

        ------------------------------------------------------------------------------------------------
        -- Finder Menu
        ------------------------------------------------------------------------------------------------
        finderMenu = {
            parentMenu = mainMenu,
            menuHotkey = nil,
            menuItems = {
                {cons.cat.action, '', 'A', 'Applications Folder', {
                    {cons.act.launcher, 'Finder'},
                    {cons.act.keycombo, {'cmd', 'shift'}, 'a'},
                }},
                {cons.cat.action, 'shift', 'A', 'Airdrop', {
                    {cons.act.launcher, 'Finder'},
                    {cons.act.keycombo, {'cmd', 'shift'}, 'r'},
                }},
                {cons.cat.action, '', 'C', 'Computer', {
                    {cons.act.launcher, 'Finder'},
                    {cons.act.keycombo, {'cmd', 'shift'}, 'c'},
                }},
                {cons.cat.action, '', 'D', 'Desktop', {
                    {cons.act.launcher, 'Finder'},
                    {cons.act.keycombo, {'cmd', 'shift'}, 'd'},
                }},
                {cons.cat.action, 'shift', 'D', 'Downloads', {
                    {cons.act.launcher, 'Finder'},
                    {cons.act.keycombo, {'cmd', 'alt'}, 'l'},
                }},
                {cons.cat.action, '', 'F', "Finder", {
                    {cons.act.launcher, 'Finder'}
                }},
                {cons.cat.action, '', 'G', 'Go to Folder...', {
                    {cons.act.launcher, 'Finder'},
                    {cons.act.keycombo, {'cmd', 'shift'}, 'g'},
                }},
                {cons.cat.action, '', 'H', 'Home', {
                    {cons.act.launcher, 'Finder'},
                    {cons.act.keycombo, {'cmd', 'shift'}, 'h'},
                }},
                {cons.cat.action, 'shift', 'H', 'Hammerspoon', {
                    {cons.act.launcher, 'Finder'},
                    {cons.act.keycombo, {'cmd', 'shift'}, 'g'},
                    {cons.act.typetext, '~/.hammerspoon\n'},
                }},
                {cons.cat.action, '', 'I', 'iCloud Drive', {
                    {cons.act.launcher, 'Finder'},
                    {cons.act.keycombo, {'cmd', 'shift'}, 'i'},
                }},
                {cons.cat.action, '', 'K', 'Connect to Server...', {
                    {cons.act.launcher, 'Finder'},
                    {cons.act.keycombo, {'cmd'}, 'K'},
                }},
                {cons.cat.action, '', 'L', 'Library', {
                    {cons.act.launcher, 'Finder'},
                    {cons.act.keycombo, {'cmd', 'shift'}, 'l'},
                }},
                {cons.cat.action, '', 'N', 'Network', {
                    {cons.act.launcher, 'Finder'},
                    {cons.act.keycombo, {'cmd', 'shift'}, 'k'},
                }},
                {cons.cat.action, '', 'O', 'Documents', {
                    {cons.act.launcher, 'Finder'},
                    {cons.act.keycombo, {'cmd', 'shift'}, 'o'},
                }},
                {cons.cat.action, '', 'R', 'Recent', {
                    {cons.act.launcher, 'Finder'},
                    {cons.act.keycombo, {'cmd', 'shift'}, 'f'},
                }},
                {cons.cat.action, '', 'U', 'Utilities', {
                    {cons.act.launcher, 'Finder'},
                    {cons.act.keycombo, {'cmd', 'shift'}, 'u'},
                }},
            }
        },

        ------------------------------------------------------------------------------------------------
        -- Hammerspoon Menu
        ------------------------------------------------------------------------------------------------
        hammerspoonMenu = {
            parentMenu = mainMenu,
            menuHotkey = nil,
            menuItems = {
                {cons.cat.action, '', 'C', "Hammerspoon Console", {
                    {cons.act.func, function() hs.toggleConsole() end }
                }},
                {cons.cat.action, '', 'H', "Hammerspoon Manual", {
                    {cons.act.func, function()
                          hs.doc.hsdocs.forceExternalBrowser(true)
                          hs.doc.hsdocs.moduleEntitiesInSidebar(true)
                          hs.doc.hsdocs.help()
                    end }
                }},
                {cons.cat.action, '', 'R', "Reload Hammerspoon", {
                    {cons.act.func, function() hs.reload() end }
                }},
                {cons.cat.action, '', 'Q', "Quit Hammerspoon", {
                    {cons.act.func, function() os.exit() end }
                }},
            }
        },

        ------------------------------------------------------------------------------------------------
        -- Media Menu
        ------------------------------------------------------------------------------------------------
        mediaMenu = {
            parentMenu = mainMenu,
            menuHotkey = nil,
            menuItems = {
                {cons.cat.action, '', 'A', "iTunes", {
                    {cons.act.launcher, "iTunes"}
                }},
                {cons.cat.action, '', 'H', "Previous Track", {
                    {cons.act.mediakey, "previous"}
                }},
                {cons.cat.action, '', 'J', "Volume Down", {
                    {cons.act.mediakey, "volume", -10}
                }},
                {cons.cat.action, '', 'K', "Volume Up", {
                    {cons.act.mediakey, "volume", 10}
                }},
                {cons.cat.action, '', 'L', "Next Track", {
                    {cons.act.mediakey, "next"}
                }},
                {cons.cat.action, '', 'X', "Mute/Unmute", {
                    {cons.act.mediakey, "mute"}
                }},
                {cons.cat.action, '', 'S', "Play/Pause", {
                    {cons.act.mediakey, "playpause"}
                }},
                {cons.cat.action, '', 'I', "Brightness Down", {
                    {cons.act.mediakey, "brightness", -10}
                }},
                {cons.cat.action, '', 'O', "Brightness Up", {
                    {cons.act.mediakey, "brightness", 10}
                }},
            }
        },

        ------------------------------------------------------------------------------------------------
        -- Open Files Menu
        ------------------------------------------------------------------------------------------------
        openFilesMenu = {
            parentMenu = mainMenu,
            menuHotkey = nil,
            menuItems = {
                {cons.cat.action, '', 'C', 'MenuHammer Custom Config', {
                     {cons.act.openfile, "~/.hammerspoon/menuHammerCustomConfig.lua"},
                }},
                {cons.cat.action, '', 'D', 'MenuHammer Default Config', {
                     {cons.act.openfile, "~/.hammerspoon/Spoons/MenuHammer.spoon/MenuConfigDefaults.lua"},
                }},
                {cons.cat.action, '', 'H', 'Hammerspoon init.lua', {
                     {cons.act.openfile, "~/.hammerspoon/init.lua"},
                }},
            }
        },

        ------------------------------------------------------------------------------------------------
        -- Resolution Menu
        ------------------------------------------------------------------------------------------------
        resolutionMenu = {
            parentMenu = mainMenu,
            menuHotkey = nil,
            menuItems = resolutionMenuItems
        },

        ------------------------------------------------------------------------------------------------
        -- System Menu
        ------------------------------------------------------------------------------------------------
        systemMenu = {
            parentMenu = mainMenu,
            menuHotkey = nil,
            menuItems = {
                {cons.cat.action, 'shift', 'F', "Force Quit Frontmost App", {
                    {cons.act.system, cons.sys.forcequit},
                }},
                {cons.cat.action, '', 'L', "Lock Screen", {
                    {cons.act.system, cons.sys.lockscreen},
                }},
                {cons.cat.action, 'shift', 'R', "Restart System", {
                    {cons.act.system, cons.sys.restart, true},
                }},
                {cons.cat.action, '', 'S', "Start Screensaver", {
                    {cons.act.system, cons.sys.screensaver},
                }},
                {cons.cat.action, 'shift', 'S', "Shutdown System", {
                    {cons.act.system, cons.sys.shutdown, true},
                }},
                {cons.cat.action, '', 'Q', 'Logout', {
                    {cons.act.system, cons.sys.logout}
                }},
                {cons.cat.action, 'shift', 'Q', 'Logout Immediately', {
                    {cons.act.system, cons.sys.logoutnow},
                }},
                {cons.cat.action, '', 'U', "Switch User", {
                    {cons.act.system, cons.sys.switchuser, true},
                }},
                {cons.cat.action, '', 'V', 'Activity Monitor', {
                    {cons.act.launcher, 'Activity Monitor'},
                }},
                {cons.cat.action, '', 'X', 'System Preferences', {
                    {cons.act.launcher, 'System Preferences'},
                }},
            }
        },
    }
end

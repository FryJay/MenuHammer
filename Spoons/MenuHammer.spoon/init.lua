--- === MenuHammer ===
---
--- Menuing system inspired by Spacemacs
---

----------------------------------------------------------------------------------------------------
---------------------------------- Menuhammer Definition -------------------------------------------
----------------------------------------------------------------------------------------------------

local mh = {}
mh.__index = mh

-- Metadata
mh.name = "MenuHammer"
mh.version = "0.3"
mh.author = "FryJay <darin.j.fry@gmail.com>"
mh.homepage = "https://github.com/FryJay/MenuHammer"
mh.license = "MIT - https://opensource.org/licenses/MIT"

mh.spoonPath = hs.spoons.scriptPath()

-- Setup the menu manager
MenuManager = dofile(mh.spoonPath.."/MenuManager.lua")

mh.menuManager = nil

----------------------------------------------------------------------------------------------------
------------------------------------------ Config file ---------------------------------------------
----------------------------------------------------------------------------------------------------

-- Load the defaults
dofile(mh.spoonPath.."/MenuConfigDefaults.lua")

-- Load the custom config
menuCustomConfig = hs.fs.pathToAbsolute(hs.configdir .. '/menuHammerCustomConfig.lua')

if menuCustomConfig then
    require "menuHammerCustomConfig"
end

----------------------------------------------------------------------------------------------------
----------------------------------------- Apply options --------------------------------------------
----------------------------------------------------------------------------------------------------

-- Determine if menus should appear over fullscreen applications.
if menuShowInFullscreen then
    -- Hide the dock icon.  This is necessary for the menu to appear over full screen apps.
    hs.dockicon.hide()
else
    hs.dockicon.show()
end

-- Determine if the menu bar item should be shown
if showMenuBarItem then
    -- The menu bar item to show current status
    menuBarItem = hs.menubar.new()

    -- Make it so that clicking on the menu bar item results in a reload of Hammerspoon
    menuBarItem:setClickCallback(function() hs.reload() end)
end

----------------------------------------------------------------------------------------------------
---------------------------------------- Menuhammer Init -------------------------------------------
----------------------------------------------------------------------------------------------------

function mh:init()

    print("MenuHammer initializing")

    assert(menuHammerToggleKey, "No toggle key set")
    assert(menuHammerMenuList, "No menu list configured.")
    assert(menuItemColors, "No menu item colors defined.")
    assert(menuItemPrefix, "No menu item prefixes defined.")

    mh.menuManager = MenuManager.new(menuHammerToggleKey,
                                     menuHammerMenuList,
                                     menuItemColors,
                                     menuItemPrefix,
                                     showMenuBarItem)

    assert(mh.menuManager, "Menu manager is nil")
end

function mh:enter()

    print("MenuHammer is activating")

    mh.menuManager:enter()
end

----------------------------------------------------------------------------------------------------
---------------------------------------- End Communication -----------------------------------------
----------------------------------------------------------------------------------------------------

-- Return the mh object.
return mh

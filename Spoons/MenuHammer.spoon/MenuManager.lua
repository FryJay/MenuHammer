----------------------------------------------------------------------------------------------------
--------------------------------- MenuManager Definition -------------------------------------------
----------------------------------------------------------------------------------------------------

-- This class is used for managing all the menus.  It stores the menu definitions, keeps track of
-- which menu is open and provides the functionality to close and open menus.

local MenuManager = {}
MenuManager.__index = MenuManager

-- The menu bar item
MenuManager.menuBarItem = nil

MenuManager.canvas = nil
MenuManager.activeMenu = nil

MenuManager.menuItems = {}
MenuManager.storedValues = {}

MenuManager.rootMenu = nil

-- Import the Menu class
Menu = dofile(hs.spoons.scriptPath() .. "/Menu.lua")
MenuCanvas = dofile(hs.spoons.scriptPath() .. "/MenuCanvas.lua")
OSMenuBarItem = dofile(hs.spoons.scriptPath() .. "/OSMenuBarItem.lua")

----------------------------------------------------------------------------------------------------
--------------------------------------- MenuManager Init -------------------------------------------
----------------------------------------------------------------------------------------------------

function MenuManager.new()

    print("Creating menu manager")

    -- Create the new object
    local self = setmetatable({}, MenuManager)

    self.menuBarItem = OSMenuBarItem.new(showMenuBarItem)

    return self
end

----------------------------------------------------------------------------------------------------
-- Enter/Activate the menu manager
function MenuManager:enter()

    print("Entering menu manager")

    -- Create the root menu
    self.rootMenu = hs.hotkey.modal.new(
        menuHammerToggleKey[1],
        menuHammerToggleKey[2],
        'Initialize Modal Environment')

    -- Bind the root menu to the configured key
    self.rootMenu:bind(menuHammerToggleKey[1],
                       menuHammerToggleKey[2],
                       "Reset Modal Environment",
                       function() self.rootMenu:exit() end)

    self.canvas = MenuCanvas.new()

    -- Build the menus
    self:populateMenus()

    -- Activate the root menu
    self.rootMenu:enter()
end

----------------------------------------------------------------------------------------------------
-- Populate Menus
function MenuManager:populateMenus()
    print("Populating menus")
    for menuName, menuConfig in pairs(menuHammerMenuList) do
        -- If a parent menu is provided, ensure it exists
        if menuConfig.parentMenu ~= nil then
            assert(menuHammerMenuList[menuConfig.parentMenu],
                   "Parent menu for " .. menuName .. " does not exist.")
        end

        -- Create the menu
        self:createMenu(menuName,
                        menuConfig.parentMenu,
                        menuConfig.menuHotkey,
                        menuConfig.menuItems)
    end
end

----------------------------------------------------------------------------------------------------
-- Create menu
function MenuManager:createMenu(menuName,
                                parentMenu,
                                menuHotkey,
                                menuItems)

    assert(menuName, "Menu name is nil")
    assert(menuItems, "Menu items is nil for " .. menuName)

    -- print("Creating menu: " .. menuName)

    local newMenu = Menu.new(menuName,
                             hs.hotkey.modal.new(),
                             parentMenu,
                             menuHotkey,
                             menuItems,
                             self)

    assert(newMenu, "Did not receive a new menu for " .. menuName)

    -- If a key combination was provided, bind it to the root menu.
    if menuHotkey ~= nil then
        print("Adding menu hotkey to " .. menuName)
        assert(self.rootMenu, "Menu manager root menu is nil")
        self.rootMenu:bind(menuHotkey[1],
                           menuHotkey[2],
                           "Open " .. menuName,
                           function() self:switchMenu(menuName) end)
    end

    menuHammerMenuList[menuName] = newMenu
end

----------------------------------------------------------------------------------------------------
-- Check for menu existence
function MenuManager:checkMenuExists(menuName)

    assert(menuName, "No menu name provided")

    if menuHammerMenuList[menuName] ~= nil then
        return true
    end

    return false
end

----------------------------------------------------------------------------------------------------
----------------------------------------- Menu Controls --------------------------------------------
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Switch menu
function MenuManager:switchMenu(menuName)
    assert(menuName, "Menu name is nil")
    print("")
    print("Switching to new menu: " .. menuName)
    print("")

    -- Close the open menu, if any
    self:closeMenu()

    -- Show the menu
    self:openMenu(menuName)
end

----------------------------------------------------------------------------------------------------
-- Close menus
function MenuManager:closeMenu()

    print("Closing menus")
    -- Shut off the active menu
    if self.activeMenu ~= nil then
        menuHammerMenuList[self.activeMenu]:exit()
    end
    self.activeMenu = nil

    self.canvas:hide()

    -- Reset the menu bar item
    self.menuBarItem:setMenuBarText(nil)
end

----------------------------------------------------------------------------------------------------
-- Show menu
function MenuManager:openMenu(menuName)

    assert(menuName, "Menu name is nil")
    assert(menuHammerMenuList[menuName], "No menu named " .. menuName)

    print("Showing menu " .. menuName)

    -- Show the menu name on the macOS menu bar
    self.menuBarItem:setMenuBarText(menuName)

    -- Set the active menu
    self.activeMenu = menuName

    -- Retrieve the menu
    local currentMenu = menuHammerMenuList[menuName]
    assert(currentMenu, "Menu " .. menuName .. " does not exist")

    self.canvas:enter(currentMenu)
end

----------------------------------------------------------------------------------------------------
-- Reload the current menu
function MenuManager:reloadMenu()
    self:switchMenu(self.activeMenu)
end

----------------------------------------------------------------------------------------------------
-- Alert MenuHammer an item was selected
function MenuManager:itemActivated(itemType, remainOpen)
    if not remainOpen and (itemType == "action" or itemType == "exit") then
        self:closeMenu()
    end
end

return MenuManager

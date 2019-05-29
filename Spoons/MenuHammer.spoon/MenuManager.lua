
----------------------------------------------------------------------------------------------------
--------------------------------- MenuManager Definition -------------------------------------------
----------------------------------------------------------------------------------------------------

-- This class is used for managing all the menus.  It stores the menu definitions, keeps track of
-- which menu is open and provides the functionality to close and open menus.

local MenuManager = {}
MenuManager.__index = MenuManager

-- The key that will open the menu
MenuManager.activationKey = {}

-- The table of menus and menu items
MenuManager.menuList = {}

-- The colors to use for showing menus
MenuManager.menuColors = {}

-- The prefixes to use for menu items
MenuManager.menuPrefixes = {}

-- Whether or not to show an item on the macOS menu bar
MenuManager.showMenuBarItems = false

-- The menu bar item
MenuManager.menuBarItem = nil

MenuManager.canvas = nil
MenuManager.activeMenu = nil

MenuManager.menuItems = {}
MenuManager.storedValues = {}

MenuManager.rootMenu = nil

MenuManager.spoonPath = hs.spoons.scriptPath()

-- Import the Menu class
Menu = dofile(MenuManager.spoonPath .. "/Menu.lua")

-- Import support methods
dofile(MenuManager.spoonPath.."/Support.lua")

----------------------------------------------------------------------------------------------------
--------------------------------------- MenuManager Init -------------------------------------------
----------------------------------------------------------------------------------------------------

function MenuManager.new(activationKey,
                         menuList,
                         menuColors,
                         menuPrefixes,
                         showMenuBarItem)

    print("Creating menu manager")

    -- Ensure we have the needed values.  showMenuBarItems will default to false.
    assert(activationKey, "No menu activation key provided")
    assert(menuList, "No menu list provided")
    assert(menuColors, "No menu colors provided")
    assert(menuPrefixes, "No menu prefixes provided")

    -- Create the new object
    local self = setmetatable({}, MenuManager)

    -- Set the provided values
    self.activationKey = activationKey
    self.menuList = menuList
    self.menuColors = menuColors
    self.menuPrefixes = menuPrefixes
    self.showMenuBarItem = showMenuBarItem

    return self
end

----------------------------------------------------------------------------------------------------
-- Enter/Activate the menu manager
function MenuManager:enter()

    print("Entering menu manager")

    -- Create the root menu
    self.rootMenu = hs.hotkey.modal.new(
        self.activationKey[1],
        self.activationKey[2],
        'Initialize Modal Environment')

    -- Bind the root menu to the configured key
    self.rootMenu:bind(self.activationKey[1],
                       self.activationKey[2],
                       "Reset Modal Environment",
                       function() self.rootMenu:exit() end)

    -- Initialize the canvas and give it the default background color.
    self.canvas = hs.canvas.new({x = 0, y = 0, w = 0, h = 0})
    self.canvas:level(hs.canvas.windowLevels.tornOffMenu)
    self.canvas[1] = {
        type = "rectangle",
        action = "fill",
        fillColor = {hex = menuItemColors.default.background, alpha = 0.95},
    }

    -- Determine if the menu bar item should be shown
    if self.showMenuBarItem then
        -- The menu bar item to show current status
        self.menuBarItem = hs.menubar.new()

        self.menuBarItem:setMenu(
            {
                { title = "Reload config", fn = function() hs.reload() end }
            }
        )

        -- Clear the menu bar text
        self:setMenuBarText(nil)
    end

    -- Build the menus
    self:populateMenus()

    -- Activate the root menu
    self.rootMenu:enter()
end

----------------------------------------------------------------------------------------------------
-- Populate Menus
function MenuManager:populateMenus()
    print("Populating menus")
    for menuName, menuConfig in pairs(self.menuList) do
        -- If a parent menu is provided, ensure it exists
        if menuConfig.parentMenu ~= nil then
            assert(self.menuList[menuConfig.parentMenu],
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

    self.menuList[menuName] = newMenu
end

----------------------------------------------------------------------------------------------------
-- Check for menu existence
function MenuManager:checkMenuExists(menuName)

    assert(menuName, "No menu name provided")

    if self.menuList[menuName] ~= nil then
        return true
    end

    return false
end

----------------------------------------------------------------------------------------------------
-- Get number of rows
function MenuManager:getNumberOfRows(menuItems, numberOfColumns)

    local numberOfRows = math.ceil(tableLength(menuItems) / numberOfColumns)

    if numberOfRows < menuMinNumberOfRows then
        numberOfRows = menuMinNumberOfRows
    end

    return numberOfRows
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
        self.menuList[self.activeMenu]:exit()
    end
    self.activeMenu = nil

    -- Clear off the canvas and hide it
    for i = 2, #self.canvas do
        self.canvas:removeElement(2)
    end
    self.canvas:hide()

    -- Reset the menu bar item
    self:setMenuBarText(nil)
end

----------------------------------------------------------------------------------------------------
-- Show menu
function MenuManager:openMenu(menuName)

    assert(menuName, "Menu name is nil")
    assert(self.menuList[menuName], "No menu named " .. menuName)

    print("Showing menu " .. menuName)

    -- Show the menu name on the macOS menu bar
    self:setMenuBarText(menuName)

    -- Set the active menu
    self.activeMenu = menuName

    -- Retrieve the menu
    local currentMenu = self.menuList[menuName]
    assert(currentMenu, "Menu " .. menuName .. " does not exist")

    -- Enter the menu
    currentMenu:enter()

    -- Get the menu frame from the menu
    self.canvas:frame(currentMenu:getMenuFrame())

    -- Retrieve the canvases from the menu
    local newMenuCanvases = currentMenu:getMenuDisplay()

    -- Append the new canvases
    for _, newCanvas in pairs(newMenuCanvases) do
        table.insert(self.canvas, newCanvas)
    end

    -- Show the menu
    self.canvas:show()
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

----------------------------------------------------------------------------------------------------
----------------------------------------- Menu Bar Item --------------------------------------------
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Set the menu bar text
function MenuManager:setMenuBarText(text)

    if self.showMenuBarItem then
        local newText = text
        local backgroundColor = {hex = menuItemColors.menuBarActive.background, alpha = 0.95}
        local textColor = {hex = menuItemColors.menuBarActive.text, alpha = 0.95}

        if text == nil then
            newText = "idle"
            backgroundColor = {hex = menuItemColors.menuBarIdle.background, alpha = 0.95}
            textColor = {hex = menuItemColors.menuBarIdle.text, alpha = 0.95}
        end

        self.menuBarItem:setTitle(hs.styledtext.new(newText, {color = textColor,
                                                        backgroundColor = backgroundColor}))
    end
end

return MenuManager

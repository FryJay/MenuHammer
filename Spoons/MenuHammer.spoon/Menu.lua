
----------------------------------------------------------------------------------------------------
---------------------------------------- Menu Definition -------------------------------------------
----------------------------------------------------------------------------------------------------

local Menu = {}
Menu.__index = Menu

Menu.name = nil
Menu.menuItemDefinitions = nil
Menu.modal = nil
Menu.hotkey = nil
Menu.parentMenu = nil

Menu.menuManager = nil
Menu.numberOfRows = nil
Menu.numberOfColumns = nil

Menu.windowHeight = nil
Menu.entryWidth = nil
Menu.entryHeight = nil

-- Internal function used to find our location, so we know where to load files from
local function scriptPath()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
MenuItem = dofile(scriptPath() .. "/MenuItem.lua")

----------------------------------------------------------------------------------------------------
-- Constructor
function Menu.new(menuName,
                  modal,
                  parentMenu,
                  hotkey,
                  menuItemDefinitions,
                  menuManager)

    assert(menuName, "Menu name is nil")
    assert(menuItemDefinitions, "Menu " .. menuName .. " has no menu item definitions")
    assert(menuManager, "Menu " .. menuName .. " has nil manager")

    local self = setmetatable({}, Menu)

    self.name = menuName
    self.menuItemDefinitions = menuItemDefinitions
    self.modal = modal
    self.hotkey = hotkey
    self.parentMenu = parentMenu
    self.menuManager = menuManager

    self.menuItems = {}

    self:buildMenu()

    return self
end

----------------------------------------------------------------------------------------------------
----------------------------------------- Modal Access ---------------------------------------------
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Enter the modal
function Menu:enter()
    self.modal:enter()
end

----------------------------------------------------------------------------------------------------
-- Exit the modal
function Menu:exit()
    self.modal:exit()
end

----------------------------------------------------------------------------------------------------
-- Get the keys from the menu modal.
function Menu:keys()
    return self.modal.keys
end

----------------------------------------------------------------------------------------------------
----------------------------------------- Build Menu -----------------------------------------------
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Build the menu
function Menu:buildMenu()

    assert(self.menuItemDefinitions, "Menu " .. self.name .. " has no menu items")
    assert(self.menuManager, "Menu " .. self.name .. " has nil menu manager")

    -- Set the number of columns and number of rows
    self.numberOfColumns = menuNumberOfColumns
    self.numberOfRows = math.ceil(tableLength(self.menuItemDefinitions) / (self.numberOfColumns - 1))

    -- Make sure we have the minimum number of rows
    if self.numberOfRows < menuMinNumberOfRows then
        self.numberOfRows = menuMinNumberOfRows
    end

    -- Set the window height
    self.windowHeight = menuRowHeight * self.numberOfRows

    -- Set the entry width
    self.entryWidth = 1 / self.numberOfColumns

    -- Set the entry height
    self.entryHeight = 1 / self.numberOfRows

    -- Build the menu items
    self:buildMenuItemList()
end

----------------------------------------------------------------------------------------------------
-- Build the list of menu items
function Menu:buildMenuItemList()

    -- Start with an exit button
    local menuItemList = {
        {cons.cat.exit, '', 'escape', 'Exit', {
             {cons.act.func, function() self.menuManager:closeMenu() end }
        }},
    }

    -- If there is a parent menu, append a back button
    if self.parentMenu ~= nil then
        table.insert(
            menuItemList,
            {cons.cat.back, '', 'delete', 'Parent Menu', {
                 {cons.act.func, function() self.menuManager:switchMenu(self.parentMenu) end }
            }}
        )
    end

    -- Add blank spaces to the first column until it's full
    while #menuItemList < self.numberOfRows do
        table.insert(
            menuItemList,
            {cons.cat.navigation, nil, nil, ''}
        )
    end

    -- Add all the defined menu items
    for _, newMenuItem in pairs(self.menuItemDefinitions) do table.insert(menuItemList, newMenuItem) end

    self.menuItemDefinitions = menuItemList

    self:createMenuItems()
end

----------------------------------------------------------------------------------------------------
-- Create the menu items
function Menu:createMenuItems()

    local boundKeys = {}

    -- Loop through the menu items
    for index, menuItem in ipairs(self.menuItemDefinitions) do

        -- Adjust the index to 0 indexed
        local adjustedIndex = index - 1

        -- Get the key combo and description
        local category = menuItem[1]
        local modifier = nil
        local key = nil
        local desc
        local commands
        -- Default to closing the menu
        local remainOpen = false
        if category ~= cons.cat.display then
            modifier = menuItem[2]
            key = menuItem[3]
            desc = menuItem[4]
            commands = menuItem[5]
            -- If remain open is set then use it
            if menuItem[6] ~= nil then
                remainOpen = menuItem[6]
            end
        else
            desc = menuItem[2]
            commands = menuItem[3]
        end

        -- Validate that the key isn't already bound on this menu
        if key ~= nil then
            local keyCombo = modifier .. key
            assert(boundKeys[keyCombo] == nil, "Key " .. keyCombo .. " double bound")
            boundKeys[keyCombo] = true
        end

        -- Calculate the row number
        local column = math.floor(adjustedIndex / self.numberOfRows)

        -- Calculate the column number
        local row = adjustedIndex % self.numberOfRows

        -- Create the menuItem object
        self:createMenuItem(category,
                            modifier,
                            key,
                            desc,
                            index,
                            row,
                            column,
                            commands,
                            remainOpen)
    end
end

----------------------------------------------------------------------------------------------------
-- Create a single menu item
function Menu:createMenuItem(category,
                             modifier,
                             key,
                             description,
                             index,
                             row,
                             column,
                             commands,
                             remainOpen)

    local newMenuItem = MenuItem.new(category,
                                     modifier,
                                     key,
                                     description,
                                     row,
                                     column,
                                     self.entryWidth,
                                     self.entryHeight,
                                     commands,
                                     self.menuManager,
                                     self)

    assert(newMenuItem, self.name .. " has nil menu item")

    -- Add the menu item to the list
    self.menuItems[index] = newMenuItem

    self:bindToMenu(newMenuItem, function() newMenuItem:runAction() end, remainOpen)
end

----------------------------------------------------------------------------------------------------
-- Bind a single item to the menu
function Menu:bindToMenu(menuItem,
                         pressedFunction,
                         remainOpen)

    if pressedFunction ~= nil then
        assert(type(pressedFunction) == "function",
               "Pressed function is of type " .. type(pressedFunction))
    end

    assert(menuItem, "Menu item is nil")

    -- Alert the menu manager the item was activated
    local preprocessFunction = function() self.menuManager:itemActivated(menuItem.category, remainOpen) end

    local finalFunction = function()

        preprocessFunction()

        -- If a function was provided, run it.
        if pressedFunction ~= nil then
            pressedFunction()
        end
    end

    local displayTitle = menuItem:displayTitle()

    -- If we have a key defined, bind it
    if menuItem.key ~= nil then
        local newModalBind = self.modal:bind(menuItem.modifier,
                                             menuItem.key,
                                             displayTitle,
                                             finalFunction)
        menuItem.desc = newModalBind.keys[tableLength(newModalBind.keys)].msg
    end

end

----------------------------------------------------------------------------------------------------
----------------------------------- Drawing Functions ----------------------------------------------
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Get the frame to put the menu in
function Menu:getMenuFrame()

    local windowHeight = self.windowHeight

    -- Calculate the dimensions using the size of the main screen.
    local cscreen = hs.screen.mainScreen()
    local cres = cscreen:frame()
    local menuFrame = {
        x = cres.x,
        y = cres.y + (cres.h - windowHeight),
        w = cres.w,
        h = windowHeight
    }

    return menuFrame
end

----------------------------------------------------------------------------------------------------
-- Return the canvases to display
function Menu:getMenuDisplay()

    assert(self.menuItems, "Menu " .. self.name .. " has no menu items defined")

    local newCanvases = {}

    -- Loop through each menu item and build them
    for _, menuItem in pairs(self.menuItems) do

        -- Create the background canvas
        local menuItemCanvases = menuItem:getBackgroundCanvas()

        -- Create the text canvas, if necessary
        if menuItem.desc ~= nil then
            table.insert(menuItemCanvases,
                         menuItem:getTextCanvas()
            )
        end

        -- Append the new canvases
        for _, newCanvas in pairs(menuItemCanvases) do table.insert(newCanvases, newCanvas) end
    end

    return newCanvases
end

return Menu

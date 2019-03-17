
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
MenuAction = dofile(scriptPath() .. "/MenuAction.lua")

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
        local modifier = menuItem[2]
        local key = menuItem[3]
        local desc = menuItem[4]

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

        -- Get the commands to execute
        local commands = menuItem[5]

        local commandFunctions = {}

        -- Loop through the commands
        if commands ~= nil then
          for _, command in ipairs(commands) do
              local menuItemAction = command[1]
              local subMenuName = command[2]

              -- If the command is to load a menu, ensure the menu exists.
              if menuItemAction == cons.act.menu then
                  assert(subMenuName, self.name .. " has nil submenu identifier")
                  assert(self.menuManager:checkMenuExists(subMenuName),
                        "Menu " .. self.name .. " has submenu " .. subMenuName .. " which does not exist")
              end
              table.insert(commandFunctions, self:getActionFunction(desc, command))
          end
        end

        local finalFunction = function()
            for _, commandFunction in ipairs(commandFunctions) do
                -- If command returns false, don't process any more
                if not commandFunction() then
                    break
                end
            end
        end

        -- Create the menuItem object
        self:createMenuItem(category,
                            modifier,
                            key,
                            desc,
                            index,
                            row,
                            column,
                            finalFunction)
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
                             action)

    local newMenuItem = MenuItem.new(category,
                                     modifier,
                                     key,
                                     description,
                                     row,
                                     column,
                                     self.entryWidth,
                                     self.entryHeight)

    assert(newMenuItem, self.name .. " has nil menu item")

    -- Add the menu item to the list
    self.menuItems[index] = newMenuItem

    self:bindToMenu(newMenuItem, action)
end

----------------------------------------------------------------------------------------------------
-- Bind a single item to the menu
function Menu:bindToMenu(menuItem,
                         pressedFunction)

    if pressedFunction ~= nil then
        assert(type(pressedFunction) == "function",
               "Pressed function is of type " .. type(pressedFunction))
    end

    assert(menuItem, "Menu item is nil")

    -- Alert the menu manager the item was activated
    local preprocessFunction = function() self.menuManager:itemActivated(menuItem.category) end

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

----------------------------------------------------------------------------------------------------
-- Get a function to execute to perform the needed action.
function Menu:getActionFunction(desc, command)

    assert(desc, self.name .. " sent a nil desc")

    local menuAction = MenuAction.new(desc, command, self)

    return menuAction:getActionFunction()

end

return Menu

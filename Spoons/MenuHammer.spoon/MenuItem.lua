----------------------------------------------------------------------------------------------------
------------------------------------ Menu Item Definition ------------------------------------------
----------------------------------------------------------------------------------------------------

local MenuItem = {}
MenuItem.__index = MenuItem

MenuItem.category = nil
MenuItem.modifier = {}
MenuItem.key = nil
MenuItem.desc = nil
MenuItem.prefix = nil

MenuItem.commands = nil
MenuItem.menuManager = nil
MenuItem.menu = nil
MenuItem.canvas = nil

MenuAction = dofile(hs.spoons.scriptPath() .. "/MenuAction.lua")
MenuItemCanvas = dofile(hs.spoons.scriptPath() .. "/MenuItemCanvas.lua")

----------------------------------------------------------------------------------------------------
-- Constructor
function MenuItem.new(category,
                      modifier,
                      key,
                      desc,
                      row,
                      column,
                      width,
                      height,
                      commands,
                      menuManager,
                      menu)

    assert(desc ~= nil, "Description is nil")
    assert(category, "Category name is nil")
    assert(row, desc .. " row is nil")
    assert(column, desc .. " column is nil")

    local self = setmetatable({}, MenuItem)

    self.category = category
    self.modifier = modifier
    self.key = key
    self.desc = desc

    self.commands = commands
    self.menuManager = menuManager
    self.menu = menu

    self.prefix = menuItemPrefix[self.category]
    assert(self.prefix ~= nil, "No prefix found for " .. self.desc .. " with category " .. self.category)

    self.canvas = MenuItemCanvas.new(
        row,
        column,
        width,
        height,
        category)
    return self
end

----------------------------------------------------------------------------------------------------
-- Get the menu item's canvas
function MenuItem:getCanvas()
    self.canvas:setDisplayValue(self:getDisplayValue())
    return self.canvas
end

----------------------------------------------------------------------------------------------------
-- Get a function to perform the needed action(s).
function MenuItem:getActionFunction(desc, command)

    assert(desc, self.desc .. " sent a nil desc")

    local menuAction = MenuAction.new(desc, command, self.menu)

    return menuAction:getActionFunction()
end

----------------------------------------------------------------------------------------------------
-- Run menu item action
function MenuItem:runAction()
    local commandFunctions = {}

    -- Loop through the commands
    if self.commands ~= nil then
      for _, command in ipairs(self.commands) do
          local menuItemAction = command[1]
          local subMenuName = command[2]

          -- If the command is to load a menu, ensure the menu exists.
          if menuItemAction == cons.act.menu then
              assert(subMenuName, self.desc .. " has nil submenu identifier")
              assert(self.menuManager:checkMenuExists(subMenuName),
                    "Menu " .. self.desc .. " has submenu " .. subMenuName .. " which does not exist")
          end
          table.insert(commandFunctions, self:getActionFunction(self.desc, command))
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

    finalFunction()
end

----------------------------------------------------------------------------------------------------
-- Get the title for the menu item
function MenuItem:displayTitle()
    return self.prefix .. " " .. self.desc
end

----------------------------------------------------------------------------------------------------
-- Get the display value to show
function MenuItem:getDisplayValue()
    if self.category ~= cons.cat.display then
        return self.desc
    else
        local displayString = nil
        for _, command in ipairs(self.commands) do
            displayString = command()
        end
        return displayString
    end
end

return MenuItem

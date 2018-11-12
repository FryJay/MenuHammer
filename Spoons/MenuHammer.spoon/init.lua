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
mh.version = "0.2"
mh.author = "FryJay <darin.j.fry@gmail.com>"
mh.homepage = "https://github.com/FryJay/MenuHammer"
mh.license = "MIT - https://opensource.org/licenses/MIT"

-- Internal function used to find our location, so we know where to load files from
local function scriptPath()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
mh.spoonPath = scriptPath()

-- Import the constants and support functions
dofile(mh.spoonPath.."/Support.lua")
Menu = dofile(mh.spoonPath.."/Menu.lua")

mh.canvas = nil
mh.menuList = {}
mh.activeMenu = nil

mh.menuItems = {}
mh.storedValues = {}

mh.rootMenu = nil
mh.interactiveMode = false

----------------------------------------------------------------------------------------------------
------------------------------------------ Config file ---------------------------------------------
----------------------------------------------------------------------------------------------------

dofile(mh.spoonPath.."/MenuConfigDefaults.lua")

menuCustomConfig = hs.fs.pathToAbsolute(hs.configdir .. '/menuHammerCustomConfig.lua')

if menuCustomConfig then
    require "menuHammerCustomConfig"
end

assert(menuItemPrefix, "No menu item prefixes defined.")
assert(menuItemColors, "No menu item colors defined.")
assert(menuHammerMenuList, "No menu list configured.")

mh.menuItemDefinitions = menuHammerMenuList

----------------------------------------------------------------------------------------------------
----------------------------------------- Apply options --------------------------------------------
----------------------------------------------------------------------------------------------------

-- Determine if should show menus over fullscreen applications.
if menuShowInFullscreen then
    -- Hide the dock icon.  This is necessary for the menu to appear over full screen apps.
    hs.dockicon.hide()
else
    hs.dockicon.show()
end

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

    self.rootMenu = hs.hotkey.modal.new(
        menuHammerToggleKey[1],
        menuHammerToggleKey[2],
        'Initialize Modal Environment')

    self.rootMenu:bind(menuHammerToggleKey[1],
                       menuHammerToggleKey[2],
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

    -- Setup the menu bar item
    self.menuBarText(nil)

    -- Build the menus
    self:populateMenus()
end

----------------------------------------------------------------------------------------------------
-- Populate Menus
function mh:populateMenus()
    print("Populating menus")
    for menuName, menuConfig in pairs(self.menuItemDefinitions) do
        -- If a parent menu is provided, ensure it exists
        if parentMenu ~= nil then
            assert(self.menuItemDefinitions[parentMenu], "Parent menu does not exist.")
        end
        self:createMenu(menuName,
                        menuConfig.parentMenu,
                        menuConfig.menuHotkey,
                        menuConfig.menuItems)
    end
end

----------------------------------------------------------------------------------------------------
-- Create menu
function mh:createMenu(menuName,
                               parentMenu,
                               menuHotkey,
                               menuItems)

    assert(menuName, "Menu name is nil")
    assert(menuItems, "Menu items is nil for " .. menuName)

    print("Creating menu: " .. menuName)

    local newMenu = Menu.new(menuName,
                             hs.hotkey.modal.new(),
                             parentMenu,
                             menuHotkey,
                             menuItems,
                             self)

    self.menuList[menuName] = newMenu
end

----------------------------------------------------------------------------------------------------
-- Toggle a menu
function mh:toggleMenu(menuName, showcheat)

    assert(menuName, "Menu name is nil")
    assert(type(menuName) == "string", "Menu name has type " .. type(menuName))

    if not self.interactive and self.activeMenu ~= nil then
        self:closeMenus()
    else
        self:switchMenu(menuName, showcheat)
    end
end

----------------------------------------------------------------------------------------------------
-- Calculate number of rows
function mh:calculateNumberOfRows(menuItems, numberOfColumns)

    local numberOfRows = math.ceil(tableLength(menuItems) / numberOfColumns)

    if numberOfRows < menuMinNumberOfRows then
        numberOfRows = menuMinNumberOfRows
    end

    return numberOfRows
end

----------------------------------------------------------------------------------------------------
-- Turn on the menu UI
function mh:toggleMenuUI(menuName)

    assert(menuName, "Menu name is nil")
    assert(self.menuList[menuName], "No menu named " .. menuName)

    print("Toggling menu " .. menuName)

    -- If the canvas is visible, then just hide it.
    if self.canvas:isShowing() then
        self.canvas:hide()
    else
        -- Retrieve the menu object
        local currentMenu = self.menuList[menuName]
        assert(currentMenu, "No entry for " .. menuName)

        -- Retrieve the menu items
        local currentMenuItems = currentMenu.menuItems
        assert(currentMenuItems, "No menu items for " .. menuName)

        -- Retrieve the control items
        local currentControlItems = currentMenu.controlItems
        assert(currentMenuItems, "No control items for " .. menuName)

        -- Calculate the number of rows we need.
        local numberOfRows = self:calculateNumberOfRows(currentMenuItems, menuNumberOfColumns - 1)

        -- Calculate the height of the entire menu.
        local windowHeight = menuRowHeight * numberOfRows

        -- Calculate the height and width of a menu item in percentage.
        local entryWidth = 1 / menuNumberOfColumns
        local entryHeight = 1 / numberOfRows

        -- Calculate the dimensions using the size of the main screen.
        local cscreen = hs.screen.mainScreen()
        local cres = cscreen:frame()
        self.canvas:frame({
                x = cres.x,
                y = cres.y + (cres.h - windowHeight),
                w = cres.w,
                h = windowHeight
        })

        -- Set the starting canvas number adn the column for control items.
        local canvasNumber = 2
        local controlItemCol = 0

        -- Draw the control items.
        canvasNumber = self:drawControlItems(currentControlItems,
                                             numberOfRows,
                                             controlItemCol,
                                             entryWidth,
                                             entryHeight,
                                             canvasNumber)

        -- Draw the menu items
        self:drawMenuItems(currentMenuItems,
                           numberOfRows,
                           menuNumberOfColumns,
                           entryWidth,
                           entryHeight,
                           canvasNumber)

        self.canvas:show()
    end
end

function mh:drawControlItems(controlItems,
                                      numberOfRows,
                                      columnNumber,
                                      controlItemWidth,
                                      controlItemHeight,
                                      startingCanvasNumber)

    local canvasNumber = startingCanvasNumber

    for controlItemIndex = 0, numberOfRows do
        local currentControlItem = controlItems[controlItemIndex]

        if currentControlItem ~= nil then
            self:drawMenuItem(currentControlItem,
                              currentControlItem.index,
                              columnNumber,
                              canvasNumber,
                              controlItemWidth,
                              controlItemHeight)

            canvasNumber = canvasNumber + 2
        else
            -- Calculate the location of the upper left corner
            local xValue = tostring(columnNumber * controlItemWidth)
            local yValue = tostring(controlItemHeight * controlItemIndex)

            -- Calculate the width and height
            local wValue = tostring(controlItemWidth)
            local hValue = tostring(controlItemHeight)

            self:drawBackground(canvasNumber,
                                menuItemColors.navigation.background,
                                xValue,
                                yValue,
                                wValue,
                                hValue)

            canvasNumber = canvasNumber + 1
        end

    end

    return canvasNumber
end

function mh:drawMenuItems(menuItems,
                                  numberOfRows,
                                  numberOfColumns,
                                  menuItemWidth,
                                  menuItemHeight,
                                  startingCanvasNumber)

    local canvasNumber = startingCanvasNumber

    -- Determine how many cells to draw.
    local numberOfItems = numberOfRows * (menuNumberOfColumns - 1)

    for menuItemIndex = 0, numberOfItems do

        if menuItems[menuItemIndex] ~= nil then

            local menuItem = menuItems[menuItemIndex]

            -- Calculate the row number
            local col = math.floor(menuItem.index / numberOfRows) + 1

            -- Calculate the column number
            local row = menuItem.index % numberOfRows

            self:drawMenuItem(menuItems[menuItemIndex],
                              row,
                              col,
                              canvasNumber,
                              menuItemWidth,
                              menuItemHeight)

            canvasNumber = canvasNumber + 2
        end
    end
end

function mh:drawMenuItem(menuItem,
                                 rowNumber,
                                 columnNumber,
                                 canvasNumber,
                                 entryWidth,
                                 entryHeight)

    assert(menuItem, "Menu item is nil")
    assert(rowNumber, "Row number is nil")
    assert(columnNumber, "Col number is nil")
    assert(canvasNumber, "Canvas number is nil")

    -- print(menuItem.desc .. ' has Index ' .. menuItem.index .. ' and canvas number ' .. canvasNumber)

    -- Calculate the location of the upper left corner
    local xValue = tostring(columnNumber * entryWidth)
    local yValue = tostring(entryHeight * rowNumber)

    -- Calculate the width and height
    local wValue = tostring(entryWidth)
    local hValue = tostring(entryHeight)
    -- print("x: " .. xValue .. " y: " .. yValue .. " w: " .. wValue .." h: " .. hValue)

    -- Draw the background
    self:drawBackground(canvasNumber,
                        menuItem:backgroundColor(),
                        xValue,
                        yValue,
                        wValue,
                        hValue)

    -- Draw the text
    self:drawText(canvasNumber + 1,
                  menuItem.desc,
                  menuItem:textColor(),
                  xValue,
                  yValue,
                  wValue,
                  hValue)
end

----------------------------------------------------------------------------------------------------
-- Draw the background for a menu item.
function mh:drawBackground(canvasNumber,
                                   backgroundColor,
                                   xValue,
                                   yValue,
                                   wValue,
                                   hValue)

    --print("x: " .. xValue .. " y: " .. yValue .. " w: " .. wValue .." h: " .. hValue)
    -- Draw the background
    self.canvas[canvasNumber] = {
        type = "rectangle",
        action = "fill",
        fillColor = {hex = backgroundColor, alpha = 0.95},
        frame = {
            x = xValue,
            y = yValue,
            w = wValue,
            h = hValue
        }
    }
end

----------------------------------------------------------------------------------------------------
-- Draw the text for a menu item.
function mh:drawText(canvasNumber,
                             textString,
                             textColor,
                             xValue,
                             yValue,
                             wValue,
                             hValue)
    -- Draw the text
    self.canvas[canvasNumber] = {
        type = "text",
        text = "    " .. textString,
        textFont = menuItemFont,
        textSize = menuItemFontSize,
        textColor = {hex = textColor, alpha = 1},
        textAlignment = menuItemTextAlign,
        frame = {
            x = xValue,
            y = yValue,
            w = wValue,
            h = hValue
        }
    }
end

----------------------------------------------------------------------------------------------------
----------------------------------------- Menu Controls --------------------------------------------
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Switch menu
function mh:switchMenu(menuName, showUI)
    assert(menuName, "Menu name is nil")
    print("")
    print("Switching to new menu: " .. menuName)
    print("")
    self:closeMenus()

    self:menuBarText(menuName)

    -- Set the active menu
    self.activeMenu = menuName

    -- Enter the menu
    self.menuList[menuName]:enter()

    -- Show the UI if required
    if showUI then
        self:toggleMenuUI(menuName, true)
    end
end

----------------------------------------------------------------------------------------------------
-- Close menus
function mh:closeMenus()

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
    self:menuBarText(nil)
end

----------------------------------------------------------------------------------------------------
----------------------------------------- Menu Bar Item --------------------------------------------
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Set the menu bar text
function mh:menuBarText(text)

    if showMenuBarItem then
        local newText = text
        local backgroundColor = {hex = menuItemColors.menuBarActive.background, alpha = 0.95}
        local textColor = {hex = menuItemColors.menuBarActive.text, alpha = 0.95}

        if text == nil then
            newText = "idle"
            backgroundColor = {hex = menuItemColors.menuBarIdle.background, alpha = 0.95}
            textColor = {hex = menuItemColors.menuBarIdle.text, alpha = 0.95}
        end

        menuBarItem:setTitle(hs.styledtext.new(newText, {color = textColor,
                                                        backgroundColor = backgroundColor}))
    end
end

----------------------------------------------------------------------------------------------------
-- Alert MenuHammer an item was selected
function mh:itemActivated(itemType)
    if itemType == "action" then
        if not mh.interactiveMode then
            mh:closeMenus()
        end
    elseif itemType == "exit" then
        mh:closeMenus()
    end
end

----------------------------------------------------------------------------------------------------
---------------------------------------- End Communication -----------------------------------------
----------------------------------------------------------------------------------------------------

-- Return the mh object.
return mh

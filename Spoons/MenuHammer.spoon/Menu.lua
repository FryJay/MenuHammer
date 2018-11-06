
----------------------------------------------------------------------------------------------------
---------------------------------------- Menu Definition -------------------------------------------
----------------------------------------------------------------------------------------------------

local Menu = {}
Menu.__index = Menu

Menu.hammer = menuHammer

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
                  hammer)

    assert(menuName, "Menu name is nil")

    local self = setmetatable({}, Menu)

    self.name = menuName
    self.menuItemDefinitions = menuItemDefinitions
    self.modal = modal
    self.hotkey = hotkey
    self.parentMenu = parentMenu
    self.hammer = hammer

    -- Initialize the control items and menu items
    self.controlItems = {}
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
----------------------------------------- Build Menu - ---------------------------------------------
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Build the menu
function Menu:buildMenu()

    -- Setup the menu control items
    self:createControlItems()

    -- If menu items were provided, create them.
    if self.menuItemDefinitions ~= nil then
        self:createMenuItems()
    end

    -- If a key combination was provided, bind it to the root menu.
    if self.hotkey ~= nil then
        print("Adding menu hotkey to " .. self.name)
        self.hammer.rootMenu:bind(self.hotkey[1],
                                  self.hotkey[2],
                                  "Open " .. self.name,
                                  function() self.hammer:toggleMenu(self.name, true) end)
    end
end

----------------------------------------------------------------------------------------------------
-- Create the menu control items
function Menu:createControlItems()
    -- Add escape to exit.
    self:createControlItem('exit',
                           '',
                           'escape',
                           'Exit',
                           0)

    -- Add delete for back button.
    if self.parentMenu ~= nil then
        self:createControlItem('back',
                               '',
                               'delete',
                               'Parent Menu',
                               1,
                               function() self.hammer:switchMenu(self.parentMenu, true) end)
    end

end

----------------------------------------------------------------------------------------------------
-- Create a control item
function Menu:createControlItem(category,
                                modifier,
                                key,
                                parentMenu,
                                index,
                                action)

    local newMenuItem = MenuItem.new(category,
                                     modifier,
                                     key,
                                     parentMenu,
                                     index)

    assert(newMenuItem, "Delete menu item nil")

    -- Add the control item to the list
    self.controlItems[index] = newMenuItem

    self:bindToMenu(newMenuItem, action)
end

----------------------------------------------------------------------------------------------------
-- Create the menu items
function Menu:createMenuItems()

    local currentIndex = 0

    -- Loop through the menu items
    for index, menuItem in ipairs(self.menuItemDefinitions) do

        -- Get the key combo and description
        local category = menuItem[1]
        local modifier = menuItem[2]
        local key = menuItem[3]
        local desc = menuItem[4]

        -- Get the commands to run
        local commands = menuItem[5]

        local commandFunctions = {}

        -- Loop through the commands
        for _, command in ipairs(commands) do
            table.insert(commandFunctions, self:getActionFunction(desc, command))
        end

        local finalFunction = function() self:runCommands(commandFunctions) end

        -- Create the menuItem object
        self:createMenuItem(category,
                            modifier,
                            key,
                            desc,
                            currentIndex,
                            finalFunction)

        currentIndex = currentIndex + 1
    end
end

----------------------------------------------------------------------------------------------------
-- Create a single menu item
function Menu:createMenuItem(category,
                             modifier,
                             key,
                             parentMenu,
                             index,
                             action)

    local newMenuItem = MenuItem.new(category,
                                     modifier,
                                     key,
                                     parentMenu,
                                     index)

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

    -- Alert menuHammer the item was activated
    local preprocessFunction = function() self.hammer:itemActivated(menuItem.category) end

    local finalFunction = function()

        preprocessFunction()

        -- If a function was provided, run it.
        if pressedFunction ~= nil then
            pressedFunction()
        end
    end

    local displayTitle = menuItem:displayTitle()

    if menuItem.category ~= mhConstants.category.blank then
        local newModalBind = self.modal:bind(menuItem.modifier,
                                             menuItem.key,
                                             displayTitle,
                                             finalFunction)

        menuItem.desc = newModalBind.keys[tableLength(newModalBind.keys)].msg
    end
end

----------------------------------------------------------------------------------------------------
-- Run shell command
function Menu:runShellCommand(shellCommand)
    assert(shellCommand)

    local commandString = '"' .. shellCommand .. '"'

    local appleScript = "do shell script " .. commandString

    print("Running shell command: " .. appleScript)

    local openFileTask = hs.task.new(
        "/usr/bin/osascript",
        function(exitCode, standardOut, standardError)

            print("Editor exit code: " .. exitCode)
            if exitCode ~= 0 then
                hs.notify.show("FAILED to open file",
                               shellCommand .. " not found.  Check the logs.",
                               "")
            end

            print("Callback standard out: \n" .. standardOut)
            print("Callback standard error: \n" .. standardError)
        end,
        {
            '-e',
            appleScript,
        }
    )

    openFileTask:start()
end

----------------------------------------------------------------------------------------------------
-- Bind open file
function Menu:openEditor(filePath)
    assert(filePath, "No file path provided")
    local openFileFunction = function()

        local commandString = '"sh -c \'' .. menuTextEditor .. ' ' ..
            filePath .. '\'"'

        local appleScript = "do shell script " .. commandString

        print("Running command: " .. appleScript)

        local openFileTask = hs.task.new(
            "/usr/bin/osascript",
            function(exitCode, standardOut, standardError)

                print("Editor exit code: " .. exitCode)
                if exitCode ~= 0 then
                    hs.notify.show("FAILED to open file",
                                   filePath .. " not found.  Check the logs.",
                                   "")
                end

                print("Callback standard out: \n" .. standardOut)
                print("Callback standard error: \n" .. standardError)
            end,
            {
                '-e',
                appleScript,
            }
        )

        openFileTask:start()
    end

    openFileFunction()
end

----------------------------------------------------------------------------------------------------
-- Bind function
function Menu:runScript(scriptName, useAdmin)
    local scriptFunction = function()

        local quotedName = '"' .. scriptName .. '"'
        local commandToRun = "do shell script " .. quotedName
        -- if useAdmin then
        --   commandToRun = commandToRun .. " with administrator privileges"
        -- end

        print("Running script " .. scriptName)
        print("Command: " .. commandToRun)

        local scriptTask = hs.task.new(
            "/usr/bin/osascript",
            function(exitCode, standardOut, standardError)

                print("Exit code: " .. exitCode)
                if exitCode == 0 then
                    hs.notify.show("Execution Complete", "Script " .. scriptName .. " completed successfully.", "")
                else
                    hs.notify.show("Execution FAILED", "Script " .. scriptName .. " failed.  Check the logs.", "")
                end

                print("Callback standard out: \n" .. standardOut)
                print("Callback standard error: \n" .. standardError)
            end,
            {
                "-e",
                commandToRun
            }
        )

        local scriptEnvironment = scriptTask:environment()
        if askpassLocation then
            print("Using askpass: " .. askpassLocation)
            scriptEnvironment.SUDOaSKPASS = askpassLocation
        else
            print("Admin set but no path to askpass")
        end

        scriptTask:setEnvironment(scriptEnvironment)

        scriptTask:start()

    end

    scriptFunction()
end

----------------------------------------------------------------------------------------------------
-- Change resolution
function Menu:changeResolution(resolutionMode)

    local device = hs.screen.mainScreen()

    device:setMode(resolutionMode["w"], resolutionMode["h"], resolutionMode["scale"])
end

----------------------------------------------------------------------------------------------------
-- Launch an application by name or package id.
function Menu:launchApplication(desc, identifier, closeMenu, waitForWindow)

    assert(desc, "Desc is nil")
    assert(identifier, "Identifier is nil for desc " .. desc)
    local appIdentifier = identifier
    if appIdentifier == nil then
        appIdentifier = desc
    end

    print("")
    print("Launching " .. appIdentifier)
    print("")

    -- Launch the application
    hs.application.open(appIdentifier, nil, true)
    -- hs.application.launchOrFocus(appIdentifier)

    -- Default to close or if true is passed.
    if closeMenu == nil or closeMenu then
        self.hammer:closeMenus()
    end
end

----------------------------------------------------------------------------------------------------
-- Bind resizer
function Menu:runResizer(action)

    assert(action, "Action is nil")

    print("Resizing with action " .. action)
    local function hasValue (tab, val)
        for index, value in ipairs(tab) do
            if value == val then
                return true
            end
        end

        return false
    end

    local stepmoveResizers = {mhConstants.resizer.left, mhConstants.resizer.right,
                              mhConstants.resizer.up, mhConstants.resizer.down}
    local moveResizers = {mhConstants.resizer.halfLeft, mhConstants.resizer.halfRight,
                          mhConstants.resizer.halfUp, mhConstants.resizer.halfDown,
                          mhConstants.resizer.northWest, mhConstants.resizer.northEast,
                          mhConstants.resizer.southWest, mhConstants.resizer.southEast,
                          mhConstants.resizer.fullScreen, mhConstants.resizer.centerWindow}
    local stepResizers = {mhConstants.resizer.stepLeft, mhConstants.resizer.stepRight,
                          mhConstants.resizer.stepUp, mhConstants.resizer.stepDown}
    local moveAndResizeResizers = {mhConstants.resizer.expand, mhConstants.resizer.shrink}
    local screenResizers = {mhConstants.resizer.screenLeft, mhConstants.resizer.screenRight,
                            mhConstants.resizer.screenUp, mhConstants.resizer.screenDown,
                            mhConstants.resizer.screenNext}

    local pressedFunction = nil

    if hasValue(stepmoveResizers, action) then
        pressedFunction = function() spoon.WinWin:stepMove(action) end
    elseif hasValue(moveResizers, action) then
        pressedFunction = function() spoon.WinWin:stash() spoon.WinWin:moveAndResize(action) end
    elseif hasValue(moveAndResizeResizers, action) then
        pressedFunction = function() spoon.WinWin:moveAndResize(action) end
    elseif hasValue(screenResizers, action) then
        local newAction = string.sub(action, string.find(action, "_")+1)
        pressedFunction = function() spoon.WinWin:stash() spoon.WinWin:moveToScreen(newAction) end
    elseif action == mhConstants.resizer.undo then
        pressedFunction = function() spoon.WinWin:undo() end
    elseif action == mhConstants.resizer.redo then
        pressedFunction = function() spoon.WinWin:redo() end
    elseif action == mhConstants.resizer.centerCursor then
        pressedFunction = function() spoon.WinWin:centerCursor() end
    elseif hasValue(stepResizers, action) then
        local newAction = string.sub(action, string.find(action, "_")+1)
        pressedFunction = function() spoon.WinWin:stepResize(newAction) end
    end

    if pressedFunction ~= nil then
        pressedFunction()
    end
end

----------------------------------------------------------------------------------------------------
-- Bind music command
function Menu:runMediaCommand(action, quantity)

    local mediaCommand = nil

    if action == "previous" then
        mediaCommand = function() hs.itunes:previous() end
    elseif action == "next" then
        mediaCommand = function() hs.itunes:next() end
    elseif action == "playpause" then
        mediaCommand = function() hs.itunes:playpause() end
    elseif action == "volume" then
        mediaCommand = function()
            local device = hs.audiodevice.defaultOutputDevice()
            local volume = device:volume() + quantity

            device:setOutputVolume(volume)

            local subtitle = "Volume is now " .. tostring(volume)

            hs.notify.show("Volume changed", subtitle, "")
        end
    elseif action == "mute" then
        mediaCommand = function()
            local device = hs.audiodevice.defaultOutputDevice()

            if device:muted() then
                print("Unmuting")
                device:setOutputMuted(false)
                hs.notify.show("Unmuted", "", "")
            else
                print("Muting")
                device:setOutputMuted(true)
                hs.notify.show("Muted", "", "")
            end
        end
    elseif action == "brightness" then
        mediaCommand = function()
            local brightness = hs.brightness.get()

            brightness = brightness + quantity

            hs.brightness.set(brightness)

            local subtitle = "Brightness is now " .. tostring(brightness)

            hs.notify.show("Brightness changed", subtitle, "")
        end
    end

    mediaCommand()
end

function Menu:getActionFunction(desc, command)

    assert(desc, self.name .. " sent a nil desc")
    local commandType = command[1]

    assert(commandType, "Command type is nil")

    local returnCommand = nil

    if commandType == mhConstants.action.menu then
        -- Add a menu
        local menu = command[2]
        assert(menu, "Sub menu is nil for " .. self.name .. " " .. desc)
        returnCommand = function() self.hammer:switchMenu(menu, true) end
    elseif commandType == mhConstants.action.launcher then
        -- Launch an application.
        local appIdentifier = command[2]
        local closeMenu = command[3]
        returnCommand = function() self:launchApplication(desc, appIdentifier, closeMenu) end
    elseif commandType == mhConstants.action.keycombo then
        local commandModifiers = command[2]
        local commandKey = command[3]
        returnCommand = function() self:runKeyCommand(commandModifiers, commandKey) end
    elseif commandType == mhConstants.action.resolution then
        local resolutionMode = command[2]
        returnCommand = function() self:changeResolution(resolutionMode) end
    elseif commandType == mhConstants.action.mediakey then
        local action = command[2]
        local quantity = command[3]
        returnCommand = function() self:runMediaCommand(action, quantity) end
    elseif commandType == mhConstants.action.func then
        local bindFunction = command[2]
        returnCommand = bindFunction
    elseif commandType == mhConstants.action.resizer then
        local action = command[2]
        returnCommand = function() self:runResizer(action) end
    elseif commandType == mhConstants.action.script then
        local scriptName = command[2]
        local useAdmin = command[3]
        returnCommand = function() self:runScript(scriptName, useAdmin) end
    elseif commandType == mhConstants.action.openfile then
        local fileName = command[2]
        assert(fileName, "FileName for " .. desc .. " is nil")
        assert(type(fileName) == "string", "File name provided is of type: " .. type(fileName))
        returnCommand = function() self:openEditor(fileName) end
    elseif commandType == mhConstants.action.shellcommand then
        local shellCommand = command[2]
        assert(shellCommand, "Shell command for " .. desc .. " is nil")
        returnCommand = function() self:runShellCommand(shellCommand) end
    end

    return returnCommand
end

----------------------------------------------------------------------------------------------------
-- Run all the provided functions.
function Menu:runCommands(commandFunctions)
    print("Running commands")
    for index, commandFunction in ipairs(commandFunctions) do
        commandFunction()
    end
end

----------------------------------------------------------------------------------------------------
-- Launch an application by name or package id.
function Menu:runKeyCommand(modifiers, key)

    local modifierString = ""
    for _, value in ipairs(modifiers) do
        modifierString = modifierString .. value .. " "
    end

    print("Executing key command " .. modifierString .. " " .. key)

    self.hammer:closeMenus()

    if modifierString == 'type ' then
        print("Typing text " .. key)
        hs.eventtap.keyStrokes(key)
    elseif modifierString == 'sleep ' then
        print("Sleeping for " .. key .. " microseconds")
        -- TODO: Replace this with something less crappy than a sleep.
        hs.timer.usleep(tonumber(key))
    else
        hs.eventtap.keyStroke(modifiers, key)
    end
end

return Menu

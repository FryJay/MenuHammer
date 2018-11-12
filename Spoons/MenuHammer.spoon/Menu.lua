
----------------------------------------------------------------------------------------------------
---------------------------------------- Menu Definition -------------------------------------------
----------------------------------------------------------------------------------------------------

local Menu = {}
Menu.__index = Menu

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
----------------------------------------- Build Menu -----------------------------------------------
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

        -- Get the commands to execute
        local commands = menuItem[5]

        local commandFunctions = {}

        -- Loop through the commands
        for _, command in ipairs(commands) do
            -- If the command is to load a menu, ensure the menu exists.
            if command[1] == cons.act.menu then
                assert(command[2], self.name .. " has nil submenu identifier")
                assert(self.hammer.menuItemDefinitions[command[2]],
                       "Menu " .. command[2] .. " does not exist.")
            end
            table.insert(commandFunctions, self:getActionFunction(desc, command))
        end

        local finalFunction = function() runCommands(commandFunctions) end

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

    -- Alert MenuHammer the item was activated
    local preprocessFunction = function() self.hammer:itemActivated(menuItem.category) end

    local finalFunction = function()

        preprocessFunction()

        -- If a function was provided, run it.
        if pressedFunction ~= nil then
            pressedFunction()
        end
    end

    local displayTitle = menuItem:displayTitle()

    local newModalBind = self.modal:bind(menuItem.modifier,
                                         menuItem.key,
                                         displayTitle,
                                         finalFunction)

    menuItem.desc = newModalBind.keys[tableLength(newModalBind.keys)].msg
end

----------------------------------------------------------------------------------------------------
------------------------------------ Action Functions ----------------------------------------------
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Launch an application by name or package id.
function Menu:launchApplication(desc, identifier)

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
end

----------------------------------------------------------------------------------------------------
-- Get user input
function Menu:getUserInput(valueIdentifier, messageValue, informativeText, defaultValue)

    assert(messageValue, "No message provided.")

    local informText = informativeText
    local default = defaultValue

    if informText == nil then
        informText = ""
    end

    if default == nil then
        default = ""
    end

    hs.focus()

    local buttonValue, textValue = hs.dialog.textPrompt(messageValue,
                                                        informText,
                                                        default,
                                                        "Ok",
                                                        "Cancel")

    self.hammer.storedValues[valueIdentifier] = {buttonValue, textValue}

end

----------------------------------------------------------------------------------------------------
-- Execute the provided key combination
function Menu:runKeyCommand(modifiers, key)

    assert(key, "Key is nil")

    -- Make a string of the modifiers for display
    local modifierString = ""
    for _, value in ipairs(modifiers) do
        modifierString = modifierString .. value .. " "
    end

    print("Executing key command " .. modifierString .. " " .. key)

    -- Close any menu that is open
    self.hammer:closeMenus()

    hs.eventtap.keyStroke(modifiers, key)
end

----------------------------------------------------------------------------------------------------
-- Type text into current window
function Menu:typeText(textToType)

    assert(textToType, "No text provided")

    print("Typing text " .. textToType)

    hs.eventtap.keyStrokes(textToType)
end
----------------------------------------------------------------------------------------------------
-- Open URL
function Menu:openURL(urlToOpen)

    print("Opening URL with raw string: " .. urlToOpen)

    local processedString = replacePlaceholders(urlToOpen, self.hammer.storedValues, true)

    print("Opening URL: " .. processedString)
    hs.urlevent.openURL(processedString)
end

----------------------------------------------------------------------------------------------------
-- Run a shell script
function Menu:runScript(scriptName, useAdmin)
    local scriptFunction = function()

        local quotedName = '"' .. scriptName .. '"'
        local commandToRun = "do shell script " .. quotedName
        if useAdmin then
            commandToRun = commandToRun .. " with administrator privileges"
        end

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
            scriptEnvironment.SUDOASKPASS = askpassLocation
        else
            print("Admin set but no path to askpass")
        end

        scriptTask:setEnvironment(scriptEnvironment)

        scriptTask:start()

    end

    scriptFunction()
end

----------------------------------------------------------------------------------------------------
-- Run shell command
function Menu:runShellCommand(shellCommand)
    assert(shellCommand)

    local commandString = '"' .. shellCommand .. '"'

    local appleScript = "do shell script " .. commandString

    print("Running shell command: " .. appleScript)

    local shellCommandTask = hs.task.new(
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

    shellCommandTask:start()
end

----------------------------------------------------------------------------------------------------
-- Bind open file
function Menu:openFile(filePath)

    assert(filePath, "No file path provided")

    local commandString = '"sh -c \'open ' .. filePath .. '\'"'

    local appleScript = "do shell script " .. commandString

    print("Running command: " .. appleScript)

    local openFileTask = hs.task.new(
        "/usr/bin/osascript",
        function(exitCode, standardOut, standardError)

            print("Exit code: " .. exitCode)
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

----------------------------------------------------------------------------------------------------
-- Perform a system action
function Menu:runSystemAction(systemAction, confirm)

    assert(systemAction, "System action is nil")

    local runAction = true

    -- If confirm is set to true, then get the user to confirm if the action should proceed.
    if confirm and not getUserConfirmation("Action: " .. systemAction,
                                           "Are you sure?") then
        runAction = false
    end

    -- If still proceeding, run the matching action.
    if runAction then
        local systemActions = {
            [cons.sys.shutdown] = function() hs.caffeinate.shutdownSystem() end,
            [cons.sys.restart] = function() hs.caffeinate.restartSystem() end,
            [cons.sys.logout] = function() hs.caffeinate.logOut() end,
            [cons.sys.logoutnow] = function() self:runKeyCommand({'cmd', 'alt', 'shift'}, 'q') end,
            [cons.sys.lockscreen] = function() hs.caffeinate.systemSleep() end,
            [cons.sys.switchuser] = function() hs.caffeinate.lockScreen() end,
            [cons.sys.screensaver] = function() hs.caffeinate.startScreensaver() end,
            [cons.sys.forcequit] = function() hs.application.frontmostApplication():kill9() end,
        }

        systemActions[systemAction]()
    end
end

----------------------------------------------------------------------------------------------------
-- Pause execution
function Menu:pauseExecution(duration)

    assert(duration, "No duration provided.")
    assert(tonumber(duration), "Duration provided not a number.")

    print("Sleeping for " .. duration .. " microseconds")

    -- TODO: Try to replace this with something less crappy than a sleep.
    hs.timer.usleep(tonumber(duration))
end

----------------------------------------------------------------------------------------------------
-- Change resolution
function Menu:changeResolution(resolutionMode)

    local device = hs.screen.mainScreen()

    device:setMode(resolutionMode["w"], resolutionMode["h"], resolutionMode["scale"])
end

----------------------------------------------------------------------------------------------------
-- Bind music command
function Menu:runMediaCommand(action, quantity)

    local mediaCommand = nil

    local mediaCommands = {
        previous = function() hs.itunes:previous() end,
        next = function() hs.itunes:next() end,
        playpause = function() hs.itunes:playpause() end,
        volume = function()
            local device = hs.audiodevice.defaultOutputDevice()
            local volume = device:volume() + quantity

            device:setOutputVolume(volume)

            local subtitle = "Volume is now " .. tostring(volume)

            hs.notify.show("Volume changed", subtitle, "")
        end,
        mute = function()
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
        end,
        brightness = function()
            local brightness = hs.brightness.get()

            brightness = brightness + quantity

            hs.brightness.set(brightness)

            local subtitle = "Brightness is now " .. tostring(brightness)

            hs.notify.show("Brightness changed", subtitle, "")
        end,
    }

    mediaCommands[action]()
end

----------------------------------------------------------------------------------------------------
-- Get a function to execute to perform the needed action.
function Menu:getActionFunction(desc, command)

    assert(desc, self.name .. " sent a nil desc")
    local commandType = command[1]

    assert(commandType, "Command type is nil")

    print("Getting action function for " .. desc)

    local actionTable = {
        [cons.act.menu] = function()
            -- Add a menu

            local menu = command[2]
            assert(menu, "Sub menu is nil for " .. self.name .. " " .. desc)

            self.hammer:switchMenu(menu, true)
        end,
        [cons.act.launcher] = function()
            -- Launch an application.

            local appIdentifier = command[2]
            local closeMenu = command[3]

            self:launchApplication(desc, appIdentifier, closeMenu)
        end,
        [cons.act.func] = function()
            -- Execute provided function

            local bindFunction = command[2]

            bindFunction()
        end,
        [cons.act.userinput] = function()
            -- Get user input

            -- Get the identifier of the input, the message, text and default value
            local valueIdentifier = command[2]
            local messageValue = command[3]
            local informativeText = command[4]
            local defaultValue = command[5]

            self:getUserInput(valueIdentifier, messageValue, informativeText, defaultValue)
        end,
        [cons.act.keycombo] = function()
            -- Execute a key combination

            local commandModifiers = command[2]
            local commandKey = command[3]

            self:runKeyCommand(commandModifiers, commandKey)
        end,

        [cons.act.typetext] = function()
            -- Type text into current window

            local textToType = command[2]

            self:typeText(textToType)
        end,
        [cons.act.script] = function()
            -- Execute shell script

            local scriptName = command[2]
            local useAdmin = command[3]

            self:runScript(scriptName, useAdmin)
        end,
        [cons.act.openurl] = function()
            -- Open a URL

            local urlToOpen = command[2]

            self:openURL(urlToOpen)
        end,
        [cons.act.shellcommand]  = function()
            -- Execute a shell command

            local shellCommand = command[2]
            assert(shellCommand, "Shell command for " .. desc .. " is nil")

            self:runShellCommand(shellCommand)
        end,
        [cons.act.openfile] = function()
            -- Open a file

            local fileName = command[2]
            assert(fileName, "FileName for " .. desc .. " is nil")
            assert(type(fileName) == "string", "File name provided is of type: " .. type(fileName))

            self:openFile(fileName)
        end,
        [cons.act.system] = function()
            -- Perform a system action (reboot, shutdown, etc)

            local systemAction = command[2]
            local confirm = command[3]

            self:runSystemAction(systemAction, confirm)
        end,
        [cons.act.sleep] = function()
            -- Pause execution (sleep)

            local duration = command[2]

            self:pauseExecution(duration)
        end,
        [cons.act.resolution] = function()
            -- Change the screen resolution

            local resolutionMode = command[2]

            self:changeResolution(resolutionMode)
        end,
        [cons.act.mediakey] = function()
            -- Press media key

            local action = command[2]
            local quantity = command[3]

            self:runMediaCommand(action, quantity)
        end,
    }

    return actionTable[commandType]
end

return Menu

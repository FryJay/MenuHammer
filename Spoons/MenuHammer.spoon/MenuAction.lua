
----------------------------------------------------------------------------------------------------
---------------------------------- Menu Action Definition ------------------------------------------
----------------------------------------------------------------------------------------------------

local MenuAction = {}
MenuAction.__index = MenuAction

MenuAction.desc = nil
MenuAction.command = nil
MenuAction.parentMenu = nil

----------------------------------------------------------------------------------------------------
-- Constructor
function MenuAction.new(desc,
                        command,
                        parentMenu)

    assert(desc, "Description is nil")
    assert(command, "Command is nil")

    local self = setmetatable({}, MenuAction)

    self.desc = desc
    self.command = command
    self.parentMenu = parentMenu

    return self
end

----------------------------------------------------------------------------------------------------
-- Get an action function
function MenuAction:getActionFunction()

    local command = self.command
    local desc = self.desc
    local commandType = command[1]

    local actionTable = {
        [cons.act.menu] = function()
            -- Add a menu

            local menu = command[2]
            assert(menu, "Sub menu is nil for " .. self.parentMenu.name .. " " .. desc)

            self.parentMenu.menuManager:switchMenu(menu)
            return true
        end,
        [cons.act.launcher] = function()
            -- Launch an application.

            local appIdentifier = command[2]

            self:launchApplication(desc, appIdentifier)
            return true
        end,
        [cons.act.func] = function()
            -- Execute provided function

            local bindFunction = command[2]

            bindFunction()
            return true
        end,
        [cons.act.userinput] = function()
            -- Get user input

            -- Get the identifier of the input, the message, text and default value
            local valueIdentifier = command[2]
            local messageValue = command[3]
            local informativeText = command[4]
            local defaultValue = command[5]

            return self:getUserInput(valueIdentifier, messageValue, informativeText, defaultValue)
        end,
        [cons.act.keycombo] = function()
            -- Execute a key combination

            local commandModifiers = command[2]
            local commandKey = command[3]

            self:runKeyCommand(commandModifiers, commandKey)
            return true
        end,

        [cons.act.typetext] = function()
            -- Type text into current window

            local textToType = command[2]

            self:typeText(textToType)
            return true
        end,
        [cons.act.script] = function()
            -- Execute shell script

            local scriptName = command[2]
            local useAdmin = command[3]

            self:runScript(scriptName, useAdmin)
            return true
        end,
        [cons.act.openurl] = function()
            -- Open a URL

            local urlToOpen = command[2]

            self:openURL(urlToOpen)
            return true
        end,
        [cons.act.shellcommand]  = function()
            -- Execute a shell command

            local shellCommand = command[2]
            assert(shellCommand, "Shell command for " .. desc .. " is nil")

            self:runShellCommand(shellCommand)
            return true
        end,
        [cons.act.openfile] = function()
            -- Open a file

            local fileName = command[2]
            assert(fileName, "FileName for " .. desc .. " is nil")
            assert(type(fileName) == "string", "File name provided is of type: " .. type(fileName))

            self:openFile(fileName)
            return true
        end,
        [cons.act.system] = function()
            -- Perform a system action (reboot, shutdown, etc)

            local systemAction = command[2]
            local confirm = command[3]

            self:runSystemAction(systemAction, confirm)
            return true
        end,
        [cons.act.sleep] = function()
            -- Pause execution (sleep)

            local duration = command[2]

            self:pauseExecution(duration)
            return true
        end,
        [cons.act.resolution] = function()
            -- Change the screen resolution

            local resolutionMode = command[2]

            self:changeResolution(resolutionMode)
            return true
        end,
        [cons.act.resizer]  = function()
            -- Resize the screen

            local action = command[2]

            self:runResizer(action)
            return true
        end,
        [cons.act.mediakey] = function()
            -- Press media key

            local action = command[2]
            local quantity = command[3]

            self:runMediaCommand(action, quantity)
            return true
        end,
    }

    return actionTable[commandType]
end

----------------------------------------------------------------------------------------------------
-- Launch an application by name or package id.
function MenuAction:launchApplication(desc, identifier)

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
function MenuAction:getUserInput(valueIdentifier, messageValue, informativeText, defaultValue)

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

    self.parentMenu.menuManager.storedValues[valueIdentifier] = {buttonValue, textValue}

    if buttonValue == "Cancel" then
        return false
    else
        return true
    end
end

----------------------------------------------------------------------------------------------------
-- Execute the provided key combination
function MenuAction:runKeyCommand(modifiers, key)

    assert(key, "Key is nil")

    -- Make a string of the modifiers for display
    local modifierString = ""
    for _, value in ipairs(modifiers) do
        modifierString = modifierString .. value .. " "
    end

    print("Executing key command " .. modifierString .. " " .. key)

    hs.eventtap.keyStroke(modifiers, key)
end

----------------------------------------------------------------------------------------------------
-- Type text into current window
function MenuAction:typeText(textToType)

    assert(textToType, "No text provided")

    print("Typing text " .. textToType)

    local processedString = self:replacePlaceholders(textToType, self.parentMenu.menuManager.storedValues, true)

    hs.eventtap.keyStrokes(processedString)
end

----------------------------------------------------------------------------------------------------
-- Open URL
function MenuAction:openURL(urlToOpen)

    print("Opening URL with raw string: " .. urlToOpen)

    local processedString = self:replacePlaceholders(urlToOpen, self.parentMenu.menuManager.storedValues, true)

    print("Opening URL: " .. processedString)
    hs.urlevent.openURL(processedString)
end

----------------------------------------------------------------------------------------------------
-- Run a shell script
function MenuAction:runScript(scriptName, useAdmin)
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
function MenuAction:runShellCommand(shellCommand)
    assert(shellCommand)

    local commandString = '"' .. shellCommand .. '"'

    local appleScript = "do shell script " .. commandString

    print("Running shell command: " .. appleScript)

    local shellCommandTask = hs.task.new(
        "/usr/bin/osascript",
        function(exitCode, standardOut, standardError)

            print("Editor exit code: " .. exitCode)
            if exitCode ~= 0 then
                hs.notify.show("FAILED to execute shell command",
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
function MenuAction:openFile(filePath)

    assert(filePath, "No file path provided")

    local firstChar = filePath:sub(1, 1)
    
    if firstChar == "~" then
        local homePath = os.getenv("HOME")
        local filePathWithoutTilde = filePath:sub(2)
        filePath = homePath .. filePathWithoutTilde
    end

    local quotedFilePath = '\\"' .. filePath .. '\\"'

    local commandString = '"sh -c \'open ' .. quotedFilePath .. '\'"'

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
function MenuAction:runSystemAction(systemAction, confirm)

    assert(systemAction, "System action is nil")

    local runAction = true

    -- If confirm is set to true, then get the user to confirm if the action should proceed.
    if confirm and not self:getUserConfirmation("Action: " .. systemAction,
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
function MenuAction:pauseExecution(duration)

    assert(duration, "No duration provided.")
    assert(tonumber(duration), "Duration provided not a number.")

    print("Sleeping for " .. duration .. " microseconds")

    -- TODO: Try to replace this with something less crappy than a sleep.
    hs.timer.usleep(tonumber(duration))
end

----------------------------------------------------------------------------------------------------
-- Change resolution
function MenuAction:changeResolution(resolutionMode)

    local device = hs.screen.mainScreen()

    device:setMode(resolutionMode["w"], resolutionMode["h"], resolutionMode["scale"])
end

----------------------------------------------------------------------------------------------------
-- Bind resizer
function MenuAction:runResizer(action)
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

    local resizeActions = {
        { -- Move
            types = {
                cons.resizer.left,
                cons.resizer.right,
                cons.resizer.up,
                cons.resizer.down
            },
            actionFunction = function()
                spoon.WinWin:stepMove(action)
            end,
        },
        { -- Move and resize
            types = {
                cons.resizer.halfLeft,
                cons.resizer.halfRight,
                cons.resizer.halfUp,
                cons.resizer.halfDown,
                cons.resizer.northWest,
                cons.resizer.northEast,
                cons.resizer.southWest,
                cons.resizer.southEast,
                cons.resizer.fullScreen,
                cons.resizer.centerWindow
            },
            actionFunction = function()
                spoon.WinWin:stash()
                spoon.WinWin:moveAndResize(action)
            end,
        },
        { -- Resize
            types = {
                cons.resizer.stepLeft,
                cons.resizer.stepRight,
                cons.resizer.stepUp,
                cons.resizer.stepDown,
            },
            actionFunction = function()
                local newAction = string.sub(action, string.find(action, "_")+1)
                spoon.WinWin:stepResize(newAction)
            end,
        },
        { -- Expand and shrinnk
            types = {
                cons.resizer.expand,
                cons.resizer.shrink
            },
            actionFunction = function()
                spoon.WinWin:moveAndResize(action)
            end,
        },
        { -- Move screen
            types = {
                cons.resizer.screenLeft,
                cons.resizer.screenRight,
                cons.resizer.screenUp,
                cons.resizer.screenDown,
                cons.resizer.screenNext
            },
            actionFunction = function()
                local newAction = string.sub(action, string.find(action, "_")+1)
                spoon.WinWin:stash()
                spoon.WinWin:moveToScreen(newAction)
            end,
        },
        { -- Undo
            types = {
                cons.resizer.undo,
            },
            actionFunction = function()
                spoon.WinWin:undo()
            end
        },

        { -- Redo
            types = {
                cons.resizer.redo,
            },
            actionFunction = function()
                spoon.WinWin:redo()
            end
        },
        { -- Center cursor
            types = {
                cons.resizer.redo,
            },
            actionFunction = function()
                spoon.WinWin:centerCursor()
            end
        },
    }

    for _, resizeAction in ipairs(resizeActions) do
        if hasValue(resizeAction.types, action) then
            resizeAction.actionFunction()
        end
    end
end

----------------------------------------------------------------------------------------------------
-- Bind music command
function MenuAction:runMediaCommand(action, quantity)

    local mediaCommands = {
        previous = function() hs.itunes:previous() end,
        next = function() hs.itunes:next() end,
        playpause = function() hs.itunes:playpause() end,
        setVolume = function()
            local device = hs.audiodevice.defaultOutputDevice()
            local newVolume = tonumber(self:replacePlaceholders(quantity,
                                                                self.parentMenu.menuManager.storedValues))


            device:setOutputVolume(newVolume)

            local subtitle = "Volume is now " .. tostring(newVolume)

            hs.notify.show("Volume changed", subtitle, "")
        end,
        adjustVolume = function()
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
        setBrightness = function()
            local newBrightness = tonumber(self:replacePlaceholders(quantity,
                                                                    self.parentMenu.menuManager.storedValues))

            hs.brightness.set(newBrightness)

            local subtitle = "Brightness is now " .. tostring(newBrightness)

            hs.notify.show("Brightness changed", subtitle, "")
        end,
        adjustBrightness = function()
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
-- Replace placeholders in the provided string with values from the stored values.
function MenuAction:replacePlaceholders(stringToProcess, storedValues, encode)

    local systemPlaceholders = {
        mhClipboardText = function() return hs.pasteboard.getContents() end,
    }

    local matchPattern = "@@(%a+)@@"
    local processedString = stringToProcess

    for valueIdentifier in string.gmatch(processedString, matchPattern) do

        print("Found value identifier: " .. valueIdentifier)

        local storedValue

        if systemPlaceholders[valueIdentifier] ~= nil then
            storedValue = systemPlaceholders[valueIdentifier]()
        else
            -- There should be a value in the second field.
            assert(storedValues[valueIdentifier][2])

            storedValue = storedValues[valueIdentifier][2]
        end

        if encode then
            storedValue = self:urlEncode(storedValue)
        end

        assert(storedValue, "No stored value by name " .. valueIdentifier)

        print("Retrieved stored value of " .. storedValue)

        local matchString = "@@" .. valueIdentifier .. "@@"

        processedString = string.gsub(processedString,
                                      matchString,
                                      storedValue)
    end

    return processedString
end

----------------------------------------------------------------------------------------------------
-- Encodes text to be used in a URL
function MenuAction:urlEncode(stringToEncode)
    if stringToEncode then
        stringToEncode = stringToEncode:gsub("\n", "\r\n")
        stringToEncode = stringToEncode:gsub(
            "([^%w %-%_%.%~])",
            function(c)
                return ("%%%02X"):format(string.byte(c))
            end
        )
        stringToEncode = stringToEncode:gsub(" ", "+")
    end
    return stringToEncode
end

----------------------------------------------------------------------------------------------------
-- Get confirmation from the user
function MenuAction:getUserConfirmation(message,
                                  informativeText)

    print("Getting user confirmation for message: " .. message .. " and text " .. informativeText)

    local buttonPressed = hs.dialog.blockAlert(message,
                                               informativeText,
                                               "Ok",
                                               "Cancel")

    if buttonPressed ~= "Ok" then
        print("User did not confirm")
        return false
    else
        print("User confirmed")
        return true
    end
end

return MenuAction

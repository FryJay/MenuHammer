-- Internal function used to find our location, so we know where to load files from
local function scriptPath()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

BaseAction = dofile(scriptPath() .. "/BaseAction.lua")

----------------------------------------------------------------------------------------------------
---------------------------------- System Action Definition ----------------------------------------
----------------------------------------------------------------------------------------------------

local SystemActions = BaseAction.new()

----------------------------------------------------------------------------------------------------
-- Perform a system action
function SystemActions:runSystemAction(desc, command)

    local systemAction = command[2]
    local confirm = command[3]

    assert(desc, "Desc is nil")
    assert(systemAction, "System action is nil")

    print("")
    print("Running system action " .. desc)
    print("")

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
            [cons.sys.logoutnow] = function() self:runKeyCommand({ 'cmd', 'alt', 'shift' }, 'q') end,
            [cons.sys.lockscreen] = function() hs.caffeinate.systemSleep() end,
            [cons.sys.switchuser] = function() hs.caffeinate.lockScreen() end,
            [cons.sys.screensaver] = function() hs.caffeinate.startScreensaver() end,
            [cons.sys.forcequit] = function() hs.application.frontmostApplication():kill9() end,
        }

        systemActions[systemAction]()
    end

    return true
end

----------------------------------------------------------------------------------------------------
-- Launch an application by name or package id.
function SystemActions:launchApplication(desc, command)

    local identifier = command[2]

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

    return true
end

----------------------------------------------------------------------------------------------------
-- Bind open file
function SystemActions:openFile(desc, command)

    local filePath = command[2]

    assert(filePath, "FileName for " .. desc .. " is nil")
    assert(type(filePath) == "string", "File name provided is of type: " .. type(filePath))
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

    return true
end

----------------------------------------------------------------------------------------------------
-- Run shell command
function SystemActions:runShellCommand(desc, command)

    local shellCommand = command[2]
    assert(shellCommand, "Shell command for " .. desc .. " is nil")

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

    return true
end

----------------------------------------------------------------------------------------------------
-- Run a shell script
function SystemActions:runScript(desc, command)

    local scriptName = command[2]
    local useAdmin = command[3]

    assert(scriptName, "Script name for " .. desc .. " is nil")

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

        return true
    end

    return scriptFunction()
end

----------------------------------------------------------------------------------------------------
-- Change resolution
function SystemActions:changeResolution(desc, command)

    local resolutionMode = command[2]

    assert(resolutionMode, "Resolution mode provided for " .. desc .. " is nill")

    local device = hs.screen.mainScreen()

    device:setMode(
        resolutionMode["w"],
        resolutionMode["h"],
        resolutionMode["scale"],
        resolutionMode["freq"],
        resolutionMode["depth"]
    )

    return true
end

return SystemActions

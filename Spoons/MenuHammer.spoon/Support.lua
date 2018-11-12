
----------------------------------------------------------------------------------------------------
----------------------------------------- Constants ------------------------------------------------
----------------------------------------------------------------------------------------------------

function readOnlyTable(table)
    return setmetatable({}, {
            __index = table,
            __newindex = function(table, key, value)
                error('Attempt to modify read-only table')
            end,
            __metatable = false
    });
end

-- Constants
cons = readOnlyTable {
    cat = {
        action = 'action',              -- Action category
        submenu = 'submenu',            -- Menu category
        back = 'back',                  -- Back button category
        exit = 'exit',                  -- Exit button category
        navigation = 'navigation',      -- Navigation category
    },
    act = {
        menu = 'menu',                  -- Open a menu
        launcher = 'launcher',          -- Launch an application
        func = 'function',              -- Execute a function
        userinput = 'userinput',        -- Get user input
        keycombo = 'keycombo',          -- Execute a key combination
        typetext = 'typetext',          -- Type some text into current window
        openurl = 'openurl',            -- Open a URL
        script = 'script',              -- Execute a shell script
        shellcommand = 'shellCommand',  -- Execute a shell command
        openfile = 'openfile',          -- Open a file
        system = 'system',              -- Execute a system command
        sleep = 'sleep',                -- Pause execution (sleep)
        resolution = 'resolution',      -- Change the screen resolution
        resizer = 'resizer',            -- Resize the screen
        mediakey = 'mediakey',          -- Execute a media key button
    },
    sys = {
        shutdown = 'shutdown',          -- Shutdown the system
        restart = 'restart',            -- Restart the system
        logout = 'logout',              -- Logout with confirmation
        logoutnow = 'logoutnow',        -- Logout without confirmation
        forcequit = 'forcequit',        -- Force quit frontmost application
        lockscreen = 'lockscreen',      -- Lock the screen (really puts to sleep)
        switchuser = 'switchuser',      -- Switch user
        screensaver = 'screensaver',    -- Start screensaver
    },
    resizer = {
        left = 'left',
        right = 'right',
        up = 'up',
        down = 'down',
        halfLeft = 'halfleft',
        halfRight = 'halfright',
        halfUp = 'halfup',
        halfDown = 'halfdown',
        northWest = 'cornerNW',
        northEast = 'cornerNE',
        southWest = 'cornerSW',
        southEast = 'cornerSE',
        fullScreen = 'fullscreen',
        centerWindow = 'center_window',
        stepLeft = 'step_left',
        stepRight = 'step_right',
        stepUp = 'step_up',
        stepDown = 'step_down',
        expand = 'expand',
        shrink = 'shrink',
        screenLeft = 'screen_left',
        screenRight = 'screen_right',
        screenUp = 'screen_up',
        screenDown = 'screen_down',
        screenNext = 'screen_next',
        undo = 'undo',
        redo = 'redo',
        centerCursor = 'center_cursor'
    }
}

----------------------------------------------------------------------------------------------------
------------------------------------ Supporting Functions ------------------------------------------
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Encodes text to be used in a URL
function urlEncode(stringToEncode)
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
-- Replace placeholders in the provided string with values from the stored values.
function replacePlaceholders(stringToProcess, storedValues, encode)

    local matchPattern = "@@(%a+)@@"
    local processedString = stringToProcess

    for valueIdentifier in string.gmatch(processedString, matchPattern) do

        print("Found value identifier: " .. valueIdentifier)

        local storedValue = storedValues[valueIdentifier][2]

        if encode then
            storedValue = urlEncode(storedValue)
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
-- Run all the provided functions.
function runCommands(commandFunctions)
    print("Running commands")
    for index, commandFunction in ipairs(commandFunctions) do
        commandFunction()
    end
end

----------------------------------------------------------------------------------------------------
-- Get confirmation from the user
function getUserConfirmation(message,
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

----------------------------------------------------------------------------------------------------
-- Get the length of the table provided.
function tableLength(inputTable)
    local count = 0
    for _ in pairs(inputTable) do count = count + 1 end
    return count
end

----------------------------------------------------------------------------------------------------
-- Create the resolution list.
local function getResolutions()

    local primary = hs.screen.primaryScreen()
    local modes = primary:availableModes()

    return modes
end

----------------------------------------------------------------------------------------------------
-- Get a list of sorted resolution names
local function getSortedResolutionKeys(resolutions)

    local function sortResolutions(resolutionA, resolutionB)

        local prefixA = tonumber(string.sub(resolutionA, 1,
                                            string.find(resolutionA, "x")-1))
        local prefixB = tonumber(string.sub(resolutionB, 1,
                                            string.find(resolutionB, "x")-1))
        return prefixA > prefixB
    end

    local resolutionKeys = {}

    -- populate the table that holds the keys
    for key, _ in pairs(resolutions) do
        table.insert(resolutionKeys, key)
    end

    -- sort the keys
    table.sort(resolutionKeys, sortResolutions)

    return resolutionKeys
end

----------------------------------------------------------------------------------------------------
-- Get resolution menu items for all available resolutions
function getResolutionMenuItems()

    local resolutions = getResolutions()

    local i = string.byte("a")
    local modifier = ''

    local resolutionMenuItems = {}

    for _, modeName in pairs(getSortedResolutionKeys(resolutions)) do

        local mode = resolutions[modeName]

        if i == string.byte("z") + 1 then
            i = string.byte("a")
            modifier = 'shift'
        end

        table.insert(resolutionMenuItems,
                     {cons.cat.action, modifier, string.char(i), modeName, {
                          {cons.act.resolution, mode}
        }})
        i = i + 1
    end

    return resolutionMenuItems
end

resolutionMenuItems = getResolutionMenuItems(getResolutions())

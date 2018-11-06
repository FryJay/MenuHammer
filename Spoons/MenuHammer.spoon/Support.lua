
----------------------------------------------------------------------------------------------------
----------------------------------------- Constants ------------------------------------------------
----------------------------------------------------------------------------------------------------

-- Constants
mhConstants = {
    resizer = {
        left = 'left'
    },
    category = {
        navigation = "navigation",
        action = "action",
        menu = "menu",
        exit = "exit",
        back = "back",
        blank = "blank"
    },
    bind = {
        menu = 'menu',
        launcher = 'launcher',
        keycombo = "keycombo",
        resolution = "resolution",
        mediakey = "mediakey",
        func = "function",
        resizer = "resizer",
        script = "script",
        openfile = "openfile",
        shellcommand = "shellCommand"
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
        undo = "undo",
        redo = "redo",
        centerCursor = 'center_cursor'
    }
}

----------------------------------------------------------------------------------------------------
------------------------------------ Supporting Functions ------------------------------------------
----------------------------------------------------------------------------------------------------

function tableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

-- Print anything - including nested tables
function tablePrint (tt, indent, done)
    done = done or {}
    indent = indent or 0
    if type(tt) == "table" then
        for key, value in pairs (tt) do
            print(string.rep (" ", indent)) -- indent it
            if type (value) == "table" and not done [value] then
                done [value] = true
                print(string.format("[%s] => table\n", tostring (key)));
                print(string.rep (" ", indent+4)) -- indent it
                print("(\n");
                tablePrint (value, indent + 7, done)
                print(string.rep (" ", indent+4)) -- indent it
                print(")\n");
            else
                print(string.format("[%s] => %s\n",
                                       tostring (key), tostring(value)))
            end
        end
    else
        io.write(tt .. "\n")
    end
end

-- Create the resolution list.
local function getResolutions()

    local primary = hs.screen.primaryScreen()
    local modes = primary:availableModes()

    return modes
end

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

-- TODO: Make this a bit less hacky looking.
-- Add all available resolutions.
local resolutions = getResolutions()

local i = string.byte("a")
local modifier = ''

resolutionMenuItems = {}

for _, modeName in pairs(getSortedResolutionKeys(resolutions)) do

    local mode = resolutions[modeName]

    if i == string.byte("z") + 1 then
        i = string.byte("a")
        modifier = 'shift'
    end

    table.insert(resolutionMenuItems,
                 {mhConstants.category.action, modifier, string.char(i), modeName, {
                      {mhConstants.bind.resolution, mode}
    }})
    i = i + 1
end

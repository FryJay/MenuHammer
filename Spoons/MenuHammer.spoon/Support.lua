
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
    },
    action = {
        menu = 'menu',
        launcher = 'launcher',
        keycombo = "keycombo",
        resolution = "resolution",
        mediakey = "mediakey",
        func = "function",
        script = "script",
        openfile = "openfile",
        shellcommand = "shellCommand"
    },
}

----------------------------------------------------------------------------------------------------
------------------------------------ Supporting Functions ------------------------------------------
----------------------------------------------------------------------------------------------------

function tableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
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
                      {mhConstants.action.resolution, mode}
    }})
    i = i + 1
end

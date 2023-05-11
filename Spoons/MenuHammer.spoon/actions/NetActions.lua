-- Internal function used to find our location, so we know where to load files from
local function scriptPath()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

BaseAction = dofile(scriptPath() .. "/BaseAction.lua")

----------------------------------------------------------------------------------------------------
---------------------------------- Net Action Definition -------------------------------------------
----------------------------------------------------------------------------------------------------

local NetActions = BaseAction.new()

----------------------------------------------------------------------------------------------------
-- Open URL
function NetActions:openURL(desc, command, storedValues)

    local urlToOpen = command[2]

    print("Opening URL with raw string: " .. urlToOpen)

    local processedString = self:replacePlaceholders(urlToOpen, storedValues, true)

    print("Opening URL: " .. processedString)
    hs.urlevent.openURL(processedString)

    return true
end

return NetActions

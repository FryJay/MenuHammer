BaseAction = dofile(hs.spoons.scriptPath() .. "/BaseAction.lua")

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

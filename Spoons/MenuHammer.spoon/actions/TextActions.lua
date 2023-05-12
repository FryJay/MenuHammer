BaseAction = dofile(hs.spoons.scriptPath() .. "/BaseAction.lua")

----------------------------------------------------------------------------------------------------
---------------------------------- Text Action Definition ------------------------------------------
----------------------------------------------------------------------------------------------------

local TextActions = BaseAction.new()

----------------------------------------------------------------------------------------------------
-- Execute the provided key combination
function TextActions:runKeyCommand(desc, command)

    local modifiers = command[2]
    local key = command[3]

    assert(key, "Key is nil")

    -- Make a string of the modifiers for display
    local modifierString = ""
    for _, value in ipairs(modifiers) do
        modifierString = modifierString .. value .. " "
    end

    print("Executing key command " .. modifierString .. " " .. key)

    hs.eventtap.keyStroke(modifiers, key)

    return true
end

----------------------------------------------------------------------------------------------------
-- Type text into current window
function TextActions:typeText(desc, command)

    local textToType = command[2]

    assert(textToType, "No text provided")

    print("Typing text " .. textToType)

    local processedString = self:replacePlaceholders(textToType, self.storedValues, true)

    hs.eventtap.keyStrokes(processedString)

    return true
end

return TextActions


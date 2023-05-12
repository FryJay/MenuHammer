BaseAction = dofile(hs.spoons.scriptPath() .. "/BaseAction.lua")

----------------------------------------------------------------------------------------------------
---------------------------------- User Action Definition ------------------------------------------
----------------------------------------------------------------------------------------------------

local UserActions = BaseAction.new()

----------------------------------------------------------------------------------------------------
-- Get user input
function UserActions:getUserInput(desc, command, storedValues)

    -- Get the identifier of the input, the message, text and default value
    local valueIdentifier = command[2]
    local messageValue = command[3]
    local informativeText = command[4]
    local defaultValue = command[5]

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

    storedValues[valueIdentifier] = { buttonValue, textValue }

    if buttonValue == "Cancel" then
        return false
    else
        return true
    end
end

return UserActions

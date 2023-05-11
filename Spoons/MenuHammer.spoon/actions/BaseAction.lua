----------------------------------------------------------------------------------------------------
---------------------------------- Base Action Definition ------------------------------------------
----------------------------------------------------------------------------------------------------

local BaseAction = {}
BaseAction.__index = BaseAction

----------------------------------------------------------------------------------------------------
-- Constructor
function BaseAction.new()
    local self = setmetatable({}, BaseAction)
    return self
end

----------------------------------------------------------------------------------------------------
-- Replace placeholders in the provided string with values from the stored values.
function BaseAction:replacePlaceholders(stringToProcess, storedValues, encode)
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
function BaseAction:urlEncode(stringToEncode)
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
function BaseAction:getUserConfirmation(message,
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

return BaseAction

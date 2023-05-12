BaseAction = dofile(hs.spoons.scriptPath() .. "/BaseAction.lua")

----------------------------------------------------------------------------------------------------
---------------------------------- Media Action Definition -----------------------------------------
----------------------------------------------------------------------------------------------------

local MediaActions = BaseAction.new()

----------------------------------------------------------------------------------------------------
-- Bind media command
function MediaActions:runMediaCommand(desc, command, storedValues)

    local action = command[2]
    local quantity = command[3]

    local mediaCommands = {
        previous = function() hs.itunes:previous() end,
        next = function() hs.itunes:next() end,
        playpause = function()
            hs.eventtap.event.newSystemKeyEvent("PLAY", true):post()
            hs.eventtap.event.newSystemKeyEvent("PLAY", false):post()

            return true
        end,
        setVolume = function()
            local device = hs.audiodevice.defaultOutputDevice()
            local newVolume = tonumber(self:replacePlaceholders(quantity, storedValues))

            device:setOutputVolume(newVolume)

            local subtitle = "Volume is now " .. tostring(newVolume)

            hs.notify.show("Volume changed", subtitle, "")

            return true
        end,
        adjustVolume = function()
            if quantity > 0 then
                hs.eventtap.event.newSystemKeyEvent("SOUND_UP", true):post()
                hs.eventtap.event.newSystemKeyEvent("SOUND_UP", false):post()
            else
                hs.eventtap.event.newSystemKeyEvent("SOUND_DOWN", true):post()
                hs.eventtap.event.newSystemKeyEvent("SOUND_DOWN", false):post()
            end

            return true
        end,
        mute = function()
            hs.eventtap.event.newSystemKeyEvent("MUTE", true):post()
            hs.eventtap.event.newSystemKeyEvent("MUTE", false):post()

            return true
        end,
        setBrightness = function()
            local newBrightness = tonumber(self:replacePlaceholders(quantity, storedValues))

            hs.brightness.set(newBrightness)

            local subtitle = "Brightness is now " .. tostring(newBrightness)

            hs.notify.show("Brightness changed", subtitle, "")

            return true
        end,
        adjustBrightness = function()
            if quantity > 0 then
                hs.eventtap.event.newSystemKeyEvent("BRIGHTNESS_UP", true):post()
                hs.eventtap.event.newSystemKeyEvent("BRIGHTNESS_UP", false):post()
            else
                hs.eventtap.event.newSystemKeyEvent("BRIGHTNESS_DOWN", true):post()
                hs.eventtap.event.newSystemKeyEvent("BRIGHTNESS_DOWN", false):post()
            end
            return true
        end,
    }

    return mediaCommands[action]()
end

return MediaActions

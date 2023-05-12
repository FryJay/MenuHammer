----------------------------------------------------------------------------------------------------
--------------------------------- OSMenuBarItem Definition -----------------------------------------
----------------------------------------------------------------------------------------------------

local OSMenuBarItem = {}
OSMenuBarItem.__index = OSMenuBarItem

-- Whether or not to show an item on the macOS menu bar
OSMenuBarItem.showMenuBarItem = false

OSMenuBarItem.menuBarItem = nil

----------------------------------------------------------------------------------------------------
-- Constructor
function OSMenuBarItem.new(showMenuBarItem)
    local self = setmetatable({}, OSMenuBarItem)

    self.showMenuBarItem = showMenuBarItem

    -- The menu bar item to show current status
    self.menuBarItem = hs.menubar.new()

    self.menuBarItem:setMenu(
        {
            { title = "Reload config", fn = function() hs.reload() end }
        }
    )

    -- Clear the menu bar text
    self:setMenuBarText(nil)

    return self
end

----------------------------------------------------------------------------------------------------
-- Set the menu bar text
function OSMenuBarItem:setMenuBarText(text)

    if self.showMenuBarItem then
        local newText = text
        local backgroundColor = {hex = menuItemColors.menuBarActive.background, alpha = 0.95}
        local textColor = {hex = menuItemColors.menuBarActive.text, alpha = 0.95}

        if text == nil then
            newText = "idle"
            backgroundColor = {hex = menuItemColors.menuBarIdle.background, alpha = 0.95}
            textColor = {hex = menuItemColors.menuBarIdle.text, alpha = 0.95}
        end

        self.menuBarItem:setTitle(hs.styledtext.new(newText, {color = textColor,
                                                        backgroundColor = backgroundColor}))
    end
end

return OSMenuBarItem

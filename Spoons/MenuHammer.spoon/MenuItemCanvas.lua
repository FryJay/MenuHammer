----------------------------------------------------------------------------------------------------
--------------------------------- MenuItemCanvas Definition ----------------------------------------
----------------------------------------------------------------------------------------------------

local MenuItemCanvas = {}
MenuItemCanvas.__index = MenuItemCanvas

MenuItemCanvas.canvas = nil

MenuItemCanvas.row = nil
MenuItemCanvas.column = nil
MenuItemCanvas.width = nil
MenuItemCanvas.height = nil
MenuItemCanvas.category = nil
MenuItemCanvas.displayValue = nil

MenuItemCanvas.xValue = nil
MenuItemCanvas.yValue = nil

----------------------------------------------------------------------------------------------------
-- Constructor
function MenuItemCanvas.new(
    row,
    column,
    width,
    height,
    category
)
    local self = setmetatable({}, MenuItemCanvas)

    self.row = row
    self.column = column
    self.width = tostring(width)
    self.height = tostring(height)
    self.category = category

    self.xValue = tostring(self.column * self.width)
    self.yValue = tostring(self.height * self.row)

    return self
end

----------------------------------------------------------------------------------------------------
-- Select menu item background color
function MenuItemCanvas:setDisplayValue(displayValue)
    self.displayValue = displayValue
end

----------------------------------------------------------------------------------------------------
-- Select menu item background color
function MenuItemCanvas:backgroundColor()

    if self.category == nil then
        print("Received nil item category.  Defaulting background color.")
        return menuItemColors.default.background
    end

    return menuItemColors[self.category].background
end

----------------------------------------------------------------------------------------------------
-- Select menu item color
function MenuItemCanvas:textColor()

    if self.category == nil then
        print("Received nil item category.  Defaulting text color.")
        return menuItemColors.default.text
    end

    return menuItemColors[self.category].text
end

----------------------------------------------------------------------------------------------------
-- Select background canvas
function MenuItemCanvas:getBackgroundCanvas()
    return
        {
            {
                type = "rectangle",
                action = "fill",
                fillColor = {hex = self:backgroundColor(), alpha = 0.95},
                frame = {
                    x = self.xValue,
                    y = self.yValue,
                    w = self.width,
                    h = self.height
                }
            }
        }
end

----------------------------------------------------------------------------------------------------
-- Select text canvas
function MenuItemCanvas:getTextCanvas()

    assert(menuItemFont, "Can't get menu item font")
    assert(menuItemFontSize, "Can't get menu item font size")
    assert(menuItemTextAlign, "Can't get menu item text align")

    return {
        type = "text",
        text = "    " .. self.displayValue,
        textFont = menuItemFont,
        textSize = menuItemFontSize,
        textColor = {hex = self:textColor(), alpha = 1},
        textAlignment = menuItemTextAlign,
        textLineBreak = "clip",
        frame = {
            x = self.xValue,
            y = self.yValue,
            w = self.width,
            h = self.height
        }
    }
end

return MenuItemCanvas

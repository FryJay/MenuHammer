
----------------------------------------------------------------------------------------------------
------------------------------------ Menu Item Definition ------------------------------------------
----------------------------------------------------------------------------------------------------

local MenuItem = {}
MenuItem.__index = MenuItem

MenuItem.category = nil
MenuItem.modifier = {}
MenuItem.key = nil
MenuItem.desc = nil
MenuItem.args = {}

MenuItem.row = nil
MenuItem.column = nil

MenuItem.xValue = nil
MenuItem.yValue = nil
MenuItem.width = nil
MenuItem.height = nil

MenuItem.textColor = nil
MenuItem.backgroundColor = nil

----------------------------------------------------------------------------------------------------
-- Constructor
function MenuItem.new(category,
                      modifier,
                      key,
                      desc,
                      row,
                      column,
                      width,
                      height)

    assert(desc ~= nil, "Description is nil")
    assert(category, "Category name is nil")
    assert(row, desc .. " row is nil")
    assert(column, desc .. " column is nil")
    assert(type(row) == "number", desc .. " row has type " .. type(index))
    assert(type(column) == "number", desc .. " column has type " .. type(index))

    local self = setmetatable({}, MenuItem)

    self.category = category
    self.modifier = modifier
    self.key = key
    self.desc = desc
    self.row = row
    self.column = column
    self.width = tostring(width)
    self.height = tostring(height)

    self.xValue = tostring(self.column * self.width)
    self.yValue = tostring(self.height * self.row)

    return self
end

function MenuItem:prefix()

    local prefix = menuItemPrefix[self.category]

    assert(prefix ~= nil, "No prefix found for " .. self.desc .. " with category " .. self.category)

    return prefix
end

function MenuItem:displayTitle()

    return self:prefix() .. " " .. self.desc
end

----------------------------------------------------------------------------------------------------
-- Select background canvas
function MenuItem:getBackgroundCanvas()
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
function MenuItem:getTextCanvas()

    assert(menuItemFont, "Can't get menu item font")
    assert(menuItemFontSize, "Can't get menu item font size")
    assert(menuItemTextAlign, "Can't get menu item text align")

    return {
        type = "text",
        text = "    " .. self.desc,
        textFont = menuItemFont,
        textSize = menuItemFontSize,
        textColor = {hex = self:textColor(), alpha = 1},
        textAlignment = menuItemTextAlign,
        frame = {
            x = self.xValue,
            y = self.yValue,
            w = self.width,
            h = self.height
        }
    }
end

----------------------------------------------------------------------------------------------------
-- Select menu item background color
function MenuItem:backgroundColor()

    if self.category == nil then
        print("Received nil item category.  Defaulting background color.")
        return menuItemColors.default.background
    end

    return menuItemColors[self.category].background
end

----------------------------------------------------------------------------------------------------
-- Select menu item color
function MenuItem:textColor()

    if self.category == nil then
        print("Received nil item category.  Defaulting text color.")
        return menuItemColors.default.text
    end

    return menuItemColors[self.category].text
end

return MenuItem

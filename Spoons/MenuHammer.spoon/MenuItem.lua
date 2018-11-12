
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
MenuItem.col = nil

MenuItem.textColor = nil
MenuItem.backgroundColor = nil

----------------------------------------------------------------------------------------------------
-- Constructor
function MenuItem.new(category,
                      modifier,
                      key,
                      desc,
                      index)

    assert(category, "Category name is nil")
    assert(modifier, "Modifier is nil")
    assert(key, "Key is nil")
    assert(desc, "Desc is nil")
    assert(index, "Index is nil")
    assert(type(index) == "number", "Index has type " .. type(index))

    local self = setmetatable({}, MenuItem)

    self.category = category
    self.modifier = modifier
    self.key = key
    self.desc = desc
    self.index = index

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
-- Calculate the row
function MenuItem:calculateRow(index, numberOfColumns)

    assert(index, "Index is nil")
    assert(numberOfColumns, "Number of columns is nil")

    local adjustedIndex = index - 4

    -- If the category is navigation, it's index is the row number
    if self.category == cons.cat.navigation
    then
        return index
    elseif self.category == cons.cat.back then
        return 0
    elseif self.category == cons.cat.exit then
        return 3
    end

    local returnValue = math.floor(adjustedIndex / (numberOfColumns - 1))

    -- Divide the index number by the number of columns and floor the result.
    return returnValue
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

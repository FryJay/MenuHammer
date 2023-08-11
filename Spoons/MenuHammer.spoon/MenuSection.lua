
----------------------------------------------------------------------------------------------------
---------------------------------------- Menu Section Definition -----------------------------------
----------------------------------------------------------------------------------------------------

local MenuSection = {}
MenuSection.__index = MenuSection

----------------------------------------------------------------------------------------------------
-- Constructor
function MenuSection.new(
    numberOfColumns,
    columnWidth
)
    local self = setmetatable({}, MenuSection)

    return self
end

return MenuSection

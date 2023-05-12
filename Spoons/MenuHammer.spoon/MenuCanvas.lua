----------------------------------------------------------------------------------------------------
--------------------------------- MenuCanvas Definition --------------------------------------------
----------------------------------------------------------------------------------------------------

local MenuCanvas = {}
MenuCanvas.__index = MenuCanvas

MenuCanvas.canvas = nil

----------------------------------------------------------------------------------------------------
-- Constructor
function MenuCanvas.new()

    -- Initialize the canvas and give it the default background color.
    local self = setmetatable({}, MenuCanvas)

    self.canvas = hs.canvas.new({x = 0, y = 0, w = 0, h = 0})
    self.canvas:level(hs.canvas.windowLevels.tornOffMenu)
    self.canvas[1] = {
        type = "rectangle",
        action = "fill",
        fillColor = {hex = menuItemColors.default.background, alpha = 0.95},
    }

    return self
end

----------------------------------------------------------------------------------------------------
-- Close the canvas
function MenuCanvas:hide()
    -- Clear off the canvas and hide it
    for i = 2, #self.canvas do
        self.canvas:removeElement(2)
    end
    self.canvas:hide()
end

----------------------------------------------------------------------------------------------------
-- Set the canvas frame
function MenuCanvas:enter(menu)

    assert(menu, "Menu was nil")

    -- Enter the menu
    menu:enter()

    self.canvas:frame(menu:getMenuFrame())

    -- Retrieve the canvases from the menu
    local newMenuCanvases = menu:getMenuDisplay()

    -- Append the new canvases
    for _, newCanvas in pairs(newMenuCanvases) do
        table.insert(self.canvas, newCanvas)
    end

    -- Show the menu
    self.canvas:show()
end

return MenuCanvas

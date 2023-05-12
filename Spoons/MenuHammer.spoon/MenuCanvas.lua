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

    self.canvas:frame(self:getMenuFrame(menu))

    -- Retrieve the canvases from the menu
    local newMenuCanvases = self:getMenuDisplay(menu)

    -- Append the new canvases
    for _, newCanvas in pairs(newMenuCanvases) do
        table.insert(self.canvas, newCanvas)
    end

    -- Show the menu
    self.canvas:show()
end

----------------------------------------------------------------------------------------------------
-- Get the frame to put the menu in
function MenuCanvas:getMenuFrame(menu)

    local windowHeight = menu.windowHeight

    -- Calculate the dimensions using the size of the main screen.
    local cscreen = hs.screen.mainScreen()
    local cres = cscreen:frame()
    local menuFrame = {
        x = cres.x,
        y = cres.y + (cres.h - windowHeight),
        w = cres.w,
        h = windowHeight
    }

    return menuFrame
end

----------------------------------------------------------------------------------------------------
-- Return the canvases to display
function MenuCanvas:getMenuDisplay(menu)

    assert(menu.menuItems, "Menu " .. menu.name .. " has no menu items defined")

    local newCanvases = {}

    -- Loop through each menu item and build them
    for _, menuItem in pairs(menu.menuItems) do

        local menuItemCanvas = menuItem:getCanvas()

        -- Create the background canvas
        local menuItemCanvases = menuItemCanvas:getBackgroundCanvas()

        -- Create the text canvas, if necessary
        if menuItem.desc ~= nil then
            table.insert(menuItemCanvases,
                         menuItemCanvas:getTextCanvas()
            )
        end

        -- Append the new canvases
        for _, newCanvas in pairs(menuItemCanvases) do table.insert(newCanvases, newCanvas) end
    end

    return newCanvases
end

return MenuCanvas

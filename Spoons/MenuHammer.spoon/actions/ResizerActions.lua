BaseAction = dofile(hs.spoons.scriptPath() .. "/BaseAction.lua")

----------------------------------------------------------------------------------------------------
---------------------------------- Resizer Action Definition ---------------------------------------
----------------------------------------------------------------------------------------------------

local ResizerActions = BaseAction.new()

----------------------------------------------------------------------------------------------------
-- Bind resizer
function ResizerActions:runResizer(desc, command)

    local action = command[2]

    assert(action, "Action is nil")

    print("Resizing with action " .. action)
    local function hasValue(tab, val)
        for index, value in ipairs(tab) do
            if value == val then
                return true
            end
        end

        return false
    end

    local resizeActions = {
        {
          -- Move
            types = {
                cons.resizer.left,
                cons.resizer.right,
                cons.resizer.up,
                cons.resizer.down
            },
            actionFunction = function()
                spoon.WinWin:stepMove(action)
            end,
        },
        {
          -- Move and resize
            types = {
                cons.resizer.halfLeft,
                cons.resizer.halfRight,
                cons.resizer.halfUp,
                cons.resizer.halfDown,
                cons.resizer.northWest,
                cons.resizer.northEast,
                cons.resizer.southWest,
                cons.resizer.southEast,
                cons.resizer.fullScreen,
                cons.resizer.centerWindow
            },
            actionFunction = function()
                spoon.WinWin:stash()
                spoon.WinWin:moveAndResize(action)
            end,
        },
        {
          -- Resize
            types = {
                cons.resizer.stepLeft,
                cons.resizer.stepRight,
                cons.resizer.stepUp,
                cons.resizer.stepDown,
            },
            actionFunction = function()
                local newAction = string.sub(action, string.find(action, "_") + 1)
                spoon.WinWin:stepResize(newAction)
            end,
        },
        {
          -- Expand and shrinnk
            types = {
                cons.resizer.expand,
                cons.resizer.shrink
            },
            actionFunction = function()
                spoon.WinWin:moveAndResize(action)
            end,
        },
        {
          -- Move screen
            types = {
                cons.resizer.screenLeft,
                cons.resizer.screenRight,
                cons.resizer.screenUp,
                cons.resizer.screenDown,
                cons.resizer.screenNext
            },
            actionFunction = function()
                local newAction = string.sub(action, string.find(action, "_") + 1)
                spoon.WinWin:stash()
                spoon.WinWin:moveToScreen(newAction)
            end,
        },
        {
          -- Undo
            types = {
                cons.resizer.undo,
            },
            actionFunction = function()
                spoon.WinWin:undo()
            end
        },

        {
          -- Redo
            types = {
                cons.resizer.redo,
            },
            actionFunction = function()
                spoon.WinWin:redo()
            end
        },
        {
          -- Center cursor
            types = {
                cons.resizer.redo,
            },
            actionFunction = function()
                spoon.WinWin:centerCursor()
            end
        },
    }

    for _, resizeAction in ipairs(resizeActions) do
        if hasValue(resizeAction.types, action) then
            resizeAction.actionFunction()
        end
    end

    return true
end

return ResizerActions

----------------------------------------------------------------------------------------------------
---------------------------------- Menu Action Definition ------------------------------------------
----------------------------------------------------------------------------------------------------

local MenuAction = {}
MenuAction.__index = MenuAction

MenuAction.desc = nil
MenuAction.command = nil
MenuAction.parentMenu = nil
MenuAction.storedValues = nil

-- Internal function used to find our location, so we know where to load files from
local function scriptPath()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

MediaActions = dofile(scriptPath() .. "/actions/MediaActions.lua")
ResizerActions = dofile(scriptPath() .. "/actions/ResizerActions.lua")
SystemActions = dofile(scriptPath() .. "/actions/SystemActions.lua")
UserActions = dofile(scriptPath() .. "/actions/UserActions.lua")
NetActions = dofile(scriptPath() .. "/actions/NetActions.lua")
TextActions = dofile(scriptPath() .. "/actions/TextActions.lua")

----------------------------------------------------------------------------------------------------
-- Constructor
function MenuAction.new(desc,
                        command,
                        parentMenu)
    assert(desc, "Description is nil")
    assert(command, "Command is nil")

    local self = setmetatable({}, MenuAction)

    self.desc = desc
    self.command = command
    self.parentMenu = parentMenu
    self.storedValues = parentMenu.menuManager.storedValues

    return self
end

----------------------------------------------------------------------------------------------------
-- Get an action function
function MenuAction:getActionFunction()
    local command = self.command
    local desc = self.desc
    local commandType = command[1]

    local actionTable = {
        [cons.act.menu]         = function()
            -- Open a menu
            return self:switchMenu(desc, command)
        end,
        [cons.act.launcher]     = function()
            -- Launch an application.
            return SystemActions:launchApplication(desc, command)
        end,
        [cons.act.func]         = function()
            -- Execute provided function
            return self:executeFunction(desc, command)
        end,
        [cons.act.userinput]    = function()
            -- Get user input
            return UserActions:getUserInput(desc, command, self.storedValues)
        end,
        [cons.act.keycombo]     = function()
            -- Execute a key combination
            return TextActions:runKeyCommand(desc, command)
        end,
        [cons.act.typetext]     = function()
            -- Type text into current window
            return TextActions:typeText(desc, command)
        end,
        [cons.act.script]       = function()
            -- Execute shell script
            return SystemActions:runScript(desc, command)
        end,
        [cons.act.openurl]      = function()
            -- Open a URL
            return NetActions:openURL(desc, command, self.storedValues)
        end,
        [cons.act.shellcommand] = function()
            -- Execute a shell command
            return SystemActions:runShellCommand(desc, command)
        end,
        [cons.act.openfile]     = function()
            -- Open a file
            return SystemActions:openFile(desc, command)
        end,
        [cons.act.system]       = function()
            -- Perform a system action (reboot, shutdown, etc)
            return SystemActions:runSystemAction(desc, command)
        end,
        [cons.act.sleep]        = function()
            return self:pauseExecution(desc, command)
        end,
        [cons.act.resolution]   = function()
            -- Change the screen resolution
            return SystemActions:changeResolution(desc, command)
        end,
        [cons.act.resizer]      = function()
            -- Resize the screen
            return ResizerActions:runResizer(command)
        end,
        [cons.act.mediakey]     = function()
            -- Press media key
            return MediaActions:runMediaCommand(desc, command, self.storedValues)
        end,
    }

    return actionTable[commandType]
end

----------------------------------------------------------------------------------------------------
-- Open menu
function MenuAction:executeFunction(desc, command)

    local bindFunction = command[2]

    return bindFunction()
end

----------------------------------------------------------------------------------------------------
-- Open menu
function MenuAction:switchMenu(desc, command)

    local menu = command[2]

    assert(menu, "Sub menu is nil for " .. self.parentMenu.name .. " " .. desc)

    self.parentMenu.menuManager:switchMenu(menu)

    return true
end

----------------------------------------------------------------------------------------------------
-- Pause execution
function MenuAction:pauseExecution(desc, command)

    local duration = command[2]

    assert(duration, "No duration provided.")
    assert(tonumber(duration), "Duration provided not a number.")

    print("Sleeping for " .. duration .. " microseconds")

    -- TODO: Try to replace this with something less crappy than a sleep.
    hs.timer.usleep(tonumber(duration))

    return true
end

return MenuAction

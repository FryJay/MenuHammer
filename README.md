# MenuHammer
A Spacemacs inspired menu system for macOS built for Hammerspoon.

![example-menu](https://raw.githubusercontent.com/FryJay/MenuHammer/master/screenshots/MenuHammer-example.png)

It displays user configured menus on the bottom of the screen.  Each menu has series of menu items that can 
perform a series of actions when activated by the configured hotkey.

Those actions include:

- Loading other menus
- Opening applications
- Getting user input
- Executing a lua function
- Executing key combinations
- Typing text into current window
- Executing a shell script (with root privileges if needed)
- Executing a shell command
- Opening a URL
- Sleeping (pause) for a specified amount of time
- Opening files
- Apply window layouts

It has some default menus configured but you will most certainly want to customize it.  Out of the box it will
bind Command-Option-Control-q to enable/disable MenuHammer and Option-Space to show/hide MenuHammer.

It is still very much a work in progress.  I have a large list of features I still want to add and some 
features are only partially implemented.  Use at your own risk.

I've included the WinWin Spoon from [Awesome Hammerspoon](https://github.com/ashfinal/awesome-hammerspoon) for resizing windows.

I'm new to both Hammerspoon and Lua so any feedback is welcome.

## Installing

Install [Hammerspoon](http://www.hammerspoon.org/).

Clone the repository and place MenuHammer.spoon in ~/.hammerspoon/Spoons

Add these two lines to your init.lua to load the menu when Hammerspoon starts:

```lua
    menuHammer = hs.loadSpoon("MenuHammer")
    menuHammer:enter()
```

For customizing menus, colors and other values, create a file called menuHammerCustomConfig.lua in 
~/.hammerspoon and customize to your liking.  Look at MenuHammer.spoon/MenuConfigDefaults.lua for what can
be customized.

## Example Configuration

Here is an example of a basic menu configuration that covers some of the things MenuHammer can do:

```lua
    menuHammerMenuList = {
        mainMenu = {
            parentMenu = nil,
            menuHotkey = {{'alt'}, 'space'},
            menuItems =  {
                {cons.cat.submenu, '', 'A', 'Applications', {
                      {cons.act.menu, "applicationMenu"}
                }},
                {cons.cat.action, '', 'T', "Terminal", {
                      {cons.act.launcher, 'Terminal'}
                }},
                {cons.cat.action, '', 'D', 'Desktop', {
                      {cons.act.launcher, 'Finder'},
                      {cons.act.keycombo, {'cmd', 'shift'}, 'd'},
                }},
                {cons.cat.action, '', 'E', "Split Safari/iTunes", {
                    {cons.act.func, function()
                          -- See Hammerspoon layout documentation for more info on this
                          local mainScreen = hs.screen{x=0,y=0}
                          hs.layout.apply({
                                  {"Safari", nil, mainScreen, hs.layout.left50, nil, nil},
                                  {"iTunes", nil, mainScreen, hs.layout.right50, nil, nil},
                          })
                    end }
                }},
                {cons.cat.action, '', 'H', "Hammerspoon Manual", {
                      {cons.act.func, function()
                          hs.doc.hsdocs.forceExternalBrowser(true)
                          hs.doc.hsdocs.moduleEntitiesInSidebar(true)
                          hs.doc.hsdocs.help()
                      end }
                }},
                {cons.cat.action, ', 'M', 'MenuHammer Default Config', {
                    {cons.act.openfile, "~/.hammerspoon/Spoons/MenuHammer.spoon/MenuConfigDefaults.lua"},
                }},
                {cons.cat.action, '', 'X', "Mute/Unmute", {
                      {cons.act.mediakey, "mute"}
                }},
            }
        },
        applicationMenu = {
            parentMenu = "mainMenu",
            menuHotkey = nil,
            menuItems = {
                {cons.cat.action, '', 'A', "App Store", {
                      {cons.act.launcher, 'App Store'}
                }},
            }
        },
    }
```

The above will configure two menus, the Main Menu which can be loaded with the hotkey "alt-space" and 
the Application Menu which it not bound to a hotkey but is accessible by pressing "A" in the main menu.

## Customizing Menus

Menus are defined in the menuHammerMenuList table.  Each menu can have the following values:

- parentMenu - Optional.  If set, MenuHammer will display a Back command to return to the parent menu.  The
value of parentMenu must match an identifier of another menu.  E.g. to load the Applications menu 
defined above, the identifier must be exactly "applicationMenu".
- menuHotkey - Optional.  A hotkey for loading the menu.  A hotkey is optional on menus but at least one
must be set in order to load MenuHammer.  Any menu that does not have a hotkey or is not linked to from another
menu is unreachable.
- menuItems - A table of menu items that will be shown in the menu.

Example of a basic menu configuration:

```lua
    mainMenu = {
        parentMenu = nil,                 -- The identifier of the parent menu.  Nil if no parent.
        menuHotkey = {{'alt'}, 'space'},  -- The hotkey that loads the menu.  Nil if no hotkey.
        menuItems =  {                    -- The menu items for this menu.
            <menu items go here>
        }
    }
```

## Customizing Menu Items

Menu items are defined in the menuItems table for each menu.  The values sent to them are:

- category - Determines how to display the item.  The background and text colors are chosen by the category.
The "exit" category also closes the menu by default without requiring an action.
- modifiers - The key modifiers (e.g. "alt", "cmd", "shift", "ctrl") to use for the hotkey for this menu item.
If no modifiers are required, enter a blank string or nil.
- key - Required field.  The key to press in the menu to activate the menu item.
- Description - The text to display to the user for this menu item.
- Actions - A table of actions (outlined below) to perform when this menu item is activated.

### Categories

Menu items have a category that are mostly used for formatting purposes.  The only category that performs an
action by default is the "exit" menu item which will always close the open menus.  The category selected 
will determine what default colors are applied and what symbol is displayed as a prefix.  Typically you 
will only need to use "submenu" and "action".  You can use the cons.cat table to refer to 
specific categories.  E.g. cons.cat.menu.

#### Sub Menu - cons.cat.submenu 

This category is used when the menu item is for loading another menu.

For example, this menu item will load the Applications menu:

```lua
    {cons.cat.menu,                           -- Category is menu
     '',                                      -- No modifier
     'A',                                     -- "a" is the hotkey to open the menu
     'Applications',                          -- The description of the menu item to display
     {                                        -- The table of actions to perform
         {cons.act.menu, "applicationMenu"}  -- Action to open the Application menu
     }
    },
```

#### Action - cons.cat.action

This category is used when the menu item performs one or more actions.  MenuHammer closes when actions are 
performed.  MenuHammer will close the open menu when an action is performed.

For example, this menu item will launch the Terminal application:

```lua
    {cons.cat.action,                        -- Category is action 
     '',                                     -- No modifier
     'T',                                    -- "t" is the hokey to activate the action
     "Terminal",                             -- The description of the action
     {                                       -- The table of actions to perform
         {cons.act.launcher, 'Terminal'}     -- Action to launch the Terminal application
     }
    },
```

#### Exit - cons.cat.display

This category is used to display data on the menu.  It will display whatever text is returned from the 
function it is provided.  

TODO: Currently, the function will block the menu from displaying until it completes
but this should be fixed in the future.

TODO: The definition for display items requires a table to surround the function but this serves no purpose
and should be fixed in the future.

For example, this definition will display "Hello" in the menu:

```lua
    {cons.cat.display,                       -- Category is display
     'MenuHammer Repo',                      -- A description (not displayed on the UI)
     {                                       -- A table that I just realized is unnecessary and I might remove.
         function()                          -- The function to execute to get the display value
             return "MH: " .. getGitStatus("~/code/MenuHammer", "master")
         end
     }
    },
```


#### Exit - cons.cat.exit 

Used for menu items that close MenuHammer.  There is an exit action defined by default on all menus that is 
bound to escape.

#### Back - cons.cat.back 

Used for "back buttons" to go to the menu set as the parent menu to the current menu.  There a back action 
defined by default on all menus that is bound to delete.

#### Navigation - cons.cat.navigation

A general category used for any nagivation item that isn't "exit" or "back".  No menu items are defined by 
default with this category.

### Actions

There are several types of actions that can be performed by menu items.  Each menu item can perform a list of
actions.  You can use the cons.act table to refer to specific actions.  E.g. cons.act.menu
to load a menu.

Each action is defined as a table with an action type and a series of other values that are dependent on the
action type.

#### Menu - cons.act.menu

This action loads the menu with the provided identifier. 

Arguments:

- Identifier - The identifier of the menu to load.  If the menu identifier is not found in the menu table, it 
will cause an error.

```lua
    {cons.cat.menu, '', 'A', 'Applications', {
        {
            cons.act.menu,     -- Action type
            "applicationMenu"  -- Identifier
        }
    }},
```

#### Func - cons.act.func

This action will execute the provided function so it can be used to run other HammerSpoon or lua functionality.

Arguments:

- Function - The function to execute when the menu item is activated.

```lua
    {cons.cat.action, 'shift', 'F', "Force Quit Frontmost App", {
        {
            cons.act.func,                                                -- Action type
            function() hs.application.frontmostApplication():kill9() end  -- Function to execute
        }
    }},
```

#### Launcher - cons.act.launcher

This action launches the application with the matching name.  Note that the name of the application must match
exactly to the name of the app.  For example,  you must use "Google Chrome" instead of "Chrome".

Arguments:

- Application name - The exact name of the application to load.

```lua
    {cons.cat.action, '', 'S', "Safari", {
        {
            cons.act.launcher,  -- Action type
            'Safari',           -- Application name
        }
    }},
```

#### User Input - cons.act.userinput

This action will display a popup to the user asking them to provide input.   It will store the value in a table
called "storedValues" that is owned by the MenuHammer object.  The values can be referenecd in future actions
and can be replaced in text using placeholders formatted as "@@valueIdentifier@@".  Text replacement is only
currently implemented on the openurl and texttype actions.

Arguments:

- Value Identifier - An identifier that will be used for storing the value in the storedValues table.
- Message - The message (title) to display to the user in the popup.
- Informative Text - The text (body) to display in the popup.
- Default value - The value to display in the input field when the popup appears.

```lua
    {cons.cat.action, '', 'W', 'Wikipedia',
     {
         {cons.act.userinput,                                             -- Action type
          "luckyWikipedia",                                               -- Value Identifier
          "Lucky Wikipedia",                                              -- Message
          "Google a Wikipedia article and hit I'm Feeling Lucky button"}, -- Informative Text
         {cons.act.openurl,
          "http://www.google.com/search?q=@@luckyWikipedia@@%20site:wikipedia.org&meta=&btnI"
         }
    }},
```

#### Keycombo - cons.act.keycombo

This action will execute the provided key combination.

Arguments:

- Modifiers - A table of the modifiers to use when the key is pressed. 
- Key - The key to execute with the modifiers above.

Here is a basic example of a keycombo:

```lua
    {cons.cat.action, '', 'A', 'Applications Folder', {
        -- Open Finder
        {cons.act.launcher, 'Finder'},
        -- Send the key combo for the Applications folder
        {
            cons.act.keycombo,   -- Action type
            {'cmd', 'shift'},    -- Modifiers
            'a'                  -- Key
        },
    }},
```

#### Type Text - cons.act.typetext

This action will type text into whatever field or window currently has focus.

Arguments:

- Text to type - The text to type into the current field or window.

```lua
    {cons.cat.action, 'shift', 'H', 'Hammerspoon Folder', {
        -- Switch to Finder with a launcher action
        {cons.act.launcher, 'Finder'},
        -- Open "Go to a folder" with a keycombo action
        {cons.act.keycombo, {'cmd', 'shift'}, 'g'},
        -- Enter the text with a typetext action
        {
            cons.act.typetext,  -- Action type
            '~/.hammerspoon\n'  -- Text to type
        },
    }},
```

#### Open URL - cons.act.openurl

This action will open a URL in the default browser.  It will replace any text placeholders with values from the
storedValues table owned by the MenuHammer object.  Placeholders are formatted as @@valueIdentifier@@.

Arguments:

- URL to open - The URL to open in the default browser.

```lua
    {cons.cat.action, '', 'W', 'Wikipedia', {
        {cons.act.userinput,
         "luckyWikipedia", 
         "Lucky Wikipedia",
         "Google a Wikipedia article and hit I'm Feeling Lucky button"}, 
        {
            -- Action type
            cons.act.openurl,
            -- URL to open
            "http://www.google.com/search?q=@@luckyWikipedia@@%20site:wikipedia.org&meta=&btnI"
        }
    }},
```

#### Script - cons.act.script

This action will execute the provided shell script.  Scripts are currently run without any environment 

Arguments:

- Script path - The path to the script.  I haven't tested relative paths but absolute paths and ~/ work.
- Use admin - A flag to indicate whether the script should be run with admin privileges.  Requires ssh_askpass. 

```lua
    {cons.cat.action, '', 'S', 'Run this script', {
        {
            -- Action type
            cons.act.script, 
            -- Location of the script to run
            "~/scripts/some_script.sh"},
    }},
```

#### Shellcommand - cons.act.shellcommand

This action will execute the provided shell command.  It does not currently allow for running it with admin
privileges but it is a feature I plan to add.

Arguments:

- Command - The command to execute in the shell.

```lua
    {cons.cat.action, '', 'W', 'Work Agenda', {
          {cons.act.shellcommand, "sh -c '/usr/local/bin/emacsclient -c ~/docs/MenuHammer.org'"},
    }},
```

#### Openfile - cons.act.openfile

This action will open the provided file in the default application.

Arguments:

- File path - The path to the file to open.

```lua
    {cons.cat.action, '', 'C', 'Hammerspoon init.lua, {
          {
              cons.act.openfile,        -- Action type
              "~/.hammerspoon/init.lua" -- File path
          },
    }},
```

#### Sleep - cons.act.sleep

This action will pause MenuHammer for the specified amount of time.  This can be used to give applications time
to prepare for the next action.

Arguments:

- Duration -  The amount of time in nanoseconds to pause.

```lua
    {cons.cat.action, '', 'C', 'MenuHammer Custom Config', {
        -- Open the Hammerspoon config file
        {cons.act.launcher, "Some App"},
        -- Sleep for a tenth of a second
        {
            cons.act.sleep, -- Action type
            "100000000"     -- Duration
        },
        -- Enter some text
        {cons.act.typetext, 'Some value that needs to wait for the app'},
    }},
```

#### Resolution - cons.act.resolution

This action accepts a resolution mode (defined in hs.screen - https://www.hammerspoon.org/docs/hs.screen.html) 
that will be used to set the resolution of the screen when activated.  By default, MenuHammer includes a
resolution menu that lists all available resolutions.

#### Mediakey - cons.act.mediakey

This action will perform a variety of media related commands.  There is a menu defined by default that shows the
commands available.

The commands include:

- Next track (iTunes)
- Previous track (iTunes)
- Play/Pause (iTunes)
- Mute/Unmute
- Volume up
- Volume down
- Brightness up
- Brightness down

## Screenshots

![basic-main-menu](https://raw.githubusercontent.com/FryJay/MenuHammer/master/screenshots/MenuHammer-basic-main-menu.png)
![basic-app-menu](https://raw.githubusercontent.com/FryJay/MenuHammer/master/screenshots/MenuHammer-basic-app-menu.png)

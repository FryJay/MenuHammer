# MenuHammer
A Spacemacs inspired menu system for macOS built for Hammerspoon.  

It allows for user configured menus with menu items that can perform a series of actions when selected.  
Those actions include:

- Loading other menus
- Opening applications
- Executing key combinations
- Execute a shell script
- Execute a shell command
- Open files (not really implemented yet, only opens files in Emacs)
- Execute a provided lua function

It has some default menus configured but you will most certainly want to customize it.

It is still very much a work in progress.  I have a large list of features I still want to add and some 
features are only partially implemented.  Use at your own risk.

This project started as a clone of the ModalMgr spoon but has since been nearly entirely rewritten.

I'm new to both Hammerspoon and Lua so any feedback is welcome.

## Installing

Install [Hammerspoon](http://www.hammerspoon.org/).

Clone the repository and place MenuHammer.spoon in ~/.hammerspoon/Spoons

Add these two lines to your init.lua to load the menu when Hammerspoon starts:

```lua
    menuHammer = hs.loadSpoon("MenuHammer")
    menuHammer.rootMenu:enter()
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
                {mhConstants.category.menu, '', 'A', 'Applications', {
                     {mhConstants.bind.menu, "applicationMenu""}
                }},
                {mhConstants.category.action, '', 'T', "Terminal", {
                     {mhConstants.bind.launcher, 'Terminal'}
                }},
                {mhConstants.category.action, '', 'D', 'Desktop', {
                     {mhConstants.bind.launcher, 'Finder'},
                     {mhConstants.bind.keycombo, {'cmd', 'shift'}, 'd'},
                }},
                {mhConstants.category.action, '', 'H', "Hammerspoon Manual", {
                     {mhConstants.bind.func, function()
                          hs.doc.hsdocs.forceExternalBrowser(true)
                          hs.doc.hsdocs.moduleEntitiesInSidebar(true)
                          hs.doc.hsdocs.help()
                     end }
                }},
                {mhConstants.category.action, '', 'X', "Mute/Unmute", {
                     {mhConstants.bind.mediakey, "mute"}
                }},
            }
        },
        applicationMenu = {
            parentMenu = "mainMenu",
            menuHotkey = nil,
            menuItems = {
                {mhConstants.category.action, '', 'A', "App Store", {
                     {mhConstants.bind.launcher, 'App Store'}
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

```lua
    mainMenu = {
        parentMenu = nil,
        menuHotkey = {{'alt'}, 'space'},
        menuItems =  {
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

Menu items have a category that are mostly used for display purposes.  The only category that performs an
action by default is the "exit" menu item which will always close MenuHammer.  The category selected 
will determine what default colors are applied and what symbol is displayed as a prefix.  Typically you 
will only need to use "menu" and "action".  You can use the mhConstants.category table to refer to 
specific categories.  E.g. mhConstants.category.menu.

#### Menu - mhConstants.category.menu 

This category is used when the menu item is for loading another menu.

For example, this menu item will load the Applications menu:

```lua
    {mhConstants.category.menu, '', 'A', 'Applications', {
        {mhConstants.bind.menu, "applicationMenu""}
    }},
```

#### Action - mhConstants.category.action

This category is used when the menu item performs one or more actions.  MenuHammer closes when actions are 
performed.  MenuHammer will close the open menu when an action is performed.  

For example, this menu item will launch the Terminal application:

```lua
    {mhConstants.category.action, '', 'T', "Terminal", {
        {mhConstants.bind.launcher, 'Terminal'}
    }},
```

#### Exit - mhConstants.category.exit 

Used for menu items that close MenuHammer.  There is an exit action defined by default on all menus that is 
bound to escape.

#### Back - mhConstants.category.back 

Used for "back buttons" to go to the menu set as the parent menu to the current menu.  There a back action 
defined by default on all menus that is bound to delete.  This category still requires that a "menu" action
be defined though this should be made automatic in the future.

#### Navigation - mhConstants.category.navigation

A general category used for any nagivation item that isn't "exit" or "back".  No menu items are defined by 
default with this category.

### Actions

There are several types of actions that can be performed by menu items.  Each menu item can perform a list of
actions.  You can use the mhConstant.action table to refer to specific actions.  E.g. mhConstants.action.menu
to load a menu.

Each action is defined as a table with an action type and a series of other values that are dependent on the
action type.

#### Menu - mhConstants.action.menu

This action loads the menu with the provided identifier. 

Arguments:

- Identifier - The identifier of the menu to load.  If the menu identifier is not found in the menu table, it 
will cause an error.

```lua
    {mhConstants.category.menu, '', 'A', 'Applications', {
        {mhConstants.bind.menu, "applicationMenu""}
    }},
```

#### Launcher - mhConstants.action.launcher

This action launches the application with the matching name.  Note that the name of the application must match
exactly to the name of the app.  For example,  you must use "Google Chrome" instead of "Chrome".

Arguments:

- Application name - The exact name of the application to load.
- Close menu - A boolean that indicates whether the menu should close after the action is performed.

```lua
    {mhConstants.category.action, '', 'S', "Safari", {
          {mhConstants.bind.launcher, 'Safari'}
    }},
```

#### Keycombo - mhConstants.action.keycombo

This action will execute the provided key combination.

Arguments:

- Modifiers - A table of the modifiers to use when the key is pressed.  There are also two alternate values 
here that will be moved into their own actions in the future.  If you put "type" as the modifier, MenuHammer
will type the key value as if you were typing it at the keyboard.  If you put "sleep" as the modifier,
MenuHammer will pause for the amount of time provided in the key argument.  This is not an ideal place for
this functionality but it's an artifact of how it changed while I was developing it.
- Key - The key to execute with the modifiers above.  As described above, this can also be keys that will be 
typed by MenuHammer or a number used for sleeping the application (in nanoseconds).

Here is a basic example of a keycombo:

```lua
    {mhConstants.category.action, '', 'A', 'Applications Folder', {
          {mhConstants.bind.launcher, 'Finder'},
          {mhConstants.bind.keycombo, {'cmd', 'shift'}, 'a'},
    }},
```

Here is an example of the "type" modifier:

```lua
    {mhConstants.category.action, 'shift', 'H', 'Hammerspoon Folder', {
          {mhConstants.bind.launcher, 'Finder'},
          {mhConstants.bind.keycombo, {'cmd', 'shift'}, 'g'},
          {mhConstants.bind.keycombo, {'type'}, '~/.hammerspoon\n'},
    }},
```

Here is an example of the "sleep" modifier:

```lua
    {mhConstants.category.action, 'shift', 'H', 'Hammerspoon Folder', {
          {mhConstants.bind.launcher, 'Some app'},
          {mhConstants.bind.keycombo, {'sleep'}, "1000000"},
          {mhConstants.bind.keycombo, {'type'}, 'Some value that needs to wait for the app'},
    }},
```

#### Func - mhConstants.action.func

This action will execute the provided function so it can be used to run other HammerSpoon or lua functionality.

Arguments:

- Function - The function to execute when the menu item is activated.

```lua
    {mhConstants.category.action, 'shift', 'F', "Force Quit Frontmost App", {
          {mhConstants.bind.func, function() hs.application.frontmostApplication():kill9() end }
    }},
```

#### Script - mhConstants.action.script

This action will execute the provided shell script.

Arguments:

- Script path - The path to the script.  I haven't tested relative paths but absolute paths and ~/ work.
- Use admin - A flag to indicate whether the script should be run with admin privileges.  Requires ssh_askpass. 
This option currently does not work and will result in an error.

```lua
    {mhConstants.category.action, '', 'S', 'Run this script', {
        {mhConstants.bind.script, "~/scripts/some_script.sh"},
    }},
```

#### Shellcommand - mhConstants.action.shellcommand

This action will execute the provided shell command.  It does not currently allow for running it with admin
privileges but it is a feature I plan to add.

Arguments:

- Command - The command to execute in the shell.

```lua
    {mhConstants.category.action, '', 'W', 'Work Agenda', {
          {mhConstants.bind.shellcommand, "sh -c '/usr/local/bin/emacsclient -c ~/docs/MenuHammer.org'"},
    }},
```

#### Resolution - mhConstants.action.resolution

This action accepts a resolution mode (defined in hs.screen - https://www.hammerspoon.org/docs/hs.screen.html) 
that will be used to set the resolution of the screen when activated.  By default, MenuHammer includes a
resolution menu that lists all available resolutions.

#### Mediakey - mhConstants.action.mediakey

I intend to remove this action entirely.  It can currently perform various media commands (play/pause, next,
etc.) but it would make more sense to use function actions instead.

##### Openfile - mhConstants.action.openfile

This action does not currently function as intended.  I'll fill this in later when it does.

## Screenshots

![basic-main-menu](https://raw.githubusercontent.com/FryJay/MenuHammer/master/screenshots/MenuHammer-basic-main-menu.png)
![basic-app-menu](https://raw.githubusercontent.com/FryJay/MenuHammer/master/screenshots/MenuHammer-basic-app-menu.png)

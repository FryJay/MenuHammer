# MenuHammer
A Spacemacs inspired menu system for macOS built for Hammerspoon.  

It allows for user configured menus with menu items that can perform a series of actions when selected.  Those actions include:
- Loading other menus
- Opening applications
- Executing key combinations
- Execute a shell script
- Execute a shell command
- Open files (not really implemented yet, only opens files in Emacs)
- Execute a provided lua function

It has some default menus configured but you will most certainly want to customize it.

It is still very much a work in progress.  I have a large list of features I still want to add and some features are only partially implemented.  Use at your own risk.

## Installing

1. Install [Hammerspoon](http://www.hammerspoon.org/).

2. Clone the repository and place MenuHammer.spoon in ~/.hammerspoon/Spoons

3. Add these two lines to your init.lua to load the menu when Hammerspoon starts:
menuHammer = hs.loadSpoon("MenuHammer")
menuHammer.rootMenu:enter()

3. For customizing menu layouts, create a file called menuHammerCustomConfig.lua in ~/.hammerspoon.

4. Customize menuHammerCustomConfig.lua with your preferred menu structure.  Look at MenuHammer.spoon/MenuConfigDefaults.lua for ideas on how it works and what options are configurable.

## Screenshots

![basic-main-menu](https://raw.githubusercontent.com/FryJay/MenuHammer/master/screenshots/MenuHammer-basic-main-menu.png)
![basic-app-menu](https://raw.githubusercontent.com/FryJay/MenuHammer/master/screenshots/MenuHammer-basic-app-menu.png)


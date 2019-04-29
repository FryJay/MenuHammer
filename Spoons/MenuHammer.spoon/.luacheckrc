unused_args = false
allow_defined_top = true

globals = {
    -- Hammerspoon
    "hs",
    "spoon",

    "menuHammer",

    -- General config
    "menuShowInFullscreen",
    "showMenuBarItem",
    "menuTextEditor",
    "askpassLocation",

    -- Menu config
    "menuHammerToggleKey",
    "menuHammerMenuList",

    -- Menu options
    "menuNumberOfColumns",
    "menuMinNumberOfRows",
    "menuRowHeight",
    "menuOuterPadding",

    -- Font options
    "menuItemFont",
    "menuItemFontSize",
    "menuItemTextAlign",

    "menuItemPrefix",
    "menuItemColors",
    "cons",

    -- Supporting functions
    "tableLength",
    "resolutionMenuItems",
}

read_globals = {
    string = {fields = {"split"}},
    table = {fields = {"copy", "getn"}},

    -- Builtin
    "vector", "ItemStack",
    "dump", "DIR_DELIM", "VoxelArea", "Settings",

    -- MTG
    "default", "sfinv", "creative",
}
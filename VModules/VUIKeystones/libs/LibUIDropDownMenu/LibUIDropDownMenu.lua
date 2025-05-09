-- This is a stripped-down version of LibUIDropDownMenu
-- The original library would be used in a full implementation

-- Define global variable for the library
UIDROPDOWNMENU_MAXLEVELS = 2
UIDROPDOWNMENU_MAXBUTTONS = 8

-- Using the LibStub library to manage versions
local MAJOR, MINOR = "LibUIDropDownMenu-4.0", 1
local LibStub = LibStub
local lib = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then return end

-- Basic functionality to support the VUIKeystones module
lib.UIDropDownMenu_Initialize = function() end
lib.UIDropDownMenu_CreateInfo = function() return {} end
lib.UIDropDownMenu_AddButton = function() end
lib.UIDropDownMenu_SetWidth = function() end
lib.UIDropDownMenu_SetButtonWidth = function() end
lib.UIDropDownMenu_JustifyText = function() end
lib.UIDropDownMenu_SetText = function() end

function lib.Create_UIDropDownMenu(name, parent)
    local frame = CreateFrame("Frame", name, parent or UIParent, "UIDropDownMenuTemplate")
    return frame
end

-- Expose the library to the global scope
_G["LibUIDropDownMenu-4.0"] = lib

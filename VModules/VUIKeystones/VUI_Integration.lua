-- Integration with the main VUI addon
local addonName, addon = ...

-- Register with the main VUI addon if it exists
if VUI and VUI.RegisterModule then
    VUI:RegisterModule("VUIKeystones", addon)
elseif VUI then
    -- Fallback if RegisterModule doesn't exist
    VUI.VUIKeystones = addon
    -- Silently register, message suppressed to avoid double messages
end

-- Add the module to the categorized list if the Categories system exists
if VUI and VUI.Categories and VUI.Categories.RegisterModule then
    VUI.Categories:RegisterModule("VUIKeystones", "Dungeons", {
        name = "VUI Keystones",
        description = "Mythic+ keystone dungeon enhancements",
        icon = "Interface\\Icons\\INV_Relics_Hourglass",
        author = "VUI Team"
    })
end 
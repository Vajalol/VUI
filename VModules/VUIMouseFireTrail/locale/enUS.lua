-- VUIMouseFireTrail Localization - English (US)
local AddonName, VUI = ...
local L = LibStub("AceLocale-3.0"):NewLocale("VUI", "enUS", true)
if not L then return end

-- Module name and description
L["VUI Mouse Fire Trail"] = true
L["Creates customizable effects that follow your mouse cursor"] = true

-- General settings
L["General Settings"] = true
L["Enable Mouse Trail Effects"] = true
L["Enable or disable the mouse cursor trail effects"] = true
L["Trail Type"] = true
L["Select the type of trail effect"] = true
L["Particle Effect"] = true
L["Texture"] = true
L["Shape"] = true
L["Glow"] = true
L["Trail Count"] = true
L["Number of segments in the trail"] = true
L["Trail Size"] = true
L["Size of each trail segment"] = true
L["Trail Opacity"] = true
L["Transparency of the trail"] = true
L["Trail Fade Speed"] = true
L["How quickly the trail fades (lower values = faster fade)"] = true

-- Appearance settings
L["Appearance"] = true
L["Color Mode"] = true
L["Select the coloring style for the trail"] = true
L["Fire"] = true
L["Arcane"] = true
L["Frost"] = true
L["Nature"] = true
L["Rainbow"] = true
L["Theme Color"] = true
L["Custom Color"] = true
L["Shape Type"] = true
L["Select the shape for shape-type trails"] = true
L["V Shape"] = true
L["Arrow"] = true
L["U Shape"] = true
L["Ellipse"] = true
L["Spiral"] = true
L["Texture Category"] = true
L["Select the texture category for texture-type trails"] = true
L["Size Variation"] = true
L["Random variation in size of trail elements (0 = none, 1 = maximum)"] = true

-- Special Effects
L["Special Effects"] = true
L["Connect Trail Segments"] = true
L["Draw lines between trail segments"] = true
L["Enable Glow Effect"] = true
L["Add a glow effect around the cursor"] = true
L["Pulsing Glow"] = true
L["Make the glow effect pulse"] = true

-- Display Conditions
L["Display Conditions"] = true
L["Show in Combat"] = true
L["Display the trail during combat"] = true
L["Show in Dungeons/Raids"] = true
L["Display the trail in instances"] = true
L["Show in Rest Areas"] = true
L["Display the trail in cities and inns"] = true
L["Show in Open World"] = true
L["Display the trail in the open world"] = true
L["Require Mouse Button"] = true
L["Only show the trail when a mouse button is held down"] = true
L["Require Key Modifier"] = true
L["Only show the trail when a modifier key (Shift, Ctrl, Alt) is held"] = true

-- Slash command responses
L["Enabled"] = true
L["Disabled"] = true
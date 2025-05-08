local addonName, VUI = ...

-- Localization support for VUINotifications module
VUI.Notifications.L = {}
local L = VUI.Notifications.L

-- English (default)
L["VUINOTIFICATIONS"] = "VUI Notifications"
L["VUINOTIFICATIONS_DESC"] = "Combat notifications for interrupts, dispels, misses and more"
L["REFLECTED"] = "Reflected"
L["GROUNDED"] = "Grounded"
L["DISPELLED"] = "Dispelled"
L["INTERRUPTED"] = "Interrupted"
L["STOLE"] = "Stole"
L["PET_DEAD"] = "Pet dead"
L["ENABLE_NOTIFICATIONS"] = "Enable Notifications"
L["ENABLE_NOTIFICATIONS_DESC"] = "Show notifications for combat events like interrupts, dispels, and misses"
L["ENABLE_SOUNDS"] = "Enable Sounds"
L["ENABLE_SOUNDS_DESC"] = "Play sounds for important notifications"
L["SUPPRESS_ERRORS"] = "Suppress Common Errors"
L["SUPPRESS_ERRORS_DESC"] = "Hide common combat error messages like 'Not enough energy', 'Out of range', etc."
L["NOTIFICATION_TYPES"] = "Notification Types"
L["NOTIFICATION_TYPES_DESC"] = "Configure which types of notifications to show"
L["SHOW_INTERRUPTS"] = "Show Interrupts"
L["SHOW_INTERRUPTS_DESC"] = "Show notifications when you successfully interrupt a spell"
L["SHOW_DISPELS"] = "Show Dispels"
L["SHOW_DISPELS_DESC"] = "Show notifications when you successfully dispel a buff or debuff"
L["SHOW_MISSES"] = "Show Misses"
L["SHOW_MISSES_DESC"] = "Show notifications when your abilities miss, are dodged, parried, etc."
L["SHOW_REFLECTS"] = "Show Reflects"
L["SHOW_REFLECTS_DESC"] = "Show notifications when spells are reflected"
L["SHOW_PET_STATUS"] = "Show Pet Status"
L["SHOW_PET_STATUS_DESC"] = "Show notifications when your pet dies"

-- Add additional language localizations here
-- German
if GetLocale() == "deDE" then
    -- German translations
end

-- Spanish
if GetLocale() == "esES" or GetLocale() == "esMX" then
    -- Spanish translations
end

-- French
if GetLocale() == "frFR" then
    -- French translations
end

-- Italian
if GetLocale() == "itIT" then
    -- Italian translations
end

-- Korean
if GetLocale() == "koKR" then
    -- Korean translations
end

-- Brazilian Portuguese
if GetLocale() == "ptBR" then
    -- Brazilian Portuguese translations
end

-- Russian
if GetLocale() == "ruRU" then
    -- Russian translations
end

-- Chinese (Simplified)
if GetLocale() == "zhCN" then
    -- Chinese (Simplified) translations
end

-- Chinese (Traditional)
if GetLocale() == "zhTW" then
    -- Chinese (Traditional) translations
end
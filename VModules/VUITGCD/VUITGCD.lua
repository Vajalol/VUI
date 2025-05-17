-- TrufiGCD for VUI
-- Original TrufiGCD by stevemyz@gmail.com, VUI integration by VUI team
-- This module exactly matches the functionality of the original TrufiGCD addon

-- The module initializes settings and provides all necessary user events to the modules.

local IS_RETAIL = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

-- Get addon namespace
---@type string, Namespace
local addonName, VUI = ...
local ns = {}

-- Create the module
local M = {}
if VUI and VUI.NewModule then
    M = VUI:NewModule("VUITGCD", "AceEvent-3.0")
else
    M = {}
    M.NAME = "VUITGCD"
    M.Debug = function(self, msg) print("[VUITGCD] " .. tostring(msg)) end
    M.OnInitialize = function() end
    M.OnEnable = function() end
end

-- Set up global namespace
if not _G.VUITGCD then _G.VUITGCD = {} end
VUI.VUITGCD = M

-- Set up the NS namespace for TrufiGCD compatibility
_G.VUI.TGCD = _G.VUI.TGCD or {}
ns = _G.VUI.TGCD

-- Initialize default required namespaces
ns.units = ns.units or {}
ns.settings = ns.settings or {}
ns.settingsFrame = ns.settingsFrame or {}
ns.blocklistFrame = ns.blocklistFrame or {}
ns.profileFrame = ns.profileFrame or {}
ns.locationCheck = ns.locationCheck or {}
ns.constants = ns.constants or { unitTypes = {} }

-- Create a function to check if units are equal
---@param unitA UnitType
---@param unitB UnitType
---@return boolean
local function areUnitsEqual(unitA, unitB)
    local nameA = UnitName(unitA)
    return nameA and nameA == UnitName(unitB) and UnitHealth(unitA) == UnitHealth(unitB)
end

---@param unitType UnitType
local function checkIfUnitAlreadyInUse(unitType)
    if not ns.constants or not ns.constants.unitTypes or not ns.units then
        return -- Guard against nil values
    end
    
    for _, existedUnitType in ipairs(ns.constants.unitTypes) do
        if existedUnitType and unitType and ns.units[existedUnitType] and ns.units[unitType] and 
           type(ns.units[unitType].Copy) == "function" and areUnitsEqual(unitType, existedUnitType) then
            ns.units[unitType]:Copy(ns.units[existedUnitType])
            return
        end
    end
end

-- Module initialization
function M:OnInitialize()
    -- Initialize database with VUI integration
    if VUI and VUI.db then
        -- Make sure namespaces exist
        if not VUI.db.namespaces then
            VUI.db.namespaces = {}
        end
        
        -- Check if a namespace already exists
        local namespace = VUI.db.namespaces["VUITGCD"] or VUI.db.namespaces["vuitgcd"]
        
        if namespace then
            -- Use existing namespace
            self.db = namespace
        else
            -- Create new namespace with default settings
            self.db = VUI.db:RegisterNamespace("VUITGCD", {
                profile = {
                    enabled = true,
                    -- Default settings will be applied by the Settings module
                }
            })
        end
        
        -- Ensure vmodules path exists for settings UI integration
        if not VUI.db.profile.vmodules then
            VUI.db.profile.vmodules = {}
        end
        
        if not VUI.db.profile.vmodules.vuitgcd then
            VUI.db.profile.vmodules.vuitgcd = {}
        end
    end
    
    -- Register with VUI Config if available
    if VUI.Config then
        VUI.Config:RegisterModuleOptions("VUITGCD", self:GetOptions(), "Global Cooldowns")
    end
    
    -- Setup events for target/focus changes and spell events
    self:RegisterModuleEvents()
end

-- Enable the module
function M:OnEnable()
    -- Load settings
    if ns.settings and type(ns.settings.Load) == "function" then
        ns.settings:Load()
        
        -- Sync UI components if they exist
        if ns.settingsFrame and ns.settingsFrame.syncWithSettings then
            ns.settingsFrame.syncWithSettings()
        end
        
        if ns.blocklistFrame and ns.blocklistFrame.syncWithSettings then
            ns.blocklistFrame.syncWithSettings()
        end
        
        if ns.profileFrame and ns.profileFrame.syncWithSettings then
            ns.profileFrame.syncWithSettings()
        end
        
        -- Update location settings
        if ns.locationCheck and ns.locationCheck.settingsChanged then
            ns.locationCheck.settingsChanged()
        end
    end
end

-- Register all events needed by the module
function M:RegisterModuleEvents()
    -- Register for target/focus changed events
    local targetFocusChangeFrame = CreateFrame("Frame", nil, UIParent)
    targetFocusChangeFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
    targetFocusChangeFrame:RegisterEvent('PLAYER_FOCUS_CHANGED')
    targetFocusChangeFrame:SetScript("OnEvent", function(_, changeEvent)
        if changeEvent == "PLAYER_TARGET_CHANGED" then
            if ns.units and ns.units.target and ns.units.target.Clear then
                ns.units.target:Clear()
                if ns.settings and ns.settings.activeProfile and 
                   ns.settings.activeProfile.layoutSettings and 
                   ns.settings.activeProfile.layoutSettings.target and 
                   ns.settings.activeProfile.layoutSettings.target.enable then
                    checkIfUnitAlreadyInUse("target")
                end
            end
        elseif changeEvent == "PLAYER_FOCUS_CHANGED" then
            if ns.units and ns.units.focus and ns.units.focus.Clear then
                ns.units.focus:Clear()
                if ns.settings and ns.settings.activeProfile and 
                   ns.settings.activeProfile.layoutSettings and 
                   ns.settings.activeProfile.layoutSettings.focus and 
                   ns.settings.activeProfile.layoutSettings.focus.enable then
                    checkIfUnitAlreadyInUse("focus")
                end
            end
        end
    end)

    --Delay the initialisation to prevent odd abilities spam at the first world enter
    C_Timer.After(0.5, function()
        local spellEventFrame = CreateFrame("Frame", nil, UIParent)
        spellEventFrame:RegisterEvent("UNIT_SPELLCAST_START")
        spellEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
        spellEventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
        spellEventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
        spellEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")

        if IS_RETAIL then
            spellEventFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START")
            spellEventFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
        end

        spellEventFrame:SetScript("OnEvent", function(_, unitEvent, unitType, castId, spellId)
            if not unitType or not spellId then return end
            
            -- Convert parameters to expected types
            if type(spellId) == "string" then
                spellId = tonumber(spellId)
            end
            
            if not spellId or spellId == 0 then return end
            
            if ns.units and ns.units[unitType] and 
               type(ns.units[unitType].OnSpellEvent) == "function" and
               ns.locationCheck and 
               ns.locationCheck.isAddonEnabled and 
               type(ns.locationCheck.isAddonEnabled) == "function" and
               ns.locationCheck.isAddonEnabled() then
                
                -- Use pcall to safely handle any errors
                local success, errorMsg = pcall(function()
                    -- Explicitly call the method with colon syntax
                    ns.units[unitType]:OnSpellEvent(unitEvent, spellId, unitType, castId)
                end)
                
                -- Log errors but don't crash the addon
                if not success and VUI and VUI.Debug then
                    VUI:Debug("VUITGCD", "Error in OnSpellEvent: " .. tostring(errorMsg))
                end
            end
        end)
    end)

    -- Setup the update frame for animation
    local minUpdateInterval = 0.03
    local lastUpdateTime = GetTime()

    local updateFrame = CreateFrame("Frame", nil, UIParent)
    updateFrame:SetScript("OnUpdate", function()
        local time = GetTime()
        local interval = time - lastUpdateTime
        if interval > minUpdateInterval then
            if ns.units then
                for unitType, unit in pairs(ns.units) do
                    if unit and type(unit.Update) == "function" then
                        -- Use pcall to handle any errors
                        pcall(function()
                            unit:Update(time, interval)
                        end)
                    end
                end
            end
            lastUpdateTime = time
        end
    end)
end

-- Options interface for VUI Config
function M:GetOptions()
    -- This will be replaced with actual options in the Config/layout/_VUITGCD.lua file
    return {
        name = "Global Cooldowns",
        type = "group",
        args = {
            toggleButton = {
                type = "execute",
                name = "Open Settings",
                desc = "Open the TrufiGCD settings panel",
                func = function()
                    if ns.settingsFrame and ns.settingsFrame.frame then
                        if ns.settingsFrame.frame.Show then
                            ns.settingsFrame.frame:Show()
                        end
                    end
                end,
                order = 1
            },
            toggleAnchors = {
                type = "execute",
                name = "Show Anchors",
                desc = "Show or hide frame anchors",
                func = function()
                    if ns.settingsFrame and ns.settingsFrame.toggleAnchors then
                        ns.settingsFrame.toggleAnchors()
                    end
                end,
                order = 2
            },
            generalSettings = {
                type = "group",
                name = "General",
                order = 10,
                args = {
                    enableModule = {
                        type = "toggle",
                        name = "Enable VUITGCD",
                        desc = "Enable or disable the VUITGCD module",
                        get = function() return self.db.profile.enabled end,
                        set = function(_, value) 
                            self.db.profile.enabled = value
                            -- Sync with TrufiGCD settings
                            if ns.settings and ns.settings.activeProfile and ns.settings.activeProfile.enabledIn then
                                ns.settings.activeProfile.enabledIn.enabled = value
                                if ns.locationCheck and ns.locationCheck.settingsChanged then
                                    ns.locationCheck.settingsChanged()
                                end
                                if ns.settings.Save then
                                    ns.settings:Save()
                                end
                            end
                        end,
                        width = "full",
                        order = 1
                    },
                    iconSize = {
                        type = "range",
                        name = "Icon Size",
                        desc = "Size of the ability icons",
                        min = 16,
                        max = 64,
                        step = 1,
                        get = function() return self.db.profile.iconSize end,
                        set = function(_, value) 
                            self.db.profile.iconSize = value
                            -- Sync with TrufiGCD settings
                            if ns.settings and ns.settings.activeProfile and ns.settings.activeProfile.layoutSettings then
                                for _, layoutSettings in pairs(ns.settings.activeProfile.layoutSettings) do
                                    layoutSettings.iconSize = value
                                end
                                if ns.settings.Save then
                                    ns.settings:Save()
                                end
                            end
                        end,
                        width = "double",
                        order = 2
                    },
                    maxIcons = {
                        type = "range",
                        name = "Max Icons",
                        desc = "Maximum number of icons to display per unit",
                        min = 1,
                        max = 16,
                        step = 1,
                        get = function() return self.db.profile.maxIcons end,
                        set = function(_, value) 
                            self.db.profile.maxIcons = value
                            -- Sync with TrufiGCD settings
                            if ns.settings and ns.settings.activeProfile and ns.settings.activeProfile.layoutSettings then
                                for _, layoutSettings in pairs(ns.settings.activeProfile.layoutSettings) do
                                    layoutSettings.iconsNumber = value
                                end
                                if ns.settings.Save then
                                    ns.settings:Save()
                                end
                            end
                        end,
                        width = "double",
                        order = 3
                    }
                }
            }
        }
    }
end

-- Return the module for use in other files
return M

---@type string, Namespace
local _, ns = ...

---@class Settings
local Settings = {}
Settings.__index = Settings

local temporalProfileId = "-1"

-- Ensure needed namespaces exist
ns.ProfileSettings = ns.ProfileSettings or {}
if not ns.ProfileSettings.New then
    ns.ProfileSettings.New = function(savedVariables)
        -- Define constants if not available yet
        if not ns.constants then 
            ns.constants = {}
            ns.constants.unitTypes = ns.constants.unitTypes or {"player", "target", "focus", "party1", "party2", "party3", "party4"}
            ns.constants.layoutTypes = ns.constants.layoutTypes or {"player", "party", "arena", "target", "focus"}
        end
        
        -- Create an empty layoutSettings table 
        local layoutSettings = {}
        for _, layoutType in ipairs(ns.constants.layoutTypes or {}) do
            layoutSettings[layoutType] = {
                enable = false,
                direction = "Left",
                iconSize = 30,
                iconsNumber = 3
            }
        end
        
        -- Make sure player layout is enabled by default
        if layoutSettings.player then
            layoutSettings.player.enable = true
        end
        
        return {
            id = savedVariables and savedVariables.id or ns.utils and ns.utils.uuid() or "default",
            name = savedVariables and savedVariables.name or ns.utils and ns.utils.defaultProfileName() or "Default",
            enabledIn = {enabled = true, party = true, arena = true, battleground = true, world = true, raid = true, combatOnly = false},
            blocklist = savedVariables and savedVariables.TrGCDBL or {},
            layoutSettings = layoutSettings,
            -- Add minimal required properties
            GetSavedVariables = function(self)
                return {
                    id = self.id,
                    name = self.name,
                    TrGCDBL = self.blocklist or {}
                }
            end
        }
    end
end

-- Default unit settings
ns.UnitSettings = ns.UnitSettings or {}
if not ns.UnitSettings.New then
    ns.UnitSettings.New = function(unitType)
        return {
            size = 30,
            alpha = 1.0,
            SetFromSavedVariables = function() end,
            GetSavedVariables = function() return {} end
        }
    end
end

-- Default layout settings
ns.LayoutSettings = ns.LayoutSettings or {}
if not ns.LayoutSettings.New then
    ns.LayoutSettings.New = function()
        return {
            enable = false,
            SetFromSavedVariables = function() end,
            GetSavedVariables = function() return {} end
        }
    end
end

function Settings:New()
    ---@class Settings
    local obj = setmetatable({}, Settings)

    obj.activeProfile = ns.ProfileSettings:New({
        id = temporalProfileId,
        name = "Default",
    })

    ---@type {[string]: ProfileSettings}
    obj.profiles = {
        [obj.activeProfile.id] = obj.activeProfile
    }

    return obj
end

function Settings:Load()
    ---@type CharacterSavedVariablesV1 | CharacterSavedVariablesV2
    _G.TrufiGCDChSave = _G.TrufiGCDChSave or {}

    ---@type GlobalSavedVariablesV1 | GlobalSavedVariablesV2
    _G.TrufiGCDGlSave = _G.TrufiGCDGlSave or {}

    self.profiles = {}

    -- Load only a new version of the global saved variables
    if type(_G.TrufiGCDGlSave.profiles) == "table" then
        local newGlobalVariables = _G.TrufiGCDGlSave --[[@as GlobalSavedVariablesV1 | GlobalSavedVariablesV2]]
        for _, profileVariables in pairs(newGlobalVariables.profiles) do
            local profile = ns.ProfileSettings:New(profileVariables)
            self.profiles[profile.id] = profile
        end
    end

   if type(_G.TrufiGCDChSave.profileId) == "string" and self.profiles[_G.TrufiGCDChSave.profileId] then
        self.activeProfile = self.profiles[_G.TrufiGCDChSave.profileId]
    end

    if not next(self.profiles) then
        local defaultProfile = ns.ProfileSettings:New({
            id = ns.utils and ns.utils.uuid() or "default",
            name = ns.utils and ns.utils.defaultProfileName() or "Default",
        })
        self.profiles[defaultProfile.id] = defaultProfile
        self.activeProfile = defaultProfile
    end

    if self.activeProfile.id == temporalProfileId then
        if type(_G.TrufiGCDGlSave.lastUsedProfileId) == "string" and self.profiles[_G.TrufiGCDGlSave.lastUsedProfileId] then
            self.activeProfile = self.profiles[_G.TrufiGCDGlSave.lastUsedProfileId]
        else
            local _, profile = next(self.profiles)
            self.activeProfile = profile --[[@as ProfileSettings]]
        end
    end

    self:Save()
end

function Settings:Save()
    ---@type GlobalSavedVariablesV2
    _G.TrufiGCDGlSave = {
        version = 2,
        profiles = {},
        lastUsedProfileId = self.activeProfile and self.activeProfile.id or "default",
    }

    for _, profile in pairs(self.profiles) do
        if profile and profile.GetSavedVariables then
            _G.TrufiGCDGlSave.profiles[profile.id] = profile:GetSavedVariables()
        end
    end

    ---@type CharacterSavedVariablesV2
    _G.TrufiGCDChSave = {
        version = 2,
        profileId = self.activeProfile and self.activeProfile.id or "default",
    }
end

---@param name string
function Settings:CreateNewProfile(name)
    if not self.activeProfile then
        local defaultProfile = ns.ProfileSettings:New({
            id = ns.utils and ns.utils.uuid() or "default",
            name = ns.utils and ns.utils.defaultProfileName() or "Default",
        })
        self.profiles[defaultProfile.id] = defaultProfile
        self.activeProfile = defaultProfile
    end

    local profile = ns.ProfileSettings:New(self.activeProfile:GetSavedVariables())
    profile.id = ns.utils and ns.utils.uuid() or "new_profile"
    profile.name = name or "New Profile"

    self.profiles[profile.id] = profile
    self.activeProfile = profile
end

function Settings:DeleteCurrentProfile()
    if self.activeProfile and self.activeProfile.id then
        self.profiles[self.activeProfile.id] = nil
    end

    if not next(self.profiles) then
        local defaultProfile = ns.ProfileSettings:New({
            id = ns.utils and ns.utils.uuid() or "default",
            name = ns.utils and ns.utils.defaultProfileName() or "Default",
        })
        self.profiles[defaultProfile.id] = defaultProfile
        self.activeProfile = defaultProfile
    else
        local _, profile = next(self.profiles)
        self.activeProfile = profile --[[@as ProfileSettings]]
    end
end

ns.settings = Settings:New()

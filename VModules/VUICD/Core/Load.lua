local AddOnName, NS = ...

-- Use global reference pattern to avoid load order issues
_G["VUICD"] = _G["VUICD"] or {}
local VUICD = _G["VUICD"]

-- Use global reference for localization
local L = _G["VUICD"].L or {}
local db = VUICD.db or {}

-- Module loading sequence
-- Store the original functions if they exist so we can call them later
local original_OnInitialize = VUICD.OnInitialize
local original_OnEnable = VUICD.OnEnable
local original_OnDisable = VUICD.OnDisable

-- Override the initializers with our enhanced version
-- This avoids the duplicate field error by properly extending the existing function
VUICD.OnInitialize = function(self)
    -- Call original if it exists and is a function
    if original_OnInitialize and type(original_OnInitialize) == "function" then
        original_OnInitialize(self)
    end
    
    -- Using the database namespace created in Init.lua
    -- No need to recreate it or overwrite it with VUI_SavedVariables.VUICD
    -- which would cause database conflicts
    
    -- For backward compatibility, migrate any data from VUI_SavedVariables if needed
    if VUI_SavedVariables.VUICD then
        -- Migrate any important settings that might be in the old location
        -- but maintain the AceDB structure created in Init.lua
        self:Debug("Migrating legacy VUICD settings from VUI_SavedVariables")
        
        -- VUI_SavedVariables.VUICD is no longer needed, as we're using the AceDB system
        -- But we won't delete it to avoid breaking anything
    end
    
    -- Initialize constants
    -- (Already initialized from Constants.lua)
    
    -- Initialize command system
    if self.Commands then
        self.Commands:Initialize()
    end
    
    -- Initialize addon compatibility
    if self.Addons then
        self.Addons:Initialize()
    end
    
    -- Initialize spell system
    if self.Spells then
        self.Spells:Initialize()
    end
    
    -- Register core events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    
    -- Initialize party module
    if self.Party then
        -- Initialize components first
        if self.Party.GroupInfo then
            self.Party.GroupInfo:Initialize()
        end
        
        if self.Party.Inspect then
            self.Party.Inspect:Initialize()
        end
        
        if self.Party.CD then
            self.Party.CD:Initialize()
        end
        
        if self.Party.Visibility then
            self.Party.Visibility:Initialize()
        end
        
        if self.Party.Highlights then
            self.Party.Highlights:Initialize()
        end
        
        if self.Party.Test then
            self.Party.Test:Initialize()
        end
        
        -- Initialize the main party UI last
        self.Party:Initialize()
        
        -- Initialize position system
        if self.Party.Position then
            self.Party.Position:Initialize()
        end
        
        -- Initialize extra bars
        if self.Party.ExtraBars then
            self.Party.ExtraBars:Initialize()
        end
        
        -- Initialize sync system
        if self.Party.Sync then
            self.Party.Sync:SetEnabled(true)
        end
    end
    
    -- Debug message
    self:Debug("VUICD initialized")
    
    -- Start disabled by default, let the settings control visibility
    if self.Party then
        self.Party:Disable()
        
        -- Check visibility based on current instance
        self:CheckInstanceType()
    end
end

-- Use hook pattern for OnEnable
VUICD.OnEnable = function(self)
    -- Call original if it exists and is a function
    if original_OnEnable and type(original_OnEnable) == "function" then
        original_OnEnable(self)
    end
    
    -- Module was enabled
    self:Debug("VUICD enabled")
end

-- Use hook pattern for OnDisable
VUICD.OnDisable = function(self)
    -- Call original if it exists and is a function
    if original_OnDisable and type(original_OnDisable) == "function" then
        original_OnDisable(self)
    end
    
    -- Module was disabled
    self:Debug("VUICD disabled")
    
    -- Disable party module
    if self.Party then
        self.Party:Disable()
    end
end

-- Event handlers
function VUICD:PLAYER_ENTERING_WORLD()
    self:CheckInstanceType()
end

function VUICD:GROUP_ROSTER_UPDATE()
    self:UpdateRoster()
end

-- Check instance type for visibility settings
function VUICD:CheckInstanceType()
    local _, instanceType = IsInInstance()
    self.instanceType = instanceType
    
    -- Update module visibility based on instance type
    if self.Party and self.Party.Visibility then
        self.Party.Visibility:Update()
    end
end

-- Update group roster
function VUICD:UpdateRoster()
    if self.Party and self.Party.GroupInfo then
        self.Party.GroupInfo:UpdateGroupInfo()
    end
end
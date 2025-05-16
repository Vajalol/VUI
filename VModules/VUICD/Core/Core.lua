local AddonName, VUI = ...

-- Use global reference pattern to avoid load order issues
_G["VUICD"] = _G["VUICD"] or {}
local M = _G["VUICD"]

-- Additional Module initialization (supplements Init.lua)
function M:SetupModules()
    -- Register media paths
    self:RegisterMedia()
    
    -- No need to initialize modules again, as they are already initialized in Init.lua
    -- through the InitializeModules function
    
    -- Events are registered in OnEnable() in Init.lua
end

-- Override the dummy function in Init.lua with a proper implementation
M.CheckInstanceType = function(self)
    local _, instanceType = IsInInstance()
    self.instanceType = instanceType
    
    -- Check if db and modules are properly initialized
    if not self.db or not self.db.profile or not self.db.profile.modules then
        return
    end
    
    -- Update module visibility based on instance type
    for moduleName, enabled in pairs(self.db.profile.modules) do
        if enabled and self[moduleName] then
            if self[moduleName].UpdateVisibility then
                self[moduleName]:UpdateVisibility(instanceType)
            end
        end
    end
end

-- Add functionality to existing OnInitialize
local originalOnInitialize = M.OnInitialize
M.OnInitialize = function(self)
    -- Call the original OnInitialize from Init.lua
    originalOnInitialize(self)
    
    -- Setup additional module functionality
    self:SetupModules()
end

-- Event handler already defined in Init.lua, just implement the handler
function M:PLAYER_ENTERING_WORLD()
    self:CheckInstanceType()
end

function M:GROUP_ROSTER_UPDATE()
    self:UpdateRoster()
end

-- Update group roster
function M:UpdateRoster()
    if self.Party and self.Party.UpdateRoster then
        self.Party:UpdateRoster()
    end
end

-- Register media paths
function M:RegisterMedia()
    local LSM = LibStub("LibSharedMedia-3.0")
    
    -- Register textures
    LSM:Register("statusbar", "VUI-Party-StatusBar", "Interface\\AddOns\\VUI\\Media\\modules\\VUICD\\statusbar.tga")
end

-- Get party module settings
function M:GetPartySettings()
    return self.db.profile.party
end

-- Additional slash command handlers
-- Note: Main slash command registration is in Init.lua
local originalSlashCommand = M.SlashCommand
M.SlashCommand = function(self, input)
    local args = {}
    for word in input:gmatch("%w+") do
        table.insert(args, word)
    end
    
    local command = args[1] and args[1]:lower() or ""
    
    if command == "test" then
        if self.Party then
            -- Add type checking to handle different types
            if type(self.Party.Test) == "table" and self.Party.Test.Test then
                self.Party.Test:Test()
            elseif type(self.Party.Test) == "function" then
                -- Always call Test as a method of Party to ensure 'self' is passed
                self.Party:Test()
            else
                -- Fallback to direct method call on Party if Test is neither a table nor function
                self.Party:Test()
            end
        end
        return -- handled
    end
    
    -- If not handled by our additions, pass to original handler
    originalSlashCommand(self, input)
end
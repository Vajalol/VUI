-- VUISkin Config
local AddonName, VUI = ...

-- Register module
local VUISkin = VUI:NewModule("VUISkin")

-- Module configuration defaults
local defaults = {
    profile = {
        enabled = true,
        autoApply = true,
        useDefaultProfile = false, -- Default profile is opt-in
    }
}

-- Improve config functionality for the module
-- Note: Main initialization happens in Init.lua
function VUISkin:SetupConfigOptions()
    -- Register module options (no need to register namespace again)
    VUI.Config:RegisterModuleCategory("VUISkin", "VUISkin", "Details! Skin")
    VUI.Config:RegisterModuleOptions("VUISkin", "VUISkin")

    -- Register slash command
    self:RegisterChatCommand("vuiskin", "SlashCommand")
end

-- Handle slash commands
function VUISkin:SlashCommand(input)
    input = string.lower(input)
    
    if input == "apply" then
        if self.db.profile.enabled then
            self:ApplySkin()
            VUI:Print("Applied VUI skin to Details!")
        else
            VUI:Print("VUISkin module is disabled. Enable it first in the VUI configuration.")
        end
    elseif input == "remove" then
        if self.db.profile.enabled then
            self:RemoveSkin()
            VUI:Print("Removed VUI skin from Details!")
        else
            VUI:Print("VUISkin module is disabled.")
        end
    elseif input == "toggle" then
        self.db.profile.enabled = not self.db.profile.enabled
        if self.db.profile.enabled then
            VUI:Print("VUISkin module enabled.")
            if self.db.profile.autoApply then
                self:ApplySkin()
            end
        else
            VUI:Print("VUISkin module disabled.")
        end
    elseif input == "profile" or input == "importprofile" then
        if self.db.profile.enabled then
            self:ImportDefaultProfile()
        else
            VUI:Print("VUISkin module is disabled. Enable it first in the VUI configuration.")
        end
    else
        VUI:Print("VUISkin commands:")
        VUI:Print("  /vuiskin apply - Apply the VUI skin to Details!")
        VUI:Print("  /vuiskin remove - Remove the VUI skin from Details!")
        VUI:Print("  /vuiskin toggle - Toggle the module on/off")
        VUI:Print("  /vuiskin profile - Import the VUI default profile for Details!")
    end
end

-- Enable module
function VUISkin:OnEnable()
    -- Only proceed if enabled in config
    if not self.db.profile.enabled then return end
    
    -- Register with VUI
    VUI:RegisterSkinModule(self)
    
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Check if Details! is loaded
    if IsAddOnLoaded("Details") then
        -- Apply skin if autoApply is enabled
        if self.db.profile.autoApply then
            self:ScheduleTimer("ApplySkin", 1) -- Slight delay to ensure Details is fully loaded
        end
    end
end

-- Handle events
function VUISkin:PLAYER_ENTERING_WORLD()
    -- Check if Details! is loaded
    if IsAddOnLoaded("Details") and self.db.profile.autoApply then
        self:ScheduleTimer("ApplySkin", 2) -- Apply with a slight delay
    end
end

-- Disable module
function VUISkin:OnDisable()
    -- Unregister events
    self:UnregisterAllEvents()
end
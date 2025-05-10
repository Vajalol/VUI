local addonName, addon = ...
local Module = VUI:NewModule("VUISkin")
local L = LibStub("AceLocale-3.0"):GetLocale("VUISkin")
local LSM = LibStub("LibSharedMedia-3.0")

-- Default settings
Module.defaults = {
    profile = {
        enabled = false,
        autoApply = true,
        themeColor = {
            r = 0.05, g = 0.61, b = 0.9 -- Default VUI blue
        },
        windowSettings = {
            backdrop = "VUI Backdrop",
            backdropColor = {0.09, 0.09, 0.09, 0.5},
            borderColor = {0.05, 0.61, 0.9, 1}, -- Default VUI blue
            titleBarTexture = "VUI TitleBar",
            menuButtonTexture = "VUI Menu Button",
            rowTexture = "VUI RowBG",
            rowHighlightTexture = "VUI RowHighlight",
            barTexture = "VUI Bar",
        }
    }
}

function Module:OnInitialize()
    -- Create a config DB for the module
    self.db = VUI.db:RegisterNamespace(self.NAME, {
        profile = self.defaults.profile
    })
    
    -- Set up config options (calls method in Config.lua)
    self:SetupConfigOptions()
    
    -- Register the module with VUI's configuration system
    VUI.Config:RegisterModuleOptions(self.NAME, self:GetOptions(), L["Module Name"])
end

function Module:OnEnable()
    -- Register events
    self:RegisterEvent("PLAYER_LOGIN", "CheckForDetails")
    self:RegisterEvent("ADDON_LOADED", "CheckForDetails")
    
    -- Apply skin if auto-apply is enabled and Details is loaded
    if self.db.profile.enabled and self.db.profile.autoApply then
        C_Timer.After(2, function() 
            self:ApplySkin()
        end)
    end
    
    VUI:Print(L["Module Name"] .. " " .. L["Enabled"])
end

function Module:OnDisable()
    -- Clean up events
    self:UnregisterAllEvents()
    
    -- Remove skin
    self:RemoveSkin()
end

function Module:CheckForDetails()
    if _G._detalhes then
        self.detailsFound = true
    end
end

function Module:SlashCommand(input)
    input = input:trim()
    
    if input == "enable" or input == "on" then
        self.db.profile.enabled = true
        self:ApplySkin()
        VUI:Print(L["Skin successfully applied"])
    elseif input == "disable" or input == "off" then
        self.db.profile.enabled = false
        self:RemoveSkin()
        VUI:Print(L["Skin successfully removed"])
    elseif input == "toggle" then
        self.db.profile.enabled = not self.db.profile.enabled
        if self.db.profile.enabled then
            self:ApplySkin()
            VUI:Print(L["Skin successfully applied"])
        else
            self:RemoveSkin()
            VUI:Print(L["Skin successfully removed"])
        end
    else
        -- Open the options panel
        VUI.Config:OpenConfig("VUISkin")
    end
end

function Module:Debug(...)
    if self.db.profile.debug then
        VUI:Print("|cff00ffffVUISkin Debug:|r", ...)
    end
end
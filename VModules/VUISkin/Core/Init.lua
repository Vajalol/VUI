local addonName = ...
local VUI = _G["VUI"]

-- Create minimal fallback if VUI doesn't exist
if not VUI then
    VUI = {}
    VUI.NewModule = function() return {} end
    VUI.TryCreateModule = function() return {} end
    _G["VUI"] = VUI
end

-- Create module with proper error handling
local Module
if VUI then
    -- Check for TryCreateModule first (preferred method)
    if VUI.TryCreateModule then
        Module = VUI:TryCreateModule("VUISkin")
    -- Fall back to NewModule if available
    elseif VUI.NewModule then
        Module = VUI:NewModule("VUISkin")
    else
        -- Last resort - create a basic object with minimum required functionality
        print("VUISkin: Warning - creating fallback module object")
        Module = {
            NAME = "VUISkin",
            RegisterEvent = function() end,
            UnregisterAllEvents = function() end,
            RegisterChatCommand = function() end,
            Debug = function(self, ...) print("VUISkin Debug:", ...) end,
            Print = function(self, ...) print("VUISkin:", ...) end,
            GetOptions = function() return {} end,
            OnInitialize = function() end,
            OnEnable = function() end,
            OnDisable = function() end
        }
        VUI["VUISkin"] = Module
    end
end

if not Module then
    print("VUISkin: Fatal error initializing module")
    return
end

local L = LibStub and LibStub("AceLocale-3.0") and LibStub("AceLocale-3.0"):GetLocale("VUISkin") or {}
local LSM = LibStub and LibStub("LibSharedMedia-3.0") or {}

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
    -- Create the database with consistent naming
    if VUI and VUI.db then
        -- Make sure namespaces exists to avoid nil indexing
        if not VUI.db.namespaces then
            VUI.db.namespaces = {}
        end
        
        -- Check if a namespace already exists with any of the possible names
        local namespace = VUI.db.namespaces["VUISkin"] or VUI.db.namespaces["vuiskin"]
        
        if namespace then
            -- Use existing namespace
            self.db = namespace
            
            -- Ensure both versions are synchronized
            VUI.db.namespaces["VUISkin"] = namespace
            VUI.db.namespaces["vuiskin"] = namespace
        else
            -- Create new namespace with proper case for consistency
            self.db = VUI.db:RegisterNamespace("VUISkin", {
                profile = self.defaults.profile
            })
            
            -- Also create lowercase reference for compatibility
            VUI.db.namespaces["vuiskin"] = self.db
        end
    else
        -- Fallback if VUI.db isn't available
        self.db = {profile = self.defaults.profile}
    end
    
    -- Register with VUI theme system if available
    if VUI and VUI.RegisterCallback then
        VUI:RegisterCallback("OnThemeChanged", function() 
            self:OnThemeChanged() 
        end)
    end
    
    -- Ensure core utility methods exist with fallbacks
    if not self.Debug then
        self.Debug = function(self, ...) 
            if VUI and type(VUI.Print) == "function" then
                VUI:Print("|cff00ffffVUISkin Debug:|r", ...)
            else
                print("|cff00ffffVUISkin Debug:|r", ...)
            end
        end
    end
    
    -- Set up config options (calls method in Config.lua)
    if self.SetupConfigOptions then
        self:SetupConfigOptions()
    end
    
    -- Register the module with VUI's configuration system
    if VUI and VUI.Config and VUI.Config.RegisterModuleCategory then
        VUI.Config:RegisterModuleCategory("VUISkin", L["VUISkin"] or "VUISkin", L["Details! Skin"] or "Details! Skin")
    end
    
    -- Register any textures
    if self.RegisterTextures then
        self:RegisterTextures()
    end
    
    -- Register slash commands
    self:RegisterChatCommand("vuiskin", "SlashCommand")
    
    -- Debug output
    self:Debug("VUISkin module initialized successfully")
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
    -- Check if debug is enabled in profile settings
    local debugEnabled = self.db and self.db.profile and self.db.profile.debug
    
    -- If debug is enabled, or if db is not available (initialization might be in progress)
    if debugEnabled then
        -- Safely use VUI:Print if available
        if VUI and type(VUI.Print) == "function" then
            VUI:Print("|cff00ffffVUISkin Debug:|r", ...)
        else
            print("|cff00ffffVUISkin Debug:|r", ...)
        end
    end
end
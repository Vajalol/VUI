-- VUIAnyFrame: Main Module
-- Allows repositioning of any UI element
-- Based on MoveAny by D4KiR with VUI integration

local AddonName, VUI = ...
local M = _G["VUIAnyFrame"]
local L = M.L

-- Create frame for setup callbacks
local setupFrame = CreateFrame("Frame")
setupFrame:RegisterEvent("PLAYER_LOGIN")
setupFrame:RegisterEvent("ADDON_LOADED")
setupFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        M:ApplySettings()
    elseif event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "VUI" then
            -- Initialize after VUI is loaded
            if M.needsInit then
                M.needsInit = nil
                -- Try to properly initialize now that VUI is available
                if VUI and VUI.NewModule then
                    local newModule = VUI:NewModule("VUIAnyFrame", "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")
                    -- Copy over any data that might have been set on the placeholder
                    for k, v in pairs(M) do
                        if k ~= "frame" then -- Don't overwrite frame reference
                            newModule[k] = v
                        end
                    end
                    -- Update global reference
                    _G["VUIAnyFrame"] = newModule
                    
                    -- Call initialization
                    if type(newModule.OnInitialize) == "function" then
                        newModule:OnInitialize()
                    end
                    if type(newModule.OnEnable) == "function" then
                        newModule:OnEnable()
                    end
                end
            end
        end
    end
end)

-- Function to create frames
function M:CreateFrames()
    -- Create options panel
    if not M.LockFrame then
        local lockFrame = CreateFrame("Frame", "VALockFrame", UIParent)
        lockFrame:SetSize(300, 200)
        lockFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        lockFrame:SetFrameStrata("HIGH")
        lockFrame:SetFrameLevel(100)
        
        -- Set backdrop
        lockFrame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets = {left = 1, right = 1, top = 1, bottom = 1}
        })
        lockFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
        lockFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        
        -- Make draggable
        lockFrame:SetMovable(true)
        lockFrame:EnableMouse(true)
        lockFrame:RegisterForDrag("LeftButton")
        lockFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
        lockFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
        
        -- Add title
        local title = lockFrame:CreateFontString(nil, "OVERLAY")
        title:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
        title:SetPoint("TOP", lockFrame, "TOP", 0, -10)
        title:SetText("VUI AnyFrame")
        
        -- Add buttons
        local buttons = {}
        local y = -40
        
        -- Lock button
        buttons.lock = M:CreateButton(lockFrame, "Lock Frames", y)
        buttons.lock:SetScript("OnClick", function()
            M:Lock()
        end)
        
        -- Grid toggle button
        y = y - 40
        buttons.grid = M:CreateButton(lockFrame, "Toggle Grid", y)
        buttons.grid:SetScript("OnClick", function()
            if M.GridFrame and M.GridFrame:IsShown() then
                M.GridFrame:Hide()
            else
                M:UpdateGrid()
                if M.GridFrame then
                    M.GridFrame:Show()
                end
            end
        end)
        
        -- Reset all button
        y = y - 40
        buttons.resetAll = M:CreateButton(lockFrame, "Reset All Frames", y)
        buttons.resetAll:SetScript("OnClick", function()
            StaticPopupDialogs["VUIANYFRAME_RESET_ALL"] = {
                text = "Are you sure you want to reset all frames to their default positions?",
                button1 = "Yes",
                button2 = "No",
                OnAccept = function()
                    M:ResetAllFrameSettings()
                    M:Print("All frames reset to default positions")
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3
            }
            StaticPopup_Show("VUIANYFRAME_RESET_ALL")
        end)
        
        -- Options button
        y = y - 40
        buttons.options = M:CreateButton(lockFrame, "Options", y)
        buttons.options:SetScript("OnClick", function()
            M:OpenOptions()
        end)
        
        -- Store in module
        M.LockFrame = lockFrame
        M.LockFrame.buttons = buttons
        
        -- Hide by default
        M.LockFrame:Hide()
    end
    
    -- Create grid frame if it doesn't exist yet
    if not M.GridFrame then
        M:UpdateGrid()
    end
    
    -- Create icon textures for minimap button
    M:CreateGridTextures()
end

-- Function to initialize module
function M:OnInitialize()
    -- Skip if already initialized
    if self.initialized then
        return
    end
    
    -- Create the database
    self:InitSettings()
    
    -- Create frames
    self:CreateFrames()
    
    -- Register slash commands
    self:RegisterChatCommand("vuianyframe", "SlashCommand")
    self:RegisterChatCommand("va", "SlashCommand")
    
    -- Initialize VUI integration
    self:InitVUIIntegration()
    
    -- Mark as initialized
    self.initialized = true
    
    -- Debug message
    if VUI and VUI.Debug then
        VUI:Debug(self.NAME .. " initialized")
    end
end

-- Function to open options panel
function M:OpenOptions()
    -- Use VUI's built-in config if available
    if VUI and VUI.Config and type(VUI.Config.OpenModule) == "function" then
        VUI.Config:OpenModule("VUIAnyFrame")
    else
        -- Fall back to AceConfigDialog if available
        if LibStub and LibStub("AceConfigDialog-3.0", true) then
            local AceConfigDialog = LibStub("AceConfigDialog-3.0")
            AceConfigDialog:Open("VUIAnyFrame")
        else
            -- Show our custom frame
            if M.LockFrame then
                M.LockFrame:Show()
            end
        end
    end
end

-- Function to set up options panel
function M:SetupOptions()
    if not LibStub then return end
    
    local AceConfigRegistry = LibStub("AceConfigRegistry-3.0", true)
    local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)
    if not AceConfigRegistry or not AceConfigDialog then return end
    
    -- Register with VUI's config system
    if VUI and VUI.Config and type(VUI.Config.RegisterModuleOptions) == "function" then
        VUI.Config:RegisterModuleOptions("VUIAnyFrame", self:GetOptions(), "VUI AnyFrame")
    end
    
    -- Register standalone options
    AceConfigRegistry:RegisterOptionsTable("VUIAnyFrame", self:GetOptions())
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("VUIAnyFrame", "VUIAnyFrame")
end

-- Register events
function M:RegisterEvents()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("ADDON_LOADED")
end

-- Profile changed callback
function M:ProfileChanged()
    -- Apply settings from the new profile
    C_Timer.After(0.5, function()
        self:ApplySettings()
    end)
    
    self:Print("Profile changed, reapplying settings")
end

-- Print a formatted message
function M:Print(...)
    if VUI and VUI.Print then
        VUI:Print("|cff00aaff" .. self.TITLE .. ":|r ", ...)
    else
        print("|cff00aaff" .. self.TITLE .. ":|r ", ...)
    end
end 
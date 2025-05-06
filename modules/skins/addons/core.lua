-- VUI Skins Module - Addon UI Skinning
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local Skins = VUI.skins

-- Registry for addon skinning functions
local addonSkins = {}

-- Register addon skins
function Skins:RegisterAddonSkins()
    -- Register skinning functions for addons
    self:RegisterAddonSkin("auctionator", addonSkins.Auctionator)
    self:RegisterAddonSkin("omnicc", addonSkins.OmniCC)
    self:RegisterAddonSkin("angrykeystones", addonSkins.AngryKeystones)
    self:RegisterAddonSkin("omnicd", addonSkins.OmniCD)
    self:RegisterAddonSkin("buffoverlay", addonSkins.BuffOverlay)
    self:RegisterAddonSkin("moveany", addonSkins.MoveAny)
    self:RegisterAddonSkin("idtip", addonSkins.IdTip)
    self:RegisterAddonSkin("trufigcd", addonSkins.TrufiGCD)
    self:RegisterAddonSkin("details", addonSkins.Details)
    self:RegisterAddonSkin("dbm", addonSkins.DBM)
    self:RegisterAddonSkin("weakauras", addonSkins.WeakAuras)
    self:RegisterAddonSkin("plater", addonSkins.Plater)
end

-- Skinning function for Auctionator
addonSkins.Auctionator = function(self)
    if not self.settings.addons.auctionator then return end
    
    -- Auctionator has multiple frames, we'll hook into their creation
    if IsAddOnLoaded("Auctionator") then
        -- Main Auctionator frame
        local auctionatorFrame = _G["Auctionator.ShoppingLists.Frame"]
        if auctionatorFrame then
            self:SkinFrame(auctionatorFrame)
        end
        
        -- Selling frame
        local sellingFrame = _G["Auctionator.Selling.Frame"]
        if sellingFrame then
            self:SkinFrame(sellingFrame)
        end
        
        -- Cancelling frame
        local cancellingFrame = _G["Auctionator.Cancelling.Frame"]
        if cancellingFrame then
            self:SkinFrame(cancellingFrame)
        end
        
        -- Shopping frame
        local shoppingFrame = _G["Auctionator.Shopping.Frame"]
        if shoppingFrame then
            self:SkinFrame(shoppingFrame)
        end
        
        -- Hook scrollframe creation for Auctionator
        if not self.AuctionatorHooked then
            -- This would be expanded in a real implementation to hook specific Auctionator functions
            -- that create UI elements
            
            self.AuctionatorHooked = true
        end
    end
end

-- Skinning function for OmniCC
addonSkins.OmniCC = function(self)
    if not self.settings.addons.omnicc then return end
    
    -- OmniCC primarily shows cooldown animations, but it has a config window
    if IsAddOnLoaded("OmniCC") and _G["OmniCC"].ShowOptionsMenu then
        -- Hook the options menu function
        if not self.OmniCCHooked then
            hooksecurefunc(_G["OmniCC"], "ShowOptionsMenu", function()
                -- Find and skin the OmniCC options frame
                for i, v in ipairs({UIParent:GetChildren()}) do
                    if v.titleText and v.titleText:GetText() == "OmniCC" then
                        self:SkinFrame(v)
                        
                        -- Skin buttons
                        for _, child in ipairs({v:GetChildren()}) do
                            if child:IsObjectType("Button") then
                                self:SkinButton(child)
                            end
                        end
                        
                        break
                    end
                end
            end)
            
            self.OmniCCHooked = true
        end
    end
end

-- Skinning function for Angry Keystones
addonSkins.AngryKeystones = function(self)
    if not self.settings.addons.angrykeystones then return end
    
    -- Angry Keystones adds elements to the Mythic+ UI
    if IsAddOnLoaded("AngryKeystones") then
        -- Skin the main elements that Angry Keystones modifies
        local challengesFrame = _G["ChallengesFrame"]
        if challengesFrame then
            -- Skin the Keystone slot
            local keystoneSlot = challengesFrame.DungeonIcons
            if keystoneSlot then
                self:SkinFrame(keystoneSlot)
            end
            
            -- Skin the schedule frame
            local scheduleFrame = challengesFrame.WeeklyInfo.Child
            if scheduleFrame then
                self:SkinFrame(scheduleFrame)
            end
        end
        
        -- Check for the Angry Keystones progress bar
        local progressBar = _G["ObjectiveTrackerBlocksFrame"].KeystoneProgress
        if progressBar then
            self:SkinFrame(progressBar)
        end
    end
end

-- Skinning function for OmniCD
addonSkins.OmniCD = function(self)
    if not self.settings.addons.omnicd then return end
    
    -- OmniCD shows party cooldowns, mainly checking for its option frames
    if IsAddOnLoaded("OmniCD") then
        -- Find and skin the OmniCD option panels
        local mainPanel = _G["OmniCDDB"] and _G["OmniCD"].Options and _G["OmniCD"].Options.frame
        if mainPanel then
            self:SkinFrame(mainPanel)
            
            -- Skin the tab buttons
            for i = 1, mainPanel.numTabs do
                local tab = _G[mainPanel:GetName().."Tab"..i]
                if tab then
                    self:SkinTab(tab)
                end
            end
            
            -- Skin buttons in the panel
            for _, child in ipairs({mainPanel:GetChildren()}) do
                if child:IsObjectType("Button") then
                    self:SkinButton(child)
                elseif child:IsObjectType("Frame") then
                    -- Recursively check for buttons in child frames
                    for _, subchild in ipairs({child:GetChildren()}) do
                        if subchild:IsObjectType("Button") then
                            self:SkinButton(subchild)
                        end
                    end
                end
            end
        end
    end
end

-- Skinning function for BuffOverlay
addonSkins.BuffOverlay = function(self)
    if not self.settings.addons.buffoverlay then return end
    
    -- BuffOverlay shows aura borders on unit frames
    if IsAddOnLoaded("BuffOverlay") then
        -- Find the options panel
        local optionsPanel = _G["BuffOverlayOptions"]
        if optionsPanel then
            self:SkinFrame(optionsPanel)
            
            -- Skin checkboxes and buttons
            for _, child in ipairs({optionsPanel:GetChildren()}) do
                if child:IsObjectType("CheckButton") then
                    self:SkinCheckButton(child)
                elseif child:IsObjectType("Button") then
                    self:SkinButton(child)
                elseif child:IsObjectType("Slider") then
                    self:SkinSlider(child)
                end
            end
        end
    end
end

-- Skinning function for MoveAny
addonSkins.MoveAny = function(self)
    if not self.settings.addons.moveany then return end
    
    -- MoveAny allows frame repositioning
    if IsAddOnLoaded("MoveAny") then
        -- Find the main MoveAny frame
        local moveAnyFrame = _G["MAOptions"]
        if moveAnyFrame then
            self:SkinFrame(moveAnyFrame)
            
            -- Skin tabs
            for i = 1, moveAnyFrame.numTabs or 0 do
                local tab = _G[moveAnyFrame:GetName().."Tab"..i]
                if tab then
                    self:SkinTab(tab)
                end
            end
            
            -- Skin child elements
            for _, child in ipairs({moveAnyFrame:GetChildren()}) do
                if child:IsObjectType("Button") then
                    self:SkinButton(child)
                elseif child:IsObjectType("CheckButton") then
                    self:SkinCheckButton(child)
                elseif child:IsObjectType("Slider") then
                    self:SkinSlider(child)
                elseif child:IsObjectType("EditBox") then
                    self:SkinEditBox(child)
                end
            end
        end
        
        -- Skin the mover frames
        -- In a real implementation we would hook MoveAny's frame creation function
    end
end

-- Skinning function for IdTip
addonSkins.IdTip = function(self)
    if not self.settings.addons.idtip then return end
    
    -- IdTip primarily modifies tooltips to show IDs
    -- We can hook GameTooltip to apply our skin whenever IdTip adds info to it
    if IsAddOnLoaded("idTip") then
        -- Ensure tooltips are skinned
        self:SkinFrame(GameTooltip)
        self:SkinFrame(ItemRefTooltip)
    end
end

-- Skinning function for TrufiGCD
addonSkins.TrufiGCD = function(self)
    if not self.settings.addons.trufigcd then return end
    
    -- TrufiGCD shows recent spell casts
    if IsAddOnLoaded("TrufiGCD") then
        -- Find the TrufiGCD options frame
        local optionsFrame = _G["TrufiGCDGUI"]
        if optionsFrame then
            self:SkinFrame(optionsFrame)
            
            -- Skin buttons and other controls
            for _, child in ipairs({optionsFrame:GetChildren()}) do
                if child:IsObjectType("Button") then
                    self:SkinButton(child)
                elseif child:IsObjectType("CheckButton") then
                    self:SkinCheckButton(child)
                elseif child:IsObjectType("Slider") then
                    self:SkinSlider(child)
                elseif child:IsObjectType("EditBox") then
                    self:SkinEditBox(child)
                end
            end
        end
        
        -- Find and skin the TrufiGCD icon frames
        -- These would be skinned when they're created by the addon
    end
end

-- Basic implementations for other popular addons
-- In a real implementation, these would be more detailed
addonSkins.Details = function(self)
    if not self.settings.addons.details then return end
    -- Details damage meter skinning implementation would go here
end

addonSkins.DBM = function(self)
    if not self.settings.addons.dbm then return end
    -- Deadly Boss Mods skinning implementation would go here
end

addonSkins.WeakAuras = function(self)
    if not self.settings.addons.weakauras then return end
    -- WeakAuras skinning implementation would go here
end

addonSkins.Plater = function(self)
    if not self.settings.addons.plater then return end
    -- Plater nameplate addon skinning implementation would go here
end

-- Register all addon skinning functions
Skins:RegisterAddonSkins()

-- Apply addon skins
function Skins:ApplyAddonSkins()
    if not self.enabled or not self.settings.addons.enabled then return end
    
    -- Get list of registered addon skins
    local registeredSkins = self:GetRegisteredAddonSkins()
    
    -- Apply each skin if enabled and addon is loaded
    for _, name in ipairs(registeredSkins) do
        if self.settings.addons[name] and self.addonSkinFuncs[name] then
            self.addonSkinFuncs[name](self)
        end
    end
end

-- Hook ADDON_LOADED to apply skins when addons load
function Skins:HookAddonLoaded()
    -- We use our event registration from the main module
    self:RegisterEvent("ADDON_LOADED", function(addonName)
        -- Check if loaded addon is one we support skinning
        if self.settings.addons[addonName:lower()] and self.settings.addons.enabled then
            -- Delay slightly to ensure addon UI is initialized
            C_Timer.After(0.5, function()
                self:ApplyAddonSkin(addonName:lower())
            end)
        end
    end)
end

-- Apply skin to a specific addon
function Skins:ApplyAddonSkin(addonName)
    if not self.enabled or not self.settings.addons.enabled then return end
    
    -- Convert addon name to lowercase for consistency
    addonName = addonName:lower()
    
    -- Check if we have a skin function for this addon
    if self.settings.addons[addonName] and self.addonSkinFuncs[addonName] then
        self.addonSkinFuncs[addonName](self)
    end
end

-- Hook addon loaded event
Skins:HookAddonLoaded()
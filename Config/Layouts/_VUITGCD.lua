local VUI, E, L, V, P, G = unpack(select(2, ...))
local C = VUI.Config

-- Load TGCD module
local TGCD = VUI.TGCD

-- Create a new layout
local LAYOUT = C:CreateLayout("VUITGCD")

function LAYOUT:Initialize()
    local panel = self:CreateRootPanel()
    
    -- Main Header
    panel:AddSpacer()
    panel:AddHeader(L["Ability History"])
    panel:AddSpacer()
    
    -- Enable or disable toggle
    local enableGroup = panel:AddGroup(L["General Settings"])
    enableGroup:AddToggle(
        "enable",
        L["Enable Ability History"],
        L["Show recently used abilities for various units"],
        function() return TGCD.enabled end,
        function(value)
            TGCD.enabled = value
            -- Update visibility
            if TGCD.LocationCheck then
                TGCD.LocationCheck.UpdateState()
            end
        end
    )
    
    -- Display conditions group
    local displayGroup = panel:AddGroup(L["Display Conditions"])
    displayGroup:AddToggle(
        "enableInWorld",
        L["Show in World"],
        L["Display ability icons when in the open world"],
        function() 
            return TGCD.Settings and TGCD.Settings.activeProfile and 
                   TGCD.Settings.activeProfile.enableInWorld 
        end,
        function(value)
            if TGCD.Settings and TGCD.Settings.activeProfile then
                TGCD.Settings.activeProfile.enableInWorld = value
                TGCD.Settings:Save()
                
                -- Update visibility
                if TGCD.LocationCheck then
                    TGCD.LocationCheck.UpdateState()
                end
            end
        end
    )
    
    displayGroup:AddToggle(
        "enableInDungeons",
        L["Show in Dungeons"],
        L["Display ability icons when in dungeon instances"],
        function() 
            return TGCD.Settings and TGCD.Settings.activeProfile and 
                   TGCD.Settings.activeProfile.enableInDungeons 
        end,
        function(value)
            if TGCD.Settings and TGCD.Settings.activeProfile then
                TGCD.Settings.activeProfile.enableInDungeons = value
                TGCD.Settings:Save()
                
                -- Update visibility
                if TGCD.LocationCheck then
                    TGCD.LocationCheck.UpdateState()
                end
            end
        end
    )
    
    displayGroup:AddToggle(
        "enableInRaids",
        L["Show in Raids"],
        L["Display ability icons when in raid instances"],
        function() 
            return TGCD.Settings and TGCD.Settings.activeProfile and 
                   TGCD.Settings.activeProfile.enableInRaids 
        end,
        function(value)
            if TGCD.Settings and TGCD.Settings.activeProfile then
                TGCD.Settings.activeProfile.enableInRaids = value
                TGCD.Settings:Save()
                
                -- Update visibility
                if TGCD.LocationCheck then
                    TGCD.LocationCheck.UpdateState()
                end
            end
        end
    )
    
    displayGroup:AddToggle(
        "enableInPvP",
        L["Show in PvP"],
        L["Display ability icons when in PvP instances (battlegrounds, arenas)"],
        function() 
            return TGCD.Settings and TGCD.Settings.activeProfile and 
                   TGCD.Settings.activeProfile.enableInPvP 
        end,
        function(value)
            if TGCD.Settings and TGCD.Settings.activeProfile then
                TGCD.Settings.activeProfile.enableInPvP = value
                TGCD.Settings:Save()
                
                -- Update visibility
                if TGCD.LocationCheck then
                    TGCD.LocationCheck.UpdateState()
                end
            end
        end
    )
    
    displayGroup:AddToggle(
        "disableOutOfCombat",
        L["Hide When Out of Combat"],
        L["Hide ability icons when not in combat"],
        function() 
            return TGCD.Settings and TGCD.Settings.activeProfile and 
                   TGCD.Settings.activeProfile.disableOutOfCombat 
        end,
        function(value)
            if TGCD.Settings and TGCD.Settings.activeProfile then
                TGCD.Settings.activeProfile.disableOutOfCombat = value
                TGCD.Settings:Save()
                
                -- Update visibility
                if TGCD.LocationCheck then
                    TGCD.LocationCheck.UpdateState()
                end
            end
        end
    )
    
    displayGroup:AddToggle(
        "disableInCities",
        L["Hide in Cities"],
        L["Hide ability icons when in major cities"],
        function() 
            return TGCD.Settings and TGCD.Settings.activeProfile and 
                   TGCD.Settings.activeProfile.disableInCities 
        end,
        function(value)
            if TGCD.Settings and TGCD.Settings.activeProfile then
                TGCD.Settings.activeProfile.disableInCities = value
                TGCD.Settings:Save()
                
                -- Update visibility
                if TGCD.LocationCheck then
                    TGCD.LocationCheck.UpdateState()
                end
            end
        end
    )
    
    -- Appearance group
    local appearanceGroup = panel:AddGroup(L["Appearance Settings"])
    
    appearanceGroup:AddToggle(
        "showGlow",
        L["Show Glow Effect"],
        L["Display a glow animation around new ability icons"],
        function() 
            return TGCD.Settings and TGCD.Settings.activeProfile and 
                   TGCD.Settings.activeProfile.showGlow 
        end,
        function(value)
            if TGCD.Settings and TGCD.Settings.activeProfile then
                TGCD.Settings.activeProfile.showGlow = value
                TGCD.Settings:Save()
            end
        end
    )
    
    local glowTypes = {
        ["none"] = L["None"],
        ["blizz"] = L["Blizzard Proc"],
        ["pixel"] = L["Pixel Glow"],
        ["shine"] = L["Shine Effect"]
    }
    
    appearanceGroup:AddDropdown(
        "glowEffect",
        L["Glow Effect Type"],
        L["Select the type of glow effect to use"],
        glowTypes,
        function() 
            return TGCD.Settings and TGCD.Settings.activeProfile and 
                   TGCD.Settings.activeProfile.glowEffect or "blizz"
        end,
        function(value)
            if TGCD.Settings and TGCD.Settings.activeProfile then
                TGCD.Settings.activeProfile.glowEffect = value
                TGCD.Settings:Save()
            end
        end
    )
    
    appearanceGroup:AddToggle(
        "showTooltips",
        L["Show Tooltips"],
        L["Display spell tooltips when hovering over ability icons"],
        function() 
            return TGCD.Settings and TGCD.Settings.activeProfile and 
                   TGCD.Settings.activeProfile.showTooltips 
        end,
        function(value)
            if TGCD.Settings and TGCD.Settings.activeProfile then
                TGCD.Settings.activeProfile.showTooltips = value
                TGCD.Settings:Save()
            end
        end
    )
    
    appearanceGroup:AddToggle(
        "showSpellNames",
        L["Show Spell Names"],
        L["Display spell names below icons"],
        function() 
            return TGCD.Settings and TGCD.Settings.activeProfile and 
                   TGCD.Settings.activeProfile.showSpellNames 
        end,
        function(value)
            if TGCD.Settings and TGCD.Settings.activeProfile then
                TGCD.Settings.activeProfile.showSpellNames = value
                TGCD.Settings:Save()
            end
        end
    )
    
    -- Unit configuration
    local unitGroup = panel:AddGroup(L["Unit Display Settings"])
    
    -- Add tabs for different units
    local unitTabs = unitGroup:AddTabs()
    
    -- Player tab
    local playerTab = unitTabs:AddTab(L["Player"])
    self:CreateUnitConfigTab(playerTab, "player")
    
    -- Target tab
    local targetTab = unitTabs:AddTab(L["Target"])
    self:CreateUnitConfigTab(targetTab, "target")
    
    -- Focus tab
    local focusTab = unitTabs:AddTab(L["Focus"])
    self:CreateUnitConfigTab(focusTab, "focus")
    
    -- Party tab
    local partyTab = unitTabs:AddTab(L["Party"])
    self:CreateUnitConfigTab(partyTab, "party1", true) -- Party has additional settings
    
    -- Arena tab
    local arenaTab = unitTabs:AddTab(L["Arena"])
    self:CreateUnitConfigTab(arenaTab, "arena1", true) -- Arena has additional settings
    
    -- Profile management
    local profileGroup = panel:AddGroup(L["Profile Management"])
    
    -- Get profile names
    local profileNames = {}
    if TGCD.Settings and TGCD.Settings.profiles then
        for name, _ in pairs(TGCD.Settings.profiles) do
            profileNames[name] = name
        end
    else
        profileNames["Default"] = "Default"
    end
    
    -- Current profile dropdown
    profileGroup:AddDropdown(
        "activeProfile",
        L["Current Profile"],
        L["Select the active profile"],
        profileNames,
        function() 
            return TGCD.Settings and TGCD.Settings.activeProfile and 
                   TGCD.Settings.activeProfile.name or "Default"
        end,
        function(value)
            if TGCD.Settings then
                TGCD.Settings:SetActiveProfile(value)
                
                -- Refresh panel to show updated settings
                self:RefreshLayout()
            end
        end
    )
    
    -- New profile button
    profileGroup:AddButton(
        "newProfile",
        L["New Profile"],
        function()
            -- Show an input dialog for new profile name
            StaticPopup_Show("VUITGCD_NEW_PROFILE")
        end
    )
    
    -- Reset profile button
    profileGroup:AddButton(
        "resetProfile",
        L["Reset Current Profile"],
        function()
            -- Show confirmation dialog
            StaticPopup_Show("VUITGCD_RESET_PROFILE")
        end
    )
    
    -- Delete profile button (disabled for Default)
    profileGroup:AddButton(
        "deleteProfile",
        L["Delete Current Profile"],
        function()
            -- Show confirmation dialog (only if not Default)
            if TGCD.Settings and TGCD.Settings.activeProfile and 
               TGCD.Settings.activeProfile.name ~= "Default" then
                StaticPopup_Show("VUITGCD_DELETE_PROFILE")
            else
                -- Show message that Default can't be deleted
                print("|cffff0000" .. L["Cannot delete the Default profile."] .. "|r")
            end
        end
    )
    
    -- Create dialogs
    self:CreatePopupDialogs()
    
    return panel
end

-- Create configuration for a specific unit
function LAYOUT:CreateUnitConfigTab(tab, unitType, hasMultiple)
    if not TGCD.Settings or not TGCD.Settings.activeProfile or 
       not TGCD.Settings.activeProfile.layoutSettings or
       not TGCD.Settings.activeProfile.layoutSettings[unitType] then
        return
    end
    
    -- Enable toggle
    tab:AddToggle(
        unitType .. "_enable",
        L["Enable"],
        L["Show ability icons for this unit"],
        function() 
            return TGCD.Settings.activeProfile.layoutSettings[unitType].enable
        end,
        function(value)
            TGCD.Settings.activeProfile.layoutSettings[unitType].enable = value
            TGCD.Settings:Save()
            
            -- Update visibility
            if TGCD.LocationCheck then
                TGCD.LocationCheck.UpdateState()
            end
        end
    )
    
    -- Icon size slider
    tab:AddSlider(
        unitType .. "_iconSize",
        L["Icon Size"],
        L["Sets the size of ability icons"],
        16, 64, 1,
        function()
            return TGCD.Settings.activeProfile.layoutSettings[unitType].iconSize or 30
        end,
        function(value)
            TGCD.Settings.activeProfile.layoutSettings[unitType].iconSize = value
            TGCD.Settings:Save()
            
            -- Update unit if it exists
            if TGCD.units and TGCD.units[unitType] and TGCD.units[unitType].iconQueue then
                TGCD.units[unitType].iconQueue:SetIconSize(value)
            end
        end
    )
    
    -- Max icons slider
    tab:AddSlider(
        unitType .. "_maxIcons",
        L["Maximum Icons"],
        L["Sets the maximum number of ability icons to display"],
        3, 20, 1,
        function()
            return TGCD.Settings.activeProfile.layoutSettings[unitType].maxIcons or 8
        end,
        function(value)
            TGCD.Settings.activeProfile.layoutSettings[unitType].maxIcons = value
            TGCD.Settings:Save()
            
            -- Update unit if it exists
            if TGCD.units and TGCD.units[unitType] and TGCD.units[unitType].iconQueue then
                TGCD.units[unitType].iconQueue:SetMaxIcons(value)
            end
        end
    )
    
    -- Layout direction dropdown
    local layoutOptions = {
        ["horizontal"] = L["Horizontal"],
        ["vertical"] = L["Vertical"]
    }
    
    tab:AddDropdown(
        unitType .. "_layout",
        L["Layout Direction"],
        L["Sets the direction in which icons are displayed"],
        layoutOptions,
        function()
            return TGCD.Settings.activeProfile.layoutSettings[unitType].layout or "horizontal"
        end,
        function(value)
            TGCD.Settings.activeProfile.layoutSettings[unitType].layout = value
            TGCD.Settings:Save()
            
            -- Update unit if it exists
            if TGCD.units and TGCD.units[unitType] and TGCD.units[unitType].iconQueue then
                TGCD.units[unitType].iconQueue:SetDirection(value)
            end
        end
    )
    
    -- Show label toggle
    tab:AddToggle(
        unitType .. "_showLabel",
        L["Show Unit Name"],
        L["Display the unit name above the icon row"],
        function() 
            return TGCD.Settings.activeProfile.layoutSettings[unitType].showLabel
        end,
        function(value)
            TGCD.Settings.activeProfile.layoutSettings[unitType].showLabel = value
            TGCD.Settings:Save()
            
            -- Update unit if it exists
            if TGCD.units and TGCD.units[unitType] then
                TGCD.units[unitType]:ApplySettings()
            end
        end
    )
    
    -- Use class color toggle
    tab:AddToggle(
        unitType .. "_useClassColor",
        L["Use Class Color"],
        L["Color the unit name based on class"],
        function() 
            return TGCD.Settings.activeProfile.layoutSettings[unitType].useClassColor
        end,
        function(value)
            TGCD.Settings.activeProfile.layoutSettings[unitType].useClassColor = value
            TGCD.Settings:Save()
            
            -- Update unit if it exists
            if TGCD.units and TGCD.units[unitType] then
                TGCD.units[unitType]:ApplySettings()
            end
        end
    )
    
    -- Position button
    tab:AddButton(
        unitType .. "_position",
        L["Unlock Position"],
        function()
            -- Show positioning helper
            if TGCD.units and TGCD.units[unitType] then
                -- TODO: Implement positioning UI
                print(L["Position unlocked for "] .. L[unitType:gsub("^%l", string.upper)] .. ". " .. L["Drag to reposition, then click again to lock."])
            end
        end
    )
    
    -- For party and arena units, show settings for multiple units
    if hasMultiple then
        tab:AddToggle(
            unitType .. "_showAll",
            L["Show All Units"],
            unitType == "party1" and L["Display icons for all party members"] or L["Display icons for all arena opponents"],
            function()
                -- Check if all units of this type are enabled
                local allEnabled = true
                local unitPrefix = unitType:match("^(%a+)")
                local maxUnits = unitPrefix == "party" and 4 or 5
                
                for i = 1, maxUnits do
                    local unitId = unitPrefix .. i
                    if TGCD.Settings.activeProfile.layoutSettings[unitId] and 
                       not TGCD.Settings.activeProfile.layoutSettings[unitId].enable then
                        allEnabled = false
                        break
                    end
                end
                
                return allEnabled
            end,
            function(value)
                -- Enable or disable all units of this type
                local unitPrefix = unitType:match("^(%a+)")
                local maxUnits = unitPrefix == "party" and 4 or 5
                
                for i = 1, maxUnits do
                    local unitId = unitPrefix .. i
                    if TGCD.Settings.activeProfile.layoutSettings[unitId] then
                        TGCD.Settings.activeProfile.layoutSettings[unitId].enable = value
                    end
                end
                
                TGCD.Settings:Save()
                
                -- Update visibility
                if TGCD.LocationCheck then
                    TGCD.LocationCheck.UpdateState()
                end
            end
        )
    end
end

-- Create popup dialogs for profile management
function LAYOUT:CreatePopupDialogs()
    -- New profile dialog
    StaticPopupDialogs["VUITGCD_NEW_PROFILE"] = {
        text = L["Enter name for new profile:"],
        button1 = ACCEPT,
        button2 = CANCEL,
        hasEditBox = true,
        maxLetters = 32,
        OnAccept = function(self)
            local name = self.editBox:GetText()
            if name and name ~= "" and TGCD.Settings then
                local newProfile = TGCD.Settings:CreateProfile(name)
                if newProfile then
                    TGCD.Settings:SetActiveProfile(name)
                    LAYOUT:RefreshLayout()
                else
                    print("|cffff0000" .. L["Profile creation failed. Name may already exist."] .. "|r")
                end
            end
        end,
        EditBoxOnEnterPressed = function(self)
            local name = self:GetText()
            if name and name ~= "" and TGCD.Settings then
                local newProfile = TGCD.Settings:CreateProfile(name)
                if newProfile then
                    TGCD.Settings:SetActiveProfile(name)
                    LAYOUT:RefreshLayout()
                else
                    print("|cffff0000" .. L["Profile creation failed. Name may already exist."] .. "|r")
                end
            end
            self:GetParent():Hide()
        end,
        OnShow = function(self)
            self.editBox:SetText("")
            self.editBox:SetFocus()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    
    -- Reset profile dialog
    StaticPopupDialogs["VUITGCD_RESET_PROFILE"] = {
        text = L["Are you sure you want to reset the current profile to default settings?"],
        button1 = ACCEPT,
        button2 = CANCEL,
        OnAccept = function()
            if TGCD.Settings and TGCD.Settings.activeProfile then
                local name = TGCD.Settings.activeProfile.name
                TGCD.Settings:ResetProfile(name)
                LAYOUT:RefreshLayout()
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    
    -- Delete profile dialog
    StaticPopupDialogs["VUITGCD_DELETE_PROFILE"] = {
        text = L["Are you sure you want to delete the current profile?"],
        button1 = ACCEPT,
        button2 = CANCEL,
        OnAccept = function()
            if TGCD.Settings and TGCD.Settings.activeProfile and 
               TGCD.Settings.activeProfile.name ~= "Default" then
                local name = TGCD.Settings.activeProfile.name
                TGCD.Settings:DeleteProfile(name)
                LAYOUT:RefreshLayout()
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
end

-- Register this layout with the configuration system
C:RegisterLayout(LAYOUT)
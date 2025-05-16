-- TrufiGCD stevemyz@gmail.com

-- The module initializes settings and provides all necessary user events to the modules.

local IS_RETAIL = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

---@type string, Namespace
local addonName, VUI = ...
local _, ns = ...

-- Ensure all required namespaces exist
if not VUI.VUITGCD then VUI.VUITGCD = {} end

-- Ensure core namespace objects exist at global level for backward compatibility
if not _G.VUITGCD then _G.VUITGCD = {} end
if not _G.VUITGCD.settings then _G.VUITGCD.settings = {} end
if not _G.VUITGCD.units then _G.VUITGCD.units = {} end
if not _G.VUITGCD.constants then _G.VUITGCD.constants = {unitTypes = {}} end

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

-- Create the main loader frame 
local loadFrame = CreateFrame("Frame", nil, UIParent)
loadFrame:RegisterEvent("ADDON_LOADED")
loadFrame:SetScript("OnEvent", function(_, event, name)
    -- Check for VUI addon loading
    if name ~= "VUI" or event ~= "ADDON_LOADED" then
        return
    end
    
    -- Add safety checks for all required namespaces
    if not ns.settings then
        print("|cffff0000VUITGCD Error:|r Missing settings namespace")
        return
    end
    
    if not ns.settings.Load then
        print("|cffff0000VUITGCD Error:|r Missing settings.Load function")
        return
    end
    
    -- Try to load settings with error handling
    local success, err = pcall(function()
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
    end)
    
    if not success then
        print("|cffff0000VUITGCD Error:|r " .. tostring(err))
    end

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

    -- Signal successful initialization
    print("|cff00BBBBVUITrufiGCD:|r Successfully loaded")
end)

-- Setup the addon in the addon compartment if in retail
if IS_RETAIL then
    AddonCompartmentFrame:RegisterAddon({
        text = "VUITGCD",
        icon = 4622474,
        notCheckable = true,
        registerForAnyClick = true,
        func = function(_, btn)
            if btn.buttonName == "LeftButton" then
                if ns.settingsFrame and ns.settingsFrame.frame and ns.settingsFrame.frame.name then
                    -- Use pcall to safely handle potential errors
                    pcall(function()
                        Settings.OpenToCategory(ns.settingsFrame.frame.name)
                    end)
                else
                    print("|cffff0000VUITGCD Error:|r Settings frame not found")
                end
            else
                if ns.settingsFrame and type(ns.settingsFrame.toggleAnchors) == "function" then
                    -- Use pcall to safely handle potential errors
                    pcall(function()
                        ns.settingsFrame.toggleAnchors()
                    end)
                else
                    print("|cffff0000VUITGCD Error:|r Toggle anchors function not found")
                end
            end
        end,
        funcOnEnter = function(button)
            if MenuUtil and MenuUtil.ShowTooltip then
                MenuUtil.ShowTooltip(button, function(tooltip)
                    tooltip:ClearLines()
                    tooltip:SetText("VUITGCD")
                    tooltip:AddLine("|cffeda55fLeft-Click|r to open the settings.", 1, 1, 1, true)
                    tooltip:AddLine("|cffeda55fRight-Click|r to show frame anchors.", 1, 1, 1, true)
                    tooltip:Show()
                end)
            end
        end,
        funcOnLeave = function(button)
            if MenuUtil and MenuUtil.HideTooltip then
                MenuUtil.HideTooltip(button)
            end
        end,
    })
end

local addonName, VUI = ...

-- Create the main Notifications table in the VUI namespace
VUI.Notifications = {
    -- Basic information
    Name = "VUINotifications",
    Version = "1.0.0",
    
    -- Flag to track initialization state
    Initialized = false,
    
    -- Module info for VUI integration
    ModuleInfo = {
        title = "VUI Notifications",
        desc = "Simple spell notifications for combat events",
        icon = [[Interface\AddOns\VUI\Media\Icons\vortex_thunderstorm.svg]],
        author = "Vortex-WoW"
    }
}

-- Access the localization system after it's loaded
local L = VUI.Notifications.L or {}

-- Private variables
local reflected = {}
local duration
local warnOP
local warnCS

-- Function called when the addon loads
function VUI.Notifications:OnLoad(self)
    local _, class = UnitClass("player")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED") -- enter combat
    self:RegisterEvent("PLAYER_REGEN_ENABLED") -- leave combat
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ACTIONBAR_UPDATE_STATE")
end

-- Function called when an event fires
function VUI.Notifications:OnEvent(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        -- Process combat log events
        self:ProcessCombatLog()
    end
    -- Other events can be handled here as needed
end

-- Process combat log events
function VUI.Notifications:ProcessCombatLog()
    local timeStamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
    local _, class = UnitClass("player")
    local size = self.Sizes()
    local color = self.Colors()
    local affiliation = self.Affiliations()
    local ME, FRIENDLY, PET = affiliation.MINE, affiliation.FRIENDLY, affiliation.PET

    local cast = {}
    function cast.by(affiliation)
        return bit.band(sourceFlags, affiliation) > 0
    end
    function cast.on(affiliation)
        return bit.band(destFlags, affiliation) > 0
    end
    function cast.notOn(affiliation)
        return bit.band(destFlags, affiliation) <= 0
    end

    -- INTERRUPTS
    if event == "SPELL_INTERRUPT" and cast.by(ME) then
        -- Check configuration
        if self:GetConfigValue("showInterrupts", true) then
            local extraSchool = select(17, CombatLogGetCurrentEventInfo())
            local spellSchool = self.SpellSchools()[extraSchool]

            if spellSchool == nil then
                spellSchool = "unknown spell school"
            end
            self.print((L["INTERRUPTED"] or "Interrupted") .. " " .. string.lower(spellSchool) .. ".", color.GREEN, size.SMALL)
        end
    end

    -- DISPEL AND PURGE
    if event == "SPELL_DISPEL" and cast.by(ME) then
        -- Check configuration
        if self:GetConfigValue("showDispels", true) then
            local spellName = select(16, CombatLogGetCurrentEventInfo())
            if cast.on(FRIENDLY) then
                self.print((L["DISPELLED"] or "Dispelled") .. " " .. spellName .. ".", color.WHITE, size.SMALL) -- friendly target
            else
                self.print((L["DISPELLED"] or "Dispelled") .. " " .. spellName .. ".", color.YELLOW, size.SMALL) -- enemy target
            end
        end
    end

    -- SPELLSTEAL
    if event == "SPELL_STOLEN" and cast.by(ME) then
        local spellName = select(16, CombatLogGetCurrentEventInfo())
        self.print((L["STOLE"] or "Stole") .. " " .. spellName .. ".", color.YELLOW, size.SMALL) -- enemy target
    end

    -- PET DIED
    if ((
        event == "UNIT_DIED" or
        event == "UNIT_DESTROYED" or
        event == "UNIT_DISSIPATES") and
        cast.on(ME) and
        cast.on(PET)
    ) then
        -- Check configuration
        if self:GetConfigValue("showPetStatus", true) then
            self.print(L["PET_DEAD"] or "Pet dead.", color.RED, size.LARGE)
            self.playSound("buzz")
        end
    end

    -- SPELL REFLECTION
    if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED" and cast.by(ME) then
        local spellName = select(13, CombatLogGetCurrentEventInfo())
        if spellName == "Mass Spell Reflection" then
            if event == "SPELL_AURA_APPLIED" then
                reflected[destGUID] = true
            else
                reflected[destGUID] = false
            end
        end
    end

    if event == "SPELL_MISSED" and cast.notOn(ME) then
        -- Check configuration
        if self:GetConfigValue("showReflects", true) then
            local spellName, _, missType = select(13, CombatLogGetCurrentEventInfo())
            if missType == "REFLECT" then
                if reflected[destGUID] ~= nil then
                    if reflected[destGUID] then
                        self.print((L["REFLECTED"] or "Reflected") .. " " .. spellName .. ".", color.BLUE, size.SMALL)
                    end
                end
            end
        end
    end

    -- REFLECTED & GROUNDED
    if event == "SPELL_MISSED" and cast.on(ME) then
        -- Check configuration
        if self:GetConfigValue("showReflects", true) then
            local spellName, _, missType = select(13, CombatLogGetCurrentEventInfo())
            if missType == "REFLECT" then
                self.print((L["REFLECTED"] or "Reflected") .. " " .. spellName .. ".", color.WHITE, size.SMALL)
            elseif destName == "Grounding Totem" and cast.on(ME) then
                self.print((L["GROUNDED"] or "Grounded") .. " " .. spellName .. ".", color.WHITE, size.SMALL)
            end
        end
    end

    --
    if event == "SPELL_DAMAGE" and cast.on(ME) then
        -- Check configuration
        if self:GetConfigValue("showReflects", true) then
            local spellName = select(13, CombatLogGetCurrentEventInfo())
            if destName == "Grounding Totem" then
                self.print((L["GROUNDED"] or "Grounded") .. " " .. spellName .. ".", color.WHITE, size.SMALL)
            end
        end
    end

    if event == "SPELL_MISSED" and cast.by(ME) then
        -- Check configuration
        if self:GetConfigValue("showMisses", true) then
            if (
                destGUID == UnitGUID("target") or
                destGUID == UnitGUID("targettarget") or
                destGUID == UnitGUID("focus") or
                destGUID == UnitGUID("player") or
                destGUID == UnitGUID("pet") or
                destGUID == UnitGUID("pettarget") or
                destGUID == UnitGUID("mouseover") or
                destGUID == UnitGUID("mouseovertarget") or
                destGUID == UnitGUID("arena1") or
                destGUID == UnitGUID("arena2") or
                destGUID == UnitGUID("arena3") or
                destGUID == UnitGUID("arena4") or
                destGUID == UnitGUID("arena5") or
                destGUID == UnitGUID("party1") or
                destGUID == UnitGUID("party2") or
                destGUID == UnitGUID("party3") or
                destGUID == UnitGUID("party4") or
                destGUID == UnitGUID("party5")
            ) then -- makes sure dest targ wasn't some random aoe
                local spellName, _, missType = select(13, CombatLogGetCurrentEventInfo())
                local resistMethod = self.MissTypes()[missType]

                if (missType == "ABSORB") then
                    return
                elseif (destName == "Grounding Totem") then
                    resistMethod = "grounded"
                    MySpellGrounded = true
                elseif (missType == "REFLECT") then
                    MySpellReflected = true
                elseif (resistMethod == nil) then
                    resistMethod = "missed"
                end

                if (resistMethod == "immune") or (resistMethod == "evaded") then
                    self.print("" .. spellName .. " " .. resistMethod .. ".", color.RED, size.LARGE)
                else
                    self.print("" .. spellName .. " " .. resistMethod .. ".", color.WHITE, size.LARGE)
                end
            end
        end
    end
end

-- Add configuration to VUI panel
function VUI.Notifications:SetupConfig()
    if VUI.Config and VUI.Config.RegisterModule then
        VUI.Config:RegisterModule("VUINotifications", self.ModuleInfo.title, self.ModuleInfo.desc, self.ModuleInfo.icon)
        
        -- Add config options
        if VUI.Config.AddOption then
            -- Main enable/disable toggle
            VUI.Config:AddOption("VUINotifications", {
                key = "enabled",
                name = L["ENABLE_NOTIFICATIONS"] or "Enable Notifications",
                desc = L["ENABLE_NOTIFICATIONS_DESC"] or "Show notifications for combat events like interrupts, dispels, and misses",
                type = "toggle",
                default = true,
                requiresReload = false,
            })
            
            -- Sound toggle
            VUI.Config:AddOption("VUINotifications", {
                key = "soundsEnabled",
                name = L["ENABLE_SOUNDS"] or "Enable Sounds",
                desc = L["ENABLE_SOUNDS_DESC"] or "Play sounds for important notifications",
                type = "toggle",
                default = true,
                requiresReload = false,
            })
            
            -- Error suppression toggle
            VUI.Config:AddOption("VUINotifications", {
                key = "suppressErrors",
                name = L["SUPPRESS_ERRORS"] or "Suppress Common Errors",
                desc = L["SUPPRESS_ERRORS_DESC"] or "Hide common combat error messages like 'Not enough energy', 'Out of range', etc.",
                type = "toggle",
                default = true,
                requiresReload = false,
            })
            
            -- Notification types header
            VUI.Config:AddOption("VUINotifications", {
                key = "notificationTypesHeader",
                name = L["NOTIFICATION_TYPES"] or "Notification Types",
                desc = L["NOTIFICATION_TYPES_DESC"] or "Configure which types of notifications to show",
                type = "header",
            })
            
            -- Interrupt notifications
            VUI.Config:AddOption("VUINotifications", {
                key = "showInterrupts",
                name = L["SHOW_INTERRUPTS"] or "Show Interrupts",
                desc = L["SHOW_INTERRUPTS_DESC"] or "Show notifications when you successfully interrupt a spell",
                type = "toggle",
                default = true,
                requiresReload = false,
            })
            
            -- Dispel notifications
            VUI.Config:AddOption("VUINotifications", {
                key = "showDispels",
                name = L["SHOW_DISPELS"] or "Show Dispels",
                desc = L["SHOW_DISPELS_DESC"] or "Show notifications when you successfully dispel a buff or debuff",
                type = "toggle",
                default = true,
                requiresReload = false,
            })
            
            -- Miss notifications
            VUI.Config:AddOption("VUINotifications", {
                key = "showMisses",
                name = L["SHOW_MISSES"] or "Show Misses",
                desc = L["SHOW_MISSES_DESC"] or "Show notifications when your abilities miss, are dodged, parried, etc.",
                type = "toggle",
                default = true,
                requiresReload = false,
            })
            
            -- Reflect notifications
            VUI.Config:AddOption("VUINotifications", {
                key = "showReflects",
                name = L["SHOW_REFLECTS"] or "Show Reflects",
                desc = L["SHOW_REFLECTS_DESC"] or "Show notifications when spells are reflected",
                type = "toggle",
                default = true,
                requiresReload = false,
            })
            
            -- Pet notifications
            VUI.Config:AddOption("VUINotifications", {
                key = "showPetStatus",
                name = L["SHOW_PET_STATUS"] or "Show Pet Status",
                desc = L["SHOW_PET_STATUS_DESC"] or "Show notifications when your pet dies",
                type = "toggle",
                default = true,
                requiresReload = false,
            })
        end
    end
end

-- Helper function to get config value with fallback to default
function VUI.Notifications:GetConfigValue(key, defaultValue)
    if VUI_SavedVariables and 
       VUI_SavedVariables.VUINotifications and 
       VUI_SavedVariables.VUINotifications[key] ~= nil then
        return VUI_SavedVariables.VUINotifications[key]
    end
    return defaultValue
end

-- Initialize the module
function VUI.Notifications:Initialize()
    if self.Initialized then
        return
    end
    
    -- Set up config
    self:SetupConfig()
    
    -- Set up error suppression
    if self:GetConfigValue("suppressErrors", true) then
        self.HookErrorsFrame()
    end
    
    -- Add slash command
    SLASH_VUINOTIFICATIONS1 = "/vuin"
    SLASH_VUINOTIFICATIONS2 = "/vuinotifications"
    SlashCmdList["VUINOTIFICATIONS"] = function(msg)
        if VUI.Config and VUI.Config.OpenConfigPanel then
            VUI.Config:OpenConfigPanel("VUINotifications")
        else
            print("|cff33ff99VUI Notifications:|r Use /vui for configuration.")
        end
    end
    
    -- Mark as initialized
    self.Initialized = true
    
    -- Log initialization
    if VUI.Utilities and VUI.Utilities.Logger then
        VUI.Utilities.Logger:Log("VUINotifications initialized")
    else
        print("|cff33ff99VUI Notifications:|r Module initialized")
    end
end
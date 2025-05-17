--[[
    VUI Global Cooldown Module Configuration
    Based on TrufiGCD by stevemyz@gmail.com
]]

local Layout = VUI:NewModule('Config.Layout.VUITGCD')

-- Initialize with the standard layout helper
VUI.ConfigHelpers.CreateStandardLayout(Layout, "VUITGCD", "VUI Global Cooldown", "vmodules.vuitgcd")

-- Function to ensure module database is properly accessible
local function ensureModuleDB(module, db)
    if not module then return nil end
    
    -- Create necessary paths in database
    if not db.profile.vmodules then db.profile.vmodules = {} end
    if not db.profile.vmodules.vuitgcd then db.profile.vmodules.vuitgcd = {} end
    
    -- If module has settings, create them if not present
    if not module.db or not module.db.profile then
        module.db = module.db or {}
        module.db.profile = module.db.profile or {}
    end
    
    -- Create necessary settings categories
    if not module.db.profile.display then module.db.profile.display = {} end
    if not module.db.profile.general then module.db.profile.general = {} end
    if not module.db.profile.tracking then module.db.profile.tracking = {} end
    if not module.db.profile.filter then module.db.profile.filter = {} end
    if not module.db.profile.instances then module.db.profile.instances = {} end
    if not module.db.profile.unitSettings then module.db.profile.unitSettings = {} end
    
    -- Ensure unit tracking settings
    local unitTypes = {"player", "target", "focus", "party1", "party2", "party3", "party4", "arena1", "arena2", "arena3"}
    for _, unitType in ipairs(unitTypes) do
        if not module.db.profile.unitSettings[unitType] then
            module.db.profile.unitSettings[unitType] = {
                enable = (unitType == "player"), -- Only player enabled by default
                scale = 1.0,
                alpha = 1.0,
                position = {"CENTER", 0, (unitType == "player") and 0 or (unitType:match("arena") and -40 * tonumber(unitType:match("%d+")) or 40 * (tonumber(unitType:match("%d+")) or 1))},
                lockFrame = false,
            }
        end
    end
    
    -- Sync with vmodules path for UI
    db.profile.vmodules.vuitgcd.display = module.db.profile.display
    db.profile.vmodules.vuitgcd.general = module.db.profile.general
    db.profile.vmodules.vuitgcd.tracking = module.db.profile.tracking
    db.profile.vmodules.vuitgcd.filter = module.db.profile.filter
    db.profile.vmodules.vuitgcd.instances = module.db.profile.instances
    db.profile.vmodules.vuitgcd.unitSettings = module.db.profile.unitSettings
    
    return module.db
end

-- Helper function to open the TrufiGCD settings panel
local function openTrufiGCDSettings(module)
    if not module then return end
    
    local ns = _G.VUI.TGCD
    if ns and ns.settingsFrame and ns.settingsFrame.frame and ns.settingsFrame.frame.Show then
        ns.settingsFrame.frame:Show()
    end
end

-- Helper function to toggle TrufiGCD anchors
local function toggleTrufiGCDAnchors(module)
    if not module then return end
    
    local ns = _G.VUI.TGCD
    if ns and ns.settingsFrame and ns.settingsFrame.toggleAnchors then
        ns.settingsFrame.toggleAnchors()
    end
end

-- Helper function to sync settings to TrufiGCD
local function syncToTrufiGCD(module)
    if not module or not module.db or not module.db.profile then return end
    
    local ns = _G.VUI.TGCD
    if not ns or not ns.settings or not ns.settings.activeProfile then return end
    
    -- Sync general settings
    if ns.settings.activeProfile.enabledIn then
        ns.settings.activeProfile.enabledIn.enabled = module.db.profile.enabled
        
        -- Location settings
        if module.db.profile.instances then
            ns.settings.activeProfile.enabledIn.world = module.db.profile.instances.showInWorld
            ns.settings.activeProfile.enabledIn.party = module.db.profile.instances.showInInstances
            ns.settings.activeProfile.enabledIn.raid = module.db.profile.instances.showInRaid
            ns.settings.activeProfile.enabledIn.arena = module.db.profile.instances.showInPVP
            ns.settings.activeProfile.enabledIn.battleground = module.db.profile.instances.showInPVP
            ns.settings.activeProfile.enabledIn.combatOnly = module.db.profile.instances.combatOnly
        end
    end
    
    -- Sync layout settings
    if ns.settings.activeProfile.layoutSettings then
        for layoutType, layoutSettings in pairs(ns.settings.activeProfile.layoutSettings) do
            layoutSettings.iconSize = module.db.profile.iconSize or 30
            layoutSettings.direction = module.db.profile.direction or "DOWN"
            layoutSettings.iconsNumber = module.db.profile.maxIcons or 8
            
            -- Enable settings based on unit type mapping
            if layoutType == "player" then
                layoutSettings.enable = module.db.profile.unitSettings.player.enable
            elseif layoutType == "target" then
                layoutSettings.enable = module.db.profile.unitSettings.target.enable
            elseif layoutType == "focus" then
                layoutSettings.enable = module.db.profile.unitSettings.focus.enable
            elseif layoutType == "party" then
                layoutSettings.enable = (
                    module.db.profile.unitSettings.party1.enable or
                    module.db.profile.unitSettings.party2.enable or
                    module.db.profile.unitSettings.party3.enable or
                    module.db.profile.unitSettings.party4.enable
                )
            elseif layoutType == "arena" then
                layoutSettings.enable = (
                    module.db.profile.unitSettings.arena1.enable or
                    module.db.profile.unitSettings.arena2.enable or
                    module.db.profile.unitSettings.arena3.enable
                )
            end
        end
    end
    
    -- Update location check based on new settings
    if ns.locationCheck and ns.locationCheck.settingsChanged then
        ns.locationCheck.settingsChanged()
    end
    
    -- Save settings to ensure they're persisted
    if ns.settings.Save then
        ns.settings:Save()
    end
end

-- Define module-specific layout construction
function Layout:BuildModuleLayout(module, db)
    -- Initialize module DB
    local moduleDB = ensureModuleDB(module, db)
    if not moduleDB then return end
    
    -- Utility function to handle setting changes
    local function handleSettingChange(self)
        if module and module.SyncWithVUIConfig then
            module:SyncWithVUIConfig()
        else
            syncToTrufiGCD(module)
        end
    end
    
    -- Add TrufiGCD-specific controls
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'TrufiGCD Controls'
        },
    })
    
    table.insert(Layout.layout.rows, {
        openSettings = {
            type = 'button',
            label = 'Open TrufiGCD Settings',
            tooltip = 'Open the complete TrufiGCD settings panel',
            column = 6,
            order = 1,
            callback = function()
                openTrufiGCDSettings(module)
            end
        },
        toggleAnchors = {
            type = 'button',
            label = 'Show Frame Anchors',
            tooltip = 'Toggle visibility of frame anchors for repositioning',
            column = 6,
            order = 2,
            callback = function()
                toggleTrufiGCDAnchors(module)
            end
        },
    })
    
    -- General settings section
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'General Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        enableModule = {
            key = 'vmodules.vuitgcd.enabled',
            type = 'checkbox',
            label = 'Enable VUITGCD',
            tooltip = 'Enable or disable the VUITGCD module',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.enabled = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
        showBorders = {
            key = 'vmodules.vuitgcd.display.showBorders',
            type = 'checkbox',
            label = 'Show Borders',
            tooltip = 'Show borders around spell icons',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showBorders = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
        showSpellName = {
            key = 'vmodules.vuitgcd.display.showSpellName',
            type = 'checkbox',
            label = 'Show Spell Names',
            tooltip = 'Show spell names on icons',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.display.showSpellName = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
    })
    
    -- Layout settings section
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Layout Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        iconSize = {
            key = 'vmodules.vuitgcd.iconSize',
            type = 'slider',
            label = 'Icon Size',
            tooltip = 'Set the size of spell icons',
            min = 16,
            max = 64,
            step = 1,
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.iconSize = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
        iconAlpha = {
            key = 'vmodules.vuitgcd.iconAlpha',
            type = 'slider',
            label = 'Icon Alpha',
            tooltip = 'Set the transparency of icons',
            min = 0.1,
            max = 1.0,
            step = 0.01,
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.iconAlpha = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
        fadeTime = {
            key = 'vmodules.vuitgcd.fadeTime',
            type = 'slider',
            label = 'Fade Time',
            tooltip = 'Set how long icons take to fade out',
            min = 0.1,
            max = 3.0,
            step = 0.1,
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.fadeTime = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
    })
    
    table.insert(Layout.layout.rows, {
        maxIcons = {
            key = 'vmodules.vuitgcd.maxIcons',
            type = 'slider',
            label = 'Maximum Icons',
            tooltip = 'Set the maximum number of icons shown',
            min = 1,
            max = 16,
            step = 1,
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.maxIcons = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
        direction = {
            key = 'vmodules.vuitgcd.direction',
            type = 'dropdown',
            label = 'Icon Direction',
            tooltip = 'Set the direction in which icons flow',
            options = {
                UP = "Up",
                RIGHT = "Right",
                DOWN = "Down",
                LEFT = "Left"
            },
            column = 8,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.direction = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
    })
    
    -- Unit tracking section
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Unit Tracking'
        },
    })
    
    table.insert(Layout.layout.rows, {
        trackPlayer = {
            key = 'vmodules.vuitgcd.unitSettings.player.enable',
            type = 'checkbox',
            label = 'Track Player',
            tooltip = 'Track spell casts for your character',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.unitSettings.player.enable = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
        trackTarget = {
            key = 'vmodules.vuitgcd.unitSettings.target.enable',
            type = 'checkbox',
            label = 'Track Target',
            tooltip = 'Track spell casts for your target',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.unitSettings.target.enable = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
        trackFocus = {
            key = 'vmodules.vuitgcd.unitSettings.focus.enable',
            type = 'checkbox',
            label = 'Track Focus',
            tooltip = 'Track spell casts for your focus target',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.unitSettings.focus.enable = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
    })
    
    -- Party and Arena tracking
    table.insert(Layout.layout.rows, {
        trackParty1 = {
            key = 'vmodules.vuitgcd.unitSettings.party1.enable',
            type = 'checkbox',
            label = 'Track Party 1',
            tooltip = 'Track spell casts for party member 1',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.unitSettings.party1.enable = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
        trackParty2 = {
            key = 'vmodules.vuitgcd.unitSettings.party2.enable',
            type = 'checkbox',
            label = 'Track Party 2',
            tooltip = 'Track spell casts for party member 2',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.unitSettings.party2.enable = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
        trackParty3 = {
            key = 'vmodules.vuitgcd.unitSettings.party3.enable',
            type = 'checkbox',
            label = 'Track Party 3',
            tooltip = 'Track spell casts for party member 3',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.unitSettings.party3.enable = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
    })
    
    table.insert(Layout.layout.rows, {
        trackArena1 = {
            key = 'vmodules.vuitgcd.unitSettings.arena1.enable',
            type = 'checkbox',
            label = 'Track Arena 1',
            tooltip = 'Track spell casts for arena opponent 1',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.unitSettings.arena1.enable = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
        trackArena2 = {
            key = 'vmodules.vuitgcd.unitSettings.arena2.enable',
            type = 'checkbox',
            label = 'Track Arena 2',
            tooltip = 'Track spell casts for arena opponent 2',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.unitSettings.arena2.enable = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
        trackArena3 = {
            key = 'vmodules.vuitgcd.unitSettings.arena3.enable',
            type = 'checkbox',
            label = 'Track Arena 3',
            tooltip = 'Track spell casts for arena opponent 3',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.unitSettings.arena3.enable = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
    })
    
    -- Instance settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Location Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        showInWorld = {
            key = 'vmodules.vuitgcd.instances.showInWorld',
            type = 'checkbox',
            label = 'Show In World',
            tooltip = 'Show icons when in the open world',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.instances.showInWorld = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
        showInInstances = {
            key = 'vmodules.vuitgcd.instances.showInInstances',
            type = 'checkbox',
            label = 'Show In Dungeons',
            tooltip = 'Show icons when in dungeons',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.instances.showInInstances = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
        showInRaid = {
            key = 'vmodules.vuitgcd.instances.showInRaid',
            type = 'checkbox',
            label = 'Show In Raids',
            tooltip = 'Show icons when in raids',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.instances.showInRaid = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
    })
    
    table.insert(Layout.layout.rows, {
        showInPVP = {
            key = 'vmodules.vuitgcd.instances.showInPVP',
            type = 'checkbox',
            label = 'Show In PVP',
            tooltip = 'Show icons when in battlegrounds and arenas',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.instances.showInPVP = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
        combatOnly = {
            key = 'vmodules.vuitgcd.instances.combatOnly',
            type = 'checkbox',
            label = 'Combat Only',
            tooltip = 'Only show icons when in combat',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.instances.combatOnly = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
    })
    
    -- Advanced settings
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Advanced Settings'
        },
    })
    
    table.insert(Layout.layout.rows, {
        showGCDOnly = {
            key = 'vmodules.vuitgcd.showGCDOnly',
            type = 'checkbox',
            label = 'Show GCD Only',
            tooltip = 'Only track spells that trigger the global cooldown',
            column = 4,
            order = 1,
            callback = function(self)
                if module and module.db then
                    module.db.profile.showGCDOnly = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
        enableMasque = {
            key = 'vmodules.vuitgcd.enableMasque',
            type = 'checkbox',
            label = 'Enable Masque',
            tooltip = 'Allow Masque addon to skin the icons',
            column = 4,
            order = 2,
            callback = function(self)
                if module and module.db then
                    module.db.profile.enableMasque = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
        hideMacroText = {
            key = 'vmodules.vuitgcd.hideMacroText',
            type = 'checkbox',
            label = 'Hide Macro Text',
            tooltip = 'Hide the macro text on icons',
            column = 4,
            order = 3,
            callback = function(self)
                if module and module.db then
                    module.db.profile.hideMacroText = self:GetValue()
                    handleSettingChange(self)
                end
            end
        },
    })
    
    -- Note about blocklist
    table.insert(Layout.layout.rows, {
        header = {
            type = 'header',
            label = 'Spell Blocklist'
        },
    })
    
    table.insert(Layout.layout.rows, {
        blocklistInfo = {
            type = 'label',
            label = 'Use the TrufiGCD settings panel to manage the spell blocklist.',
            column = 12,
            order = 1,
        },
    })
end

-- Return the layout
return Layout 
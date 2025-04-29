-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Theme Integration
-- Author: VortexQ8
-- VUI Theme integration for MSBT
-------------------------------------------------------------------------------

local addonName, VUI = ...

-- Create a local reference to MikSBT
local MikSBT = _G["MikSBT"]
if not MikSBT then return end

-- Create the theme integration namespace
local MSBT = VUI.modules.MSBT
MSBT.ThemeIntegration = {}
local ThemeIntegration = MSBT.ThemeIntegration

-- Local references for faster access
local Media = MikSBT.Media
local Profiles = MikSBT.Profiles
local Animations = MikSBT.Animations

-- Theme color definitions
local themeColors = {
    phoenixflame = {
        background = {26/255, 10/255, 5/255, 0.85}, -- Dark red/brown background
        border = {230/255, 77/255, 13/255}, -- Fiery orange borders
        highlight = {255/255, 163/255, 26/255}, -- Amber highlights
        damage = {255/255, 128/255, 0/255},
        critdamage = {255/255, 64/255, 0/255},
        healing = {255/255, 192/255, 64/255},
        crithealing = {255/255, 215/255, 0/255},
    },
    thunderstorm = {
        background = {10/255, 10/255, 26/255, 0.85}, -- Deep blue backgrounds
        border = {13/255, 157/255, 230/255}, -- Electric blue borders
        highlight = {64/255, 179/255, 255/255}, -- Light blue highlights 
        damage = {32/255, 154/255, 214/255},
        critdamage = {0/255, 191/255, 255/255},
        healing = {102/255, 205/255, 255/255},
        crithealing = {126/255, 236/255, 255/255},
    },
    arcanemystic = {
        background = {26/255, 10/255, 47/255, 0.85}, -- Deep purple backgrounds
        border = {157/255, 13/255, 230/255}, -- Violet borders
        highlight = {179/255, 64/255, 255/255}, -- Light purple highlights
        damage = {153/255, 51/255, 255/255},
        critdamage = {178/255, 102/255, 255/255},
        healing = {216/255, 191/255, 216/255},
        crithealing = {238/255, 130/255, 238/255},
    },
    felenergy = {
        background = {10/255, 26/255, 10/255, 0.85}, -- Dark green backgrounds
        border = {26/255, 255/255, 26/255}, -- Fel green borders
        highlight = {64/255, 255/255, 64/255}, -- Light green highlights
        damage = {0/255, 204/255, 0/255},
        critdamage = {124/255, 252/255, 0/255},
        healing = {144/255, 238/255, 144/255},
        crithealing = {0/255, 255/255, 127/255},
    },
}

-- Animation path definitions based on themes
local animationPaths = {
    phoenixflame = "Interface\\Addons\\VUI\\media\\textures\\phoenixflame\\msbt\\animpath",
    thunderstorm = "Interface\\Addons\\VUI\\media\\textures\\thunderstorm\\msbt\\animpath",
    arcanemystic = "Interface\\Addons\\VUI\\media\\textures\\arcanemystic\\msbt\\animpath",
    felenergy = "Interface\\Addons\\VUI\\media\\textures\\felenergy\\msbt\\animpath",
    default = "Interface\\Addons\\VUI\\media\\textures\\msbt\\animpath",
}

-- Initialize theme integration
function ThemeIntegration:Initialize()
    -- Register for theme change events from VUI
    if VUI.RegisterCallback then
        VUI:RegisterCallback("ThemeChanged", function(theme)
            ThemeIntegration:ApplyTheme(theme)
        end)
    end
    
    -- Register additional animation paths
    self:RegisterAnimationPaths()
end

-- Register theme-specific animation paths
function ThemeIntegration:RegisterAnimationPaths()
    -- Register animation paths for each theme if the Animations module is available
    if Animations and Animations.RegisterAnimationPath then
        Animations:RegisterAnimationPath("VUI Phoenix Flame", animationPaths.phoenixflame)
        Animations:RegisterAnimationPath("VUI Thunder Storm", animationPaths.thunderstorm)
        Animations:RegisterAnimationPath("VUI Arcane Mystic", animationPaths.arcanemystic)
        Animations:RegisterAnimationPath("VUI Fel Energy", animationPaths.felenergy)
    end
end

-- Register default scroll areas with theme support
function ThemeIntegration:RegisterDefaultScrollAreas()
    -- Only proceed if profiles are available
    if not Profiles or not Profiles.RegisterScrollArea then return end
    
    -- Get current theme colors
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    local colors = themeColors[theme] or themeColors.thunderstorm
    
    -- Set up VUI themed scroll areas if they don't exist
    if not Profiles.IsScrollAreaRegistered or not Profiles:IsScrollAreaRegistered("VUI_INCOMING") then
        -- Register incoming damage area (center and down)
        Profiles:RegisterScrollArea("VUI_INCOMING", L["Incoming"], -35, -65, true)
    end
    
    if not Profiles.IsScrollAreaRegistered or not Profiles:IsScrollAreaRegistered("VUI_OUTGOING") then
        -- Register outgoing damage area (center and up)
        Profiles:RegisterScrollArea("VUI_OUTGOING", L["Outgoing"], -35, 65, true)
    end
    
    if not Profiles.IsScrollAreaRegistered or not Profiles:IsScrollAreaRegistered("VUI_NOTIFICATION") then
        -- Register notification area (slightly right of center)
        Profiles:RegisterScrollArea("VUI_NOTIFICATION", L["Notification"], 35, 0, true)
    end
    
    -- Update default MSBT events to use our themed scroll areas if VUI theme is enabled
    if Profiles.currentProfile and VUI.db.profile.modules.msbt.useVUITheme then
        -- Redirect incoming events
        Profiles.currentProfile.events.INCOMING_DAMAGE.scrollArea = "VUI_INCOMING"
        Profiles.currentProfile.events.INCOMING_DAMAGE_CRIT.scrollArea = "VUI_INCOMING"
        Profiles.currentProfile.events.INCOMING_MISS.scrollArea = "VUI_INCOMING"
        
        -- Redirect outgoing events
        Profiles.currentProfile.events.OUTGOING_DAMAGE.scrollArea = "VUI_OUTGOING"
        Profiles.currentProfile.events.OUTGOING_DAMAGE_CRIT.scrollArea = "VUI_OUTGOING"
        Profiles.currentProfile.events.OUTGOING_MISS.scrollArea = "VUI_OUTGOING"
        Profiles.currentProfile.events.OUTGOING_HEAL.scrollArea = "VUI_OUTGOING"
        Profiles.currentProfile.events.OUTGOING_HEAL_CRIT.scrollArea = "VUI_OUTGOING"
        
        -- Redirect notification events
        Profiles.currentProfile.events.NOTIFICATION_DEBUFF.scrollArea = "VUI_NOTIFICATION"
        Profiles.currentProfile.events.NOTIFICATION_BUFF.scrollArea = "VUI_NOTIFICATION"
        Profiles.currentProfile.events.NOTIFICATION_ITEM_BUFF.scrollArea = "VUI_NOTIFICATION"
        Profiles.currentProfile.events.NOTIFICATION_BUFF_FADE.scrollArea = "VUI_NOTIFICATION" 
        Profiles.currentProfile.events.NOTIFICATION_DEBUFF_FADE.scrollArea = "VUI_NOTIFICATION"
        Profiles.currentProfile.events.NOTIFICATION_ITEM_BUFF_FADE.scrollArea = "VUI_NOTIFICATION"
        Profiles.currentProfile.events.NOTIFICATION_COMBAT_ENTER.scrollArea = "VUI_NOTIFICATION"
        Profiles.currentProfile.events.NOTIFICATION_COMBAT_LEAVE.scrollArea = "VUI_NOTIFICATION"
        Profiles.currentProfile.events.NOTIFICATION_POWER_GAIN.scrollArea = "VUI_NOTIFICATION"
        Profiles.currentProfile.events.NOTIFICATION_POWER_LOSS.scrollArea = "VUI_NOTIFICATION"
        Profiles.currentProfile.events.NOTIFICATION_CP_GAIN.scrollArea = "VUI_NOTIFICATION"
        Profiles.currentProfile.events.NOTIFICATION_CP_FULL.scrollArea = "VUI_NOTIFICATION"
        Profiles.currentProfile.events.NOTIFICATION_HONOR_GAIN.scrollArea = "VUI_NOTIFICATION"
        Profiles.currentProfile.events.NOTIFICATION_REP_GAIN.scrollArea = "VUI_NOTIFICATION"
        Profiles.currentProfile.events.NOTIFICATION_REP_LOSS.scrollArea = "VUI_NOTIFICATION"
        Profiles.currentProfile.events.NOTIFICATION_SKILL_GAIN.scrollArea = "VUI_NOTIFICATION"
        Profiles.currentProfile.events.NOTIFICATION_EXPERIENCE_GAIN.scrollArea = "VUI_NOTIFICATION"
    end
end

-- Apply the current theme to MSBT
function ThemeIntegration:ApplyTheme(theme)
    -- Don't do anything if Profile or Media modules aren't available
    if not MikSBT or not MikSBT.Media or not MikSBT.Profiles then return end
    
    -- Ensure we have a valid theme
    theme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    if not themeColors[theme] then theme = "thunderstorm" end
    
    -- Apply theme-specific sounds
    self:ApplyThemeSounds(theme)
    
    -- Only modify colors and appearance if VUI theme integration is enabled
    if VUI.db.profile.modules.msbt.useVUITheme then
        self:ApplyThemeColors(theme)
        self:ApplyThemeAnimations(theme)
    end
end

-- Apply theme-specific sounds based on the current theme
function ThemeIntegration:ApplyThemeSounds(theme)
    -- Get the MikSBT Media module
    local Media = MikSBT.Media
    if not Media or not Media.RegisterSound then return end
    
    -- Register theme-specific sounds
    if theme == "phoenixflame" then
        Media.RegisterSound("MSBT Low Health", "Interface\\Addons\\VUI\\media\\sounds\\phoenixflame\\msbt\\LowHealth.ogg")
        Media.RegisterSound("MSBT Low Mana", "Interface\\Addons\\VUI\\media\\sounds\\phoenixflame\\msbt\\LowMana.ogg")
        Media.RegisterSound("MSBT Cooldown", "Interface\\Addons\\VUI\\media\\sounds\\phoenixflame\\msbt\\Cooldown.ogg")
        Media.RegisterSound("MSBT Crit", "Interface\\Addons\\VUI\\media\\sounds\\phoenixflame\\msbt\\Crit.ogg")
        Media.RegisterSound("MSBT Proc", "Interface\\Addons\\VUI\\media\\sounds\\phoenixflame\\msbt\\Proc.ogg")
        Media.RegisterSound("MSBT Dodge", "Interface\\Addons\\VUI\\media\\sounds\\phoenixflame\\msbt\\Dodge.ogg")
        Media.RegisterSound("MSBT Parry", "Interface\\Addons\\VUI\\media\\sounds\\phoenixflame\\msbt\\Parry.ogg")
        Media.RegisterSound("MSBT Block", "Interface\\Addons\\VUI\\media\\sounds\\phoenixflame\\msbt\\Block.ogg")
        Media.RegisterSound("MSBT Heal", "Interface\\Addons\\VUI\\media\\sounds\\phoenixflame\\msbt\\Heal.ogg")
    elseif theme == "thunderstorm" then
        Media.RegisterSound("MSBT Low Health", "Interface\\Addons\\VUI\\media\\sounds\\thunderstorm\\msbt\\LowHealth.ogg")
        Media.RegisterSound("MSBT Low Mana", "Interface\\Addons\\VUI\\media\\sounds\\thunderstorm\\msbt\\LowMana.ogg")
        Media.RegisterSound("MSBT Cooldown", "Interface\\Addons\\VUI\\media\\sounds\\thunderstorm\\msbt\\Cooldown.ogg")
        Media.RegisterSound("MSBT Crit", "Interface\\Addons\\VUI\\media\\sounds\\thunderstorm\\msbt\\Crit.ogg")
        Media.RegisterSound("MSBT Proc", "Interface\\Addons\\VUI\\media\\sounds\\thunderstorm\\msbt\\Proc.ogg")
        Media.RegisterSound("MSBT Dodge", "Interface\\Addons\\VUI\\media\\sounds\\thunderstorm\\msbt\\Dodge.ogg")
        Media.RegisterSound("MSBT Parry", "Interface\\Addons\\VUI\\media\\sounds\\thunderstorm\\msbt\\Parry.ogg")
        Media.RegisterSound("MSBT Block", "Interface\\Addons\\VUI\\media\\sounds\\thunderstorm\\msbt\\Block.ogg")
        Media.RegisterSound("MSBT Heal", "Interface\\Addons\\VUI\\media\\sounds\\thunderstorm\\msbt\\Heal.ogg")
    elseif theme == "arcanemystic" then
        Media.RegisterSound("MSBT Low Health", "Interface\\Addons\\VUI\\media\\sounds\\arcanemystic\\msbt\\LowHealth.ogg")
        Media.RegisterSound("MSBT Low Mana", "Interface\\Addons\\VUI\\media\\sounds\\arcanemystic\\msbt\\LowMana.ogg")
        Media.RegisterSound("MSBT Cooldown", "Interface\\Addons\\VUI\\media\\sounds\\arcanemystic\\msbt\\Cooldown.ogg")
        Media.RegisterSound("MSBT Crit", "Interface\\Addons\\VUI\\media\\sounds\\arcanemystic\\msbt\\Crit.ogg")
        Media.RegisterSound("MSBT Proc", "Interface\\Addons\\VUI\\media\\sounds\\arcanemystic\\msbt\\Proc.ogg")
        Media.RegisterSound("MSBT Dodge", "Interface\\Addons\\VUI\\media\\sounds\\arcanemystic\\msbt\\Dodge.ogg")
        Media.RegisterSound("MSBT Parry", "Interface\\Addons\\VUI\\media\\sounds\\arcanemystic\\msbt\\Parry.ogg")
        Media.RegisterSound("MSBT Block", "Interface\\Addons\\VUI\\media\\sounds\\arcanemystic\\msbt\\Block.ogg")
        Media.RegisterSound("MSBT Heal", "Interface\\Addons\\VUI\\media\\sounds\\arcanemystic\\msbt\\Heal.ogg")
    elseif theme == "felenergy" then
        Media.RegisterSound("MSBT Low Health", "Interface\\Addons\\VUI\\media\\sounds\\felenergy\\msbt\\LowHealth.ogg")
        Media.RegisterSound("MSBT Low Mana", "Interface\\Addons\\VUI\\media\\sounds\\felenergy\\msbt\\LowMana.ogg")
        Media.RegisterSound("MSBT Cooldown", "Interface\\Addons\\VUI\\media\\sounds\\felenergy\\msbt\\Cooldown.ogg")
        Media.RegisterSound("MSBT Crit", "Interface\\Addons\\VUI\\media\\sounds\\felenergy\\msbt\\Crit.ogg")
        Media.RegisterSound("MSBT Proc", "Interface\\Addons\\VUI\\media\\sounds\\felenergy\\msbt\\Proc.ogg")
        Media.RegisterSound("MSBT Dodge", "Interface\\Addons\\VUI\\media\\sounds\\felenergy\\msbt\\Dodge.ogg")
        Media.RegisterSound("MSBT Parry", "Interface\\Addons\\VUI\\media\\sounds\\felenergy\\msbt\\Parry.ogg")
        Media.RegisterSound("MSBT Block", "Interface\\Addons\\VUI\\media\\sounds\\felenergy\\msbt\\Block.ogg")
        Media.RegisterSound("MSBT Heal", "Interface\\Addons\\VUI\\media\\sounds\\felenergy\\msbt\\Heal.ogg")
    else
        -- Fallback to default sounds
        Media.RegisterSound("MSBT Low Health", "Interface\\Addons\\VUI\\media\\sounds\\msbt\\LowHealth.ogg")
        Media.RegisterSound("MSBT Low Mana", "Interface\\Addons\\VUI\\media\\sounds\\msbt\\LowMana.ogg")
        Media.RegisterSound("MSBT Cooldown", "Interface\\Addons\\VUI\\media\\sounds\\msbt\\Cooldown.ogg")
        Media.RegisterSound("MSBT Crit", "Interface\\Addons\\VUI\\media\\sounds\\msbt\\Crit.ogg")
        Media.RegisterSound("MSBT Proc", "Interface\\Addons\\VUI\\media\\sounds\\msbt\\Proc.ogg")
        Media.RegisterSound("MSBT Dodge", "Interface\\Addons\\VUI\\media\\sounds\\msbt\\Dodge.ogg")
        Media.RegisterSound("MSBT Parry", "Interface\\Addons\\VUI\\media\\sounds\\msbt\\Parry.ogg")
        Media.RegisterSound("MSBT Block", "Interface\\Addons\\VUI\\media\\sounds\\msbt\\Block.ogg")
        Media.RegisterSound("MSBT Heal", "Interface\\Addons\\VUI\\media\\sounds\\msbt\\Heal.ogg")
    end
    
    -- Connect sounds to notification events
    if VUI.db.profile.modules.msbt.soundsEnabled and Profiles and Profiles.currentProfile then
        local currentProfile = Profiles.currentProfile
        if currentProfile.events then
            -- Low health notification
            if currentProfile.events.NOTIFICATION_LOW_HEALTH then
                currentProfile.events.NOTIFICATION_LOW_HEALTH.soundName = "MSBT Low Health"
            end
            
            -- Low mana notification
            if currentProfile.events.NOTIFICATION_LOW_MANA then
                currentProfile.events.NOTIFICATION_LOW_MANA.soundName = "MSBT Low Mana"
            end
            
            -- Cooldown notification
            if currentProfile.events.NOTIFICATION_COOLDOWN then
                currentProfile.events.NOTIFICATION_COOLDOWN.soundName = "MSBT Cooldown"
            end
            
            -- Proc notification
            if currentProfile.events.NOTIFICATION_BUFF then
                currentProfile.events.NOTIFICATION_BUFF.soundName = "MSBT Proc"
            end
            
            -- Critical hit notification
            if currentProfile.events.OUTGOING_DAMAGE_CRIT then
                currentProfile.events.OUTGOING_DAMAGE_CRIT.soundName = "MSBT Crit"
            end
        end
    end
end

-- Apply theme colors to scroll areas
function ThemeIntegration:ApplyThemeColors(theme)
    -- Get the current profile and theme colors
    local currentProfile = Profiles.currentProfile
    if not currentProfile then return end
    
    local colors = themeColors[theme] or themeColors.thunderstorm
    
    -- Apply theme colors to all scroll areas
    for _, scrollArea in pairs(currentProfile.scrollAreas) do
        -- Apply scroll area colors
        scrollArea.backgroundColorR = colors.background[1]
        scrollArea.backgroundColorG = colors.background[2]
        scrollArea.backgroundColorB = colors.background[3]
        scrollArea.backgroundColorA = colors.background[4] or 0.85
        
        scrollArea.borderColorR = colors.border[1]
        scrollArea.borderColorG = colors.border[2]
        scrollArea.borderColorB = colors.border[3]
        
        -- Apply normal text colors
        if VUI.db.profile.modules.msbt.themeColoredText then
            if string.find(scrollArea.name, "INCOMING") then
                scrollArea.normalFontColor = {colors.damage[1], colors.damage[2], colors.damage[3]}
                scrollArea.critFontColor = {colors.critdamage[1], colors.critdamage[2], colors.critdamage[3]}
            elseif string.find(scrollArea.name, "OUTGOING") then
                scrollArea.normalFontColor = {colors.healing[1], colors.healing[2], colors.healing[3]}
                scrollArea.critFontColor = {colors.crithealing[1], colors.crithealing[2], colors.crithealing[3]}
            end
        end
    end
    
    -- Apply event colors 
    if VUI.db.profile.modules.msbt.themeColoredText and currentProfile.events then
        -- Outgoing damage
        if currentProfile.events.OUTGOING_DAMAGE then
            currentProfile.events.OUTGOING_DAMAGE.colorR = colors.damage[1]
            currentProfile.events.OUTGOING_DAMAGE.colorG = colors.damage[2]
            currentProfile.events.OUTGOING_DAMAGE.colorB = colors.damage[3]
        end
        
        -- Outgoing damage crit
        if currentProfile.events.OUTGOING_DAMAGE_CRIT then
            currentProfile.events.OUTGOING_DAMAGE_CRIT.colorR = colors.critdamage[1]
            currentProfile.events.OUTGOING_DAMAGE_CRIT.colorG = colors.critdamage[2]
            currentProfile.events.OUTGOING_DAMAGE_CRIT.colorB = colors.critdamage[3]
        end
        
        -- Outgoing heal
        if currentProfile.events.OUTGOING_HEAL then
            currentProfile.events.OUTGOING_HEAL.colorR = colors.healing[1]
            currentProfile.events.OUTGOING_HEAL.colorG = colors.healing[2]
            currentProfile.events.OUTGOING_HEAL.colorB = colors.healing[3]
        end
        
        -- Outgoing heal crit
        if currentProfile.events.OUTGOING_HEAL_CRIT then
            currentProfile.events.OUTGOING_HEAL_CRIT.colorR = colors.crithealing[1]
            currentProfile.events.OUTGOING_HEAL_CRIT.colorG = colors.crithealing[2]
            currentProfile.events.OUTGOING_HEAL_CRIT.colorB = colors.crithealing[3]
        end
    end
end

-- Apply theme-specific animations
function ThemeIntegration:ApplyThemeAnimations(theme)
    -- Get the current profile
    local currentProfile = Profiles.currentProfile
    if not currentProfile then return end
    
    -- Get the animation path for the current theme
    local animPath = "VUI " .. (
        theme == "phoenixflame" and "Phoenix Flame" or
        theme == "thunderstorm" and "Thunder Storm" or
        theme == "arcanemystic" and "Arcane Mystic" or
        theme == "felenergy" and "Fel Energy" or
        "Thunder Storm" -- default
    )
    
    -- Set the animation path for all scroll areas
    for _, scrollArea in pairs(currentProfile.scrollAreas) do
        if scrollArea.animationStyle == "Straight" or scrollArea.animationStyle == "Parabola" then
            scrollArea.animationStyle = animPath
        end
    end
end

-- Function to create MSBT config panel with VUI styling (placeholder for future implementation)
function ThemeIntegration:CreateConfigPanel()
    -- This is a placeholder for future implementation
    -- For now, we'll just return nil to indicate that the panel creation failed
    return nil
end
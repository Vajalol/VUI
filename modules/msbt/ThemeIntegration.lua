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
    
    -- Register default scroll areas for VUI
    self:RegisterDefaultScrollAreas()
    
    -- Apply the current theme
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    self:ApplyTheme(currentTheme)
    
    -- Register initialization with MSBT
    if MikSBT and MikSBT.Profiles and MikSBT.Profiles.RegisterCallback then
        MikSBT.Profiles:RegisterCallback("ProfileChanged", function()
            -- Re-register scroll areas and apply theme when profile changes
            self:RegisterDefaultScrollAreas()
            self:ApplyTheme(VUI.db.profile.appearance.theme)
        end)
    end
    
    -- Theme integration initialized
end

-- Register theme-specific animation paths
function ThemeIntegration:RegisterAnimationPaths()
    -- Only register if Animations module is available
    if not Animations or not Animations.RegisterAnimationPath then
        return
    end
    
    -- Load animation paths from files
    local function LoadAnimationPath(theme)
        local success, points = pcall(function() 
            local path = "Interface\\AddOns\\VUI\\media\\textures\\" .. theme .. "\\msbt\\animpath.lua"
            return loadfile(path)()
        end)
        
        if success and points then
            return points
        else
            -- Return a default animation path if loading failed
            -- Failed to load animation path, will use default
            
            -- Default animation pattern (simple parabola)
            return {
                {x = 0, y = 0, deltaX = 0, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 0},
                {x = 0, y = 0.1, deltaX = 0.1, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 0.7},
                {x = 0.1, y = 0.2, deltaX = 0.15, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 0.8},
                {x = 0.25, y = 0.3, deltaX = 0.15, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 0.9},
                {x = 0.4, y = 0.4, deltaX = 0.1, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 1},
                {x = 0.5, y = 0.5, deltaX = 0, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 1},
                {x = 0.5, y = 0.6, deltaX = -0.1, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 1},
                {x = 0.4, y = 0.7, deltaX = -0.15, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 0.9},
                {x = 0.25, y = 0.8, deltaX = -0.15, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 0.8},
                {x = 0.1, y = 0.9, deltaX = -0.1, deltaY = 0.1, scaleX = 1, scaleY = 1, alpha = 0.7},
                {x = 0, y = 1, deltaX = 0, deltaY = 0, scaleX = 1, scaleY = 1, alpha = 0}
            }
        end
    end
    
    -- Register animation paths for each theme
    local themes = {
        ["phoenixflame"] = "Phoenix Flame",
        ["thunderstorm"] = "Thunder Storm",
        ["arcanemystic"] = "Arcane Mystic",
        ["felenergy"] = "Fel Energy"
    }
    
    for themeId, themeName in pairs(themes) do
        local animPath = LoadAnimationPath(themeId)
        if animPath then
            Animations:RegisterAnimationPath("VUI " .. themeName, animPath)
            -- Animation path registered successfully
        end
    end
    
    -- Force animation reset to apply new paths
    if MikSBT.Main and MikSBT.Main.ResetAnimations then
        MikSBT.Main:ResetAnimations()
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
    
    -- Animation settings for each theme
    local animSettings = {
        phoenixflame = {
            scrollHeight = 300,
            scrollWidth = 500,
            scrollSpeed = 2.5,
            animationStyle = animPath,
            textAlignIndex = 2, -- CENTER
            fontSize = 18,
            fontOutline = true,
            stickyBehavior = 2, -- MSBT_NORMAL
            behavior = 2, -- MSBT_NORMAL
            inheritFontSize = false,
            fontSizeInherit = false
        },
        thunderstorm = {
            scrollHeight = 300,
            scrollWidth = 500,
            scrollSpeed = 2.7,
            animationStyle = animPath,
            textAlignIndex = 2, -- CENTER
            fontSize = 18,
            fontOutline = true,
            stickyBehavior = 2, -- MSBT_NORMAL
            behavior = 2, -- MSBT_NORMAL
            inheritFontSize = false,
            fontSizeInherit = false
        },
        arcanemystic = {
            scrollHeight = 300,
            scrollWidth = 500,
            scrollSpeed = 2.3,
            animationStyle = animPath,
            textAlignIndex = 2, -- CENTER
            fontSize = 18,
            fontOutline = true,
            stickyBehavior = 2, -- MSBT_NORMAL
            behavior = 2, -- MSBT_NORMAL
            inheritFontSize = false,
            fontSizeInherit = false
        },
        felenergy = {
            scrollHeight = 300,
            scrollWidth = 500,
            scrollSpeed = 3.0,
            animationStyle = animPath,
            textAlignIndex = 2, -- CENTER
            fontSize = 18,
            fontOutline = true,
            stickyBehavior = 2, -- MSBT_NORMAL
            behavior = 2, -- MSBT_NORMAL
            inheritFontSize = false,
            fontSizeInherit = false
        }
    }
    
    -- Get the animation settings for the current theme or use thunderstorm as default
    local settings = animSettings[theme] or animSettings.thunderstorm
    
    -- Apply animation settings to all scroll areas
    for _, scrollArea in pairs(currentProfile.scrollAreas) do
        -- Only apply if theme integration is enabled
        if VUI.db.profile.modules.msbt.useVUITheme then
            -- Apply animation style if it's a standard style or already a VUI style
            if scrollArea.animationStyle == "Straight" or 
               scrollArea.animationStyle == "Parabola" or 
               string.find(scrollArea.animationStyle, "VUI ") then
                scrollArea.animationStyle = settings.animationStyle
            end
            
            -- Apply additional animation settings
            if string.find(scrollArea.name, "VUI_") or 
               string.find(scrollArea.name, "INCOMING") or 
               string.find(scrollArea.name, "OUTGOING") then
                scrollArea.scrollHeight = settings.scrollHeight
                scrollArea.scrollWidth = settings.scrollWidth
                scrollArea.scrollSpeed = settings.scrollSpeed
                scrollArea.textAlignIndex = settings.textAlignIndex
                
                -- Apply font outline if enhanced fonts are enabled
                if VUI.db.profile.modules.msbt.enhancedFonts then
                    scrollArea.fontOutline = settings.fontOutline
                    -- Use theme-specific font size if not inheriting
                    if not settings.fontSizeInherit then
                        scrollArea.fontSize = settings.fontSize
                    end
                end
                
                -- Apply sticky behavior
                scrollArea.stickyBehavior = settings.stickyBehavior
                scrollArea.behavior = settings.behavior
            end
        end
    end
    
    -- Reset animations to apply changes
    if MikSBT.Main and MikSBT.Main.ResetAnimations then
        MikSBT.Main:ResetAnimations()
    end
end

-- Function to create MSBT config panel with VUI styling
function ThemeIntegration:CreateConfigPanel()
    -- Get references to key modules
    local Profiles = MikSBT.Profiles
    local Animations = MikSBT.Animations
    local Media = MikSBT.Media
    
    -- Create the frame
    local configPanel = CreateFrame("Frame", "VUIMSBTConfigPanel", UIParent, "BackdropTemplate")
    configPanel:SetSize(800, 600)
    configPanel:SetPoint("CENTER")
    configPanel:SetFrameStrata("DIALOG")
    configPanel:EnableMouse(true)
    configPanel:SetMovable(true)
    configPanel:RegisterForDrag("LeftButton")
    configPanel:SetScript("OnDragStart", configPanel.StartMoving)
    configPanel:SetScript("OnDragStop", configPanel.StopMovingOrSizing)
    
    -- Set up backdrop
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    local colors = themeColors[theme] or themeColors.thunderstorm
    
    configPanel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\" .. theme .. "\\border",
        edgeSize = 24,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    
    -- Set background color based on theme
    configPanel:SetBackdropColor(
        colors.background[1],
        colors.background[2],
        colors.background[3],
        colors.background[4] or 0.9
    )
    
    -- Set border color based on theme
    configPanel:SetBackdropBorderColor(
        colors.border[1],
        colors.border[2],
        colors.border[3],
        1
    )
    
    -- Create title bar
    local titleBar = configPanel:CreateTexture(nil, "ARTWORK")
    titleBar:SetHeight(24)
    titleBar:SetPoint("TOPLEFT", 12, -8)
    titleBar:SetPoint("TOPRIGHT", -12, -8)
    titleBar:SetColorTexture(
        colors.border[1],
        colors.border[2],
        colors.border[3],
        0.4
    )
    
    -- Create title text
    local titleText = configPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetPoint("TOP", titleBar, "TOP", 0, 0)
    titleText:SetText("VUI MSBT Configuration")
    titleText:SetTextColor(1, 1, 1)
    
    -- Create close button
    local closeButton = CreateFrame("Button", nil, configPanel, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function() configPanel:Hide() end)
    
    -- Main configuration content frame
    local contentFrame = CreateFrame("Frame", nil, configPanel)
    contentFrame:SetPoint("TOPLEFT", 16, -40)
    contentFrame:SetPoint("BOTTOMRIGHT", -16, 16)
    
    -- Create tabs
    local tabHeight = 30
    local tabNames = {
        "General", "Scroll Areas", "Events", "Triggers", "Animations", "Font & Colors"
    }
    local tabs = {}
    local tabContents = {}
    
    for i, tabName in ipairs(tabNames) do
        -- Create tab button
        local tab = CreateFrame("Button", nil, contentFrame, "BackdropTemplate")
        tab:SetSize(120, tabHeight)
        tab:SetPoint("TOPLEFT", 5 + (i-1) * 125, 20)
        
        tab:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\" .. theme .. "\\border",
            edgeSize = 8,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        
        tab:SetBackdropColor(
            colors.background[1], 
            colors.background[2], 
            colors.background[3], 
            0.7
        )
        
        -- Tab hover effect
        tab:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(
                colors.highlight[1],
                colors.highlight[2],
                colors.highlight[3],
                1
            )
        end)
        
        tab:SetScript("OnLeave", function(self)
            if i ~= 1 then -- Don't change for active tab
                self:SetBackdropBorderColor(
                    colors.border[1],
                    colors.border[2],
                    colors.border[3],
                    1
                )
            end
        end)
        
        -- Tab text
        local tabText = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        tabText:SetPoint("CENTER", 0, 0)
        tabText:SetText(tabName)
        
        -- Tab content area
        local tabContent = CreateFrame("Frame", nil, contentFrame)
        tabContent:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, -10)
        tabContent:SetPoint("BOTTOMRIGHT", contentFrame, "BOTTOMRIGHT", 0, 0)
        
        if i > 1 then
            tabContent:Hide()
            tab:SetBackdropBorderColor(colors.border[1], colors.border[2], colors.border[3], 1)
        else
            tab:SetBackdropBorderColor(colors.highlight[1], colors.highlight[2], colors.highlight[3], 1)
        end
        
        -- Tab switching behavior
        tab:SetScript("OnClick", function()
            for j, content in ipairs(tabContents) do
                content:Hide()
                tabs[j]:SetBackdropBorderColor(colors.border[1], colors.border[2], colors.border[3], 1)
            end
            tabContent:Show()
            tab:SetBackdropBorderColor(colors.highlight[1], colors.highlight[2], colors.highlight[3], 1)
        end)
        
        table.insert(tabs, tab)
        table.insert(tabContents, tabContent)
    end
    
    -- Create scroll frames for each tab content if needed
    for i, tabContent in ipairs(tabContents) do
        -- Add tab-specific content
        self:CreateTabContent(tabContent, tabNames[i], theme, colors)
    end
    
    -- Add methods to the config panel
    configPanel.RefreshTheme = function(self, newTheme)
        theme = newTheme or VUI.db.profile.appearance.theme or "thunderstorm"
        colors = themeColors[theme] or themeColors.thunderstorm
        
        -- Update panel backdrop
        self:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\" .. theme .. "\\border",
            edgeSize = 24,
            insets = { left = 8, right = 8, top = 8, bottom = 8 }
        })
        
        -- Update colors
        self:SetBackdropColor(colors.background[1], colors.background[2], colors.background[3], colors.background[4] or 0.9)
        self:SetBackdropBorderColor(colors.border[1], colors.border[2], colors.border[3], 1)
        
        -- Update title bar
        titleBar:SetColorTexture(colors.border[1], colors.border[2], colors.border[3], 0.4)
        
        -- Update tabs
        for i, tab in ipairs(tabs) do
            tab:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\" .. theme .. "\\border",
                edgeSize = 8,
                insets = { left = 3, right = 3, top = 3, bottom = 3 }
            })
            
            tab:SetBackdropColor(colors.background[1], colors.background[2], colors.background[3], 0.7)
            
            -- Only update active tab border
            if tabContents[i]:IsShown() then
                tab:SetBackdropBorderColor(colors.highlight[1], colors.highlight[2], colors.highlight[3], 1)
            else
                tab:SetBackdropBorderColor(colors.border[1], colors.border[2], colors.border[3], 1)
            end
        end
    end
    
    return configPanel
end

-- Helper function to create the content for each tab
function ThemeIntegration:CreateTabContent(tabFrame, tabName, theme, colors)
    -- Different content creation based on tab name
    if tabName == "General" then
        self:CreateGeneralTab(tabFrame, theme, colors)
    elseif tabName == "Scroll Areas" then
        self:CreateScrollAreasTab(tabFrame, theme, colors)
    elseif tabName == "Events" then
        self:CreateEventsTab(tabFrame, theme, colors)
    elseif tabName == "Triggers" then
        self:CreateTriggersTab(tabFrame, theme, colors)
    elseif tabName == "Animations" then
        self:CreateAnimationsTab(tabFrame, theme, colors)
    elseif tabName == "Font & Colors" then
        self:CreateFontColorsTab(tabFrame, theme, colors)
    end
end

-- Create content for General tab
function ThemeIntegration:CreateGeneralTab(tabFrame, theme, colors)
    -- Title
    local title = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -20)
    title:SetText("General Settings")
    title:SetTextColor(colors.highlight[1], colors.highlight[2], colors.highlight[3])
    
    -- Create content
    local yOffset = -60
    
    -- Show/Hide MSBT toggle
    local enableCheckbox = CreateFrame("CheckButton", nil, tabFrame, "UICheckButtonTemplate")
    enableCheckbox:SetPoint("TOPLEFT", 30, yOffset)
    enableCheckbox:SetChecked(MikSBT.Main and MikSBT.Main.isEnabled and MikSBT.Main:isEnabled())
    
    enableCheckbox:SetScript("OnClick", function(self)
        VUI.db.profile.modules.msbt.enabled = self:GetChecked()
        if self:GetChecked() then
            if MikSBT.Main and MikSBT.Main.EnableMSBT then
                MikSBT.Main:EnableMSBT()
            end
        else
            if MikSBT.Main and MikSBT.Main.DisableMSBT then
                MikSBT.Main:DisableMSBT()
            end
        end
    end)
    
    local enableText = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enableText:SetPoint("LEFT", enableCheckbox, "RIGHT", 5, 0)
    enableText:SetText("Enable MSBT")
    
    yOffset = yOffset - 30
    
    -- VUI Theme Integration toggle
    local themeCheckbox = CreateFrame("CheckButton", nil, tabFrame, "UICheckButtonTemplate")
    themeCheckbox:SetPoint("TOPLEFT", 30, yOffset)
    themeCheckbox:SetChecked(VUI.db.profile.modules.msbt.useVUITheme)
    
    themeCheckbox:SetScript("OnClick", function(self)
        VUI.db.profile.modules.msbt.useVUITheme = self:GetChecked()
        
        -- Apply to all scroll areas
        if MikSBT and MikSBT.Profiles and MikSBT.Profiles.currentProfile then
            for _, scrollArea in pairs(MikSBT.Profiles.currentProfile.scrollAreas) do
                scrollArea.useVUITheme = self:GetChecked()
            end
            
            -- Apply the theme
            if MSBT.ThemeIntegration then
                MSBT.ThemeIntegration:ApplyTheme(VUI.db.profile.appearance.theme or "thunderstorm")
            end
        end
    end)
    
    local themeText = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    themeText:SetPoint("LEFT", themeCheckbox, "RIGHT", 5, 0)
    themeText:SetText("Use VUI Theme Colors")
    
    yOffset = yOffset - 30
    
    -- Theme Colored Text toggle
    local colorTextCheckbox = CreateFrame("CheckButton", nil, tabFrame, "UICheckButtonTemplate")
    colorTextCheckbox:SetPoint("TOPLEFT", 30, yOffset)
    colorTextCheckbox:SetChecked(VUI.db.profile.modules.msbt.themeColoredText)
    
    colorTextCheckbox:SetScript("OnClick", function(self)
        VUI.db.profile.modules.msbt.themeColoredText = self:GetChecked()
        
        -- Apply the theme
        if MSBT.ThemeIntegration then
            MSBT.ThemeIntegration:ApplyTheme(VUI.db.profile.appearance.theme or "thunderstorm")
        end
    end)
    
    local colorTextText = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    colorTextText:SetPoint("LEFT", colorTextCheckbox, "RIGHT", 5, 0)
    colorTextText:SetText("Theme-Colored Text")
    
    yOffset = yOffset - 30
    
    -- Enable Sounds toggle
    local soundsCheckbox = CreateFrame("CheckButton", nil, tabFrame, "UICheckButtonTemplate")
    soundsCheckbox:SetPoint("TOPLEFT", 30, yOffset)
    soundsCheckbox:SetChecked(VUI.db.profile.modules.msbt.soundsEnabled)
    
    soundsCheckbox:SetScript("OnClick", function(self)
        VUI.db.profile.modules.msbt.soundsEnabled = self:GetChecked()
        
        -- Update the MSBT settings
        if MikSBT and MikSBT.Profiles and MikSBT.Profiles.currentProfile then
            -- Turn on/off sound for all notification events
            local currentProfile = MikSBT.Profiles.currentProfile
            if currentProfile.events then
                for eventName, eventSettings in pairs(currentProfile.events) do
                    if string.find(eventName, "NOTIFICATION_") then
                        eventSettings.soundName = self:GetChecked() and "MSBT Cooldown" or ""
                    end
                end
            end
        end
    end)
    
    local soundsText = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    soundsText:SetPoint("LEFT", soundsCheckbox, "RIGHT", 5, 0)
    soundsText:SetText("Enable Sound Effects")
    
    -- Add test buttons
    yOffset = yOffset - 50
    
    local testTitle = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    testTitle:SetPoint("TOPLEFT", 30, yOffset)
    testTitle:SetText("Test MSBT Animations:")
    
    yOffset = yOffset - 30
    
    -- Test Normal button
    local testNormalBtn = CreateFrame("Button", nil, tabFrame, "UIPanelButtonTemplate")
    testNormalBtn:SetPoint("TOPLEFT", 50, yOffset)
    testNormalBtn:SetSize(120, 25)
    testNormalBtn:SetText("Test Normal Hits")
    
    testNormalBtn:SetScript("OnClick", function()
        if MikSBT and MikSBT.Animations and MikSBT.Animations.DisplayEvent then
            MikSBT.Animations:DisplayEvent("OUTGOING_DAMAGE", nil, 1000)
            MikSBT.Animations:DisplayEvent("INCOMING_DAMAGE", nil, 800)
            MikSBT.Animations:DisplayEvent("OUTGOING_HEAL", nil, 1500)
        end
    end)
    
    -- Test Crit button
    local testCritBtn = CreateFrame("Button", nil, tabFrame, "UIPanelButtonTemplate")
    testCritBtn:SetPoint("LEFT", testNormalBtn, "RIGHT", 20, 0)
    testCritBtn:SetSize(120, 25)
    testCritBtn:SetText("Test Critical Hits")
    
    testCritBtn:SetScript("OnClick", function()
        if MikSBT and MikSBT.Animations and MikSBT.Animations.DisplayEvent then
            MikSBT.Animations:DisplayEvent("OUTGOING_DAMAGE_CRIT", nil, 2000)
            MikSBT.Animations:DisplayEvent("INCOMING_DAMAGE_CRIT", nil, 1600)
            MikSBT.Animations:DisplayEvent("OUTGOING_HEAL_CRIT", nil, 3000)
        end
    end)
    
    -- Test Miss button
    local testMissBtn = CreateFrame("Button", nil, tabFrame, "UIPanelButtonTemplate")
    testMissBtn:SetPoint("LEFT", testCritBtn, "RIGHT", 20, 0)
    testMissBtn:SetSize(120, 25)
    testMissBtn:SetText("Test Misses")
    
    testMissBtn:SetScript("OnClick", function()
        if MikSBT and MikSBT.Animations and MikSBT.Animations.DisplayEvent then
            MikSBT.Animations:DisplayEvent("OUTGOING_MISS", nil, "Miss")
            MikSBT.Animations:DisplayEvent("OUTGOING_MISS", nil, "Dodge")
            MikSBT.Animations:DisplayEvent("OUTGOING_MISS", nil, "Parry")
        end
    end)
    
    -- Add reset button
    yOffset = yOffset - 50
    
    local resetBtn = CreateFrame("Button", nil, tabFrame, "UIPanelButtonTemplate")
    resetBtn:SetPoint("TOPLEFT", 50, yOffset)
    resetBtn:SetSize(180, 25)
    resetBtn:SetText("Reset All Settings")
    
    resetBtn:SetScript("OnClick", function()
        if MikSBT and MikSBT.Profiles and MikSBT.Profiles.ResetProfile then
            MikSBT.Profiles:ResetProfile()
            
            -- Apply theme after reset
            if MSBT.ThemeIntegration then
                -- Register default scroll areas again
                MSBT.ThemeIntegration:RegisterDefaultScrollAreas()
                MSBT.ThemeIntegration:ApplyTheme(VUI.db.profile.appearance.theme or "thunderstorm")
            end
        end
    end)
    
    -- Get original MSBT config button
    local originalConfigBtn = CreateFrame("Button", nil, tabFrame, "UIPanelButtonTemplate")
    originalConfigBtn:SetPoint("LEFT", resetBtn, "RIGHT", 20, 0)
    originalConfigBtn:SetSize(180, 25)
    originalConfigBtn:SetText("Original MSBT Config")
    
    originalConfigBtn:SetScript("OnClick", function()
        if MikSBT and MikSBT.Main and MikSBT.Main.ShowConfigurationMenu then
            MikSBT.Main:ShowConfigurationMenu()
        end
    end)
end

-- Placeholder for scroll areas tab
function ThemeIntegration:CreateScrollAreasTab(tabFrame, theme, colors)
    -- Title
    local title = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -20)
    title:SetText("Scroll Areas")
    title:SetTextColor(colors.highlight[1], colors.highlight[2], colors.highlight[3])
    
    -- To be implemented with specific scroll area configuration options
    local desc = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    desc:SetPoint("TOPLEFT", 30, -60)
    desc:SetText("This feature will be fully implemented in a future update.")
end

-- Placeholder for other tabs
function ThemeIntegration:CreateEventsTab(tabFrame, theme, colors)
    -- Title
    local title = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -20)
    title:SetText("Event Settings")
    title:SetTextColor(colors.highlight[1], colors.highlight[2], colors.highlight[3])
    
    -- To be implemented with specific event configuration options
    local desc = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    desc:SetPoint("TOPLEFT", 30, -60)
    desc:SetText("This feature will be fully implemented in a future update.")
end

function ThemeIntegration:CreateTriggersTab(tabFrame, theme, colors)
    -- Title
    local title = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -20)
    title:SetText("Trigger Configuration")
    title:SetTextColor(colors.highlight[1], colors.highlight[2], colors.highlight[3])
    
    -- To be implemented with specific trigger configuration options
    local desc = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    desc:SetPoint("TOPLEFT", 30, -60)
    desc:SetText("This feature will be fully implemented in a future update.")
end

function ThemeIntegration:CreateAnimationsTab(tabFrame, theme, colors)
    -- Title
    local title = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -20)
    title:SetText("Animation Settings")
    title:SetTextColor(colors.highlight[1], colors.highlight[2], colors.highlight[3])
    
    -- To be implemented with specific animation configuration options
    local desc = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    desc:SetPoint("TOPLEFT", 30, -60)
    desc:SetText("This feature will be fully implemented in a future update.")
end

function ThemeIntegration:CreateFontColorsTab(tabFrame, theme, colors)
    -- Title
    local title = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -20)
    title:SetText("Font & Color Settings")
    title:SetTextColor(colors.highlight[1], colors.highlight[2], colors.highlight[3])
    
    -- To be implemented with specific font and color configuration options
    local desc = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    desc:SetPoint("TOPLEFT", 30, -60)
    desc:SetText("This feature will be fully implemented in a future update.")
end
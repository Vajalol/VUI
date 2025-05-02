--[[
    VUI - TrufiGCD Icon Customization
    Version: 0.2.0
    Author: VortexQ8
    
    This file implements enhanced icon customization for the TrufiGCD module:
    - Custom icon borders and styles
    - Icon highlighting based on spell type
    - Configurable visibility for different spell types
    - Icon size variations based on importance
    - Animated icon effects
    - Enhanced visual feedback
    - Custom icon masks and shapes
]]

local addonName, VUI = ...

if not VUI.modules.trufigcd then return end

-- Namespaces
local TrufiGCD = VUI.modules.trufigcd
TrufiGCD.IconCustomization = {}

-- Import frequently used globals into locals for performance
local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo
local GetSpellTexture = GetSpellTexture
local GetTime = GetTime
local tinsert, tremove = table.insert, table.remove
local min, max = math.min, math.max
local cos, sin, pi = math.cos, math.sin, math.pi
local format = string.format

-- Default settings for icon customization
local iconCustomizationDefaults = {
    enabled = true,
    -- Border styles
    borderStyle = "theme", -- Options: "theme", "class", "spell", "none", "custom"
    customBorderColor = {1, 1, 1, 1},
    borderThickness = 1,
    -- Icon styles
    iconStyle = "default", -- Options: "default", "circular", "square", "hexagon", "diamond"
    iconSaturation = 1.0,
    iconBrightness = 1.0,
    iconOverlayOpacity = 0.3,
    useDesaturateForCooldown = true,
    -- Glow effects
    enableGlow = true,
    glowColor = {1, 1, 0, 0.7},
    glowType = "pixel", -- Options: "pixel", "auto", "button", "proc"
    glowThickness = 1,
    glowLines = 8,
    glowFrequency = 0.25,
    -- Highlighting by type
    highlightOptions = {
        offensive = {r = 1.0, g = 0.3, b = 0.3, a = 1.0, border = true, glow = true},
        defensive = {r = 0.3, g = 0.7, b = 1.0, a = 1.0, border = true, glow = true},
        cooldown = {r = 0.8, g = 0.8, b = 0.0, a = 1.0, border = true, glow = false},
        utility = {r = 0.7, g = 0.7, b = 0.7, a = 1.0, border = true, glow = false},
        movement = {r = 0.0, g = 0.8, b = 0.0, a = 1.0, border = true, glow = false},
        interrupt = {r = 1.0, g = 0.5, b = 0.0, a = 1.0, border = true, glow = true},
        covenant = {r = 0.8, g = 0.4, b = 0.8, a = 1.0, border = true, glow = true},
    },
    -- Animation options
    enableAnimations = true,
    fadeInDuration = 0.2,
    fadeOutDuration = 0.5,
    useScaleAnimation = true,
    scaleMin = 0.8,
    scaleMax = 1.2,
    scaleDuration = 0.3,
    -- Importance scaling
    enableImportanceScaling = true,
    importantSpellScale = 1.2,
    normalSpellScale = 1.0,
    minorSpellScale = 0.9,
    -- Icon masking/cropping
    enableIconMasking = true, 
    iconMaskType = "circular", -- Options: "circular", "square", "diamond", "hexagon"
    cropIcons = true,
    iconCropAmount = 0.08, -- Amount to crop from each side (0.08 = 8%)
    -- Cooldown text options
    showCooldownText = true,
    cooldownTextSize = 12,
    cooldownTextOutline = "OUTLINE", -- Options: "NONE", "OUTLINE", "THICKOUTLINE"
    cooldownTextPosition = "CENTER", -- Options: "CENTER", "BOTTOM", "TOP"
    -- Spell name options
    showSpellName = true,
    spellNameSize = 10,
    spellNamePosition = "BOTTOM", -- Options: "BOTTOM", "TOP"
    spellNameLength = 10, -- Max characters for spell name
    -- Keybind options
    showKeybind = true,
    keybindPosition = "TOPRIGHT", -- Options: "TOPRIGHT", "TOPLEFT", "BOTTOMRIGHT", "BOTTOMLEFT"
    keybindSize = 9,
    -- Spell type options
    indicateSpellType = true,
    spellTypePosition = "TOPLEFT", -- Options: "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"
    spellTypeSize = 12,
    spellTypeIcons = true,
}

-- Known important spell types for highlighting
local spellTypes = {
    -- Interrupt spells by class
    interrupts = {
        [1766] = true,   -- Kick (Rogue)
        [2139] = true,   -- Counterspell (Mage)
        [6552] = true,   -- Pummel (Warrior)
        [19647] = true,  -- Spell Lock (Warlock)
        [47528] = true,  -- Mind Freeze (Death Knight)
        [57994] = true,  -- Wind Shear (Shaman)
        [91802] = true,  -- Shambling Rush (Death Knight)
        [96231] = true,  -- Rebuke (Paladin)
        [106839] = true, -- Skull Bash (Druid)
        [115781] = true, -- Optical Blast (Warlock)
        [116705] = true, -- Spear Hand Strike (Monk)
        [132409] = true, -- Spell Lock (Warlock)
        [147362] = true, -- Counter Shot (Hunter)
        [183752] = true, -- Disrupt (Demon Hunter)
        [187707] = true, -- Muzzle (Hunter)
        [351338] = true, -- Quell (Evoker)
    },
    
    -- Defensive cooldowns by class (examples)
    defensives = {
        -- Death Knight
        [48707] = true,  -- Anti-Magic Shell
        [51052] = true,  -- Anti-Magic Zone
        [48792] = true,  -- Icebound Fortitude
        
        -- Demon Hunter
        [198589] = true, -- Blur
        [196555] = true, -- Netherwalk
        [187827] = true, -- Metamorphosis (Vengeance)
        
        -- Druid
        [22812] = true,  -- Barkskin
        [61336] = true,  -- Survival Instincts
        [102342] = true, -- Ironbark
        
        -- Evoker
        [363916] = true, -- Obsidian Scales
        [374348] = true, -- Renewing Blaze
        
        -- Hunter
        [186265] = true, -- Aspect of the Turtle
        [264735] = true, -- Survival of the Fittest
        
        -- Mage
        [45438] = true,  -- Ice Block
        [235450] = true, -- Prismatic Barrier
        [235313] = true, -- Blazing Barrier
        
        -- Monk
        [122470] = true, -- Touch of Karma
        [115203] = true, -- Fortifying Brew
        [122278] = true, -- Dampen Harm
        
        -- Paladin
        [642] = true,    -- Divine Shield
        [86659] = true,  -- Guardian of Ancient Kings
        [31850] = true,  -- Ardent Defender
        
        -- Priest
        [47585] = true,  -- Dispersion
        [33206] = true,  -- Pain Suppression
        [19236] = true,  -- Desperate Prayer
        
        -- Rogue
        [31224] = true,  -- Cloak of Shadows
        [5277] = true,   -- Evasion
        [185311] = true, -- Crimson Vial
        
        -- Shaman
        [108271] = true, -- Astral Shift
        [198103] = true, -- Earth Elemental
        
        -- Warlock
        [104773] = true, -- Unending Resolve
        [108416] = true, -- Dark Pact
        
        -- Warrior
        [871] = true,    -- Shield Wall
        [12975] = true,  -- Last Stand
        [118038] = true, -- Die by the Sword
    },
    
    -- Major offensive cooldowns
    offensives = {
        -- Death Knight
        [47568] = true,  -- Empower Rune Weapon
        [275699] = true, -- Apocalypse
        
        -- Demon Hunter
        [191427] = true, -- Metamorphosis (Havoc)
        
        -- Druid
        [194223] = true, -- Celestial Alignment
        [106951] = true, -- Berserk
        [102543] = true, -- Incarnation: King of the Jungle
        
        -- Evoker
        [375087] = true, -- Dragonrage
        
        -- Hunter
        [193530] = true, -- Aspect of the Wild
        [288613] = true, -- Trueshot
        [266779] = true, -- Coordinated Assault
        
        -- Mage
        [12472] = true,  -- Icy Veins
        [190319] = true, -- Combustion
        
        -- Monk
        [137639] = true, -- Storm, Earth, and Fire
        [152173] = true, -- Serenity
        
        -- Paladin
        [31884] = true,  -- Avenging Wrath
        [231895] = true, -- Crusade
        
        -- Priest
        [10060] = true,  -- Power Infusion
        [194249] = true, -- Voidform
        
        -- Rogue
        [13750] = true,  -- Adrenaline Rush
        [121471] = true, -- Shadow Blades
        
        -- Shaman
        [114051] = true, -- Ascendance
        [51533] = true,  -- Feral Spirit
        
        -- Warlock
        [1122] = true,   -- Summon Infernal
        [205180] = true, -- Summon Darkglare
        
        -- Warrior
        [107574] = true, -- Avatar
        [1719] = true,   -- Recklessness
    },
    
    -- Movement abilities
    movement = {
        [1850] = true,   -- Dash (Druid)
        [2983] = true,   -- Sprint (Rogue)
        [100] = true,    -- Charge (Warrior)
        [1953] = true,   -- Blink (Mage)
        [36554] = true,  -- Shadowstep (Rogue)
        [109132] = true, -- Roll (Monk)
        [111400] = true, -- Burning Rush (Warlock)
        [190784] = true, -- Divine Steed (Paladin)
        [358267] = true, -- Hover (Evoker)
    },
    
    -- Covenant abilities (examples from Shadowlands)
    covenant = {
        [307443] = true, -- Radiant Spark (Kyrian Mage)
        [312202] = true, -- Shackle the Unworthy (Kyrian Death Knight)
        [325013] = true, -- Boon of the Ascended (Kyrian Priest)
        [326059] = true, -- Kindred Spirits (Night Fae Druid)
        [328923] = true, -- Fallen Order (Venthyr Monk)
        [323547] = true, -- Condemn (Venthyr Warrior)
        [324631] = true, -- Fleshcraft (Necrolord)
    },
    
    -- Utility spells
    utility = {
        [20484] = true,  -- Rebirth (Druid)
        [2825] = true,   -- Bloodlust (Shaman)
        [32182] = true,  -- Heroism (Shaman)
        [115310] = true, -- Revival (Monk)
        [64901] = true,  -- Symbol of Hope (Priest)
    },
}

-- Initialize icon customization
function TrufiGCD:InitializeIconCustomization()
    -- Register defaults if not already registered
    VUI.db.profile.modules.trufigcd.iconCustomization = VUI.db.profile.modules.trufigcd.iconCustomization or iconCustomizationDefaults
    
    -- Update any missing fields (for version compatibility)
    for k, v in pairs(iconCustomizationDefaults) do
        if VUI.db.profile.modules.trufigcd.iconCustomization[k] == nil then
            VUI.db.profile.modules.trufigcd.iconCustomization[k] = v
        end
        
        -- If it's a table, update any missing nested fields
        if type(v) == "table" and type(VUI.db.profile.modules.trufigcd.iconCustomization[k]) == "table" then
            for nestedKey, nestedValue in pairs(v) do
                if VUI.db.profile.modules.trufigcd.iconCustomization[k][nestedKey] == nil then
                    VUI.db.profile.modules.trufigcd.iconCustomization[k][nestedKey] = nestedValue
                end
                
                -- If the nested value is also a table, update its fields too
                if type(nestedValue) == "table" and type(VUI.db.profile.modules.trufigcd.iconCustomization[k][nestedKey]) == "table" then
                    for deepKey, deepValue in pairs(nestedValue) do
                        if VUI.db.profile.modules.trufigcd.iconCustomization[k][nestedKey][deepKey] == nil then
                            VUI.db.profile.modules.trufigcd.iconCustomization[k][nestedKey][deepKey] = deepValue
                        end
                    end
                end
            end
        end
    end
    
    -- Register custom LibGlow effects if available
    if LibStub and LibStub:GetLibrary("LibCustomGlow-1.0", true) then
        self.LibGlow = LibStub:GetLibrary("LibCustomGlow-1.0")
    end
    
    -- Register options for the configuration UI
    self:RegisterIconCustomizationOptions()
    
    -- Load icon masking textures if needed
    if VUI.db.profile.modules.trufigcd.iconCustomization.enableIconMasking then
        self:LoadIconMasks()
    end
    
    -- Icon customization system ready
end

-- Load icon mask textures based on selected mask type
function TrufiGCD:LoadIconMasks()
    -- Define paths to mask textures
    local maskTextures = {
        circular = "Interface\\AddOns\\VUI\\media\\textures\\masks\\circle.tga",
        square = "Interface\\AddOns\\VUI\\media\\textures\\masks\\square.tga",
        diamond = "Interface\\AddOns\\VUI\\media\\textures\\masks\\diamond.tga", 
        hexagon = "Interface\\AddOns\\VUI\\media\\textures\\masks\\hexagon.tga",
    }
    
    self.iconMasks = {}
    
    -- Preload mask textures
    for maskType, texturePath in pairs(maskTextures) do
        -- If we're using the atlas system, get the texture from there
        local atlasTextureInfo = VUI:GetTextureCached(texturePath)
        
        if atlasTextureInfo and atlasTextureInfo.isAtlas then
            self.iconMasks[maskType] = {
                texture = atlasTextureInfo.path,
                coords = atlasTextureInfo.coords,
                isAtlas = true
            }
        else
            -- Just use the direct texture path
            self.iconMasks[maskType] = {
                texture = texturePath,
                isAtlas = false
            }
        end
    end
end

-- Apply icon customization to an icon frame
function TrufiGCD:ApplyIconCustomization(iconFrame, spellID, isActive)
    local settings = VUI.db.profile.modules.trufigcd.iconCustomization
    
    -- Skip if customization is disabled
    if not settings.enabled then return end
    
    -- Get the spell type for advanced customization
    local spellType = self:GetSpellType(spellID)
    
    -- Apply icon cropping if enabled
    if settings.cropIcons then
        local crop = settings.iconCropAmount
        iconFrame.icon:SetTexCoord(crop, 1-crop, crop, 1-crop)
    else
        iconFrame.icon:SetTexCoord(0, 1, 0, 1)
    end
    
    -- Apply icon masking if enabled
    if settings.enableIconMasking and self.iconMasks then
        local maskType = settings.iconMaskType or "circular"
        local mask = self.iconMasks[maskType]
        
        if mask then
            if not iconFrame.mask then
                iconFrame.mask = iconFrame:CreateMaskTexture()
                iconFrame.mask:SetAllPoints(iconFrame.icon)
            end
            
            if mask.isAtlas then
                iconFrame.mask:SetTexture(mask.texture)
                iconFrame.mask:SetTexCoord(
                    mask.coords.left,
                    mask.coords.right,
                    mask.coords.top,
                    mask.coords.bottom
                )
            else
                iconFrame.mask:SetTexture(mask.texture)
            end
            
            iconFrame.icon:AddMaskTexture(iconFrame.mask)
        end
    elseif iconFrame.mask then
        -- Remove mask if disabled
        iconFrame.icon:RemoveMaskTexture(iconFrame.mask)
    end
    
    -- Apply border style
    self:ApplyBorderStyle(iconFrame, spellID, spellType, isActive, settings)
    
    -- Apply icon saturation and brightness
    iconFrame.icon:SetDesaturated(isActive and settings.useDesaturateForCooldown or false)
    iconFrame.icon:SetVertexColor(
        settings.iconBrightness, 
        settings.iconBrightness, 
        settings.iconBrightness, 
        1.0
    )
    
    -- Apply glow effects for special abilities
    self:ApplyGlowEffect(iconFrame, spellID, spellType, isActive, settings)
    
    -- Apply importance scaling
    if settings.enableImportanceScaling then
        local importance = self:GetSpellImportance(spellID, spellType)
        local scale = settings.normalSpellScale
        
        if importance == "important" then
            scale = settings.importantSpellScale
        elseif importance == "minor" then
            scale = settings.minorSpellScale
        end
        
        iconFrame:SetScale(scale)
    else
        iconFrame:SetScale(1.0)
    end
    
    -- Apply animations if enabled
    if settings.enableAnimations and not iconFrame.fadeInAnim then
        -- Create fade in animation
        iconFrame.fadeInAnim = iconFrame:CreateAnimationGroup()
        local fadeIn = iconFrame.fadeInAnim:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(1)
        fadeIn:SetDuration(settings.fadeInDuration)
        fadeIn:SetOrder(1)
        
        -- Create scale animation if enabled
        if settings.useScaleAnimation then
            local scaleIn = iconFrame.fadeInAnim:CreateAnimation("Scale")
            scaleIn:SetFromScale(settings.scaleMin, settings.scaleMin)
            scaleIn:SetToScale(1, 1)
            scaleIn:SetDuration(settings.scaleDuration)
            scaleIn:SetOrder(1)
        end
        
        -- Play the animation
        iconFrame.fadeInAnim:Play()
    end
    
    -- Add spell name if enabled
    if settings.showSpellName then
        if not iconFrame.spellName then
            iconFrame.spellName = iconFrame:CreateFontString(nil, "OVERLAY")
            local font = VUI:GetFont() or "Fonts\\FRIZQT__.TTF"
            iconFrame.spellName:SetFont(font, settings.spellNameSize, "OUTLINE")
            
            if settings.spellNamePosition == "BOTTOM" then
                iconFrame.spellName:SetPoint("TOP", iconFrame, "BOTTOM", 0, -2)
            else
                iconFrame.spellName:SetPoint("BOTTOM", iconFrame, "TOP", 0, 2)
            end
        end
        
        local spellName = GetSpellInfo(spellID) or ""
        if spellName and settings.spellNameLength > 0 and string.len(spellName) > settings.spellNameLength then
            spellName = string.sub(spellName, 1, settings.spellNameLength) .. "..."
        end
        
        iconFrame.spellName:SetText(spellName)
        iconFrame.spellName:Show()
    elseif iconFrame.spellName then
        iconFrame.spellName:Hide()
    end
    
    -- Add keybind if enabled
    if settings.showKeybind then
        -- Keybind display would require additional code to find actual keybinds
        -- This is a placeholder for that functionality
    end
    
    -- Add spell type indicator if enabled
    if settings.indicateSpellType and spellType then
        if not iconFrame.spellTypeIndicator then
            iconFrame.spellTypeIndicator = iconFrame:CreateTexture(nil, "OVERLAY")
            iconFrame.spellTypeIndicator:SetSize(settings.spellTypeSize, settings.spellTypeSize)
            
            -- Position the indicator based on settings
            local point
            if settings.spellTypePosition == "TOPLEFT" then
                point = "TOPLEFT"
            elseif settings.spellTypePosition == "TOPRIGHT" then
                point = "TOPRIGHT"
            elseif settings.spellTypePosition == "BOTTOMLEFT" then
                point = "BOTTOMLEFT"
            else
                point = "BOTTOMRIGHT"
            end
            
            iconFrame.spellTypeIndicator:SetPoint(point, iconFrame, point, 0, 0)
        end
        
        -- Use color-coded dots if not using icons
        if not settings.spellTypeIcons then
            local color = self:GetSpellTypeColor(spellType, settings)
            iconFrame.spellTypeIndicator:SetColorTexture(color.r, color.g, color.b, color.a)
            iconFrame.spellTypeIndicator:Show()
        else
            -- This would use spell type specific icons, which would require additional assets
            -- Placeholder for that functionality
            iconFrame.spellTypeIndicator:Hide()
        end
    elseif iconFrame.spellTypeIndicator then
        iconFrame.spellTypeIndicator:Hide()
    end
end

-- Apply border style based on configuration
function TrufiGCD:ApplyBorderStyle(iconFrame, spellID, spellType, isActive, settings)
    if not iconFrame.border then
        iconFrame.border = iconFrame:CreateTexture(nil, "OVERLAY")
        iconFrame.border:SetPoint("TOPLEFT", iconFrame, "TOPLEFT", -settings.borderThickness, settings.borderThickness)
        iconFrame.border:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", settings.borderThickness, -settings.borderThickness)
        
        -- Get border texture from atlas if available
        local borderTexture = "Interface\\Buttons\\UI-Debuff-Overlays"
        local atlasTextureInfo = VUI:GetTextureCached(borderTexture)
        
        if atlasTextureInfo and atlasTextureInfo.isAtlas then
            iconFrame.border:SetTexture(atlasTextureInfo.path)
            iconFrame.border:SetTexCoord(
                atlasTextureInfo.coords.left,
                atlasTextureInfo.coords.right,
                atlasTextureInfo.coords.top,
                atlasTextureInfo.coords.bottom
            )
        else
            iconFrame.border:SetTexture(borderTexture)
            iconFrame.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
        end
    end
    
    -- Determine border color based on selected style
    local r, g, b, a = 1, 1, 1, 1
    
    if settings.borderStyle == "none" then
        iconFrame.border:Hide()
        return
    end
    
    if settings.borderStyle == "theme" then
        -- Use current VUI theme color
        local theme = VUI.db.profile.appearance.theme or "thunderstorm"
        if theme == "phoenixflame" then
            r, g, b = 0.9, 0.3, 0.1 -- Fiery orange
        elseif theme == "thunderstorm" then
            r, g, b = 0.05, 0.6, 0.9 -- Electric blue
        elseif theme == "arcanemystic" then
            r, g, b = 0.6, 0.05, 0.9 -- Violet
        elseif theme == "felenergy" then
            r, g, b = 0.1, 0.9, 0.1 -- Fel green
        else
            -- Class color theme uses player class color
            local _, playerClass = UnitClass("player")
            if playerClass then
                local classColor = RAID_CLASS_COLORS[playerClass]
                if classColor then
                    r, g, b = classColor.r, classColor.g, classColor.b
                end
            end
        end
    elseif settings.borderStyle == "class" then
        -- Use class color
        local _, playerClass = UnitClass("player")
        if playerClass then
            local classColor = RAID_CLASS_COLORS[playerClass]
            if classColor then
                r, g, b = classColor.r, classColor.g, classColor.b
            end
        end
    elseif settings.borderStyle == "spell" and spellType then
        -- Use color based on spell type
        local color = self:GetSpellTypeColor(spellType, settings)
        r, g, b, a = color.r, color.g, color.b, color.a
    elseif settings.borderStyle == "custom" then
        -- Use custom color
        r, g, b, a = unpack(settings.customBorderColor)
    end
    
    iconFrame.border:SetVertexColor(r, g, b, a)
    iconFrame.border:Show()
end

-- Apply glow effect based on configuration
function TrufiGCD:ApplyGlowEffect(iconFrame, spellID, spellType, isActive, settings)
    -- Skip if glow is disabled
    if not settings.enableGlow then
        -- Remove any existing glow
        self:RemoveGlowFromFrame(iconFrame)
        return
    end
    
    -- Check if spell type should have glow
    local shouldGlow = false
    if spellType and settings.highlightOptions[spellType] and settings.highlightOptions[spellType].glow then
        shouldGlow = true
    end
    
    -- Remove glow if we shouldn't be glowing
    if not shouldGlow then
        self:RemoveGlowFromFrame(iconFrame)
        return
    end
    
    -- Get glow color based on spell type
    local r, g, b, a = unpack(settings.glowColor)
    if spellType and settings.highlightOptions[spellType] then
        r = settings.highlightOptions[spellType].r or r
        g = settings.highlightOptions[spellType].g or g
        b = settings.highlightOptions[spellType].b or b
        a = settings.highlightOptions[spellType].a or a
    end
    
    -- Apply glow effect based on type
    local glowType = settings.glowType
    
    -- If we have LibGlow available, use it
    if self.LibGlow then
        -- Remove any existing glow first
        self:RemoveGlowFromFrame(iconFrame)
        
        if glowType == "pixel" then
            self.LibGlow.PixelGlow_Start(
                iconFrame,
                {r, g, b, a},
                settings.glowLines,
                settings.glowFrequency,
                nil,
                settings.glowThickness,
                0,
                0,
                false,
                "TrufiGCDIconGlow"
            )
        elseif glowType == "auto" then
            self.LibGlow.AutoCastGlow_Start(
                iconFrame,
                {r, g, b, a},
                settings.glowLines,
                settings.glowFrequency,
                settings.glowThickness,
                0,
                0,
                "TrufiGCDIconGlow"
            )
        elseif glowType == "button" then
            self.LibGlow.ButtonGlow_Start(
                iconFrame,
                {r, g, b, a},
                settings.glowFrequency,
                "TrufiGCDIconGlow"
            )
        else
            -- Fallback to proc glow
            self.LibGlow.ShowOverlayGlow(iconFrame)
        end
    else
        -- Create a simple glow if LibGlow isn't available
        if not iconFrame.glow then
            iconFrame.glow = iconFrame:CreateTexture(nil, "OVERLAY")
            iconFrame.glow:SetPoint("TOPLEFT", iconFrame, "TOPLEFT", -5, 5)
            iconFrame.glow:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", 5, -5)
            
            -- Get glow texture from atlas if available
            local glowTexture = "Interface\\SpellActivationOverlay\\IconAlert"
            local atlasTextureInfo = VUI:GetTextureCached(glowTexture)
            
            if atlasTextureInfo and atlasTextureInfo.isAtlas then
                iconFrame.glow:SetTexture(atlasTextureInfo.path)
                iconFrame.glow:SetTexCoord(
                    atlasTextureInfo.coords.left,
                    atlasTextureInfo.coords.right,
                    atlasTextureInfo.coords.top,
                    atlasTextureInfo.coords.bottom
                )
            else
                iconFrame.glow:SetTexture(glowTexture)
                iconFrame.glow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
            end
        end
        
        iconFrame.glow:SetVertexColor(r, g, b, a)
        iconFrame.glow:Show()
    end
end

-- Remove glow effect from a frame
function TrufiGCD:RemoveGlowFromFrame(iconFrame)
    if self.LibGlow then
        self.LibGlow.PixelGlow_Stop(iconFrame, "TrufiGCDIconGlow")
        self.LibGlow.AutoCastGlow_Stop(iconFrame, "TrufiGCDIconGlow")
        self.LibGlow.ButtonGlow_Stop(iconFrame, "TrufiGCDIconGlow")
        self.LibGlow.HideOverlayGlow(iconFrame)
    end
    
    if iconFrame.glow then
        iconFrame.glow:Hide()
    end
end

-- Get the color for a spell type
function TrufiGCD:GetSpellTypeColor(spellType, settings)
    local color = {r = 1, g = 1, b = 1, a = 1}
    
    if spellType and settings.highlightOptions[spellType] then
        color.r = settings.highlightOptions[spellType].r
        color.g = settings.highlightOptions[spellType].g
        color.b = settings.highlightOptions[spellType].b
        color.a = settings.highlightOptions[spellType].a
    end
    
    return color
end

-- Get the type of a spell for customization
function TrufiGCD:GetSpellType(spellID)
    if not spellID then return nil end
    
    if spellTypes.interrupts[spellID] then
        return "interrupt"
    elseif spellTypes.defensives[spellID] then
        return "defensive"
    elseif spellTypes.offensives[spellID] then
        return "offensive"
    elseif spellTypes.movement[spellID] then
        return "movement"
    elseif spellTypes.covenant[spellID] then
        return "covenant"
    elseif spellTypes.utility[spellID] then
        return "utility"
    end
    
    return "cooldown" -- Default type
end

-- Get the importance level of a spell
function TrufiGCD:GetSpellImportance(spellID, spellType)
    if not spellID then return "normal" end
    
    -- Interrupts, offensive and defensive cooldowns are important
    if spellType == "interrupt" or spellType == "offensive" or spellType == "defensive" or spellType == "covenant" then
        return "important"
    end
    
    -- Movement and utility are minor
    if spellType == "movement" or spellType == "utility" then
        return "minor"
    end
    
    -- Default to normal
    return "normal"
end

-- Register configuration options for icon customization
function TrufiGCD:RegisterIconCustomizationOptions()
    -- Add to the module's options table when it's generated
    local originalGetOptions = self.GetOptions
    
    self.GetOptions = function(self)
        local options = originalGetOptions and originalGetOptions(self) or {}
        
        -- Ensure we have args table
        options.args = options.args or {}
        
        -- Add icon customization section
        options.args.iconCustomizationHeader = {
            type = "header",
            name = "Icon Customization",
            order = 50
        }
        
        options.args.iconCustomizationEnabled = {
            type = "toggle",
            name = "Enable Icon Customization",
            desc = "Toggle advanced icon customization",
            get = function() return VUI.db.profile.modules.trufigcd.iconCustomization.enabled end,
            set = function(_, value)
                VUI.db.profile.modules.trufigcd.iconCustomization.enabled = value
                self:UpdateFrame()
            end,
            width = "full",
            order = 51
        }
        
        -- Icon Style options
        options.args.iconStyleGroup = {
            type = "group",
            name = "Icon Style",
            inline = true,
            order = 52,
            disabled = function() return not VUI.db.profile.modules.trufigcd.iconCustomization.enabled end,
            args = {
                cropIcons = {
                    type = "toggle",
                    name = "Crop Icons",
                    desc = "Crop the edges of spell icons for a cleaner look",
                    get = function() return VUI.db.profile.modules.trufigcd.iconCustomization.cropIcons end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.iconCustomization.cropIcons = value
                        self:UpdateFrame()
                    end,
                    width = "full",
                    order = 1
                },
                
                iconCropAmount = {
                    type = "range",
                    name = "Crop Amount",
                    desc = "Amount to crop from each edge of the icon",
                    min = 0,
                    max = 0.2,
                    step = 0.01,
                    get = function() return VUI.db.profile.modules.trufigcd.iconCustomization.iconCropAmount end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.iconCustomization.iconCropAmount = value
                        self:UpdateFrame()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.iconCustomization.enabled or not VUI.db.profile.modules.trufigcd.iconCustomization.cropIcons end,
                    width = "full",
                    order = 2
                },
                
                enableIconMasking = {
                    type = "toggle",
                    name = "Enable Icon Masking",
                    desc = "Apply shaped masks to spell icons",
                    get = function() return VUI.db.profile.modules.trufigcd.iconCustomization.enableIconMasking end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.iconCustomization.enableIconMasking = value
                        if value then self:LoadIconMasks() end
                        self:UpdateFrame()
                    end,
                    width = "full",
                    order = 3
                },
                
                iconMaskType = {
                    type = "select",
                    name = "Icon Mask Shape",
                    desc = "Choose the shape of the icon mask",
                    values = {
                        circular = "Circular",
                        square = "Square",
                        diamond = "Diamond",
                        hexagon = "Hexagon"
                    },
                    get = function() return VUI.db.profile.modules.trufigcd.iconCustomization.iconMaskType end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.iconCustomization.iconMaskType = value
                        self:UpdateFrame()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.iconCustomization.enabled or not VUI.db.profile.modules.trufigcd.iconCustomization.enableIconMasking end,
                    width = "full",
                    order = 4
                },
                
                iconSaturation = {
                    type = "range",
                    name = "Icon Saturation",
                    desc = "Adjust the color saturation of the icons",
                    min = 0,
                    max = 2,
                    step = 0.05,
                    get = function() return VUI.db.profile.modules.trufigcd.iconCustomization.iconSaturation end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.iconCustomization.iconSaturation = value
                        self:UpdateFrame()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.iconCustomization.enabled end,
                    width = "full",
                    order = 5
                },
                
                iconBrightness = {
                    type = "range",
                    name = "Icon Brightness",
                    desc = "Adjust the brightness of the icons",
                    min = 0.5,
                    max = 1.5,
                    step = 0.05,
                    get = function() return VUI.db.profile.modules.trufigcd.iconCustomization.iconBrightness end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.iconCustomization.iconBrightness = value
                        self:UpdateFrame()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.iconCustomization.enabled end,
                    width = "full",
                    order = 6
                },
                
                useDesaturateForCooldown = {
                    type = "toggle",
                    name = "Desaturate On Cooldown",
                    desc = "Desaturate icons when abilities are on cooldown",
                    get = function() return VUI.db.profile.modules.trufigcd.iconCustomization.useDesaturateForCooldown end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.iconCustomization.useDesaturateForCooldown = value
                        self:UpdateFrame()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.iconCustomization.enabled end,
                    width = "full",
                    order = 7
                },
            }
        }
        
        -- Border options
        options.args.borderStyleGroup = {
            type = "group",
            name = "Border Style",
            inline = true,
            order = 53,
            disabled = function() return not VUI.db.profile.modules.trufigcd.iconCustomization.enabled end,
            args = {
                borderStyle = {
                    type = "select",
                    name = "Border Style",
                    desc = "Choose how to color the borders of icons",
                    values = {
                        theme = "Match Theme Color",
                        class = "Class Color",
                        spell = "Spell Type Color",
                        none = "No Border",
                        custom = "Custom Color"
                    },
                    get = function() return VUI.db.profile.modules.trufigcd.iconCustomization.borderStyle end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.iconCustomization.borderStyle = value
                        self:UpdateFrame()
                    end,
                    width = "full",
                    order = 1
                },
                
                customBorderColor = {
                    type = "color",
                    name = "Custom Border Color",
                    desc = "Set a custom color for the icon borders",
                    hasAlpha = true,
                    get = function()
                        local color = VUI.db.profile.modules.trufigcd.iconCustomization.customBorderColor
                        return color[1], color[2], color[3], color[4]
                    end,
                    set = function(_, r, g, b, a)
                        VUI.db.profile.modules.trufigcd.iconCustomization.customBorderColor = {r, g, b, a}
                        self:UpdateFrame()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.iconCustomization.enabled or VUI.db.profile.modules.trufigcd.iconCustomization.borderStyle ~= "custom" end,
                    width = "full",
                    order = 2
                },
                
                borderThickness = {
                    type = "range",
                    name = "Border Thickness",
                    desc = "Adjust the thickness of the icon borders",
                    min = 0.5,
                    max = 3,
                    step = 0.5,
                    get = function() return VUI.db.profile.modules.trufigcd.iconCustomization.borderThickness end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.iconCustomization.borderThickness = value
                        self:UpdateFrame()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.iconCustomization.enabled or VUI.db.profile.modules.trufigcd.iconCustomization.borderStyle == "none" end,
                    width = "full",
                    order = 3
                },
            }
        }
        
        -- Glow options
        options.args.glowOptionsGroup = {
            type = "group",
            name = "Glow Effects",
            inline = true,
            order = 54,
            disabled = function() return not VUI.db.profile.modules.trufigcd.iconCustomization.enabled end,
            args = {
                enableGlow = {
                    type = "toggle",
                    name = "Enable Glow Effects",
                    desc = "Enable glow effects for important abilities",
                    get = function() return VUI.db.profile.modules.trufigcd.iconCustomization.enableGlow end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.iconCustomization.enableGlow = value
                        self:UpdateFrame()
                    end,
                    width = "full",
                    order = 1
                },
                
                glowType = {
                    type = "select",
                    name = "Glow Type",
                    desc = "Choose the type of glow effect",
                    values = {
                        pixel = "Pixel Glow",
                        auto = "AutoCast Glow",
                        button = "Button Glow",
                        proc = "Proc Glow"
                    },
                    get = function() return VUI.db.profile.modules.trufigcd.iconCustomization.glowType end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.iconCustomization.glowType = value
                        self:UpdateFrame()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.iconCustomization.enabled or not VUI.db.profile.modules.trufigcd.iconCustomization.enableGlow end,
                    width = "full",
                    order = 2
                },
                
                glowColor = {
                    type = "color",
                    name = "Default Glow Color",
                    desc = "Default color for glow effects (can be overridden by spell type)",
                    hasAlpha = true,
                    get = function()
                        local color = VUI.db.profile.modules.trufigcd.iconCustomization.glowColor
                        return color[1], color[2], color[3], color[4]
                    end,
                    set = function(_, r, g, b, a)
                        VUI.db.profile.modules.trufigcd.iconCustomization.glowColor = {r, g, b, a}
                        self:UpdateFrame()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.iconCustomization.enabled or not VUI.db.profile.modules.trufigcd.iconCustomization.enableGlow end,
                    width = "full",
                    order = 3
                },
            }
        }
        
        -- Animations group
        options.args.animationsGroup = {
            type = "group",
            name = "Animation Options",
            inline = true,
            order = 55,
            disabled = function() return not VUI.db.profile.modules.trufigcd.iconCustomization.enabled end,
            args = {
                enableAnimations = {
                    type = "toggle",
                    name = "Enable Animations",
                    desc = "Enable fade and scale animations for icons",
                    get = function() return VUI.db.profile.modules.trufigcd.iconCustomization.enableAnimations end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.iconCustomization.enableAnimations = value
                        self:UpdateFrame()
                    end,
                    width = "full",
                    order = 1
                },
                
                useScaleAnimation = {
                    type = "toggle",
                    name = "Scale Animation",
                    desc = "Enable scale animation when icons appear",
                    get = function() return VUI.db.profile.modules.trufigcd.iconCustomization.useScaleAnimation end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.iconCustomization.useScaleAnimation = value
                        self:UpdateFrame()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.iconCustomization.enabled or not VUI.db.profile.modules.trufigcd.iconCustomization.enableAnimations end,
                    width = "full",
                    order = 2
                },
                
                fadeInDuration = {
                    type = "range",
                    name = "Fade In Duration",
                    desc = "Duration of the fade in animation (seconds)",
                    min = 0.1,
                    max = 1.0,
                    step = 0.05,
                    get = function() return VUI.db.profile.modules.trufigcd.iconCustomization.fadeInDuration end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.iconCustomization.fadeInDuration = value
                        self:UpdateFrame()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.iconCustomization.enabled or not VUI.db.profile.modules.trufigcd.iconCustomization.enableAnimations end,
                    width = "full",
                    order = 3
                },
            }
        }
        
        -- Importance scaling options
        options.args.scalingGroup = {
            type = "group",
            name = "Icon Scaling",
            inline = true,
            order = 56,
            disabled = function() return not VUI.db.profile.modules.trufigcd.iconCustomization.enabled end,
            args = {
                enableImportanceScaling = {
                    type = "toggle",
                    name = "Enable Importance Scaling",
                    desc = "Scale icons based on spell importance",
                    get = function() return VUI.db.profile.modules.trufigcd.iconCustomization.enableImportanceScaling end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.iconCustomization.enableImportanceScaling = value
                        self:UpdateFrame()
                    end,
                    width = "full",
                    order = 1
                },
                
                importantSpellScale = {
                    type = "range",
                    name = "Important Spell Scale",
                    desc = "Scale factor for important spells",
                    min = 0.8,
                    max = 1.5,
                    step = 0.05,
                    get = function() return VUI.db.profile.modules.trufigcd.iconCustomization.importantSpellScale end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.iconCustomization.importantSpellScale = value
                        self:UpdateFrame()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.iconCustomization.enabled or not VUI.db.profile.modules.trufigcd.iconCustomization.enableImportanceScaling end,
                    width = "full",
                    order = 2
                },
                
                normalSpellScale = {
                    type = "range",
                    name = "Normal Spell Scale",
                    desc = "Scale factor for normal spells",
                    min = 0.8,
                    max = 1.5,
                    step = 0.05,
                    get = function() return VUI.db.profile.modules.trufigcd.iconCustomization.normalSpellScale end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.iconCustomization.normalSpellScale = value
                        self:UpdateFrame()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.iconCustomization.enabled or not VUI.db.profile.modules.trufigcd.iconCustomization.enableImportanceScaling end,
                    width = "full",
                    order = 3
                },
                
                minorSpellScale = {
                    type = "range",
                    name = "Minor Spell Scale",
                    desc = "Scale factor for minor spells",
                    min = 0.5,
                    max = 1.0,
                    step = 0.05,
                    get = function() return VUI.db.profile.modules.trufigcd.iconCustomization.minorSpellScale end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.iconCustomization.minorSpellScale = value
                        self:UpdateFrame()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.iconCustomization.enabled or not VUI.db.profile.modules.trufigcd.iconCustomization.enableImportanceScaling end,
                    width = "full",
                    order = 4
                },
            }
        }
        
        -- Text options
        options.args.textOptionsGroup = {
            type = "group",
            name = "Text Options",
            inline = true,
            order = 57,
            disabled = function() return not VUI.db.profile.modules.trufigcd.iconCustomization.enabled end,
            args = {
                showSpellName = {
                    type = "toggle",
                    name = "Show Spell Name",
                    desc = "Show the spell name below the icon",
                    get = function() return VUI.db.profile.modules.trufigcd.iconCustomization.showSpellName end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.iconCustomization.showSpellName = value
                        self:UpdateFrame()
                    end,
                    width = "full",
                    order = 1
                },
                
                spellNameSize = {
                    type = "range",
                    name = "Spell Name Size",
                    desc = "Font size for spell names",
                    min = 6,
                    max = 16,
                    step = 1,
                    get = function() return VUI.db.profile.modules.trufigcd.iconCustomization.spellNameSize end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.iconCustomization.spellNameSize = value
                        self:UpdateFrame()
                    end,
                    disabled = function() return not VUI.db.profile.modules.trufigcd.iconCustomization.enabled or not VUI.db.profile.modules.trufigcd.iconCustomization.showSpellName end,
                    width = "full",
                    order = 2
                },
                
                showCooldownText = {
                    type = "toggle",
                    name = "Show Cooldown Text",
                    desc = "Show cooldown time text on icons",
                    get = function() return VUI.db.profile.modules.trufigcd.iconCustomization.showCooldownText end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.iconCustomization.showCooldownText = value
                        self:UpdateFrame()
                    end,
                    width = "full",
                    order = 3
                },
                
                indicateSpellType = {
                    type = "toggle",
                    name = "Indicate Spell Type",
                    desc = "Show an indicator of the spell's type (offensive, defensive, etc.)",
                    get = function() return VUI.db.profile.modules.trufigcd.iconCustomization.indicateSpellType end,
                    set = function(_, value)
                        VUI.db.profile.modules.trufigcd.iconCustomization.indicateSpellType = value
                        self:UpdateFrame()
                    end,
                    width = "full",
                    order = 4
                },
            }
        }
        
        return options
    end
end

-- Override the CreateIconFrame function to incorporate icon customization
local originalCreateIconFrame
if TrufiGCD.CreateIconFrame then
    originalCreateIconFrame = TrufiGCD.CreateIconFrame
    
    TrufiGCD.CreateIconFrame = function(self, spellID, index)
        -- Call the original function
        local frame = originalCreateIconFrame(self, spellID, index)
        
        -- Apply icon customization
        if frame and spellID then
            self:ApplyIconCustomization(frame, spellID, false)
        end
        
        return frame
    end
end

-- Override the UpdateIconFrame function to incorporate icon customization
local originalUpdateIconFrame
if TrufiGCD.UpdateIconFrame then
    originalUpdateIconFrame = TrufiGCD.UpdateIconFrame
    
    TrufiGCD.UpdateIconFrame = function(self, frame, spellID, isActive)
        -- Call the original function
        originalUpdateIconFrame(self, frame, spellID, isActive)
        
        -- Apply icon customization
        if frame and spellID then
            self:ApplyIconCustomization(frame, spellID, isActive)
        end
    end
end
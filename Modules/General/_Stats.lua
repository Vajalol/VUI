local Module = VUI:NewModule("General.Stats");

-- Cache frequently used functions
local min, max, floor, format, sin = math.min, math.max, math.floor, string.format, math.sin
local CreateFrame = CreateFrame
local UnitStat, GetCombatRating, GetCombatRatingBonus = UnitStat, GetCombatRating, GetCombatRatingBonus
local GetSpellCritChance, GetRangedCritChance, GetMeleeCritChance = GetSpellCritChance, GetRangedCritChance, GetMeleeCritChance
local UnitAttackSpeed, UnitRangedDamage = UnitAttackSpeed, UnitRangedDamage
local GetHaste, GetMasteryEffect, GetCritChance, GetVersatilityBonus = GetHaste, GetMasteryEffect, GetCritChance, GetVersatilityBonus
local GetAvoidance, GetLifesteal, GetSpeedRating = GetAvoidance, GetLifesteal, GetSpeedRating

-- Bloodlust effect tracking
local BLOODLUST_BUFFS = {
    [2825] = true,   -- Bloodlust (Horde Shaman)
    [32182] = true,  -- Heroism (Alliance Shaman)
    [80353] = true,  -- Time Warp (Mage)
    [90355] = true,  -- Ancient Hysteria (Hunter pet)
    [160452] = true, -- Netherwinds (Hunter pet)
    [264667] = true, -- Primal Rage (Hunter pet)
    [178207] = true, -- Drums of Fury
    [230935] = true, -- Drums of the Mountain
    [256740] = true, -- Drums of the Maelstrom
    [309658] = true, -- Drums of Deathly Ferocity
    [390386] = true, -- Fury of the Aspects (Evoker)
    [146555] = true, -- Drums of Rage (MoP Drums)
    [292686] = true, -- Mallet of Thunderous Skins (craftable)
    [35475] = true,  -- Drums of War (Leatherworking)
    [217750] = true, -- Warrior PvP talent - Warbringer's buff
    [204362] = true, -- Hero's Bloodlust in Torghast
}

-- Table to store previous stat values for change detection
local prevStats = {}

-- Safe wrapper for GetUnitSpeedMultiplier API to handle compatibility across WoW versions
local function SafeGetUnitSpeedMultiplier(unit)
    unit = unit or "player"
    
    -- Default to 100% speed multiplier (1.0x)
    local defaultMultiplier = 1.0
    
    -- Check if the function exists
    if GetUnitSpeedMultiplier and type(GetUnitSpeedMultiplier) == "function" then
        -- Use pcall to safely call the function
        local success, multiplier = pcall(function() return GetUnitSpeedMultiplier(unit) end)
        
        if success and multiplier and type(multiplier) == "number" and multiplier > 0 then
            return multiplier
        end
    end
    
    -- Fallback mechanism - try to calculate from GetUnitSpeed
    if GetUnitSpeed and type(GetUnitSpeed) == "function" then
        local success, speed = pcall(function() return GetUnitSpeed(unit) end)
        
        if success and speed and type(speed) == "number" then
            -- Only mounted or with speed buffs will be significantly over 7 yards/sec
            local baseSpeed = 7.0
            
            -- If player is mounted or has speed buffs, this will be > 1.0
            return math.max(1.0, speed / baseSpeed)
        end
    end
    
    -- For isMoving detection
    local isMoving = false
    if UnitExists and IsUnitOnCooldown then
        if UnitExists(unit) and not IsUnitOnCooldown(unit) then
            isMoving = true
        end
    end
    
    -- Return default value if all else fails
    return defaultMultiplier, isMoving
end

function Module:OnEnable()
    local db = {
        display = VUI.db.profile.general.display,
        statsframe = VUI.db.profile.edit.statsframe,
        playerstats = VUI.db.profile.general.playerstats or {}
    }

    -- Basic StatsFrame for FPS, Latency, etc.
    StatsFrame = CreateFrame("Frame", "StatsFrame", UIParent)
    StatsFrame:ClearAllPoints()
    StatsFrame:SetPoint(db.statsframe.point, UIParent, db.statsframe.point, db.statsframe.x, db.statsframe.y)

    if (db.display.fps or db.display.ms or db.display.movementSpeed) then
        local font = VUI.db.profile.general.font or STANDARD_TEXT_FONT
        local fontSize = 13
        local fontFlag = "THINOUTLINE"
        local textAlign = "CENTER"
        local customColor = db.color
        local useShadow = true
        local color

        if customColor == false then
            color = { r = 1, g = 1, b = 1 }
        else
            local _, class = UnitClass("player")
            color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
        end

        local function status()
            -- Color-coded FPS display (Red < 15, Yellow < 30, Green >= 30)
            local function getFPS() 
                local fps = floor(GetFramerate())
                local color
                if fps < 15 then
                    color = "ff0000" -- Red
                elseif fps < 30 then
                    color = "ffff00" -- Yellow
                else
                    color = "00ff00" -- Green
                end
                return "|c00" .. color .. fps .. "|r fps"
            end

            -- Color-coded latency display (Green < 50, Yellow < 100, Orange < 200, Red >= 200)
            local function getLatency() 
                local ms = select(4, GetNetStats())
                local color
                if ms < 50 then
                    color = "00ff00" -- Green
                elseif ms < 100 then
                    color = "ffff00" -- Yellow
                elseif ms < 200 then
                    color = "ff9900" -- Orange
                else
                    color = "ff0000" -- Red
                end
                return "|c00" .. color .. ms .. "|r ms"
            end

            -- Loot specialization display with class color and spec icon
            local function getLootSpec()
                local specID = GetLootSpecialization()
                local className, classFileName = UnitClass("player")
                local classColor = RAID_CLASS_COLORS[classFileName]
                local colorStr = string.format("%02x%02x%02x", classColor.r*255, classColor.g*255, classColor.b*255)
                
                -- If no loot spec is selected, use current spec
                if specID == 0 then
                    specID = GetSpecialization()
                    if specID then 
                        specID = GetSpecializationInfo(specID)
                    else
                        return "|cffff0000No Spec|r"
                    end
                end
                
                -- Get spec name and icon
                local _, specName, _, specIcon = GetSpecializationInfoByID(specID)
                if not specName then return "|cffff0000Unknown|r" end
                
                -- Create icon texture string (16x16 pixels)
                local iconString = "|T" .. specIcon .. ":16:16:0:0|t"
                
                -- Return formatted loot spec string with icon
                return iconString .. " |c00" .. colorStr .. "LOOT: " .. specName .. "|r"
            end
            
            local speedPercent, isGliding = SafeGetUnitSpeedMultiplier()
            local function getMovementSpeed()
                if isGliding then
                    return "|c00ffffff" .. string.format("%d", speedPercent) .. "%|r gliding"
                else
                    return "|c00ffffff" .. string.format("%d", speedPercent) .. "%|r speed"
                end
            end

            local result = {}
            if db.display.fps then
                table.insert(result, getFPS())
            end

            if db.display.ms then
                table.insert(result, getLatency())
            end
            
            if db.display.lootspec then
                table.insert(result, getLootSpec())
            end

            if db.display.movementSpeed then
                table.insert(result, getMovementSpeed())
            end

            return table.concat(result, "  ")
        end

        StatsFrame:SetWidth(200) -- Wider initial width to accommodate loot spec display
        StatsFrame:SetHeight(fontSize)
        StatsFrame.text = StatsFrame:CreateFontString(nil, "BACKGROUND")
        StatsFrame.text:SetPoint(textAlign, StatsFrame)
        StatsFrame.text:SetFont(font, fontSize, fontFlag)
        if useShadow then
            StatsFrame.text:SetShadowOffset(1, -1)
            StatsFrame.text:SetShadowColor(0, 0, 0)
        end
        StatsFrame.text:SetTextColor(color.r, color.g, color.b)

        local lastUpdate = 0

        local function update(self, elapsed)
            lastUpdate = lastUpdate + elapsed
            if lastUpdate > 0.2 then
                lastUpdate = 0
                local statusText = status()
                StatsFrame.text:SetText(statusText)
                -- Add extra width for the icon in loot spec display
                local width = StatsFrame.text:GetStringWidth()
                if db.display.lootspec then
                    width = width + 20 -- Additional space for spec icon
                end
                self:SetWidth(width)
                self:SetHeight(StatsFrame.text:GetStringHeight())
            end
        end

        StatsFrame:SetScript("OnUpdate", update)
    end

    -- Create the PlayerStats Frame
    if VUI.db.profile.general.playerstats and VUI.db.profile.general.playerstats.enabled then
        -- Main frame setup
        local PlayerStatsFrame = CreateFrame("Frame", "VUIPlayerStatsFrame", UIParent, "BackdropTemplate")
        
        -- Get saved position or use default
        local position = db.playerstats.position or {"CENTER", UIParent, "CENTER", 0, 0}
        local width = db.playerstats.width or 200
        local height = db.playerstats.height or 160
        
        PlayerStatsFrame:SetSize(width, height)
        PlayerStatsFrame:SetPoint(position[1], position[2], position[3], position[4], position[5])
        
        -- Set appearance with 3D style
        PlayerStatsFrame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", -- Built-in 3D-style border
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 5, right = 5, top = 5, bottom = 5 }
        })
        
        -- Create a gradient background for 3D effect
        local bg = PlayerStatsFrame:CreateTexture(nil, "BACKGROUND")
        bg:SetPoint("TOPLEFT", PlayerStatsFrame, "TOPLEFT", 5, -5)
        bg:SetPoint("BOTTOMRIGHT", PlayerStatsFrame, "BOTTOMRIGHT", -5, 5)
        bg:SetColorTexture(0.1, 0.1, 0.1, 0.1) -- Much more transparent background
        
        -- Create a light source effect at the top left
        local highlight = PlayerStatsFrame:CreateTexture(nil, "BACKGROUND", nil, 1)
        highlight:SetPoint("TOPLEFT", PlayerStatsFrame, "TOPLEFT", 5, -5)
        highlight:SetSize(width/2, height/2)
        highlight:SetColorTexture(1, 1, 1, 0.05)
        
        -- Try modern SetGradient first, then SetGradientAlpha, falling back to SetColorTexture
        local function SafeSetGradient(tex, orientation, startR, startG, startB, startA, endR, endG, endB, endA)
            if tex.SetGradient and type(tex.SetGradient) == "function" then
                -- Modern API (Shadowlands+)
                tex:SetGradient(orientation, 
                    CreateColor(startR, startG, startB, startA), 
                    CreateColor(endR, endG, endB, endA))
            elseif tex.SetGradientAlpha and type(tex.SetGradientAlpha) == "function" then
                -- Legacy API
                tex:SetGradientAlpha(orientation, startR, startG, startB, startA, endR, endG, endB, endA)
            else
                -- Ultimate fallback - just set a solid color
                tex:SetColorTexture((startR + endR)/2, (startG + endG)/2, (startB + endB)/2, (startA + endA)/2)
            end
        end
        
        -- Apply gradient safely
        SafeSetGradient(highlight, "VERTICAL", 0.2, 0.2, 0.2, 0.15, 0.1, 0.1, 0.1, 0)
        
        -- Create a shadow at bottom right for depth
        local shadow = PlayerStatsFrame:CreateTexture(nil, "BACKGROUND", nil, 0)
        shadow:SetPoint("BOTTOMRIGHT", PlayerStatsFrame, "BOTTOMRIGHT", -5, 5)
        shadow:SetSize(width/2, height/2)
        shadow:SetColorTexture(0, 0, 0, 0.2)
        
        -- Apply gradient safely
        SafeSetGradient(shadow, "VERTICAL", 0, 0, 0, 0, 0.05, 0.05, 0.05, 0.25)
        
        PlayerStatsFrame:SetBackdropColor(0.05, 0.05, 0.12, 0.1) -- Much more transparent backdrop
        PlayerStatsFrame:SetBackdropBorderColor(0.4, 0.4, 0.6, 1) -- Slightly blue-tinted border
        
        -- Add a subtle glow effect around the frame for 3D depth
        local glow = CreateFrame("Frame", nil, PlayerStatsFrame, "BackdropTemplate")
        glow:SetPoint("TOPLEFT", PlayerStatsFrame, "TOPLEFT", -3, 3)
        glow:SetPoint("BOTTOMRIGHT", PlayerStatsFrame, "BOTTOMRIGHT", 3, -3)
        glow:SetFrameStrata("BACKGROUND")
        glow:SetBackdrop({
            edgeFile = "Interface\\AddOns\\VUI\\Media\\Textures\\Glow", 
            edgeSize = 3,
        })
        glow:SetBackdropBorderColor(0.2, 0.2, 0.8, 0.2)
        
        -- Use default glow if custom one doesn't exist
        local function SafeGetBackdropTexture(frame, textureName)
            if frame and frame.GetBackdropTexture and type(frame.GetBackdropTexture) == "function" then
                return frame:GetBackdropTexture(textureName)
            end
            return nil
        end
        
        if not SafeGetBackdropTexture(glow, "border") or not (SafeGetBackdropTexture(glow, "border") and SafeGetBackdropTexture(glow, "border"):GetTexture()) then
            glow:SetBackdrop({
                edgeFile = "Interface\\Buttons\\UI-Panel-Button-Glow", 
                edgeSize = 5,
            })
            glow:SetBackdropBorderColor(0.2, 0.2, 0.8, 0.3)
        end
        
        -- Make frame movable and resizable
        PlayerStatsFrame:SetMovable(true)
        PlayerStatsFrame:SetResizable(true)
        
        -- Add safety checks for resize functions
        if PlayerStatsFrame.SetMinResize and type(PlayerStatsFrame.SetMinResize) == "function" then
            PlayerStatsFrame:SetMinResize(150, 140)
        end
        
        if PlayerStatsFrame.SetMaxResize and type(PlayerStatsFrame.SetMaxResize) == "function" then
            PlayerStatsFrame:SetMaxResize(400, 300)
        end
        
        -- Add a 3D-styled header (can be used to move the frame)
        local header = CreateFrame("Frame", nil, PlayerStatsFrame)
        header:SetHeight(24)
        header:SetPoint("TOPLEFT", PlayerStatsFrame, "TOPLEFT", 2, -2)
        header:SetPoint("TOPRIGHT", PlayerStatsFrame, "TOPRIGHT", -2, -2)
        header:EnableMouse(true)
        
        -- Create header background with 3D effect
        local headerBg = header:CreateTexture(nil, "BACKGROUND")
        headerBg:SetAllPoints()
        headerBg:SetColorTexture(0.15, 0.15, 0.2, 0.8)
        
        -- Create header top highlight for 3D effect
        local headerHighlight = header:CreateTexture(nil, "BORDER")
        headerHighlight:SetHeight(1)
        headerHighlight:SetPoint("TOPLEFT", header, "TOPLEFT", 0, 0)
        headerHighlight:SetPoint("TOPRIGHT", header, "TOPRIGHT", 0, 0)
        headerHighlight:SetColorTexture(0.6, 0.6, 0.8, 0.6)
        
        -- Create header bottom shadow for 3D effect
        local headerShadow = header:CreateTexture(nil, "BORDER")
        headerShadow:SetHeight(1)
        headerShadow:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
        headerShadow:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
        headerShadow:SetColorTexture(0.1, 0.1, 0.1, 0.8)
        
        -- Add header text with shadow for 3D effect
        local headerText = header:CreateFontString(nil, "OVERLAY")
        headerText:SetPoint("CENTER", header, "CENTER", 0, 0)
        headerText:SetFont(VUI.db.profile.general.font or "Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 13, "OUTLINE")
        headerText:SetText("Player Stats")
        headerText:SetTextColor(0.8, 0.8, 1)
        
        -- Add text shadow for 3D effect
        headerText:SetShadowOffset(1.5, -1.5)
        headerText:SetShadowColor(0, 0, 0, 0.8)
        
        -- Add resize handle
        local resizeButton = CreateFrame("Button", nil, PlayerStatsFrame)
        resizeButton:SetSize(16, 16)
        resizeButton:SetPoint("BOTTOMRIGHT", PlayerStatsFrame, "BOTTOMRIGHT", 0, 0)
        resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
        resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
        
        -- Forward declaration of update function (will be defined fully later)
        local UpdateLayout
        
        -- Make the frame draggable with continuous update
        header:SetScript("OnMouseDown", function()
            PlayerStatsFrame:StartMoving()
        end)
        
        header:SetScript("OnMouseUp", function()
            PlayerStatsFrame:StopMovingOrSizing()
            -- Save position
            local point, relativeTo, relativePoint, xOfs, yOfs = PlayerStatsFrame:GetPoint()
            db.playerstats.position = {point, relativeTo, relativePoint, xOfs, yOfs}
            VUI.db.profile.general.playerstats.position = {point, relativeTo, relativePoint, xOfs, yOfs}
        end)
        
        -- Add continuous update during dragging
        header:SetScript("OnUpdate", function(self)
            if PlayerStatsFrame and PlayerStatsFrame.IsMoving and type(PlayerStatsFrame.IsMoving) == "function" and PlayerStatsFrame:IsMoving() then
                -- Save position continuously while moving
                local point, relativeTo, relativePoint, xOfs, yOfs = PlayerStatsFrame:GetPoint()
                db.playerstats.position = {point, relativeTo, relativePoint, xOfs, yOfs}
                VUI.db.profile.general.playerstats.position = {point, relativeTo, relativePoint, xOfs, yOfs}
            end
        end)
        
        -- Make the frame resizable
        resizeButton:SetScript("OnMouseDown", function()
            PlayerStatsFrame:StartSizing("BOTTOMRIGHT")
        end)
        
        resizeButton:SetScript("OnMouseUp", function()
            PlayerStatsFrame:StopMovingOrSizing()
            -- Update and save size if UpdateLayout is defined
            if UpdateLayout then
                UpdateLayout()
            else
                -- Fallback if not yet defined
                db.playerstats.width = PlayerStatsFrame:GetWidth()
                db.playerstats.height = PlayerStatsFrame:GetHeight()
                VUI.db.profile.general.playerstats.width = PlayerStatsFrame:GetWidth()
                VUI.db.profile.general.playerstats.height = PlayerStatsFrame:GetHeight()
            end
        end)
        
        -- Create stat lines
        local stats = {
            { name = "Crit", color = {r=1, g=0.3, b=0.3}, getValueFunc = function() return GetCritChance() end },
            { name = "Haste", color = {r=1, g=1, b=0.3}, getValueFunc = function() return GetHaste() end },
            { name = "Mastery", color = {r=0.3, g=0.7, b=1}, getValueFunc = function() return GetMasteryEffect() end },
            { name = "Versatility", color = {r=0.3, g=1, b=0.3}, getValueFunc = function() 
                return GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE) 
            end },
            { name = "Speed", color = {r=0.7, g=0.3, b=1}, getValueFunc = function() 
                -- Fix calculation to properly show the player's movement speed
                local speedBonus = GetCombatRatingBonus(CR_SPEED)
                local speedMultiplier = SafeGetUnitSpeedMultiplier("player")
                
                -- Convert multiplier to percentage (base speed = 100%)
                local speedValue = (speedMultiplier * 100) - 100 + speedBonus
                
                -- Ensure the value is never negative
                return math.max(0, speedValue)
            end },
            { name = "Leech", color = {r=0.3, g=1, b=0.3}, getValueFunc = function() return GetLifesteal() end },
            { name = "Avoidance", color = {r=1, g=1, b=1}, getValueFunc = function() return GetAvoidance() end },
        }
        
        -- Create containers for each stat row to hold the 3D styled elements
        local statContainers = {}
        local statLabels = {}
        local statValues = {}
        
        for i, stat in ipairs(stats) do
            -- Create container for each stat row with 3D effect
            statContainers[i] = CreateFrame("Frame", nil, PlayerStatsFrame)
            statContainers[i]:SetSize(width-20, 18)
            statContainers[i]:SetPoint("TOPLEFT", PlayerStatsFrame, "TOPLEFT", 10, -30 - (i-1)*22)
            
            -- Create background for stat row
            local rowBg = statContainers[i]:CreateTexture(nil, "BACKGROUND")
            rowBg:SetAllPoints()
            rowBg:SetColorTexture(0.1, 0.1, 0.12, 0.3)
            
            -- Top highlight for 3D effect
            local rowHighlight = statContainers[i]:CreateTexture(nil, "BORDER")
            rowHighlight:SetHeight(1)
            rowHighlight:SetPoint("TOPLEFT", statContainers[i], "TOPLEFT", 0, 0)
            rowHighlight:SetPoint("TOPRIGHT", statContainers[i], "TOPRIGHT", 0, 0)
            rowHighlight:SetColorTexture(stat.color.r, stat.color.g, stat.color.b, 0.3)
            
            -- Bottom shadow for 3D effect
            local rowShadow = statContainers[i]:CreateTexture(nil, "BORDER")
            rowShadow:SetHeight(1)
            rowShadow:SetPoint("BOTTOMLEFT", statContainers[i], "BOTTOMLEFT", 0, 0)
            rowShadow:SetPoint("BOTTOMRIGHT", statContainers[i], "BOTTOMRIGHT", 0, 0)
            rowShadow:SetColorTexture(0, 0, 0, 0.5)
            
            -- Create label with 3D text effect
            statLabels[i] = statContainers[i]:CreateFontString(nil, "OVERLAY")
            statLabels[i]:SetPoint("LEFT", statContainers[i], "LEFT", 5, 0)
            statLabels[i]:SetFont(VUI.db.profile.general.font or "Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 12, "OUTLINE")
            statLabels[i]:SetText(stat.name)
            statLabels[i]:SetTextColor(stat.color.r, stat.color.g, stat.color.b)
            
            -- Add shadow to label for 3D effect
            statLabels[i]:SetShadowOffset(1, -1)
            statLabels[i]:SetShadowColor(0, 0, 0, 0.8)
            
            -- Create value text with 3D effect
            statValues[i] = statContainers[i]:CreateFontString(nil, "OVERLAY")
            statValues[i]:SetPoint("RIGHT", statContainers[i], "RIGHT", -5, 0)
            statValues[i]:SetFont(VUI.db.profile.general.font or "Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 13, "OUTLINE")
            statValues[i]:SetText("0%")
            statValues[i]:SetTextColor(stat.color.r, stat.color.g, stat.color.b)
            
            -- Add shadow to value for 3D effect
            statValues[i]:SetShadowOffset(1, -1)
            statValues[i]:SetShadowColor(0, 0, 0, 0.8)
        end
        
        -- Create bottom row for cooldown icons
        local iconSize = 24
        local iconSpacing = 4
        local iconRowHeight = iconSize + 6
        local bottomRow = CreateFrame("Frame", nil, PlayerStatsFrame)
        bottomRow:SetSize(width, iconRowHeight)
        bottomRow:SetPoint("BOTTOMLEFT", PlayerStatsFrame, "BOTTOMLEFT", 5, 5)
        bottomRow:SetPoint("BOTTOMRIGHT", PlayerStatsFrame, "BOTTOMRIGHT", -5, 5)
        
        -- Create background for icon row
        local rowBg = bottomRow:CreateTexture(nil, "BACKGROUND")
        rowBg:SetAllPoints()
        rowBg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
        
        -- Create 3D inset for icon row
        local rowBorder = CreateFrame("Frame", nil, bottomRow, "BackdropTemplate")
        rowBorder:SetAllPoints()
        rowBorder:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", 
            edgeSize = 8,
            insets = { left = 1, right = 1, top = 1, bottom = 1 }
        })
        rowBorder:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
        
        -- Function to create cooldown icons with consistent style
        local function CreateCooldownIcon(parent, texture, tooltip)
            local container = CreateFrame("Frame", nil, parent)
            container:SetSize(iconSize, iconSize)
            
            -- Background
            local bg = container:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0, 0, 0, 0.6)
            
            -- Icon
            local icon = container:CreateTexture(nil, "ARTWORK")
            icon:SetSize(iconSize - 4, iconSize - 4)
            icon:SetPoint("CENTER")
            icon:SetTexture(texture)
            icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim icon borders
            
            -- Cooldown swipe - this is the visual spinning animation
            local cooldown = CreateFrame("Cooldown", nil, container, "CooldownFrameTemplate")
            cooldown:SetAllPoints(icon)
            cooldown:SetDrawEdge(true)
            cooldown:SetDrawSwipe(true)
            cooldown:SetSwipeColor(0, 0, 0, 0.8)
            cooldown:SetReverse(false) -- Counter-clockwise swipe
            cooldown:SetHideCountdownNumbers(true) -- We'll handle our own text
            
            -- Add border frame for better visibility
            local border = container:CreateTexture(nil, "OVERLAY", nil, 1)
            border:SetPoint("CENTER")
            border:SetSize(iconSize + 2, iconSize + 2)
            border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
            border:SetBlendMode("ADD")
            border:SetAlpha(0)
            
            -- Create glow effect
            local glow = container:CreateTexture(nil, "OVERLAY", nil, 2)
            glow:SetPoint("CENTER")
            glow:SetSize(iconSize + 8, iconSize + 8)
            glow:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
            glow:SetTexCoord(0.00781250, 0.50781250, 0.53515625, 0.78515625)
            glow:SetBlendMode("ADD")
            glow:SetAlpha(0)
            
            -- Count text
            local count = container:CreateFontString(nil, "OVERLAY")
            count:SetPoint("BOTTOMRIGHT", -1, 1)
            count:SetFont(VUI.db.profile.general.font or "Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 10, "OUTLINE")
            count:SetText("")
            count:SetShadowOffset(1, -1)
            count:SetShadowColor(0, 0, 0, 1)
            
            -- Timer text
            local timer = container:CreateFontString(nil, "OVERLAY")
            timer:SetPoint("CENTER")
            timer:SetFont(VUI.db.profile.general.font or "Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 12, "OUTLINE")
            timer:SetText("")
            timer:SetShadowOffset(1, -1)
            timer:SetShadowColor(0, 0, 0, 1)
            
            -- Tooltip
            if tooltip then
                container:EnableMouse(true)
                container:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
                    GameTooltip:SetText(tooltip)
                    GameTooltip:Show()
                end)
                container:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
            end
            
            return {
                frame = container,
                icon = icon,
                cooldown = cooldown,
                glow = glow,
                border = border,
                count = count,
                timer = timer,
                isOnCooldown = false,
                timeLeft = 0,
                startTime = 0,
                duration = 0,
                -- Method to set the icon to ready state
                SetReady = function(self, isReady)
                    if isReady then
                        self.icon:SetAlpha(1)
                        self.icon:SetVertexColor(1, 1, 1)
                        self.glow:SetAlpha(0.7)
                        self.border:SetAlpha(0.7)
                        -- Clear any cooldown swipe
                        self.cooldown:Clear()
                        self.timer:SetText("")
                        self.isOnCooldown = false
                        self.timeLeft = 0
                        
                        -- Add subtle pulsing effect when ready
                        if not self.pulseAnimation then
                            self.pulseAnimation = C_Timer.NewTicker(0.5, function()
                                if not self.isOnCooldown then
                                    self.glow:SetAlpha(0.7 + 0.3 * sin(GetTime() * 3))
                                    self.border:SetAlpha(0.7 + 0.3 * sin(GetTime() * 3))
                                end
                            end)
                        end
                    else
                        self.icon:SetAlpha(0.6)
                        self.icon:SetVertexColor(0.7, 0.7, 0.7)
                        self.glow:SetAlpha(0)
                        self.border:SetAlpha(0)
                        
                        -- Cancel pulse animation
                        if self.pulseAnimation then
                            self.pulseAnimation:Cancel()
                            self.pulseAnimation = nil
                        end
                    end
                end,
                -- Method to set the icon to cooldown state
                SetOnCooldown = function(self, timeLeft, duration)
                    local now = GetTime()
                    
                    -- Cancel pulse animation
                    if self.pulseAnimation then
                        self.pulseAnimation:Cancel()
                        self.pulseAnimation = nil
                    end
                    
                    -- Store cooldown information
                    self.isOnCooldown = true
                    self.timeLeft = timeLeft
                    self.startTime = now
                    self.duration = duration or timeLeft
                    
                    -- Start cooldown swipe animation from current time (reversed)
                    if self.cooldown.SetCooldown and type(self.cooldown.SetCooldown) == "function" then
                        -- Use current time offset for proper animation
                        self.cooldown:SetCooldown(now - (self.duration - timeLeft), self.duration)
                    elseif CooldownFrame_Set and type(CooldownFrame_Set) == "function" then
                        -- Alternative method using WoW's builtin function
                        CooldownFrame_Set(self.cooldown, now - (self.duration - timeLeft), self.duration, true)
                    end
                    
                    -- Dim the icon and remove glow while on cooldown
                    self.icon:SetAlpha(0.8)
                    self.icon:SetVertexColor(0.5, 0.5, 0.5)
                    self.glow:SetAlpha(0)
                    self.border:SetAlpha(0)
                    
                    -- Set timer text based on remaining time
                    if timeLeft > 0 then
                        if timeLeft > 60 then
                            self.timer:SetText(format("%d:%02d", floor(timeLeft/60), floor(timeLeft%60)))
                        else
                            self.timer:SetText(format("%d", floor(timeLeft)))
                        end
                    else
                        self.timer:SetText("")
                        self:SetReady(true)
                    end
                end,
                -- Method to update cooldown progress (called every frame)
                UpdateCooldown = function(self, elapsed)
                    if self.isOnCooldown and self.timeLeft > 0 then
                        -- Update remaining time
                        self.timeLeft = self.timeLeft - elapsed
                        
                        -- Update timer text
                        if self.timeLeft > 0 then
                            -- Different format based on time remaining
                            if self.timeLeft > 60 then
                                -- Minutes:Seconds format
                                self.timer:SetText(format("%d:%02d", floor(self.timeLeft/60), floor(self.timeLeft%60)))
                            elseif self.timeLeft > 10 then
                                -- Whole number format
                                self.timer:SetText(format("%d", floor(self.timeLeft)))
                            else
                                -- Decimal format for 10 seconds or less
                                self.timer:SetText(format("%.1f", self.timeLeft))
                            end
                            
                            -- Visual effects when cooldown is about to end
                            if self.timeLeft < 5 then
                                local pulseIntensity = 0.2 + 0.4 * sin(GetTime() * 5)
                                self.border:SetAlpha(pulseIntensity)
                                self.timer:SetTextColor(1, 0.3, 0.3) -- Red color
                            else
                                self.border:SetAlpha(0)
                                self.timer:SetTextColor(1, 1, 1) -- White color
                            end
                        else
                            -- Cooldown finished
                            self.timer:SetText("")
                            self.isOnCooldown = false
                            self:SetReady(true)
                            
                            -- Play finish animation
                            self.glow:SetAlpha(1)
                            self.border:SetAlpha(1)
                            C_Timer.After(0.5, function()
                                if not self.isOnCooldown then
                                    self.glow:SetAlpha(0.7)
                                    self.border:SetAlpha(0.7)
                                end
                            end)
                        end
                    end
                end,
                -- Method to force update the cooldown state
                ForceUpdate = function(self)
                    if self.isOnCooldown and self.timeLeft > 0 then
                        self:SetOnCooldown(self.timeLeft, self.duration)
                    else
                        self:SetReady(true)
                    end
                end
            }
        end
        
        -- Create icons for bloodlust, battle res, and trinkets
        local bloodlustIcon = CreateCooldownIcon(bottomRow, "Interface\\Icons\\Spell_Nature_Bloodlust", "Bloodlust/Heroism")
        bloodlustIcon.frame:SetPoint("LEFT", bottomRow, "LEFT", 6, 0)
        
        local battleResIcon = CreateCooldownIcon(bottomRow, "Interface\\Icons\\Spell_Holy_Resurrection", "Battle Resurrection")
        battleResIcon.frame:SetPoint("LEFT", bloodlustIcon.frame, "RIGHT", iconSpacing, 0)
        
        -- Trinket icons with actual equipped trinket display
        local trinket1Icon = CreateCooldownIcon(bottomRow, "Interface\\Icons\\INV_Jewelry_Trinket_01", "Upper Trinket")
        trinket1Icon.frame:SetPoint("LEFT", battleResIcon.frame, "RIGHT", iconSpacing, 0)
        
        local trinket2Icon = CreateCooldownIcon(bottomRow, "Interface\\Icons\\INV_Jewelry_Trinket_02", "Lower Trinket")
        trinket2Icon.frame:SetPoint("LEFT", trinket1Icon.frame, "RIGHT", iconSpacing, 0)
        
        -- Get player racial ability
        local _, playerRace = UnitRace("player")
        local racialSpellID, racialName, racialIcon
        
        -- Map of racial abilities by race
        local racialAbilities = {
            Human = {id = 59752, name = "Every Man for Himself"}, -- Human
            Dwarf = {id = 59224, name = "Stoneform"}, -- Dwarf
            NightElf = {id = 58984, name = "Shadowmeld"}, -- Night Elf
            Gnome = {id = 20589, name = "Escape Artist"}, -- Gnome
            Draenei = {id = 59548, name = "Gift of the Naaru"}, -- Draenei
            Worgen = {id = 68992, name = "Darkflight"}, -- Worgen
            VoidElf = {id = 256948, name = "Spatial Rift"}, -- Void Elf
            LightforgedDraenei = {id = 255647, name = "Light's Judgment"}, -- Lightforged Draenei
            DarkIronDwarf = {id = 265221, name = "Fireblood"}, -- Dark Iron Dwarf
            KulTiran = {id = 287712, name = "Haymaker"}, -- Kul Tiran
            Mechagnome = {id = 312924, name = "Hyper Organic Light Originator"}, -- Mechagnome
            
            Orc = {id = 20572, name = "Blood Fury"}, -- Orc
            Undead = {id = 7744, name = "Will of the Forsaken"}, -- Undead
            Tauren = {id = 20549, name = "War Stomp"}, -- Tauren
            Troll = {id = 26297, name = "Berserking"}, -- Troll
            BloodElf = {id = 28730, name = "Arcane Torrent"}, -- Blood Elf
            Goblin = {id = 69070, name = "Rocket Jump"}, -- Goblin
            Nightborne = {id = 260364, name = "Arcane Pulse"}, -- Nightborne
            HighmountainTauren = {id = 255654, name = "Bull Rush"}, -- Highmountain Tauren
            MagharOrc = {id = 274738, name = "Ancestral Call"}, -- Maghar Orc
            ZandalariTroll = {id = 291944, name = "Regeneratin'"}, -- Zandalari Troll
            Vulpera = {id = 312411, name = "Bag of Tricks"}, -- Vulpera
            
            Pandaren = {id = 107079, name = "Quaking Palm"}, -- Pandaren (both factions)
            Dracthyr = {id = 358267, name = "Tail Swipe"} -- Dracthyr (both factions)
        }
        
        -- Also include default icons for racial abilities in case GetSpellInfo fails
        local racialIcons = {
            [59752] = "Interface\\Icons\\Spell_Holy_AshesToAshes", -- Human
            [59224] = "Interface\\Icons\\Spell_Holy_SealOfValor", -- Dwarf
            [58984] = "Interface\\Icons\\Ability_Ambush", -- Night Elf
            [20589] = "Interface\\Icons\\Spell_Magic_LesserInvisibilty", -- Gnome
            [59548] = "Interface\\Icons\\Spell_Holy_Heal", -- Draenei
            [68992] = "Interface\\Icons\\Ability_Druid_CatForm", -- Worgen
            [256948] = "Interface\\Icons\\Ability_Void_Shift", -- Void Elf
            [255647] = "Interface\\Icons\\Spell_Holy_AngelicBulwark", -- Lightforged Draenei
            [265221] = "Interface\\Icons\\Spell_Fire_FlameBolt", -- Dark Iron Dwarf
            [287712] = "Interface\\Icons\\Ability_Warrior_SeismicSmash", -- Kul Tiran
            [312924] = "Interface\\Icons\\INV_Engineering_90_Hologram", -- Mechagnome
            
            [20572] = "Interface\\Icons\\Racial_Orc_BerserkerStrength", -- Orc
            [7744] = "Interface\\Icons\\Spell_Shadow_RaiseDead", -- Undead
            [20549] = "Interface\\Icons\\Ability_WarStomp", -- Tauren
            [26297] = "Interface\\Icons\\Racial_Troll_Berserk", -- Troll
            [28730] = "Interface\\Icons\\Spell_Nature_Lightning", -- Blood Elf
            [69070] = "Interface\\Icons\\Ability_Racial_RocketJump", -- Goblin
            [260364] = "Interface\\Icons\\Spell_Arcane_Blast", -- Nightborne
            [255654] = "Interface\\Icons\\Ability_Racial_BullRush", -- Highmountain Tauren
            [274738] = "Interface\\Icons\\Ability_Racial_AncestralCall", -- Maghar Orc
            [291944] = "Interface\\Icons\\Ability_Racial_Regeneratin", -- Zandalari Troll
            [312411] = "Interface\\Icons\\Ability_Racial_BagOfTricks", -- Vulpera
            
            [107079] = "Interface\\Icons\\PandarenRacial_QuakingPalm", -- Pandaren
            [358267] = "Interface\\Icons\\Ability_DragonRiding_SwooP" -- Dracthyr
        }
        
        -- Get racial spell ID based on player race
        if racialAbilities[playerRace] then
            racialSpellID = racialAbilities[playerRace].id
            racialName = racialAbilities[playerRace].name
            
            -- Try to get spell icon from API first with safety checks
            if racialSpellID then
                if C_Spell and C_Spell.GetSpellInfo then
                    local spellInfo = {C_Spell.GetSpellInfo(racialSpellID)}
                    if spellInfo and spellInfo[3] then
                        racialIcon = spellInfo[3]
                    end
                elseif GetSpellInfo then
                    local _, _, icon = GetSpellInfo(racialSpellID)
                    if icon then
                        racialIcon = icon
                    end
                end
                
                -- If API calls failed, use hardcoded fallback icons
                if not racialIcon and racialIcons[racialSpellID] then
                    racialIcon = racialIcons[racialSpellID]
                end
            end
        end
        
        -- Create racial ability icon
        local racialAbilityIcon
        if racialIcon then
            racialAbilityIcon = CreateCooldownIcon(bottomRow, racialIcon, racialName or "Racial Ability")
            racialAbilityIcon.frame:SetPoint("LEFT", trinket2Icon.frame, "RIGHT", iconSpacing, 0)
        end
        
        -- Store references for later use
        local trinket1CooldownRemaining = 0
        local trinket2CooldownRemaining = 0
        
        -- Create enhanced 3D animation functions
        local function PulseText(fontString, color)
            -- Store original properties
            local currentScale = fontString:GetScale()
            local r, g, b = fontString:GetTextColor()
            local origShadowOffsetX, origShadowOffsetY = fontString:GetShadowOffset()
            local origShadowR, origShadowG, origShadowB, origShadowA = fontString:GetShadowColor()
            
            -- Initial expansion with glow
            fontString:SetScale(currentScale * 1.5)
            fontString:SetTextColor(1, 1, 1) -- Bright white flash
            fontString:SetShadowOffset(2, -2) -- Exaggerated shadow
            fontString:SetShadowColor(0, 0, 0, 1)
            
            -- Animation sequence
            C_Timer.After(0.1, function() 
                fontString:SetScale(currentScale * 1.4)
                fontString:SetTextColor(color.r + 0.2, color.g + 0.2, color.b + 0.2)
                
                C_Timer.After(0.1, function() 
                    fontString:SetScale(currentScale * 1.3)
                    fontString:SetTextColor(color.r + 0.1, color.g + 0.1, color.b + 0.1)
                    fontString:SetShadowOffset(1.8, -1.8)
                    
                    C_Timer.After(0.1, function() 
                        fontString:SetScale(currentScale * 1.2)
                        fontString:SetTextColor(color.r, color.g, color.b)
                        fontString:SetShadowOffset(1.5, -1.5)
                        
                        C_Timer.After(0.1, function() 
                            fontString:SetScale(currentScale * 1.1)
                            fontString:SetShadowOffset(1.2, -1.2)
                            
                            C_Timer.After(0.1, function() 
                                -- Restore original properties
                                fontString:SetScale(currentScale)
                                fontString:SetTextColor(r, g, b)
                                fontString:SetShadowOffset(origShadowOffsetX, origShadowOffsetY)
                                fontString:SetShadowColor(origShadowR, origShadowG, origShadowB, origShadowA)
                            end)
                        end)
                    end)
                end)
            end)
        end
        
        -- Update function for player stats
        local lastStatsUpdate = 0
        local function UpdatePlayerStats(self, elapsed)
            lastStatsUpdate = lastStatsUpdate + elapsed
            
            -- Update all cooldown timers every frame for smooth countdowns
            if bloodlustIcon then bloodlustIcon:UpdateCooldown(elapsed) end
            if battleResIcon then battleResIcon:UpdateCooldown(elapsed) end
            if trinket1Icon then trinket1Icon:UpdateCooldown(elapsed) end
            if trinket2Icon then trinket2Icon:UpdateCooldown(elapsed) end
            if racialAbilityIcon then racialAbilityIcon:UpdateCooldown(elapsed) end
            
            -- Only update other stats less frequently to save performance
            if lastStatsUpdate < 0.2 then return end
            lastStatsUpdate = 0
            
            -- Update each stat
            for i, stat in ipairs(stats) do
                -- Skip if this container is hidden
                if statContainers[i]:IsShown() then
                    local value = stat.getValueFunc()
                    
                    -- Get raw rating for display
                    local rawValue = 0
                    local statName = stat.name
                    
                    if statName == "Crit" then
                        rawValue = floor(GetCombatRating(CR_CRIT_SPELL))
                    elseif statName == "Haste" then
                        rawValue = floor(GetCombatRating(CR_HASTE_SPELL))
                    elseif statName == "Mastery" then
                        rawValue = floor(GetCombatRating(CR_MASTERY))
                    elseif statName == "Versatility" then
                        rawValue = floor(GetCombatRating(CR_VERSATILITY_DAMAGE_DONE))
                    elseif statName == "Speed" then
                        rawValue = floor(GetCombatRating(CR_SPEED))
                    elseif statName == "Leech" then
                        rawValue = floor(GetCombatRating(CR_LIFESTEAL))
                    elseif statName == "Avoidance" then
                        rawValue = floor(GetCombatRating(CR_AVOIDANCE))
                    end
                    
                    -- Format with both percentage and raw number in brackets
                    local valueText = format("%.2f%% [%d]", value, rawValue)
                    statValues[i]:SetText(valueText)
                    
                    -- Check for significant changes and animate with 3D effect
                    if prevStats[i] and (value - prevStats[i] > 3) then
                        PulseText(statValues[i], stat.color)
                        
                        -- Also pulse the container for additional effect
                        local rowHighlight = statContainers[i]:GetRegions()
                        rowHighlight:SetColorTexture(stat.color.r, stat.color.g, stat.color.b, 0.6)
                        C_Timer.After(0.4, function()
                            rowHighlight:SetColorTexture(stat.color.r, stat.color.g, stat.color.b, 0.3)
                        end)
                    end
                    
                    prevStats[i] = value
                end
            end
        end
        
        -- Create a separate function for cooldown updates to be called by events
        local function UpdateAllCooldowns()
            -- Ensure cooldown frames and icons exist
            if not trinket1Icon or not trinket2Icon or not bloodlustIcon or not battleResIcon or not racialAbilityIcon then
                return
            end
            
            -- ===== TRINKET COOLDOWNS =====
            -- Check upper trinket (slot 13)
            local trinketSlot1 = 13
            local trinketSlot2 = 14
            
            local function UpdateTrinketIcon(icon, slot)
                local start, duration, enable = GetInventoryItemCooldown("player", slot)
                local itemID = GetInventoryItemID("player", slot)
                
                if not itemID then
                    -- No trinket equipped
                    icon:SetReady(false)
                    icon.icon:SetDesaturated(true)
                    return
                end
                
                -- Update the trinket icon texture
                local itemTexture = GetItemIcon(itemID)
                if itemTexture then
                    icon.icon:SetTexture(itemTexture)
                    icon.icon:SetDesaturated(false)
                end
                
                if enable == 1 then -- Item has a cooldown (usable)
                    -- Get trinket name for tooltip
                    local itemName = GetItemInfo(itemID)
                    if itemName then
                        icon.frame:SetScript("OnEnter", function(self)
                            GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
                            GameTooltip:SetText(itemName)
                            
                            -- Add cooldown info to tooltip
                            if icon.isOnCooldown and icon.timeLeft > 0 then
                                GameTooltip:AddLine(" ")
                                GameTooltip:AddLine("Cooldown: " .. format("%d:%02d", floor(icon.timeLeft/60), floor(icon.timeLeft%60)), 1, 0.5, 0)
                            end
                            
                            GameTooltip:Show()
                        end)
                        
                        icon.frame:SetScript("OnLeave", function()
                            GameTooltip:Hide()
                        end)
                    end
                    
                    -- Check if on cooldown
                    if start > 0 and duration > 0 then
                        local remainingCD = start + duration - GetTime()
                        if remainingCD > 0 then
                            icon:SetOnCooldown(remainingCD, duration)
                        else
                            icon:SetReady(true)
                        end
                    else
                        icon:SetReady(true)
                    end
                else
                    -- Item doesn't have usable cooldown
                    icon:SetReady(false)
                end
            end
            
            -- Update both trinkets
            UpdateTrinketIcon(trinket1Icon, trinketSlot1)
            UpdateTrinketIcon(trinket2Icon, trinketSlot2)
            
            -- ===== BLOODLUST STATUS =====
            local hasBloodlust = false
            local bloodlustTimeLeft = 0
            local bloodlustStackCount = 0
            
            -- Cache of spell names to avoid repeated calls to GetSpellInfo
            if not Module.bloodlustSpellNames then
                Module.bloodlustSpellNames = {}
                for spellID in pairs(BLOODLUST_BUFFS) do
                    if C_Spell and C_Spell.GetSpellInfo then
                        local spellName = C_Spell.GetSpellInfo(spellID)
                        if spellName then
                            Module.bloodlustSpellNames[spellID] = spellName
                        end
                    elseif GetSpellInfo then
                        local spellName = GetSpellInfo(spellID)
                        if spellName then
                            Module.bloodlustSpellNames[spellID] = spellName
                        end
                    end
                end
                
                -- Manual fallbacks for important spells if API calls fail
                if not Module.bloodlustSpellNames[2825] then Module.bloodlustSpellNames[2825] = "Bloodlust" end
                if not Module.bloodlustSpellNames[32182] then Module.bloodlustSpellNames[32182] = "Heroism" end
                if not Module.bloodlustSpellNames[80353] then Module.bloodlustSpellNames[80353] = "Time Warp" end
                if not Module.bloodlustSpellNames[90355] then Module.bloodlustSpellNames[90355] = "Ancient Hysteria" end
            end
            
            -- Check for bloodlust buffs
            for spellID in pairs(BLOODLUST_BUFFS) do
                local spellName = Module.bloodlustSpellNames[spellID]
                if spellName and UnitBuff then
                    local name, _, _, count, _, duration, expirationTime = UnitBuff("player", spellName)
                    if name then
                        hasBloodlust = true
                        bloodlustTimeLeft = expirationTime - GetTime()
                        bloodlustStackCount = count or 0
                        break
                    end
                end
            end
            
            -- Alternative method: scan all buffs looking for bloodlust-like effects
            if not hasBloodlust and UnitBuff then
                local i = 1
                local name, _, _, count, _, duration, expirationTime = UnitBuff("player", i)
                while name do
                    -- Check if the buff name contains any known bloodlust keywords
                    local lowerName = name:lower()
                    if lowerName:find("bloodlust") or lowerName:find("heroism") or 
                       lowerName:find("time warp") or lowerName:find("ancient hysteria") or
                       lowerName:find("primal rage") or lowerName:find("drums") then
                        hasBloodlust = true
                        bloodlustTimeLeft = expirationTime - GetTime()
                        bloodlustStackCount = count or 0
                        break
                    end
                    i = i + 1
                    name, _, _, count, _, duration, expirationTime = UnitBuff("player", i)
                end
            end
            
            -- Update bloodlust icon with nil check
            if bloodlustIcon and hasBloodlust then
                if bloodlustTimeLeft > 0 then
                    bloodlustIcon:SetOnCooldown(bloodlustTimeLeft, bloodlustTimeLeft)
                    if bloodlustTimeLeft < 5 then
                        -- Pulse the glow as time runs out
                        local pulseAlpha = 0.3 + 0.4 * sin(GetTime() * 5)
                        bloodlustIcon.glow:SetAlpha(pulseAlpha)
                    end
                    
                    if bloodlustStackCount > 1 then
                        bloodlustIcon.count:SetText(bloodlustStackCount)
                    else
                        bloodlustIcon.count:SetText("")
                    end
                else
                    bloodlustIcon:SetReady(true)
                    bloodlustIcon.timer:SetText("")
                    bloodlustIcon.count:SetText("")
                end
            elseif bloodlustIcon then
                bloodlustIcon:SetReady(true)
                bloodlustIcon.timer:SetText("")
                bloodlustIcon.count:SetText("")
            end
            
            -- ===== BATTLE RESURRECTION STATUS =====
            local battleResAvailable = false
            local battleResCount = 0
            local battleResRechargeTime = 0
            
            -- In a raid or instance, get battle resurrection info
            if IsInGroup() and (IsInRaid() or IsInInstance()) then
                battleResAvailable = true
                
                -- Get battle resurrection charges from the encounter
                local combatResInfo = C_DeathInfo and C_DeathInfo.GetSoulbindResurrectInfo()
                if combatResInfo then
                    -- Add safety checks for nil values and validate types
                    if type(combatResInfo) == "table" then
                        battleResCount = combatResInfo.charges
                        if battleResCount == nil or type(battleResCount) ~= "number" then 
                            battleResCount = 0 
                        end
                        battleResRechargeTime = combatResInfo.chargeRechargeTime or 0
                    else
                        battleResCount = 0
                        battleResRechargeTime = 0
                    end
                else
                    -- Fallback method for older API
                    local maxCharges = 0
                    local chargesSpent = 0
                    local startTime = 0
                    local duration = 0
                    
                    if C_UIWidgetManager and C_UIWidgetManager.GetCombatResurrectionTimerInfo then
                        local info = C_UIWidgetManager.GetCombatResurrectionTimerInfo()
                        if info then
                            maxCharges = info.maxCharges or 0
                            chargesSpent = info.charges or 0
                            startTime = info.startTime or 0
                            duration = info.duration or 0
                            
                            battleResCount = max(0, maxCharges - chargesSpent)
                            if startTime > 0 and duration > 0 then
                                battleResRechargeTime = max(0, (startTime + duration) - GetTime())
                            end
                        end
                    end
                end
            end
            
            -- Update battle resurrection icon with nil check
            if battleResIcon and battleResAvailable then
                if battleResCount > 0 then
                    -- Battle res is available
                    battleResIcon:SetReady(true)
                    battleResIcon.count:SetText(tostring(battleResCount))
                    if battleResRechargeTime > 0 then
                        battleResIcon.timer:SetText(format("%d:%02d", floor(battleResRechargeTime/60), floor(battleResRechargeTime%60)))
                    else
                        battleResIcon.timer:SetText("")
                    end
                else
                    -- No charges available
                    battleResIcon:SetReady(false)
                    battleResIcon.count:SetText("0")
                    
                    if battleResRechargeTime > 0 then
                        battleResIcon:SetOnCooldown(battleResRechargeTime, battleResRechargeTime)
                    else
                        battleResIcon.timer:SetText("")
                    end
                end
            elseif battleResIcon then
                battleResIcon:SetReady(true)
                battleResIcon.timer:SetText("")
                battleResIcon.count:SetText("")
            end
            
            -- ===== RACIAL ABILITY =====
            if racialAbilityIcon and racialSpellID then
                local start, duration, enabled = 0, 0, 0
                
                -- Safely check for racial cooldown with fallbacks
                if GetSpellCooldown and type(GetSpellCooldown) == "function" then
                    start, duration, enabled = GetSpellCooldown(racialSpellID)
                end
                
                -- If the primary cooldown check failed, try alternative methods
                if not start or not duration then
                    -- Try to check by spell name if available
                    if racialName and GetSpellCooldown then
                        start, duration, enabled = GetSpellCooldown(racialName)
                    end
                    
                    -- Last resort: try to find it by scanning action bars
                    if (not start or not duration) and racialName then
                        for i = 1, 120 do  -- Check all possible action slots
                            local actionType, actionId = GetActionInfo(i)
                            if actionType == "spell" and actionId == racialSpellID then
                                start, duration = GetActionCooldown(i)
                                enabled = 1
                                break
                            end
                        end
                    end
                    
                    -- If all else failed, just assume it's ready
                    if not start or not duration then
                        start, duration, enabled = 0, 0, 1
                    end
                end
                
                -- Add tooltip with cooldown information
                racialAbilityIcon.frame:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
                    GameTooltip:SetText(racialName or "Racial Ability")
                    -- Add cooldown info to tooltip
                    if racialAbilityIcon.isOnCooldown and racialAbilityIcon.timeLeft > 0 then
                        GameTooltip:AddLine(" ")
                        GameTooltip:AddLine("Cooldown: " .. format("%d:%02d", floor(racialAbilityIcon.timeLeft/60), floor(racialAbilityIcon.timeLeft%60)), 1, 0.5, 0)
                    end
                    GameTooltip:Show()
                end)
                
                if enabled == 1 then
                    if start > 0 and duration > 0 then
                        local remainingCD = start + duration - GetTime()
                        if remainingCD > 0 then
                            racialAbilityIcon:SetOnCooldown(remainingCD, duration)
                        else
                            racialAbilityIcon:SetReady(true)
                        end
                    else
                        -- Racial ability is ready - make it glow
                        racialAbilityIcon:SetReady(true)
                    end
                else
                    racialAbilityIcon:SetReady(false)
                    racialAbilityIcon.timer:SetText("")
                end
            end
        end
        
        PlayerStatsFrame:SetScript("OnUpdate", UpdatePlayerStats)
        
        -- Show/hide based on settings or combat state
        local function UpdateFrameVisibility()
            if VUI.db.profile.general.playerstats.enabled then
                if VUI.db.profile.general.playerstats.combatOnly then
                    if InCombatLockdown() then
                        PlayerStatsFrame:Show()
                    else
                        PlayerStatsFrame:Hide()
                    end
                else
                    PlayerStatsFrame:Show()
                end
            else
                PlayerStatsFrame:Hide()
            end
        end
        
        -- Register events
        PlayerStatsFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
        PlayerStatsFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        PlayerStatsFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        
        -- Add additional event registrations for cooldown tracking
        PlayerStatsFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        PlayerStatsFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
        PlayerStatsFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
        PlayerStatsFrame:RegisterEvent("BAG_UPDATE_COOLDOWN")
        PlayerStatsFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
        PlayerStatsFrame:RegisterEvent("UNIT_AURA")
        PlayerStatsFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        
        -- Helper function to extract info from combat log events
        local function ParseCombatLogEvent()
            local timestamp, eventType, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName = CombatLogGetCurrentEventInfo()
            
            -- Only process player actions
            if not (sourceGUID == UnitGUID("player")) then
                return
            end
            
            -- Track specific events that indicate ability usage
            if eventType == "SPELL_CAST_SUCCESS" or eventType == "SPELL_AURA_APPLIED" then
                -- Check if this is a racial ability
                if racialAbilityIcon and racialSpellID and spellID == racialSpellID then
                    C_Timer.After(0.1, function()
                        local start, duration = GetSpellCooldown(racialSpellID)
                        if start > 0 and duration > 0 then
                            local remainingCD = start + duration - GetTime()
                            if remainingCD > 0 then
                                racialAbilityIcon:SetOnCooldown(remainingCD, duration)
                            end
                        end
                    end)
                end
                
                -- Check if a bloodlust effect was applied
                if BLOODLUST_BUFFS[spellID] then
                    -- Force an immediate UNIT_AURA check
                    if bloodlustIcon then
                        C_Timer.After(0.1, function()
                            local name, _, _, count, _, duration, expirationTime = UnitBuff("player", spellName)
                            if name and expirationTime then
                                local timeLeft = expirationTime - GetTime()
                                if timeLeft > 0 then
                                    bloodlustIcon:SetOnCooldown(timeLeft, duration or timeLeft)
                                    if count and count > 1 then
                                        bloodlustIcon.count:SetText(count)
                                    else
                                        bloodlustIcon.count:SetText("")
                                    end
                                end
                            end
                        end)
                    end
                end
            elseif eventType == "SPELL_AURA_REMOVED" then
                -- Check if a bloodlust effect was removed
                if BLOODLUST_BUFFS[spellID] and bloodlustIcon then
                    -- Set the bloodlust icon to ready immediately when the aura is removed
                    bloodlustIcon:SetReady(true)
                    bloodlustIcon.timer:SetText("")
                    bloodlustIcon.count:SetText("")
                end
            end
        end
        
        PlayerStatsFrame:SetScript("OnEvent", function(self, event, ...)
            local arg1, arg2, arg3 = ...
            
            if event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
                UpdateFrameVisibility()
            elseif event == "PLAYER_ENTERING_WORLD" then
                UpdateFrameVisibility()
                C_Timer.After(1, function()
                    if UpdateAllCooldowns then
                        UpdateAllCooldowns()
                    end
                end)
            end
        end)
        
        -- Initial call
        UpdateFrameVisibility()
        C_Timer.After(0.5, function()
            if UpdateAllCooldowns then
                UpdateAllCooldowns() 
            end
        end) -- Initial cooldown update with slight delay
        
        -- Save reference for outside access
        Module.PlayerStatsFrame = PlayerStatsFrame

        -- UpdateLayout function
        UpdateLayout = function()
            local newWidth = PlayerStatsFrame:GetWidth()
            local newHeight = PlayerStatsFrame:GetHeight()
            
            -- Update stat containers width
            for i = 1, #stats do
                statContainers[i]:SetWidth(newWidth - 20)
            end
            
            -- Update bottom row size
            if bottomRow then
                bottomRow:SetWidth(newWidth - 10)
            end
            
            -- Save size immediately
            db.playerstats.width = newWidth
            db.playerstats.height = newHeight
            VUI.db.profile.general.playerstats.width = newWidth
            VUI.db.profile.general.playerstats.height = newHeight
            
            -- Immediately update the backdrop if needed
            if PlayerStatsFrame.SetBackdrop and type(PlayerStatsFrame.SetBackdrop) == "function" then
                PlayerStatsFrame:SetBackdrop({
                    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                    tile = true, tileSize = 16, edgeSize = 16,
                    insets = { left = 5, right = 5, top = 5, bottom = 5 }
                })
                PlayerStatsFrame:SetBackdropColor(0.05, 0.05, 0.12, 0.1) -- Transparent backdrop
                PlayerStatsFrame:SetBackdropBorderColor(0.4, 0.4, 0.6, 1)
            end
        end
        
        -- Add continuous update during resizing
        PlayerStatsFrame:SetScript("OnSizeChanged", function()
            if PlayerStatsFrame and PlayerStatsFrame.IsSizing and type(PlayerStatsFrame.IsSizing) == "function" and PlayerStatsFrame:IsSizing() then
                UpdateLayout()
            end
        end)
    end
end

local Module = VUI:NewModule("General.Stats");

-- Cache frequently used functions
local min, max, floor, format = math.min, math.max, math.floor, string.format
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
}

-- Table to store previous stat values for change detection
local prevStats = {}

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
            local function getFPS() return "|c00ffffff" .. floor(GetFramerate()) .. "|r fps" end

            local function getLatency() return "|c00ffffff" .. select(4, GetNetStats()) .. "|r ms" end

            local isGliding, canGlide, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
            local function getMovementSpeed()
                if isGliding then
                    return "|c00ffffff" ..
                    string.format("%d", forwardSpeed and (forwardSpeed / BASE_MOVEMENT_SPEED * 100)) .. "%|r speed"
                else
                    return "|c00ffffff" ..
                    string.format("%d", (GetUnitSpeed("player") / BASE_MOVEMENT_SPEED * 100)) .. "%|r speed"
                end
            end

            local result = {}
            if db.display.fps then
                table.insert(result, getFPS())
            end

            if db.display.ms then
                table.insert(result, getLatency())
            end

            if db.display.movementSpeed then
                table.insert(result, getMovementSpeed())
            end

            return table.concat(result, " ")
        end

        StatsFrame:SetWidth(50)
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
                StatsFrame.text:SetText(status())
                self:SetWidth(StatsFrame.text:GetStringWidth())
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
        
        -- Set appearance
        PlayerStatsFrame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        PlayerStatsFrame:SetBackdropColor(0, 0, 0, 0.5) -- Semi-transparent background
        PlayerStatsFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
        
        -- Make frame movable and resizable
        PlayerStatsFrame:SetMovable(true)
        PlayerStatsFrame:SetResizable(true)
        PlayerStatsFrame:SetMinResize(150, 140)
        PlayerStatsFrame:SetMaxResize(400, 300)
        
        -- Add a header (can be used to move the frame)
        local header = CreateFrame("Frame", nil, PlayerStatsFrame)
        header:SetHeight(20)
        header:SetPoint("TOPLEFT", PlayerStatsFrame, "TOPLEFT", 0, 0)
        header:SetPoint("TOPRIGHT", PlayerStatsFrame, "TOPRIGHT", 0, 0)
        header:EnableMouse(true)
        
        -- Add header text
        local headerText = header:CreateFontString(nil, "OVERLAY")
        headerText:SetPoint("CENTER", header, "CENTER", 0, 0)
        headerText:SetFont(VUI.db.profile.general.font or "Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 12, "OUTLINE")
        headerText:SetText("Player Stats")
        headerText:SetTextColor(1, 1, 1)
        
        -- Add resize handle
        local resizeButton = CreateFrame("Button", nil, PlayerStatsFrame)
        resizeButton:SetSize(16, 16)
        resizeButton:SetPoint("BOTTOMRIGHT", PlayerStatsFrame, "BOTTOMRIGHT", 0, 0)
        resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
        resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
        
        -- Make the frame draggable
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
        
        -- Make the frame resizable
        resizeButton:SetScript("OnMouseDown", function()
            PlayerStatsFrame:StartSizing("BOTTOMRIGHT")
        end)
        
        resizeButton:SetScript("OnMouseUp", function()
            PlayerStatsFrame:StopMovingOrSizing()
            -- Save size
            db.playerstats.width = PlayerStatsFrame:GetWidth()
            db.playerstats.height = PlayerStatsFrame:GetHeight()
            VUI.db.profile.general.playerstats.width = PlayerStatsFrame:GetWidth()
            VUI.db.profile.general.playerstats.height = PlayerStatsFrame:GetHeight()
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
                return GetCombatRatingBonus(CR_SPEED) + GetUnitSpeedMultiplier("player") * 100 - 100
            end },
            { name = "Leech", color = {r=0.3, g=1, b=0.3}, getValueFunc = function() return GetLifesteal() end },
            { name = "Avoidance", color = {r=1, g=1, b=1}, getValueFunc = function() return GetAvoidance() end },
        }
        
        -- Bloodlust tracking
        local bloodlustTracker = CreateFrame("Frame", nil, PlayerStatsFrame)
        bloodlustTracker:SetSize(24, 24)
        bloodlustTracker:SetPoint("TOPRIGHT", PlayerStatsFrame, "TOPRIGHT", -5, -25)
        
        local bloodlustIcon = bloodlustTracker:CreateTexture(nil, "ARTWORK")
        bloodlustIcon:SetAllPoints()
        bloodlustIcon:SetTexture("Interface\\Icons\\Spell_Nature_Bloodlust")
        bloodlustIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9) -- Crop to remove border
        bloodlustIcon:SetAlpha(0.3) -- Default to semi-transparent when not active
        
        local bloodlustTimer = bloodlustTracker:CreateFontString(nil, "OVERLAY")
        bloodlustTimer:SetPoint("CENTER", bloodlustIcon, "BOTTOM", 0, 0)
        bloodlustTimer:SetFont(VUI.db.profile.general.font or "Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 10, "OUTLINE")
        bloodlustTimer:SetText("")
        
        local bloodlustStacks = bloodlustTracker:CreateFontString(nil, "OVERLAY")
        bloodlustStacks:SetPoint("TOPRIGHT", bloodlustIcon, "TOPRIGHT", 0, 0)
        bloodlustStacks:SetFont(VUI.db.profile.general.font or "Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 10, "OUTLINE")
        bloodlustStacks:SetText("")
        
        -- Create stat text fields
        local statLabels = {}
        local statValues = {}
        
        for i, stat in ipairs(stats) do
            -- Create label
            statLabels[i] = PlayerStatsFrame:CreateFontString(nil, "OVERLAY")
            statLabels[i]:SetPoint("TOPLEFT", PlayerStatsFrame, "TOPLEFT", 10, -25 - (i-1)*18)
            statLabels[i]:SetFont(VUI.db.profile.general.font or "Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 12, "OUTLINE")
            statLabels[i]:SetText(stat.name)
            statLabels[i]:SetTextColor(stat.color.r, stat.color.g, stat.color.b)
            
            -- Create value text
            statValues[i] = PlayerStatsFrame:CreateFontString(nil, "OVERLAY")
            statValues[i]:SetPoint("TOPLEFT", statLabels[i], "TOPRIGHT", 5, 0)
            statValues[i]:SetFont(VUI.db.profile.general.font or "Interface\\AddOns\\VUI\\Media\\Fonts\\PTSansNarrow.ttf", 12, "OUTLINE")
            statValues[i]:SetText("0%")
            statValues[i]:SetTextColor(stat.color.r, stat.color.g, stat.color.b)
        end
        
        -- Create animation functions
        local function PulseText(fontString)
            local currentScale = fontString:GetScale()
            fontString:SetScale(currentScale * 1.5)
            C_Timer.After(0.1, function() 
                fontString:SetScale(currentScale * 1.4) 
                C_Timer.After(0.1, function() 
                    fontString:SetScale(currentScale * 1.3) 
                    C_Timer.After(0.1, function() 
                        fontString:SetScale(currentScale * 1.2) 
                        C_Timer.After(0.1, function() 
                            fontString:SetScale(currentScale * 1.1) 
                            C_Timer.After(0.1, function() 
                                fontString:SetScale(currentScale) 
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
            if lastStatsUpdate < 0.5 then return end
            lastStatsUpdate = 0
            
            -- Update stat values
            for i, stat in ipairs(stats) do
                local value = stat.getValueFunc()
                value = floor(value * 100) / 100 -- Round to 2 decimal places
                
                -- Format percentage
                local valueText = format("%.2f%%", value)
                statValues[i]:SetText(valueText)
                
                -- Check for significant changes and animate
                if prevStats[i] and (value - prevStats[i] > 5) then
                    PulseText(statValues[i])
                end
                
                prevStats[i] = value
            end
            
            -- Check for bloodlust effects
            local hasBloodlust = false
            local bloodlustTimeLeft = 0
            local bloodlustStackCount = 0
            
            for spellID in pairs(BLOODLUST_BUFFS) do
                local name, _, _, count, _, duration, expirationTime = UnitBuff("player", GetSpellInfo(spellID))
                if name then
                    hasBloodlust = true
                    bloodlustTimeLeft = expirationTime - GetTime()
                    bloodlustStackCount = count or 0
                    break
                end
            end
            
            if hasBloodlust then
                bloodlustIcon:SetAlpha(1)
                if bloodlustTimeLeft > 0 then
                    local minutes = floor(bloodlustTimeLeft / 60)
                    local seconds = floor(bloodlustTimeLeft % 60)
                    bloodlustTimer:SetText(format("%d:%02d", minutes, seconds))
                else
                    bloodlustTimer:SetText("")
                end
                
                if bloodlustStackCount > 0 then
                    bloodlustStacks:SetText(bloodlustStackCount)
                else
                    bloodlustStacks:SetText("")
                end
            else
                bloodlustIcon:SetAlpha(0.3)
                bloodlustTimer:SetText("")
                bloodlustStacks:SetText("")
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
        
        PlayerStatsFrame:SetScript("OnEvent", function(self, event, ...)
            UpdateFrameVisibility()
        end)
        
        -- Initial call
        UpdateFrameVisibility()
        
        -- Save reference for outside access
        Module.PlayerStatsFrame = PlayerStatsFrame
    end
end

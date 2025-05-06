-------------------------------------------------------------------------------
-- Title: AngryKeystones Progress Enhancement
-- Author: VortexQ8
-- Enhanced progress tracking and visualization for Mythic+ dungeons
-------------------------------------------------------------------------------

local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
local AngryKeystones = VUI.angrykeystone
if not AngryKeystones then return end

-- Create the progress enhancement namespace
AngryKeystones.ProgressEnhancement = {}
local ProgressEnhancement = AngryKeystones.ProgressEnhancement

-- Dungeon-specific enemy values (example values, would be updated for each patch)
-- These values would be populated based on the current season's dungeons
local enemyValues = {
    -- Dawn of the Infinite: Galakrond's Fall
    ["DOTI-GalakrondsFall"] = {
        totalCount = 380,
        importantEnemies = {
            ["Infinite Keeper"] = 12,
            ["Epoch Ripper"] = 10,
            ["Coalesced Time"] = 24,
            ["Tyr's Vanguard"] = 16,
            ["Infinite Artificer"] = 14,
            ["Infinite Timebender"] = 20,
        }
    },
    -- Dawn of the Infinite: Murozond's Rise
    ["DOTI-MurozondsRise"] = {
        totalCount = 390,
        importantEnemies = {
            ["Infinite Slayer"] = 12,
            ["Infinite Chronoweaver"] = 18,
            ["Temporal Fusion"] = 24,
            ["Infinite Diversionist"] = 8,
            ["Temporal Devotee"] = 4,
        }
    },
    -- Atal'Dazar
    ["AtalDazar"] = {
        totalCount = 320,
        importantEnemies = {
            ["Reanimated Honor Guard"] = 10,
            ["Shadowblade Stalker"] = 6,
            ["Rezan"] = 0, -- Boss
            ["Dazar'ai Confessor"] = 7,
            ["Dazar'ai Augur"] = 7,
        }
    },
    -- Waycrest Manor
    ["WaycrestManor"] = {
        totalCount = 350,
        importantEnemies = {
            ["Heartsbane Vinetwister"] = 12,
            ["Bewitched Captain"] = 15,
            ["Coven Thornshaper"] = 8,
            ["Jagged Hound"] = 5,
            ["Devouring Maggot"] = 2,
        }
    },
    -- Black Rook Hold
    ["BlackRookHold"] = {
        totalCount = 340,
        importantEnemies = {
            ["Amalgam of Souls"] = 0, -- Boss
            ["Risen Scout"] = 5,
            ["Soul-Torn Champion"] = 15,
            ["Lord Etheldrin Ravencrest"] = 0, -- Boss
            ["Ghostly Councilor"] = 8,
        }
    },
    -- Throne of the Tides
    ["ThroneOfTheTides"] = {
        totalCount = 370,
        importantEnemies = {
            ["Deep Murloc Drudge"] = 2,
            ["Naz'jar Sentinel"] = 10,
            ["Naz'jar Oracle"] = 8,
            ["Faceless Seer"] = 15,
            ["Blight of Ozumat"] = 20,
        }
    },
    -- Vortex Pinnacle
    ["VortexPinnacle"] = {
        totalCount = 330,
        importantEnemies = {
            ["Armored Mistral"] = 10,
            ["Wild Vortex"] = 5,
            ["Turbulent Squall"] = 8,
            ["Young Storm Dragon"] = 12,
            ["Empyrean Assassin"] = 6,
        }
    },
    -- Darkheart Thicket
    ["DarkheartThicket"] = {
        totalCount = 310,
        importantEnemies = {
            ["Rotheart Keeper"] = 10,
            ["Nightmare Dweller"] = 8,
            ["Dreadsoul Poisoner"] = 12,
            ["Frenzied Nightclaw"] = 6,
            ["Vilethorn Blossom"] = 5,
        }
    },
}

-- Get config from saved variables
local function GetConfig(option)
    return VUI.db.profile.modules.angrykeystone[option]
end

-- Format enemy count to show current/total
local function FormatEnemyCount(current, total)
    if GetConfig("progressFormat") == "percent" then
        local percent = math.floor((current / total) * 100 + 0.5)
        return percent .. "%"
    elseif GetConfig("progressFormat") == "count" then
        return current .. "/" .. total
    else
        -- Both percent and count
        local percent = math.floor((current / total) * 100 + 0.5)
        return current .. "/" .. total .. " (" .. percent .. "%)"
    end
end

-- Calculate the optimal pull based on current progress
local function CalculateOptimalPull(current, total)
    local remaining = total - current
    if remaining <= 0 then return "Complete!" end
    
    local currentDungeon = nil
    local mapID = C_Map.GetBestMapForUnit("player")
    
    -- Map the current mapID to one of our defined dungeons
    -- This would need real mapIDs in a working addon
    for dungeonKey, _ in pairs(enemyValues) do
        -- Logic to determine the current dungeon based on mapID
        -- This is a placeholder for the actual implementation
        if mapID and mapID > 0 then
            -- Just using a sample dungeon for demonstration
            currentDungeon = enemyValues["DOTI-MurozondsRise"]
            break
        end
    end
    
    if not currentDungeon then return "Unknown dungeon" end
    
    -- Find combinations of enemies that could get to 100% with minimal overpull
    local bestPull = {}
    local bestOverpull = 999
    local importantEnemies = currentDungeon.importantEnemies
    
    -- Simple greedy algorithm for suggestion (would be more sophisticated in real implementation)
    for enemyName, value in pairs(importantEnemies) do
        if value > 0 and remaining <= value + 10 then
            local overpull = value - remaining
            if overpull >= 0 and overpull < bestOverpull then
                bestOverpull = overpull
                bestPull = {enemyName}
            end
        end
    end
    
    -- Return suggested pull
    if #bestPull > 0 then
        return "Suggested: " .. table.concat(bestPull, ", ")
    else
        local percentRemaining = math.floor((remaining / total) * 100 + 0.5)
        return percentRemaining .. "% remaining"
    end
end

-- Enhance the progress tracker with additional information
function ProgressEnhancement:EnhanceProgressTracker(block)
    if not block then return end
    
    -- Apply theme if needed
    if GetConfig("useVUITheme") and AngryKeystones.ThemeIntegration then
        AngryKeystones.ThemeIntegration:ApplyThemeToEnemyForces(block)
    end
    
    -- Get progress information
    local bar = block.ProgressBar
    if not bar then return end
    
    local current, total = bar:GetValue(), select(2, bar:GetMinMaxValues())
    
    -- Create or update the detailed progress information
    if not block.EnhancedInfo then
        -- Create new frame for enhanced info
        block.EnhancedInfo = CreateFrame("Frame", nil, block)
        block.EnhancedInfo:SetPoint("TOPLEFT", block, "BOTTOMLEFT", 0, -5)
        block.EnhancedInfo:SetPoint("TOPRIGHT", block, "BOTTOMRIGHT", 0, -5)
        block.EnhancedInfo:SetHeight(40)
        
        -- Theme the frame
        if GetConfig("useVUITheme") and AngryKeystones.ThemeIntegration then
            AngryKeystones.ThemeIntegration:ApplyThemeToFrame(block.EnhancedInfo)
        end
        
        -- Create detail text
        block.EnhancedInfo.Detail = block.EnhancedInfo:CreateFontString(nil, "OVERLAY")
        block.EnhancedInfo.Detail:SetPoint("TOPLEFT", block.EnhancedInfo, "TOPLEFT", 5, -5)
        block.EnhancedInfo.Detail:SetPoint("TOPRIGHT", block.EnhancedInfo, "TOPRIGHT", -5, -5)
        local font = VUI:GetFont("expressway")
        block.EnhancedInfo.Detail:SetFont(font, 12, "OUTLINE")
        
        -- Create suggestion text
        block.EnhancedInfo.Suggestion = block.EnhancedInfo:CreateFontString(nil, "OVERLAY")
        block.EnhancedInfo.Suggestion:SetPoint("TOPLEFT", block.EnhancedInfo.Detail, "BOTTOMLEFT", 0, -5)
        block.EnhancedInfo.Suggestion:SetPoint("TOPRIGHT", block.EnhancedInfo.Detail, "BOTTOMRIGHT", 0, -5)
        block.EnhancedInfo.Suggestion:SetFont(font, 10, "OUTLINE")
        
        -- Apply text color
        if GetConfig("useVUITheme") and AngryKeystones.ThemeIntegration then
            local colors = AngryKeystones.ThemeIntegration:GetThemeColors()
            block.EnhancedInfo.Detail:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
            block.EnhancedInfo.Suggestion:SetTextColor(colors.highlight[1], colors.highlight[2], colors.highlight[3], 1)
        end
    end
    
    -- Update the text
    block.EnhancedInfo.Detail:SetText("Enemy Forces: " .. FormatEnemyCount(current, total))
    block.EnhancedInfo.Suggestion:SetText(CalculateOptimalPull(current, total))
    
    -- Show or hide based on settings
    if GetConfig("showEnemyCounter") then
        block.EnhancedInfo:Show()
    else
        block.EnhancedInfo:Hide()
    end
end

-- Hook the ScenarioObjectiveBlock to update our enhanced display
function ProgressEnhancement:SetupHooks()
    if not ScenarioObjectiveBlock_UpdateProgressBar then return end
    
    -- Only set up once
    if self.hooked then return end
    
    -- Hook the progress bar update function
    hooksecurefunc("ScenarioObjectiveBlock_UpdateProgressBar", function(block)
        if AngryKeystones.enabled and block and block.ProgressBar then
            -- If this is an enemy forces progress bar
            local blockType = block.questLogIndex and C_QuestLog.GetQuestType(block.questLogIndex)
            if blockType == Enum.QuestType.Monster then
                self:EnhanceProgressTracker(block)
            end
        end
    end)
    
    self.hooked = true
end

-- Initialize the progress enhancement
function ProgressEnhancement:Initialize()
    self:SetupHooks()
    
    -- Register for theme changes
    VUI:RegisterCallback("ThemeChanged", function()
        if AngryKeystones.enabled and AngryKeystones.enemyForcesFrame then
            self:EnhanceProgressTracker(AngryKeystones.enemyForcesFrame)
        end
    end)
    
    -- Debug disabled in production release
end
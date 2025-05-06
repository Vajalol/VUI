-------------------------------------------------------------------------------
-- Title: VUI Premade Group Finder Rating Visualization
-- Author: VortexQ8
-- Visual group rating system for premade group finder
-------------------------------------------------------------------------------

local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local PGF = VUI.modules.premadegroupfinder or {}

-- Skip if premadegroupfinder module is not available
if not PGF then return end

-- Create the rating visualization namespace
PGF.RatingVisualization = {}
local RV = PGF.RatingVisualization

-- Initialize rating visualization
function RV:Initialize()
    self.isEnabled = PGF.settings.advanced.showScores
    
    -- Register for events
    if self.isEnabled then
        self:RegisterHooks()
    end
end

-- Register necessary hooks
function RV:RegisterHooks()
    -- Hook into search entry updates
    if _G.LFGListSearchEntry_Update then
        hooksecurefunc("LFGListSearchEntry_Update", function(button)
            if self.isEnabled then
                self:ApplyRatingVisualization(button)
            end
        end)
    end
    
    -- Hook into tooltip function
    if _G.LFGListUtil_SetSearchEntryTooltip then
        hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", function(tooltip, resultID)
            if self.isEnabled then
                self:AddScoreToTooltip(tooltip, resultID)
            end
        end)
    end
    
    -- Hook into applicant display
    if _G.LFGListApplicationViewer_UpdateApplicantMember then
        hooksecurefunc("LFGListApplicationViewer_UpdateApplicantMember", function(member, applicantInfo, memberIdx)
            if self.isEnabled then
                self:ApplyApplicantRating(member, applicantInfo, memberIdx)
            end
        end)
    end
end

-- Apply rating visualization to a search entry
function RV:ApplyRatingVisualization(button)
    if not button or not button.resultID then return end
    
    local resultID = button.resultID
    local score = PGF.AdvancedFiltering and PGF.AdvancedFiltering:GetLeaderScore(resultID) or self:CalculateScore(resultID)
    
    -- Create score display if it doesn't exist
    if not button.VUIScore then
        button.VUIScore = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        button.VUIScore:SetPoint("TOPRIGHT", button.Name, "TOPLEFT", -5, 0)
        button.VUIScore:SetJustifyH("RIGHT")
        
        -- Create score icon
        button.VUIScoreIcon = button:CreateTexture(nil, "OVERLAY")
        button.VUIScoreIcon:SetSize(16, 16)
        button.VUIScoreIcon:SetPoint("RIGHT", button.VUIScore, "LEFT", -2, 0)
        
        -- Create score background
        button.VUIScoreBg = button:CreateTexture(nil, "BACKGROUND")
        button.VUIScoreBg:SetPoint("TOPLEFT", button.VUIScoreIcon, "TOPLEFT", -2, 2)
        button.VUIScoreBg:SetPoint("BOTTOMRIGHT", button.VUIScore, "BOTTOMRIGHT", 2, -2)
        button.VUIScoreBg:SetColorTexture(0, 0, 0, 0.4)
    end
    
    -- Update score display
    if score > 0 then
        button.VUIScore:SetText(score)
        button.VUIScore:Show()
        button.VUIScoreIcon:Show()
        button.VUIScoreBg:Show()
        
        -- Set color based on score
        local r, g, b = self:GetScoreColor(score)
        button.VUIScore:SetTextColor(r, g, b)
        
        -- Set icon based on score
        local iconPath = self:GetScoreIcon(score)
        button.VUIScoreIcon:SetTexture(iconPath)
        
        -- Adjust layout to make room for score display
        if button.ActivityName then
            button.ActivityName:SetPoint("TOPLEFT", button.Name, "BOTTOMLEFT", 0, -2)
        end
    else
        button.VUIScore:Hide()
        button.VUIScoreIcon:Hide()
        button.VUIScoreBg:Hide()
        
        -- Restore original layout
        if button.ActivityName then
            button.ActivityName:SetPoint("TOPLEFT", button.Name, "BOTTOMLEFT", 0, -2)
        end
    end
    
    -- Add success prediction indicator
    self:AddSuccessPrediction(button, resultID)
end

-- Add success prediction indicator to entry
function RV:AddSuccessPrediction(button, resultID)
    if not button or not resultID or not PGF.settings.advanced.showPredictedSuccess then return end
    
    local successChance = self:CalculateSuccessChance(resultID)
    
    -- Create success chance indicator if it doesn't exist
    if not button.VUISuccessChance then
        button.VUISuccessChance = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        button.VUISuccessChance:SetPoint("BOTTOMRIGHT", -5, 5)
        
        -- Create icon
        button.VUISuccessIcon = button:CreateTexture(nil, "OVERLAY")
        button.VUISuccessIcon:SetSize(16, 16)
        button.VUISuccessIcon:SetPoint("RIGHT", button.VUISuccessChance, "LEFT", -2, 0)
    end
    
    -- Update success chance display
    if successChance > 0 then
        button.VUISuccessChance:SetText(string.format("%.0f%%", successChance))
        button.VUISuccessChance:Show()
        button.VUISuccessIcon:Show()
        
        -- Set color based on success chance
        local r, g, b = self:GetSuccessColor(successChance)
        button.VUISuccessChance:SetTextColor(r, g, b)
        
        -- Set icon based on success chance
        if successChance >= 80 then
            button.VUISuccessIcon:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
        elseif successChance >= 50 then
            button.VUISuccessIcon:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Waiting")
        else
            button.VUISuccessIcon:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
        end
    else
        button.VUISuccessChance:Hide()
        button.VUISuccessIcon:Hide()
    end
end

-- Calculate a score for a search result
function RV:CalculateScore(resultID)
    local info = C_LFGList.GetSearchResultInfo(resultID)
    if not info then return 0 end
    
    -- Look for leader's score (this is where an integration with Raider.IO would occur)
    -- For now, return a placeholder value based on the activity's difficulty
    local activityInfo = C_LFGList.GetActivityInfoTable(info.activityID)
    if not activityInfo then return 0 end
    
    -- Base score on the dungeon/raid level
    local difficultyLevel = 0
    
    -- Parse activity name to extract M+ level
    local activityName = activityInfo.fullName or ""
    local keyLevel = activityName:match("+(%d+)")
    
    if keyLevel then
        difficultyLevel = tonumber(keyLevel) or 0
    elseif activityInfo.categoryID == 2 then -- Dungeons
        -- Approximate based on difficulty
        if activityInfo.shortName:find("Heroic") then
            difficultyLevel = 5
        elseif activityInfo.shortName:find("Mythic") then
            difficultyLevel = 10
        else
            difficultyLevel = 2
        end
    elseif activityInfo.categoryID == 3 then -- Raids
        -- Approximate based on difficulty
        if activityInfo.shortName:find("LFR") then
            difficultyLevel = 5
        elseif activityInfo.shortName:find("Normal") then
            difficultyLevel = 10
        elseif activityInfo.shortName:find("Heroic") then
            difficultyLevel = 15
        elseif activityInfo.shortName:find("Mythic") then
            difficultyLevel = 20
        end
    end
    
    -- Convert to an approximate score
    local score = difficultyLevel * 50
    
    -- Add leader bonus
    score = score + 200
    
    -- Item level bonus
    if info.requiredItemLevel > 0 then
        score = score + ((info.requiredItemLevel - 400) * 2)
    end
    
    return math.floor(score)
end

-- Calculate success chance for a group
function RV:CalculateSuccessChance(resultID)
    local info = C_LFGList.GetSearchResultInfo(resultID)
    if not info then return 0 end
    
    -- Get leader's score
    local leaderScore = PGF.AdvancedFiltering and PGF.AdvancedFiltering:GetLeaderScore(resultID) or self:CalculateScore(resultID)
    
    -- Base success chance on score
    local baseChance = 0
    
    if leaderScore >= PGF.settings.ratingVisualization.thresholds.exceptional then
        baseChance = 90
    elseif leaderScore >= PGF.settings.ratingVisualization.thresholds.high then
        baseChance = 80
    elseif leaderScore >= PGF.settings.ratingVisualization.thresholds.medium then
        baseChance = 65
    elseif leaderScore >= PGF.settings.ratingVisualization.thresholds.low then
        baseChance = 50
    else
        baseChance = 35
    end
    
    -- Adjust based on group composition
    local neededRoles = 0
    if info.tanks and info.tanks.needed > 0 then neededRoles = neededRoles + 1 end
    if info.healers and info.healers.needed > 0 then neededRoles = neededRoles + 1 end
    if info.dps and info.dps.needed > 0 then neededRoles = neededRoles + 1 end
    
    -- Penalty for missing roles
    local rolePenalty = neededRoles * 5
    
    -- Adjust for voice chat (bonus for having voice)
    local voiceBonus = info.voiceChat and info.voiceChat ~= "" and 5 or 0
    
    -- Adjust for activity type
    local activityInfo = C_LFGList.GetActivityInfoTable(info.activityID)
    local activityPenalty = 0
    
    if activityInfo then
        -- Mythic keystones get easier with more people
        local activityName = activityInfo.fullName or ""
        local keyLevel = activityName:match("+(%d+)")
        
        if keyLevel then
            keyLevel = tonumber(keyLevel) or 0
            -- Higher keys have more risk
            if keyLevel >= 15 then
                activityPenalty = 15
            elseif keyLevel >= 10 then
                activityPenalty = 10
            elseif keyLevel >= 5 then
                activityPenalty = 5
            end
        end
    end
    
    -- Calculate final chance
    local successChance = baseChance - rolePenalty + voiceBonus - activityPenalty
    
    -- Clamp to valid range
    return math.max(1, math.min(99, successChance))
end

-- Get color based on score
function RV:GetScoreColor(score)
    local thresholds = PGF.settings.ratingVisualization.thresholds
    local colors = PGF.settings.ratingVisualization.colors
    
    if score >= thresholds.exceptional then
        return colors.exceptional.r, colors.exceptional.g, colors.exceptional.b
    elseif score >= thresholds.high then
        return colors.high.r, colors.high.g, colors.high.b
    elseif score >= thresholds.medium then
        return colors.medium.r, colors.medium.g, colors.medium.b
    elseif score >= thresholds.low then
        return colors.low.r, colors.low.g, colors.low.b
    else
        -- Default color for low scores
        return 0.7, 0.7, 0.7
    end
end

-- Get success chance color
function RV:GetSuccessColor(chance)
    if chance >= 80 then
        return 0, 1, 0
    elseif chance >= 60 then
        return 1, 1, 0
    elseif chance >= 40 then
        return 1, 0.5, 0
    else
        return 1, 0, 0
    end
end

-- Get icon based on score
function RV:GetScoreIcon(score)
    local thresholds = PGF.settings.ratingVisualization.thresholds
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Base path for theme icons
    local iconPath = string.format("Interface\\Addons\\VUI\\media\\textures\\%s\\premadegroupfinder\\rating_", currentTheme)
    
    if score >= thresholds.exceptional then
        return iconPath .. "exceptional.tga"
    elseif score >= thresholds.high then
        return iconPath .. "high.tga"
    elseif score >= thresholds.medium then
        return iconPath .. "medium.tga"
    elseif score >= thresholds.low then
        return iconPath .. "low.tga"
    else
        -- Default icon for low scores
        return iconPath .. "poor.tga"
    end
end

-- Add score information to tooltip
function RV:AddScoreToTooltip(tooltip, resultID)
    if not tooltip or not resultID or not PGF.settings.ratingVisualization.showScoreTooltips then return end
    
    local info = C_LFGList.GetSearchResultInfo(resultID)
    if not info then return end
    
    -- Get scores
    local leaderScore = PGF.AdvancedFiltering and PGF.AdvancedFiltering:GetLeaderScore(resultID) or self:CalculateScore(resultID)
    local averageScore = PGF.AdvancedFiltering and PGF.AdvancedFiltering:GetAverageGroupScore(resultID) or math.floor(leaderScore * 0.9)
    local successChance = PGF.settings.advanced.showPredictedSuccess and self:CalculateSuccessChance(resultID) or 0
    
    -- Add header
    tooltip:AddLine(" ")
    tooltip:AddLine("VUI Rating Information", 1, 1, 1)
    
    -- Add leader score
    local r, g, b = self:GetScoreColor(leaderScore)
    tooltip:AddDoubleLine("Leader Score:", leaderScore, 1, 1, 1, r, g, b)
    
    -- Add average score
    r, g, b = self:GetScoreColor(averageScore)
    tooltip:AddDoubleLine("Group Score:", averageScore, 1, 1, 1, r, g, b)
    
    -- Add success chance
    if successChance > 0 then
        r, g, b = self:GetSuccessColor(successChance)
        tooltip:AddDoubleLine("Success Chance:", string.format("%.0f%%", successChance), 1, 1, 1, r, g, b)
    end
    
    -- Add score details for this activity
    local activityInfo = C_LFGList.GetActivityInfoTable(info.activityID)
    if activityInfo then
        local activityName = activityInfo.fullName or ""
        local keyLevel = activityName:match("+(%d+)")
        
        if keyLevel then
            -- Add mythic+ information
            tooltip:AddLine(" ")
            tooltip:AddLine("Mythic+ Details:", 1, 1, 1)
            
            -- Timed runs for this group leader
            local timedRuns = math.floor(leaderScore / 100)
            tooltip:AddDoubleLine("Estimated Timed Runs:", timedRuns, 1, 1, 1, 1, 1, 1)
            
            -- Expected completion time
            local keyDifficulty = tonumber(keyLevel) or 0
            local baseTime = 30 -- Base time in minutes
            local timePerLevel = 2 -- Additional minutes per key level
            local completionTime = baseTime + (keyDifficulty * timePerLevel)
            
            tooltip:AddDoubleLine("Expected Duration:", string.format("%d-%d minutes", completionTime - 5, completionTime + 5), 1, 1, 1, 1, 1, 1)
        end
    end
    
    -- Show tooltip
    tooltip:Show()
end

-- Apply rating to applicant member frame
function RV:ApplyApplicantRating(member, applicantInfo, memberIdx)
    if not member or not applicantInfo then return end
    
    -- Calculate approximate score based on applicant data
    local score = self:CalculateApplicantScore(applicantInfo, memberIdx)
    
    -- Create score display if it doesn't exist
    if not member.VUIScore then
        member.VUIScore = member:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        member.VUIScore:SetPoint("TOPRIGHT", member, "TOPRIGHT", -20, -2)
        
        -- Create score icon
        member.VUIScoreIcon = member:CreateTexture(nil, "OVERLAY")
        member.VUIScoreIcon:SetSize(16, 16)
        member.VUIScoreIcon:SetPoint("RIGHT", member.VUIScore, "LEFT", -2, 0)
        
        -- Create score background
        member.VUIScoreBg = member:CreateTexture(nil, "BACKGROUND")
        member.VUIScoreBg:SetPoint("TOPLEFT", member.VUIScoreIcon, "TOPLEFT", -2, 2)
        member.VUIScoreBg:SetPoint("BOTTOMRIGHT", member.VUIScore, "BOTTOMRIGHT", 2, -2)
        member.VUIScoreBg:SetColorTexture(0, 0, 0, 0.4)
    end
    
    -- Update score display
    if score > 0 then
        member.VUIScore:SetText(score)
        member.VUIScore:Show()
        member.VUIScoreIcon:Show()
        member.VUIScoreBg:Show()
        
        -- Set color based on score
        local r, g, b = self:GetScoreColor(score)
        member.VUIScore:SetTextColor(r, g, b)
        
        -- Set icon based on score
        local iconPath = self:GetScoreIcon(score)
        member.VUIScoreIcon:SetTexture(iconPath)
    else
        member.VUIScore:Hide()
        member.VUIScoreIcon:Hide()
        member.VUIScoreBg:Hide()
    end
end

-- Calculate score for an applicant
function RV:CalculateApplicantScore(applicantInfo, memberIdx)
    if not applicantInfo then return 0 end
    
    local member = applicantInfo.applicantInfo.members[memberIdx]
    if not member then return 0 end
    
    -- Base score on role and item level
    local score = 0
    local itemLevel = member.itemLevel or 0
    
    -- Baseline score based on item level
    if itemLevel > 0 then
        score = math.floor((itemLevel - 400) * 3)
    end
    
    -- Role bonus
    if member.role == "TANK" then
        score = score + 100
    elseif member.role == "HEALER" then
        score = score + 75
    elseif member.role == "DAMAGER" then
        score = score + 50
    end
    
    -- Class and spec bonus (would need to be expanded with all spec IDs)
    local classID = member.classID
    local specID = member.specID
    
    -- Certain classes/specs are historically better for M+
    local tierClasses = {
        [8] = 50,  -- Mage
        [11] = 40, -- Druid
        [12] = 30, -- Demon Hunter
    }
    
    if tierClasses[classID] then
        score = score + tierClasses[classID]
    end
    
    -- Addition info that could be integrated from Raider.IO or similar
    -- This would include actual M+ score, previous season rating, etc.
    
    return math.max(0, score)
end

-- Enable rating visualization
function RV:Enable()
    self.isEnabled = true
    self:RegisterHooks()
end

-- Disable rating visualization
function RV:Disable()
    self.isEnabled = false
end
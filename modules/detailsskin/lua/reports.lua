local _, VUI = ...
local DS = VUI.detailsskin or {}
VUI.detailsskin = DS

-- Local references for performance
local _G = _G
local Details = _G.Details
local format = string.format
local gsub = string.gsub
local ceil = math.ceil
local floor = math.floor

-- Report formatting functions
DS.Reports = {}

-- Template variables
local PLAYER = "|c%s%s|r"    -- Player name with class color
local VALUE = "|cffffffff%s|r"   -- Value in white
local PERCENT = "|cffffffff%.1f%%|r"  -- Percentage in white
local SEPARATOR = " • "      -- Separator between elements

-- Message header templates for each theme
DS.Reports.HeaderTemplates = {
    phoenixflame = "|cFFE64D0D« |r|cFFFFD0A0%s|r|cFFE64D0D »|r",
    thunderstorm = "|cFF0D9DE6« |r|cFFD0E8FF%s|r|cFF0D9DE6 »|r",
    arcanemystic = "|cFF9D0DE6« |r|cFFE0D0FF%s|r|cFF9D0DE6 »|r",
    felenergy = "|cFF1AFF1A« |r|cFFD0FFD0%s|r|cFF1AFF1A »|r"
}

-- Default header template
DS.Reports.DefaultHeader = "|cFFFFFFFF« %s »|r"

-- Initialize custom report templates
function DS.Reports:Initialize()
    if not Details then
        return false
    end
    
    -- Register custom report templates
    self:RegisterDamageTemplate()
    self:RegisterHealingTemplate()
    self:RegisterDeathsTemplate()
    self:RegisterInterruptsTemplate()
    self:RegisterDispelsTemplate()
    
    return true
end

-- Format player name with class color
function DS.Reports:FormatPlayerName(playerName, class)
    local classColor = Details:GetClassColor(class) or "FFFFFFFF"
    return format(PLAYER, classColor, playerName)
end

-- Format a number value (shortening if needed)
function DS.Reports:FormatNumber(value)
    return format(VALUE, Details:ToK(value))
end

-- Format a percentage value
function DS.Reports:FormatPercent(value)
    return format(PERCENT, value)
end

-- Get the appropriate header template for the current theme
function DS.Reports:GetHeaderTemplate()
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    return self.HeaderTemplates[theme] or self.DefaultHeader
end

-- Register custom damage report template
function DS.Reports:RegisterDamageTemplate()
    local damageTemplate = function(reportData)
        -- Check if data is valid
        if not reportData or not reportData.playerData then
            return Details:GetReportFunc()(reportData) -- Fall back to default
        end
        
        local reportLines = {}
        local headerTemplate = self:GetHeaderTemplate()
        
        -- Add report header with themed formatting
        tinsert(reportLines, format(headerTemplate, "Damage Done"))
        
        -- Add each player's data
        for i = 1, #reportData.playerData do
            local playerTable = reportData.playerData[i]
            local playerInfo = playerTable[1] -- Contains player name, class, etc.
            local playerTotal = playerTable[2] -- Total damage
            local playerPercent = playerTable[3] -- Damage percentage
            
            -- Build the player line with theme-specific formatting
            local playerLine = self:FormatPlayerName(playerInfo[1], playerInfo[2]) -- Name with class color
            playerLine = playerLine .. SEPARATOR .. self:FormatNumber(playerTotal) -- Add damage value
            playerLine = playerLine .. " (" .. self:FormatPercent(playerPercent) .. ")" -- Add percentage
            
            -- Add DPS if available
            if playerTable[4] then
                playerLine = playerLine .. SEPARATOR .. self:FormatNumber(playerTable[4]) .. " DPS"
            end
            
            -- Add the line to the report
            tinsert(reportLines, playerLine)
        end
        
        -- Return the formatted report
        return reportLines
    end
    
    -- Register this template with Details
    Details:RegisterReportTemplate("VUI Damage Template", damageTemplate)
    
    -- Set this as the default template for damage if configured
    if VUI.db.profile.modules.detailsskin.useCustomTemplates then
        Details:SetReportTemplate("damage", "VUI Damage Template")
    end
end

-- Register custom healing report template
function DS.Reports:RegisterHealingTemplate()
    local healingTemplate = function(reportData)
        -- Check if data is valid
        if not reportData or not reportData.playerData then
            return Details:GetReportFunc()(reportData) -- Fall back to default
        end
        
        local reportLines = {}
        local headerTemplate = self:GetHeaderTemplate()
        
        -- Add report header with themed formatting
        tinsert(reportLines, format(headerTemplate, "Healing Done"))
        
        -- Add each player's data
        for i = 1, #reportData.playerData do
            local playerTable = reportData.playerData[i]
            local playerInfo = playerTable[1] -- Contains player name, class, etc.
            local playerTotal = playerTable[2] -- Total healing
            local playerPercent = playerTable[3] -- Healing percentage
            
            -- Build the player line with theme-specific formatting
            local playerLine = self:FormatPlayerName(playerInfo[1], playerInfo[2]) -- Name with class color
            playerLine = playerLine .. SEPARATOR .. self:FormatNumber(playerTotal) -- Add healing value
            playerLine = playerLine .. " (" .. self:FormatPercent(playerPercent) .. ")" -- Add percentage
            
            -- Add HPS if available
            if playerTable[4] then
                playerLine = playerLine .. SEPARATOR .. self:FormatNumber(playerTable[4]) .. " HPS"
            end
            
            -- Add overheal percentage if available
            if playerTable[5] then
                playerLine = playerLine .. SEPARATOR .. format("%.1f%% overheal", playerTable[5])
            end
            
            -- Add the line to the report
            tinsert(reportLines, playerLine)
        end
        
        -- Return the formatted report
        return reportLines
    end
    
    -- Register this template with Details
    Details:RegisterReportTemplate("VUI Healing Template", healingTemplate)
    
    -- Set this as the default template for healing if configured
    if VUI.db.profile.modules.detailsskin.useCustomTemplates then
        Details:SetReportTemplate("healing", "VUI Healing Template")
    end
end

-- Register custom deaths report template
function DS.Reports:RegisterDeathsTemplate()
    local deathsTemplate = function(reportData)
        -- Check if data is valid
        if not reportData or not reportData.playerData then
            return Details:GetReportFunc()(reportData) -- Fall back to default
        end
        
        local reportLines = {}
        local headerTemplate = self:GetHeaderTemplate()
        
        -- Add report header with themed formatting
        tinsert(reportLines, format(headerTemplate, "Deaths"))
        
        -- Add each death entry
        for i = 1, #reportData.playerData do
            local deathInfo = reportData.playerData[i]
            
            -- Format the death information
            local playerName = deathInfo[1]
            local playerClass = deathInfo[2]
            local deathTime = deathInfo[3]
            local deathCause = deathInfo[4]
            local lastEvents = deathInfo[5]
            
            -- Create the death header
            local deathHeader = self:FormatPlayerName(playerName, playerClass)
            deathHeader = deathHeader .. SEPARATOR .. "died at " .. deathTime
            if deathCause then
                deathHeader = deathHeader .. SEPARATOR .. "from " .. deathCause
            end
            
            -- Add the death header to the report
            tinsert(reportLines, deathHeader)
            
            -- Add the last events before death if available
            if lastEvents and #lastEvents > 0 then
                tinsert(reportLines, "Last events:")
                
                for j = 1, math.min(#lastEvents, 5) do -- Show up to 5 events
                    local event = lastEvents[j]
                    local time = event[1]
                    local eventType = event[2]
                    local source = event[3]
                    local spellName = event[4]
                    local amount = event[5]
                    
                    local eventLine = format("  %.1fs: %s", time, eventType)
                    
                    if source then
                        eventLine = eventLine .. " from " .. source
                    end
                    
                    if spellName then
                        eventLine = eventLine .. " (" .. spellName .. ")"
                    end
                    
                    if amount then
                        eventLine = eventLine .. SEPARATOR .. self:FormatNumber(amount)
                    end
                    
                    tinsert(reportLines, eventLine)
                end
            end
            
            -- Add a blank line between deaths
            if i < #reportData.playerData then
                tinsert(reportLines, " ")
            end
        end
        
        -- Return the formatted report
        return reportLines
    end
    
    -- Register this template with Details
    Details:RegisterReportTemplate("VUI Deaths Template", deathsTemplate)
    
    -- Set this as the default template for deaths if configured
    if VUI.db.profile.modules.detailsskin.useCustomTemplates then
        Details:SetReportTemplate("deaths", "VUI Deaths Template")
    end
end

-- Register custom interrupts report template
function DS.Reports:RegisterInterruptsTemplate()
    local interruptsTemplate = function(reportData)
        -- Check if data is valid
        if not reportData or not reportData.playerData then
            return Details:GetReportFunc()(reportData) -- Fall back to default
        end
        
        local reportLines = {}
        local headerTemplate = self:GetHeaderTemplate()
        
        -- Add report header with themed formatting
        tinsert(reportLines, format(headerTemplate, "Interrupts"))
        
        -- Add each player's data
        for i = 1, #reportData.playerData do
            local playerTable = reportData.playerData[i]
            local playerInfo = playerTable[1] -- Contains player name, class, etc.
            local interruptCount = playerTable[2] -- Number of interrupts
            
            -- Build the player line with theme-specific formatting
            local playerLine = self:FormatPlayerName(playerInfo[1], playerInfo[2]) -- Name with class color
            playerLine = playerLine .. SEPARATOR .. interruptCount .. " interrupts"
            
            -- Add percentage if available
            if playerTable[3] then
                playerLine = playerLine .. " (" .. self:FormatPercent(playerTable[3]) .. ")"
            end
            
            -- Add the line to the report
            tinsert(reportLines, playerLine)
        end
        
        -- Return the formatted report
        return reportLines
    end
    
    -- Register this template with Details
    Details:RegisterReportTemplate("VUI Interrupts Template", interruptsTemplate)
    
    -- Set this as the default template for interrupts if configured
    if VUI.db.profile.modules.detailsskin.useCustomTemplates then
        Details:SetReportTemplate("interrupt", "VUI Interrupts Template")
    end
end

-- Register custom dispels report template
function DS.Reports:RegisterDispelsTemplate()
    local dispelsTemplate = function(reportData)
        -- Check if data is valid
        if not reportData or not reportData.playerData then
            return Details:GetReportFunc()(reportData) -- Fall back to default
        end
        
        local reportLines = {}
        local headerTemplate = self:GetHeaderTemplate()
        
        -- Add report header with themed formatting
        tinsert(reportLines, format(headerTemplate, "Dispels"))
        
        -- Add each player's data
        for i = 1, #reportData.playerData do
            local playerTable = reportData.playerData[i]
            local playerInfo = playerTable[1] -- Contains player name, class, etc.
            local dispelCount = playerTable[2] -- Number of dispels
            
            -- Build the player line with theme-specific formatting
            local playerLine = self:FormatPlayerName(playerInfo[1], playerInfo[2]) -- Name with class color
            playerLine = playerLine .. SEPARATOR .. dispelCount .. " dispels"
            
            -- Add percentage if available
            if playerTable[3] then
                playerLine = playerLine .. " (" .. self:FormatPercent(playerTable[3]) .. ")"
            end
            
            -- Add the line to the report
            tinsert(reportLines, playerLine)
        end
        
        -- Return the formatted report
        return reportLines
    end
    
    -- Register this template with Details
    Details:RegisterReportTemplate("VUI Dispels Template", dispelsTemplate)
    
    -- Set this as the default template for dispels if configured
    if VUI.db.profile.modules.detilsskin.useCustomTemplates then
        Details:SetReportTemplate("dispel", "VUI Dispels Template")
    end
end
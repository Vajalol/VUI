local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()
local P = VUICD.Party

-- Local variables
local partyFrames = {}
local activeMembers = {}
local activeSpells = {}
local isEnabled = false
local testMode = false

-- Initialize the Party module
function P:Initialize()
    -- Create main container frame
    self.container = CreateFrame("Frame", "VUICD_PartyContainer", UIParent)
    self.container:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    self.container:SetSize(200, 100)
    self.container:Hide()
    
    -- Initialize settings
    self.db = VUICD:GetPartySettings()
    
    -- Initialize spells
    if VUICD.Cooldowns and VUICD.Cooldowns.Initialize then
        VUICD.Cooldowns:Initialize()
    end
    
    -- Register events
    self.container:SetScript("OnEvent", function(_, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end)
    
    self.container:RegisterEvent("GROUP_ROSTER_UPDATE")
    self.container:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Initialize visibility
    self:UpdateVisibility(VUICD.instanceType)
end

-- Enable the Party module
function P:Enable()
    if isEnabled then return end
    isEnabled = true
    
    self.container:Show()
    self:UpdateRoster()
end

-- Disable the Party module
function P:Disable()
    if not isEnabled then return end
    isEnabled = false
    
    self.container:Hide()
    self:ClearFrames()
end

-- Update module visibility based on instance type
function P:UpdateVisibility(instanceType)
    local shouldShow = false
    
    if testMode and self.db.visibility.inTest then
        shouldShow = true
    elseif instanceType == "arena" then
        shouldShow = self.db.visibility.arena
    elseif instanceType == "raid" then
        shouldShow = self.db.visibility.raid
    elseif instanceType == "party" then
        shouldShow = self.db.visibility.party
    elseif instanceType == "scenario" then
        shouldShow = self.db.visibility.scenario
    elseif instanceType == "none" then
        shouldShow = self.db.visibility.none
    else
        shouldShow = self.db.visibility.outside
    end
    
    if shouldShow and self.db.enabled then
        self:Enable()
    else
        self:Disable()
    end
end

-- Update the roster when group composition changes
function P:UpdateRoster()
    if not isEnabled then return end
    
    -- Clear current frames
    self:ClearFrames()
    
    -- Check if we're in a group
    if not IsInGroup() and not testMode then
        return
    end
    
    -- Build active member list
    self:BuildMemberList()
    
    -- Create frames for each member
    self:CreateMemberFrames()
    
    -- Update cooldown data
    self:UpdateCooldowns()
end

-- Build list of active group members
function P:BuildMemberList()
    wipe(activeMembers)
    
    if testMode then
        -- Add test players
        table.insert(activeMembers, {name = "TestWarrior", class = "WARRIOR", unit = "player"})
        table.insert(activeMembers, {name = "TestPaladin", class = "PALADIN", unit = "player"})
        table.insert(activeMembers, {name = "TestHunter", class = "HUNTER", unit = "player"})
        table.insert(activeMembers, {name = "TestRogue", class = "ROGUE", unit = "player"})
        table.insert(activeMembers, {name = "TestPriest", class = "PRIEST", unit = "player"})
    else
        -- Add actual group members
        local prefix = IsInRaid() and "raid" or "party"
        local numMembers = IsInRaid() and GetNumGroupMembers() or GetNumGroupMembers() - 1
        
        -- Add player
        local playerName = UnitName("player")
        local _, playerClass = UnitClass("player")
        table.insert(activeMembers, {name = playerName, class = playerClass, unit = "player"})
        
        -- Add group members
        for i = 1, numMembers do
            local unit = prefix .. i
            if UnitExists(unit) then
                local name = UnitName(unit)
                local _, class = UnitClass(unit)
                table.insert(activeMembers, {name = name, class = class, unit = unit})
            end
        end
    end
end

-- Create frames for each member
function P:CreateMemberFrames()
    if #activeMembers == 0 then return end
    
    -- Get settings
    local settings = self.db
    
    -- Determine frame size based on settings
    local frameHeight = 25 -- Default height
    local frameWidth = 160 -- Default width
    
    -- Create frames for each member
    for i, member in ipairs(activeMembers) do
        -- Create or reuse frame
        local frame = partyFrames[i]
        if not frame then
            frame = CreateFrame("Frame", "VUICD_PartyMember" .. i, self.container, "VUICD_PartyMemberTemplate")
            partyFrames[i] = frame
        end
        
        -- Set size
        frame:SetSize(frameWidth, frameHeight)
        
        -- Set position - vertical stack
        frame:ClearAllPoints()
        if i == 1 then
            frame:SetPoint("TOPLEFT", self.container, "TOPLEFT", 0, 0)
        else
            frame:SetPoint("TOPLEFT", partyFrames[i-1], "BOTTOMLEFT", 0, -5)
        end
        
        -- Set member info
        frame.unit = member.unit
        frame.name = member.name
        frame.class = member.class
        
        -- Set class icon
        local classCoords = CLASS_ICON_TCOORDS[member.class]
        if classCoords then
            frame.classIcon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
            frame.classIcon:SetTexCoord(unpack(classCoords))
        else
            frame.classIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        end
        
        -- Set name text with class color
        local classColor = RAID_CLASS_COLORS[member.class] or RAID_CLASS_COLORS["PRIEST"]
        frame.nameText:SetText(member.name)
        frame.nameText:SetTextColor(classColor.r, classColor.g, classColor.b)
        
        -- Create cooldown icons
        local iconCount = 0
        if VUICD.Icons then
            iconCount = VUICD.Icons:Initialize(frame.iconContainer, member.unit, member.class)
        end
        
        -- Resize frame based on number of icons
        if iconCount > 0 then
            local spellSettings = settings.icons
            local iconSize = frameHeight * spellSettings.scale
            local padding = spellSettings.padding
            local columns = spellSettings.columns or 10
            local rows = math.ceil(iconCount / columns)
            
            local containerHeight = (rows * (iconSize + padding)) - padding
            frame.iconContainer:SetHeight(containerHeight)
            
            -- Adjust frame height if needed
            frame:SetHeight(frameHeight + containerHeight + 5)
        end
        
        -- Show frame
        frame:Show()
    end
    
    -- Hide unused frames
    for i = #activeMembers + 1, #partyFrames do
        partyFrames[i]:Hide()
    end
    
    -- Resize container
    self:UpdateContainerSize()
end

-- Clear existing frames
function P:ClearFrames()
    for _, frame in pairs(partyFrames) do
        frame:Hide()
    end
    wipe(partyFrames)
end

-- Update container size based on member frames
function P:UpdateContainerSize()
    if #partyFrames == 0 then return end
    
    -- Calculate total height and width
    local totalHeight = 0
    local maxWidth = 0
    
    for i, frame in ipairs(partyFrames) do
        if frame:IsShown() then
            totalHeight = totalHeight + frame:GetHeight()
            
            -- Add spacing between frames
            if i > 1 then
                totalHeight = totalHeight + 5
            end
            
            maxWidth = math.max(maxWidth, frame:GetWidth())
        end
    end
    
    -- Set container size
    self.container:SetSize(maxWidth, totalHeight)
end

-- Update cooldown data
function P:UpdateCooldowns()
    -- Update all cooldown icons
    if VUICD.Icons then
        VUICD.Icons:UpdateCooldowns()
    end
    
    -- Update all highlights
    if VUICD.Party.Highlights then
        VUICD.Party.Highlights:UpdateAll()
    end
end

-- Toggle test mode
function P:Test()
    testMode = not testMode
    self:UpdateVisibility(VUICD.instanceType)
    
    if testMode then
        print("|cff33ff99VUICD|r: Test mode |cff00ff00enabled|r")
    else
        print("|cff33ff99VUICD|r: Test mode |cffff0000disabled|r")
    end
end
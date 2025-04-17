-- VUI UnitFrames Module - Core Functionality
local _, VUI = ...
local UnitFrames = VUI.unitframes
local LSM = LibStub("LibSharedMedia-3.0")

-- Constants
local CLASS_ICONS = {
    ["WARRIOR"] = "Interface\\Icons\\ClassIcon_Warrior",
    ["PALADIN"] = "Interface\\Icons\\ClassIcon_Paladin",
    ["HUNTER"] = "Interface\\Icons\\ClassIcon_Hunter",
    ["ROGUE"] = "Interface\\Icons\\ClassIcon_Rogue",
    ["PRIEST"] = "Interface\\Icons\\ClassIcon_Priest",
    ["DEATHKNIGHT"] = "Interface\\Icons\\ClassIcon_DeathKnight",
    ["SHAMAN"] = "Interface\\Icons\\ClassIcon_Shaman",
    ["MAGE"] = "Interface\\Icons\\ClassIcon_Mage",
    ["WARLOCK"] = "Interface\\Icons\\ClassIcon_Warlock",
    ["MONK"] = "Interface\\Icons\\ClassIcon_Monk",
    ["DRUID"] = "Interface\\Icons\\ClassIcon_Druid",
    ["DEMONHUNTER"] = "Interface\\Icons\\ClassIcon_DemonHunter",
    ["EVOKER"] = "Interface\\Icons\\ClassIcon_Evoker",
}

local POWER_TYPES = {
    [0] = "MANA",
    [1] = "RAGE",
    [2] = "FOCUS",
    [3] = "ENERGY",
    [4] = "COMBO_POINTS",
    [5] = "RUNES",
    [6] = "RUNIC_POWER",
    [7] = "SOUL_SHARDS",
    [8] = "LUNAR_POWER",
    [9] = "HOLY_POWER",
    [10] = "ALTERNATE",
    [11] = "MAELSTROM",
    [12] = "CHI",
    [13] = "INSANITY",
    [14] = "OBSOLETE",
    [15] = "OBSOLETE2",
    [16] = "ARCANE_CHARGES",
    [17] = "FURY",
    [18] = "PAIN",
}

-- Frame creation methods
function UnitFrames:CreateFrames()
    if self.framesCreated then return end
    
    -- Create the main frames
    self:CreatePlayerFrame()
    self:CreateTargetFrame()
    self:CreateFocusFrame()
    self:CreatePetFrame()
    self:CreateTargetTargetFrame()
    self:CreatePartyFrames()
    self:CreateBossFrames()
    self:CreateArenaFrames()
    
    -- Mark as created
    self.framesCreated = true
    
    -- Apply theme
    self:ApplyTheme()
    
    -- Update visibility based on settings
    self:UpdateFrameVisibility()
end

-- Create Player frame
function UnitFrames:CreatePlayerFrame()
    -- Skip if already created
    if self.frames and self.frames.player then return self.frames.player end
    
    -- Initialize frames table if needed
    if not self.frames then self.frames = {} end
    
    -- Get settings
    local settings = self.settings.frames.player
    
    -- Create the main frame
    local frame = self:CreateFrame("VUIPlayerFrame", UIParent)
    frame:SetSize(settings.width, settings.height)
    
    -- Set initial position
    frame:SetPoint(settings.position[1], settings.position[2], settings.position[3], settings.position[4], settings.position[5])
    
    -- Set scale
    frame:SetScale(settings.scale * self.settings.scale)
    
    -- Make frame movable
    self:MakeFrameMovable(frame, "player")
    
    -- Add health bar
    local healthBar = self:CreateHealthBar(frame, "player")
    healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    healthBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    healthBar:SetHeight(settings.height * 0.7)
    
    -- Add power bar
    local powerBar = self:CreatePowerBar(frame, "player")
    powerBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    powerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    powerBar:SetHeight(settings.height * 0.3)
    
    -- Add portrait if enabled
    if self.settings.showPortraits then
        local portrait = self:CreatePortrait(frame, "player")
        portrait:SetSize(settings.height, settings.height)
        portrait:SetPoint("RIGHT", frame, "LEFT", -5, 0)
        frame.Portrait = portrait
    end
    
    -- Add name text
    local nameText = frame:CreateFontString(nil, "OVERLAY")
    nameText:SetPoint("TOP", healthBar, "TOP", 0, -2)
    nameText:SetFont(self:GetFont(), 12, "OUTLINE")
    nameText:SetTextColor(1, 1, 1)
    nameText:SetJustifyH("CENTER")
    frame.Name = nameText
    
    -- Add health text
    local healthText = frame:CreateFontString(nil, "OVERLAY")
    healthText:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
    healthText:SetFont(self:GetFont(), 10, "OUTLINE")
    healthText:SetTextColor(1, 1, 1)
    healthText:SetJustifyH("CENTER")
    frame.Health = healthText
    
    -- Add power text
    local powerText = frame:CreateFontString(nil, "OVERLAY")
    powerText:SetPoint("CENTER", powerBar, "CENTER", 0, 0)
    powerText:SetFont(self:GetFont(), 9, "OUTLINE")
    powerText:SetTextColor(1, 1, 1)
    powerText:SetJustifyH("CENTER")
    frame.Power = powerText
    
    -- Add level text
    local levelText = frame:CreateFontString(nil, "OVERLAY")
    levelText:SetPoint("BOTTOMLEFT", healthBar, "TOPLEFT", 2, 2)
    levelText:SetFont(self:GetFont(), 10, "OUTLINE")
    levelText:SetTextColor(1, 1, 1)
    levelText:SetJustifyH("LEFT")
    frame.Level = levelText
    
    -- Add combat indicator if enabled
    if settings.showCombatIndicator then
        local combatIndicator = frame:CreateTexture(nil, "OVERLAY")
        combatIndicator:SetSize(24, 24)
        combatIndicator:SetPoint("CENTER", frame, "TOPLEFT", 0, 0)
        combatIndicator:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
        combatIndicator:SetTexCoord(0.5, 1, 0, 0.5)
        combatIndicator:Hide()
        frame.CombatIndicator = combatIndicator
    end
    
    -- Add resting indicator if enabled
    if settings.showRestingIndicator then
        local restingIndicator = frame:CreateTexture(nil, "OVERLAY")
        restingIndicator:SetSize(24, 24)
        restingIndicator:SetPoint("CENTER", frame, "TOPLEFT", 0, 0)
        restingIndicator:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
        restingIndicator:SetTexCoord(0, 0.5, 0, 0.5)
        restingIndicator:Hide()
        frame.RestingIndicator = restingIndicator
    end
    
    -- Add leader indicator if enabled
    if settings.showLeaderIndicator then
        local leaderIndicator = frame:CreateTexture(nil, "OVERLAY")
        leaderIndicator:SetSize(16, 16)
        leaderIndicator:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, 2)
        leaderIndicator:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
        leaderIndicator:Hide()
        frame.LeaderIndicator = leaderIndicator
    end
    
    -- Store in frames table
    self.frames.player = frame
    
    -- Initial update
    self:UpdatePlayerFrame()
    
    return frame
end

-- Create Target frame
function UnitFrames:CreateTargetFrame()
    -- Skip if already created
    if self.frames and self.frames.target then return self.frames.target end
    
    -- Initialize frames table if needed
    if not self.frames then self.frames = {} end
    
    -- Get settings
    local settings = self.settings.frames.target
    
    -- Create the main frame
    local frame = self:CreateFrame("VUITargetFrame", UIParent)
    frame:SetSize(settings.width, settings.height)
    
    -- Set initial position
    frame:SetPoint(settings.position[1], settings.position[2], settings.position[3], settings.position[4], settings.position[5])
    
    -- Set scale
    frame:SetScale(settings.scale * self.settings.scale)
    
    -- Make frame movable
    self:MakeFrameMovable(frame, "target")
    
    -- Add health bar
    local healthBar = self:CreateHealthBar(frame, "target")
    healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    healthBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    healthBar:SetHeight(settings.height * 0.7)
    
    -- Add power bar
    local powerBar = self:CreatePowerBar(frame, "target")
    powerBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    powerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    powerBar:SetHeight(settings.height * 0.3)
    
    -- Add portrait if enabled
    if self.settings.showPortraits then
        local portrait = self:CreatePortrait(frame, "target")
        portrait:SetSize(settings.height, settings.height)
        portrait:SetPoint("LEFT", frame, "RIGHT", 5, 0)
        frame.Portrait = portrait
    end
    
    -- Add name text
    local nameText = frame:CreateFontString(nil, "OVERLAY")
    nameText:SetPoint("TOP", healthBar, "TOP", 0, -2)
    nameText:SetFont(self:GetFont(), 12, "OUTLINE")
    nameText:SetTextColor(1, 1, 1)
    nameText:SetJustifyH("CENTER")
    frame.Name = nameText
    
    -- Add health text
    local healthText = frame:CreateFontString(nil, "OVERLAY")
    healthText:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
    healthText:SetFont(self:GetFont(), 10, "OUTLINE")
    healthText:SetTextColor(1, 1, 1)
    healthText:SetJustifyH("CENTER")
    frame.Health = healthText
    
    -- Add power text
    local powerText = frame:CreateFontString(nil, "OVERLAY")
    powerText:SetPoint("CENTER", powerBar, "CENTER", 0, 0)
    powerText:SetFont(self:GetFont(), 9, "OUTLINE")
    powerText:SetTextColor(1, 1, 1)
    powerText:SetJustifyH("CENTER")
    frame.Power = powerText
    
    -- Add level text
    local levelText = frame:CreateFontString(nil, "OVERLAY")
    levelText:SetPoint("BOTTOMRIGHT", healthBar, "TOPRIGHT", -2, 2)
    levelText:SetFont(self:GetFont(), 10, "OUTLINE")
    levelText:SetTextColor(1, 1, 1)
    levelText:SetJustifyH("RIGHT")
    frame.Level = levelText
    
    -- Add classification indicator if enabled
    if settings.classificationIndicator then
        local classificationIndicator = frame:CreateFontString(nil, "OVERLAY")
        classificationIndicator:SetPoint("LEFT", levelText, "RIGHT", 2, 0)
        classificationIndicator:SetFont(self:GetFont(), 14, "OUTLINE")
        classificationIndicator:SetTextColor(1, 0.3, 0.3)
        classificationIndicator:Hide()
        frame.ClassificationIndicator = classificationIndicator
    end
    
    -- Store in frames table
    self.frames.target = frame
    
    -- Initial update
    self:UpdateTargetFrame()
    
    return frame
end

-- Create Focus frame (Similar to target but with focus unit)
function UnitFrames:CreateFocusFrame()
    -- Skip if already created
    if self.frames and self.frames.focus then return self.frames.focus end
    
    -- Initialize frames table if needed
    if not self.frames then self.frames = {} end
    
    -- Get settings
    local settings = self.settings.frames.focus
    
    -- Create the main frame using the module's CreateFrame function
    local frame = self:CreateFrame("VUIFocusFrame", UIParent)
    frame:SetSize(settings.width, settings.height)
    
    -- Set initial position
    frame:SetPoint(settings.position[1], settings.position[2], settings.position[3], settings.position[4], settings.position[5])
    
    -- Set scale
    frame:SetScale(settings.scale * self.settings.scale)
    
    -- Make frame movable
    self:MakeFrameMovable(frame, "focus")
    
    -- Add health bar
    local healthBar = self:CreateHealthBar(frame, "focus")
    healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    healthBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    healthBar:SetHeight(settings.height * 0.7)
    
    -- Add power bar
    local powerBar = self:CreatePowerBar(frame, "focus")
    powerBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    powerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    powerBar:SetHeight(settings.height * 0.3)
    
    -- Add portrait if enabled
    if self.settings.showPortraits then
        local portrait = self:CreatePortrait(frame, "focus")
        portrait:SetSize(settings.height, settings.height)
        portrait:SetPoint("RIGHT", frame, "LEFT", -5, 0)
        frame.Portrait = portrait
    end
    
    -- Add name text
    local nameText = frame:CreateFontString(nil, "OVERLAY")
    nameText:SetPoint("TOP", healthBar, "TOP", 0, -2)
    nameText:SetFont(self:GetFont(), 12, "OUTLINE")
    nameText:SetTextColor(1, 1, 1)
    nameText:SetJustifyH("CENTER")
    frame.Name = nameText
    
    -- Add health text
    local healthText = frame:CreateFontString(nil, "OVERLAY")
    healthText:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
    healthText:SetFont(self:GetFont(), 10, "OUTLINE")
    healthText:SetTextColor(1, 1, 1)
    healthText:SetJustifyH("CENTER")
    frame.Health = healthText
    
    -- Add power text
    local powerText = frame:CreateFontString(nil, "OVERLAY")
    powerText:SetPoint("CENTER", powerBar, "CENTER", 0, 0)
    powerText:SetFont(self:GetFont(), 9, "OUTLINE")
    powerText:SetTextColor(1, 1, 1)
    powerText:SetJustifyH("CENTER")
    frame.Power = powerText
    
    -- Store in frames table
    self.frames.focus = frame
    
    -- Initial update
    self:UpdateFocusFrame()
    
    return frame
end

-- Create Pet frame
function UnitFrames:CreatePetFrame()
    -- Skip if already created
    if self.frames and self.frames.pet then return self.frames.pet end
    
    -- Initialize frames table if needed
    if not self.frames then self.frames = {} end
    
    -- Get settings
    local settings = self.settings.frames.pet
    
    -- Create the main frame
    local frame = self:CreateFrame("VUIPetFrame", UIParent)
    frame:SetSize(settings.width, settings.height)
    
    -- Set initial position
    frame:SetPoint(settings.position[1], settings.position[2], settings.position[3], settings.position[4], settings.position[5])
    
    -- Set scale
    frame:SetScale(settings.scale * self.settings.scale)
    
    -- Make frame movable
    self:MakeFrameMovable(frame, "pet")
    
    -- Add health bar
    local healthBar = self:CreateHealthBar(frame, "pet")
    healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    healthBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    healthBar:SetHeight(settings.height * 0.7)
    
    -- Add power bar
    local powerBar = self:CreatePowerBar(frame, "pet")
    powerBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    powerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    powerBar:SetHeight(settings.height * 0.3)
    
    -- Add name text
    local nameText = frame:CreateFontString(nil, "OVERLAY")
    nameText:SetPoint("TOP", healthBar, "TOP", 0, -2)
    nameText:SetFont(self:GetFont(), 10, "OUTLINE")
    nameText:SetTextColor(1, 1, 1)
    nameText:SetJustifyH("CENTER")
    frame.Name = nameText
    
    -- Add health text
    local healthText = frame:CreateFontString(nil, "OVERLAY")
    healthText:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
    healthText:SetFont(self:GetFont(), 9, "OUTLINE")
    healthText:SetTextColor(1, 1, 1)
    healthText:SetJustifyH("CENTER")
    frame.Health = healthText
    
    -- Store in frames table
    self.frames.pet = frame
    
    -- Initial update
    self:UpdatePetFrame()
    
    return frame
end

-- Create Target of Target frame
function UnitFrames:CreateTargetTargetFrame()
    -- Skip if already created
    if self.frames and self.frames.targettarget then return self.frames.targettarget end
    
    -- Initialize frames table if needed
    if not self.frames then self.frames = {} end
    
    -- Get settings
    local settings = self.settings.frames.targettarget
    
    -- Create the main frame
    local frame = self:CreateFrame("VUITargetTargetFrame", UIParent)
    frame:SetSize(settings.width, settings.height)
    
    -- Set initial position
    frame:SetPoint(settings.position[1], settings.position[2], settings.position[3], settings.position[4], settings.position[5])
    
    -- Set scale
    frame:SetScale(settings.scale * self.settings.scale)
    
    -- Make frame movable
    self:MakeFrameMovable(frame, "targettarget")
    
    -- Add health bar
    local healthBar = self:CreateHealthBar(frame, "targettarget")
    healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    healthBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    healthBar:SetHeight(settings.height * 0.7)
    
    -- Add power bar
    local powerBar = self:CreatePowerBar(frame, "targettarget")
    powerBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    powerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    powerBar:SetHeight(settings.height * 0.3)
    
    -- Add name text
    local nameText = frame:CreateFontString(nil, "OVERLAY")
    nameText:SetPoint("TOP", healthBar, "TOP", 0, -2)
    nameText:SetFont(self:GetFont(), 10, "OUTLINE")
    nameText:SetTextColor(1, 1, 1)
    nameText:SetJustifyH("CENTER")
    frame.Name = nameText
    
    -- Add health text
    local healthText = frame:CreateFontString(nil, "OVERLAY")
    healthText:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
    healthText:SetFont(self:GetFont(), 9, "OUTLINE")
    healthText:SetTextColor(1, 1, 1)
    healthText:SetJustifyH("CENTER")
    frame.Health = healthText
    
    -- Store in frames table
    self.frames.targettarget = frame
    
    -- Initial update
    self:UpdateTargetTargetFrame()
    
    return frame
end

-- Create Party frames
function UnitFrames:CreatePartyFrames()
    -- Skip if already created
    if self.frames and self.frames.party then return self.frames.party end
    
    -- Initialize frames table if needed
    if not self.frames then self.frames = {} end
    if not self.frames.party then self.frames.party = {} end
    
    -- Get settings
    local settings = self.settings.frames.party
    
    -- Create container frame
    local container = self:CreateFrame("VUIPartyContainer", UIParent)
    container:SetPoint(settings.position[1], settings.position[2], settings.position[3], settings.position[4], settings.position[5])
    container:SetSize(settings.width, settings.height * 5 + settings.spacing * 4)
    
    -- Make container movable
    self:MakeFrameMovable(container, "party")
    
    -- Create individual party frames
    for i = 1, 4 do
        local frame = self:CreateFrame("VUIPartyFrame"..i, container)
        frame:SetSize(settings.width, settings.height)
        
        if i == 1 then
            frame:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
        else
            if settings.vertical then
                frame:SetPoint("TOPLEFT", self.frames.party[i-1], "BOTTOMLEFT", 0, -settings.spacing)
            else
                frame:SetPoint("TOPLEFT", self.frames.party[i-1], "TOPRIGHT", settings.spacing, 0)
            end
        end
        
        -- Add health bar
        local healthBar = self:CreateHealthBar(frame, "party"..i)
        healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        healthBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
        healthBar:SetHeight(settings.height * 0.7)
        
        -- Add power bar
        local powerBar = self:CreatePowerBar(frame, "party"..i)
        powerBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
        powerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
        powerBar:SetHeight(settings.height * 0.3)
        
        -- Add portrait if enabled
        if self.settings.showPortraits then
            local portrait = self:CreatePortrait(frame, "party"..i)
            portrait:SetSize(settings.height, settings.height)
            portrait:SetPoint("RIGHT", frame, "LEFT", -5, 0)
            frame.Portrait = portrait
        end
        
        -- Add name text
        local nameText = frame:CreateFontString(nil, "OVERLAY")
        nameText:SetPoint("TOP", healthBar, "TOP", 0, -2)
        nameText:SetFont(self:GetFont(), 10, "OUTLINE")
        nameText:SetTextColor(1, 1, 1)
        nameText:SetJustifyH("CENTER")
        frame.Name = nameText
        
        -- Add health text
        local healthText = frame:CreateFontString(nil, "OVERLAY")
        healthText:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
        healthText:SetFont(self:GetFont(), 9, "OUTLINE")
        healthText:SetTextColor(1, 1, 1)
        healthText:SetJustifyH("CENTER")
        frame.Health = healthText
        
        -- Add role icon if enabled
        if settings.showRoleIcon then
            local roleIcon = frame:CreateTexture(nil, "OVERLAY")
            roleIcon:SetSize(16, 16)
            roleIcon:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
            roleIcon:Hide()
            frame.RoleIcon = roleIcon
        end
        
        -- Store in frames table
        self.frames.party[i] = frame
    end
    
    -- Store container
    self.frames.partyContainer = container
    
    -- Set initial scale
    container:SetScale(settings.scale * self.settings.scale)
    
    -- Initial update
    self:UpdatePartyFrames()
    
    return container
end

-- Create Boss frames
function UnitFrames:CreateBossFrames()
    -- Skip if already created
    if self.frames and self.frames.boss then return self.frames.boss end
    
    -- Initialize frames table if needed
    if not self.frames then self.frames = {} end
    if not self.frames.boss then self.frames.boss = {} end
    
    -- Get settings
    local settings = self.settings.frames.boss
    
    -- Create container frame
    local container = self:CreateFrame("VUIBossContainer", UIParent)
    container:SetPoint(settings.position[1], settings.position[2], settings.position[3], settings.position[4], settings.position[5])
    container:SetSize(settings.width, settings.height * 5 + settings.spacing * 4)
    
    -- Make container movable
    self:MakeFrameMovable(container, "boss")
    
    -- Create individual boss frames
    for i = 1, 5 do
        local frame = self:CreateFrame("VUIBossFrame"..i, container)
        frame:SetSize(settings.width, settings.height)
        
        if i == 1 then
            frame:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
        else
            if settings.vertical then
                frame:SetPoint("TOPLEFT", self.frames.boss[i-1], "BOTTOMLEFT", 0, -settings.spacing)
            else
                frame:SetPoint("TOPLEFT", self.frames.boss[i-1], "TOPRIGHT", settings.spacing, 0)
            end
        end
        
        -- Add health bar
        local healthBar = self:CreateHealthBar(frame, "boss"..i)
        healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        healthBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
        healthBar:SetHeight(settings.height * 0.7)
        
        -- Add power bar
        local powerBar = self:CreatePowerBar(frame, "boss"..i)
        powerBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
        powerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
        powerBar:SetHeight(settings.height * 0.3)
        
        -- Add name text
        local nameText = frame:CreateFontString(nil, "OVERLAY")
        nameText:SetPoint("TOP", healthBar, "TOP", 0, -2)
        nameText:SetFont(self:GetFont(), 10, "OUTLINE")
        nameText:SetTextColor(1, 1, 1)
        nameText:SetJustifyH("CENTER")
        frame.Name = nameText
        
        -- Add health text
        local healthText = frame:CreateFontString(nil, "OVERLAY")
        healthText:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
        healthText:SetFont(self:GetFont(), 9, "OUTLINE")
        healthText:SetTextColor(1, 1, 1)
        healthText:SetJustifyH("CENTER")
        frame.Health = healthText
        
        -- Store in frames table
        self.frames.boss[i] = frame
    end
    
    -- Store container
    self.frames.bossContainer = container
    
    -- Set initial scale
    container:SetScale(settings.scale * self.settings.scale)
    
    -- Initial update
    self:UpdateBossFrames()
    
    return container
end

-- Create Arena frames
function UnitFrames:CreateArenaFrames()
    -- Skip if already created
    if self.frames and self.frames.arena then return self.frames.arena end
    
    -- Initialize frames table if needed
    if not self.frames then self.frames = {} end
    if not self.frames.arena then self.frames.arena = {} end
    
    -- Get settings
    local settings = self.settings.frames.arena
    
    -- Create container frame
    local container = self:CreateFrame("VUIArenaContainer", UIParent)
    container:SetPoint(settings.position[1], settings.position[2], settings.position[3], settings.position[4], settings.position[5])
    container:SetSize(settings.width, settings.height * 5 + settings.spacing * 4)
    
    -- Make container movable
    self:MakeFrameMovable(container, "arena")
    
    -- Create individual arena frames
    for i = 1, 5 do
        local frame = self:CreateFrame("VUIArenaFrame"..i, container)
        frame:SetSize(settings.width, settings.height)
        
        if i == 1 then
            frame:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
        else
            if settings.vertical then
                frame:SetPoint("TOPLEFT", self.frames.arena[i-1], "BOTTOMLEFT", 0, -settings.spacing)
            else
                frame:SetPoint("TOPLEFT", self.frames.arena[i-1], "TOPRIGHT", settings.spacing, 0)
            end
        end
        
        -- Add health bar
        local healthBar = self:CreateHealthBar(frame, "arena"..i)
        healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        healthBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
        healthBar:SetHeight(settings.height * 0.7)
        
        -- Add power bar
        local powerBar = self:CreatePowerBar(frame, "arena"..i)
        powerBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
        powerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
        powerBar:SetHeight(settings.height * 0.3)
        
        -- Add name text
        local nameText = frame:CreateFontString(nil, "OVERLAY")
        nameText:SetPoint("TOP", healthBar, "TOP", 0, -2)
        nameText:SetFont(self:GetFont(), 10, "OUTLINE")
        nameText:SetTextColor(1, 1, 1)
        nameText:SetJustifyH("CENTER")
        frame.Name = nameText
        
        -- Add health text
        local healthText = frame:CreateFontString(nil, "OVERLAY")
        healthText:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
        healthText:SetFont(self:GetFont(), 9, "OUTLINE")
        healthText:SetTextColor(1, 1, 1)
        healthText:SetJustifyH("CENTER")
        frame.Health = healthText
        
        -- Add spec icon if enabled
        if settings.showSpecIcon then
            local specIcon = frame:CreateTexture(nil, "OVERLAY")
            specIcon:SetSize(16, 16)
            specIcon:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
            specIcon:Hide()
            frame.SpecIcon = specIcon
        end
        
        -- Add trinket icon if enabled
        if settings.showTrinketIcon then
            local trinketIcon = frame:CreateTexture(nil, "OVERLAY")
            trinketIcon:SetSize(16, 16)
            trinketIcon:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -2)
            trinketIcon:Hide()
            frame.TrinketIcon = trinketIcon
        end
        
        -- Store in frames table
        self.frames.arena[i] = frame
    end
    
    -- Store container
    self.frames.arenaContainer = container
    
    -- Set initial scale
    container:SetScale(settings.scale * self.settings.scale)
    
    -- Initial update
    self:UpdateArenaFrames()
    
    return container
end

-- Frame component creation methods

-- Create a frame with the VUI styling
function UnitFrames:CreateFrame(name, parent)
    local frame = self:CreateBaseFrame(name, parent)
    return frame
end

-- Create base frame
function UnitFrames:CreateBaseFrame(name, parent)
    local frame = CreateFrame("Frame", name, parent)
    frame:SetFrameStrata("MEDIUM")
    
    -- Add border and background
    local backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false, tileSize = 0, edgeSize = 1,
        insets = {left = 0, right = 0, top = 0, bottom = 0}
    }
    
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(0.1, 0.1, 0.1, 0.8) -- Default background color
    frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1) -- Default border color
    
    return frame
end

-- Create health bar
function UnitFrames:CreateHealthBar(parent, unit)
    local bar = CreateFrame("StatusBar", parent:GetName().."HealthBar", parent)
    bar:SetStatusBarTexture(self:GetStatusBarTexture())
    bar:SetMinMaxValues(0, 100)
    bar:SetValue(100)
    
    -- Add background
    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture(self:GetStatusBarTexture())
    bg:SetAllPoints(bar)
    bg:SetVertexColor(0.1, 0.1, 0.1, 0.7)
    
    -- Store the unit for updating
    bar.unit = unit
    
    return bar
end

-- Create power bar
function UnitFrames:CreatePowerBar(parent, unit)
    local bar = CreateFrame("StatusBar", parent:GetName().."PowerBar", parent)
    bar:SetStatusBarTexture(self:GetStatusBarTexture())
    bar:SetMinMaxValues(0, 100)
    bar:SetValue(100)
    
    -- Add background
    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture(self:GetStatusBarTexture())
    bg:SetAllPoints(bar)
    bg:SetVertexColor(0.1, 0.1, 0.1, 0.7)
    
    -- Store the unit for updating
    bar.unit = unit
    
    return bar
end

-- Create portrait
function UnitFrames:CreatePortrait(parent, unit)
    local portrait = CreateFrame("Frame", parent:GetName().."Portrait", parent)
    
    -- Add border and background
    local backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false, tileSize = 0, edgeSize = 1,
        insets = {left = 0, right = 0, top = 0, bottom = 0}
    }
    
    portrait:SetBackdrop(backdrop)
    portrait:SetBackdropColor(0.1, 0.1, 0.1, 0.8) -- Default background color
    portrait:SetBackdropBorderColor(0.3, 0.3, 0.3, 1) -- Default border color
    
    -- Create portrait texture
    local texture = portrait:CreateTexture(nil, "ARTWORK")
    texture:SetAllPoints(portrait)
    texture:SetTexCoord(0.15, 0.85, 0.15, 0.85) -- Crop the edges
    
    -- Store the unit and texture for updating
    portrait.unit = unit
    portrait.texture = texture
    
    return portrait
end

-- Make a frame movable
function UnitFrames:MakeFrameMovable(frame, frameType)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    
    -- Add a transparent overlay for moving when unlocked
    local overlay = frame:CreateTexture(nil, "OVERLAY")
    overlay:SetAllPoints(frame)
    overlay:SetColorTexture(0.5, 0.5, 1, 0.3)
    overlay:Hide()
    frame.moveOverlay = overlay
    
    -- Add handlers for dragging
    frame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and self.unlocked then
            self:StartMoving()
        end
    end)
    
    frame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.unlocked then
            self:StopMovingOrSizing()
            
            -- Save position
            local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
            
            -- Convert relative frame to string
            local relativeToName = "UIParent"
            if relativeTo and relativeTo ~= UIParent and relativeTo.GetName then
                relativeToName = relativeTo:GetName() or "UIParent"
            end
            
            UnitFrames.settings.frames[frameType].position = {point, relativeToName, relativePoint, xOfs, yOfs}
        end
    end)
    
    -- Store the frame type for unlocking
    frame.frameType = frameType
end

-- Unlock all frames for movement
function UnitFrames:UnlockFrames()
    -- Process all frames
    if self.frames then
        -- Process main frames
        for _, frameType in pairs({"player", "target", "targettarget", "pet", "focus"}) do
            if self.frames[frameType] then
                self.frames[frameType].unlocked = true
                if self.frames[frameType].moveOverlay then
                    self.frames[frameType].moveOverlay:Show()
                end
            end
        end
        
        -- Process container frames
        for _, containerType in pairs({"partyContainer", "bossContainer", "arenaContainer"}) do
            if self.frames[containerType] then
                self.frames[containerType].unlocked = true
                if self.frames[containerType].moveOverlay then
                    self.frames[containerType].moveOverlay:Show()
                end
            end
        end
    end
    
    VUI:Print("UnitFrames unlocked for movement. Drag them to position, then use /vuiuf lock to lock.")
end

-- Lock all frames after movement
function UnitFrames:LockFrames()
    -- Process all frames
    if self.frames then
        -- Process main frames
        for _, frameType in pairs({"player", "target", "targettarget", "pet", "focus"}) do
            if self.frames[frameType] then
                self.frames[frameType].unlocked = false
                if self.frames[frameType].moveOverlay then
                    self.frames[frameType].moveOverlay:Hide()
                end
            end
        end
        
        -- Process container frames
        for _, containerType in pairs({"partyContainer", "bossContainer", "arenaContainer"}) do
            if self.frames[containerType] then
                self.frames[containerType].unlocked = false
                if self.frames[containerType].moveOverlay then
                    self.frames[containerType].moveOverlay:Hide()
                end
            end
        end
    end
    
    VUI:Print("UnitFrames locked.")
end

-- Reset all frame positions
function UnitFrames:ResetPositions()
    -- Reset the stored positions to defaults
    self.settings.frames.player.position = {"CENTER", "UIParent", "CENTER", -280, -140}
    self.settings.frames.target.position = {"CENTER", "UIParent", "CENTER", 280, -140}
    self.settings.frames.targettarget.position = {"TOPLEFT", "VUITargetFrame", "BOTTOMLEFT", 0, -18}
    self.settings.frames.pet.position = {"TOPRIGHT", "VUIPlayerFrame", "BOTTOMRIGHT", 0, -18}
    self.settings.frames.focus.position = {"LEFT", "UIParent", "LEFT", 20, 0}
    self.settings.frames.party.position = {"TOPLEFT", "UIParent", "TOPLEFT", 20, -200}
    self.settings.frames.boss.position = {"RIGHT", "UIParent", "RIGHT", -100, 0}
    self.settings.frames.arena.position = {"RIGHT", "UIParent", "RIGHT", -100, 0}
    
    -- Apply the new positions
    for _, frameType in pairs({"player", "target", "targettarget", "pet", "focus"}) do
        local frame = self.frames[frameType]
        if frame then
            local pos = self.settings.frames[frameType].position
            frame:ClearAllPoints()
            frame:SetPoint(pos[1], _G[pos[2]], pos[3], pos[4], pos[5])
        end
    end
    
    -- Reset container frames
    for _, containerType in pairs({"party", "boss", "arena"}) do
        local container = self.frames[containerType.."Container"]
        if container then
            local pos = self.settings.frames[containerType].position
            container:ClearAllPoints()
            container:SetPoint(pos[1], _G[pos[2]], pos[3], pos[4], pos[5])
        end
    end
    
    VUI:Print("UnitFrames positions reset to defaults.")
end

-- Reset a specific frame position
function UnitFrames:ResetPosition(frameType)
    if not frameType or not self.settings.frames[frameType] then return end
    
    -- Reset the stored position to default
    local defaultPositions = {
        player = {"CENTER", "UIParent", "CENTER", -280, -140},
        target = {"CENTER", "UIParent", "CENTER", 280, -140},
        targettarget = {"TOPLEFT", "VUITargetFrame", "BOTTOMLEFT", 0, -18},
        pet = {"TOPRIGHT", "VUIPlayerFrame", "BOTTOMRIGHT", 0, -18},
        focus = {"LEFT", "UIParent", "LEFT", 20, 0},
        party = {"TOPLEFT", "UIParent", "TOPLEFT", 20, -200},
        boss = {"RIGHT", "UIParent", "RIGHT", -100, 0},
        arena = {"RIGHT", "UIParent", "RIGHT", -100, 0}
    }
    
    self.settings.frames[frameType].position = defaultPositions[frameType]
    
    -- Apply the new position
    if frameType == "party" or frameType == "boss" or frameType == "arena" then
        local container = self.frames[frameType.."Container"]
        if container then
            local pos = self.settings.frames[frameType].position
            container:ClearAllPoints()
            container:SetPoint(pos[1], _G[pos[2]], pos[3], pos[4], pos[5])
        end
    else
        local frame = self.frames[frameType]
        if frame then
            local pos = self.settings.frames[frameType].position
            frame:ClearAllPoints()
            frame:SetPoint(pos[1], _G[pos[2]], pos[3], pos[4], pos[5])
        end
    end
    
    VUI:Print(frameType:gsub("^%l", string.upper) .. " frame position reset to default.")
end

-- Update methods

-- Update all frames
function UnitFrames:UpdateAllFrames()
    self:UpdatePlayerFrame()
    self:UpdateTargetFrame()
    self:UpdateFocusFrame()
    self:UpdatePetFrame()
    self:UpdateTargetTargetFrame()
    self:UpdatePartyFrames()
    self:UpdateBossFrames()
    self:UpdateArenaFrames()
end

-- Update player frame
function UnitFrames:UpdatePlayerFrame()
    local frame = self.frames and self.frames.player
    if not frame then return end
    
    self:UpdateUnitFrame(frame, "player")
    
    -- Update combat indicator
    if frame.CombatIndicator then
        if UnitAffectingCombat("player") then
            frame.CombatIndicator:Show()
        else
            frame.CombatIndicator:Hide()
        end
    end
    
    -- Update resting indicator
    if frame.RestingIndicator then
        if IsResting() then
            frame.RestingIndicator:Show()
        else
            frame.RestingIndicator:Hide()
        end
    end
    
    -- Update leader indicator
    if frame.LeaderIndicator then
        if UnitIsGroupLeader("player") then
            frame.LeaderIndicator:Show()
        else
            frame.LeaderIndicator:Hide()
        end
    end
end

-- Update target frame
function UnitFrames:UpdateTargetFrame()
    local frame = self.frames and self.frames.target
    if not frame then return end
    
    if UnitExists("target") then
        frame:Show()
        self:UpdateUnitFrame(frame, "target")
        
        -- Update classification indicator
        if frame.ClassificationIndicator then
            local classification = UnitClassification("target")
            local symbol = ""
            
            if classification == "worldboss" then
                symbol = "B"
            elseif classification == "rareelite" then
                symbol = "R+"
            elseif classification == "elite" then
                symbol = "+"
            elseif classification == "rare" then
                symbol = "R"
            end
            
            if symbol ~= "" then
                frame.ClassificationIndicator:SetText(symbol)
                frame.ClassificationIndicator:Show()
            else
                frame.ClassificationIndicator:Hide()
            end
        end
    else
        frame:Hide()
    end
end

-- Update focus frame
function UnitFrames:UpdateFocusFrame()
    local frame = self.frames and self.frames.focus
    if not frame then return end
    
    if UnitExists("focus") then
        frame:Show()
        self:UpdateUnitFrame(frame, "focus")
    else
        frame:Hide()
    end
end

-- Update pet frame
function UnitFrames:UpdatePetFrame()
    local frame = self.frames and self.frames.pet
    if not frame then return end
    
    if UnitExists("pet") then
        frame:Show()
        self:UpdateUnitFrame(frame, "pet")
    else
        frame:Hide()
    end
end

-- Update target of target frame
function UnitFrames:UpdateTargetTargetFrame()
    local frame = self.frames and self.frames.targettarget
    if not frame then return end
    
    if UnitExists("targettarget") then
        frame:Show()
        self:UpdateUnitFrame(frame, "targettarget")
    else
        frame:Hide()
    end
end

-- Update party frames
function UnitFrames:UpdatePartyFrames()
    if not self.frames or not self.frames.party then return end
    
    -- Get settings
    local settings = self.settings.frames.party
    
    -- Update each party frame
    for i = 1, 4 do
        local frame = self.frames.party[i]
        local unit = "party"..i
        
        if UnitExists(unit) then
            frame:Show()
            self:UpdateUnitFrame(frame, unit)
            
            -- Update role icon if enabled
            if settings.showRoleIcon and frame.RoleIcon then
                local role = UnitGroupRolesAssigned(unit)
                if role ~= "NONE" then
                    local roleTexture = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES"
                    local roleCoord = {
                        TANK = {0, 0.28, 0.28, 0.56},
                        HEALER = {0.28, 0.56, 0, 0.28},
                        DAMAGER = {0.56, 0.84, 0, 0.28}
                    }
                    
                    frame.RoleIcon:SetTexture(roleTexture)
                    frame.RoleIcon:SetTexCoord(unpack(roleCoord[role]))
                    frame.RoleIcon:Show()
                else
                    frame.RoleIcon:Hide()
                end
            end
        else
            frame:Hide()
        end
    end
end

-- Update boss frames
function UnitFrames:UpdateBossFrames()
    if not self.frames or not self.frames.boss then return end
    
    -- Update each boss frame
    for i = 1, 5 do
        local frame = self.frames.boss[i]
        local unit = "boss"..i
        
        if UnitExists(unit) then
            frame:Show()
            self:UpdateUnitFrame(frame, unit)
        else
            frame:Hide()
        end
    end
end

-- Update arena frames
function UnitFrames:UpdateArenaFrames()
    if not self.frames or not self.frames.arena then return end
    
    -- Get settings
    local settings = self.settings.frames.arena
    
    -- Update each arena frame
    for i = 1, 5 do
        local frame = self.frames.arena[i]
        local unit = "arena"..i
        
        if UnitExists(unit) then
            frame:Show()
            self:UpdateUnitFrame(frame, unit)
            
            -- Update spec icon if enabled
            if settings.showSpecIcon and frame.SpecIcon then
                -- This would require additional PvP functions
                -- For now, hide it
                frame.SpecIcon:Hide()
            end
            
            -- Update trinket icon if enabled
            if settings.showTrinketIcon and frame.TrinketIcon then
                -- This would require additional PvP tracking
                -- For now, hide it
                frame.TrinketIcon:Hide()
            end
        else
            frame:Hide()
        end
    end
end

-- Update a generic unit frame
function UnitFrames:UpdateUnitFrame(frame, unit)
    if not frame or not UnitExists(unit) then return end
    
    -- Update name
    if frame.Name then
        frame.Name:SetText(UnitName(unit))
    end
    
    -- Update health bar
    local healthBar = frame:GetName() and _G[frame:GetName().."HealthBar"]
    if healthBar then
        local health = UnitHealth(unit)
        local maxHealth = UnitHealthMax(unit)
        
        if maxHealth > 0 then
            healthBar:SetMinMaxValues(0, maxHealth)
            healthBar:SetValue(health)
            
            -- Set color based on settings
            if self.settings.classColoredBars and UnitIsPlayer(unit) then
                local _, class = UnitClass(unit)
                if class and RAID_CLASS_COLORS[class] then
                    local color = RAID_CLASS_COLORS[class]
                    healthBar:SetStatusBarColor(color.r, color.g, color.b)
                end
            else
                local r, g, b = 0.2, 0.8, 0.2 -- Default color
                
                if UnitIsTapDenied(unit) then
                    -- Tapped unit
                    local color = self.settings.colors.health.tapped
                    r, g, b = color.r, color.g, color.b
                elseif UnitIsDeadOrGhost(unit) then
                    -- Dead unit
                    r, g, b = 0.6, 0.6, 0.6
                elseif not UnitIsConnected(unit) then
                    -- Disconnected unit
                    local color = self.settings.colors.health.disconnected
                    r, g, b = color.r, color.g, color.b
                elseif not UnitIsPlayer(unit) then
                    -- NPC - color by reaction
                    local reaction = UnitReaction(unit, "player")
                    if reaction then
                        if reaction <= 2 then
                            -- Hostile
                            local color = self.settings.colors.health.reaction.hostile
                            r, g, b = color.r, color.g, color.b
                        elseif reaction <= 4 then
                            -- Neutral
                            local color = self.settings.colors.health.reaction.neutral
                            r, g, b = color.r, color.g, color.b
                        else
                            -- Friendly
                            local color = self.settings.colors.health.reaction.friendly
                            r, g, b = color.r, color.g, color.b
                        end
                    end
                end
                
                healthBar:SetStatusBarColor(r, g, b)
            end
            
            -- Update health text
            if frame.Health then
                local healthText = ""
                if UnitIsDeadOrGhost(unit) then
                    healthText = "Dead"
                elseif not UnitIsConnected(unit) then
                    healthText = "Offline"
                elseif health == maxHealth then
                    healthText = UnitFrames:FormatNumber(health)
                else
                    healthText = UnitFrames:FormatNumber(health) .. " / " .. UnitFrames:FormatNumber(maxHealth)
                    
                    -- Add percentage if enabled
                    local settings = self.settings.frames[frame.frameType] or {}
                    if settings.showHealthPercent then
                        local percent = math.floor((health / maxHealth) * 100 + 0.5)
                        healthText = healthText .. " (" .. percent .. "%)"
                    end
                end
                
                frame.Health:SetText(healthText)
            end
        end
    end
    
    -- Update power bar
    local powerBar = frame:GetName() and _G[frame:GetName().."PowerBar"]
    if powerBar then
        local power = UnitPower(unit)
        local maxPower = UnitPowerMax(unit)
        local powerType = UnitPowerType(unit)
        
        if maxPower > 0 then
            powerBar:SetMinMaxValues(0, maxPower)
            powerBar:SetValue(power)
            
            -- Set color based on power type
            local powerTypeStr = POWER_TYPES[powerType] or "MANA"
            local powerColor = self.settings.colors.power[powerTypeStr] or {r = 0.3, g = 0.5, b = 0.9, a = 1.0}
            powerBar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b, powerColor.a)
            
            -- Update power text
            if frame.Power then
                local settings = self.settings.frames[frame.frameType] or {}
                if settings.showPowerValue then
                    local powerText = UnitFrames:FormatNumber(power)
                    
                    -- Add percentage if enabled
                    if settings.showPowerPercent and maxPower > 0 then
                        local percent = math.floor((power / maxPower) * 100 + 0.5)
                        powerText = powerText .. " (" .. percent .. "%)"
                    end
                    
                    frame.Power:SetText(powerText)
                else
                    frame.Power:SetText("")
                end
            end
        end
    end
    
    -- Update level text
    if frame.Level then
        local level = UnitLevel(unit)
        local levelText = level > 0 and level or "??"
        
        -- Add classification indicators
        local classification = UnitClassification(unit)
        if classification == "worldboss" then
            levelText = levelText .. " (Boss)"
        elseif classification == "rareelite" then
            levelText = levelText .. "+ (Rare)"
        elseif classification == "elite" then
            levelText = levelText .. "+"
        elseif classification == "rare" then
            levelText = levelText .. " (Rare)"
        end
        
        frame.Level:SetText(levelText)
    end
    
    -- Update portrait if enabled
    if self.settings.showPortraits and frame.Portrait then
        if self.settings.useClassPortraits and UnitIsPlayer(unit) then
            local _, class = UnitClass(unit)
            if class and CLASS_ICONS[class] then
                frame.Portrait.texture:SetTexture(CLASS_ICONS[class])
                frame.Portrait.texture:SetTexCoord(0, 1, 0, 1)
            end
        else
            SetPortraitTexture(frame.Portrait.texture, unit)
        end
    end
end

-- Format a number with commas or abbreviations
function UnitFrames:FormatNumber(number)
    if number >= 1000000 then
        return string.format("%.1fM", number / 1000000)
    elseif number >= 1000 then
        return string.format("%.1fK", number / 1000)
    else
        return number
    end
end

-- Get the font to use
function UnitFrames:GetFont()
    local fontPath = "Fonts\\FRIZQT__.TTF" -- Default WoW font
    
    if VUI.media and VUI.media.fonts then
        fontPath = VUI:GetFont(VUI.db.profile.appearance.font)
    end
    
    return fontPath
end

-- Get the status bar texture to use
function UnitFrames:GetStatusBarTexture()
    local texture = "Interface\\TargetingFrame\\UI-StatusBar"
    
    if VUI.media and VUI.media.textures then
        texture = VUI.media.textures[VUI.db.profile.appearance.statusbarTexture] or texture
    end
    
    return texture
end

-- Update frame visibility based on settings
function UnitFrames:UpdateFrameVisibility(frameType)
    if not frameType then
        -- Update all frames
        for type, _ in pairs(self.settings.frames) do
            self:UpdateFrameVisibility(type)
        end
        return
    end
    
    -- Update specific frame
    if not self.frames then return end
    
    if frameType == "party" or frameType == "boss" or frameType == "arena" then
        local container = self.frames[frameType.."Container"]
        if container then
            if self.settings.frames[frameType].enabled then
                container:Show()
            else
                container:Hide()
            end
        end
    else
        local frame = self.frames[frameType]
        if frame then
            if self.settings.frames[frameType].enabled then
                frame:Show()
                -- Re-run the update for this frame type
                local updateMethod = "Update" .. frameType:gsub("^%l", string.upper) .. "Frame"
                if self[updateMethod] then
                    self[updateMethod](self)
                end
            else
                frame:Hide()
            end
        end
    end
end

-- Update frame scale based on settings
function UnitFrames:UpdateFrameScale(frameType)
    if not frameType then
        -- Update all frames
        for type, _ in pairs(self.settings.frames) do
            self:UpdateFrameScale(type)
        end
        return
    end
    
    -- Update specific frame
    if not self.frames then return end
    
    if frameType == "party" or frameType == "boss" or frameType == "arena" then
        local container = self.frames[frameType.."Container"]
        if container then
            container:SetScale(self.settings.frames[frameType].scale * self.settings.scale)
        end
    else
        local frame = self.frames[frameType]
        if frame then
            frame:SetScale(self.settings.frames[frameType].scale * self.settings.scale)
        end
    end
end

-- Update frame size based on settings
function UnitFrames:UpdateFrameSize(frameType)
    if not frameType then
        -- Update all frames
        for type, _ in pairs(self.settings.frames) do
            self:UpdateFrameSize(type)
        end
        return
    end
    
    -- Update specific frame
    if not self.frames then return end
    
    if frameType == "party" or frameType == "boss" or frameType == "arena" then
        -- Update container size based on new frame sizes
        local container = self.frames[frameType.."Container"]
        if container then
            local settings = self.settings.frames[frameType]
            if settings.vertical then
                container:SetSize(settings.width, settings.height * 5 + settings.spacing * 4)
            else
                container:SetSize(settings.width * 5 + settings.spacing * 4, settings.height)
            end
            
            -- Update individual frames
            for i = 1, 5 do
                local frame = self.frames[frameType][i]
                if frame then
                    frame:SetSize(settings.width, settings.height)
                    
                    -- Update health and power bars
                    local healthBar = frame:GetName() and _G[frame:GetName().."HealthBar"]
                    local powerBar = frame:GetName() and _G[frame:GetName().."PowerBar"]
                    
                    if healthBar then
                        healthBar:SetHeight(settings.height * 0.7)
                    end
                    
                    if powerBar then
                        powerBar:SetHeight(settings.height * 0.3)
                    end
                end
            end
        end
    else
        local frame = self.frames[frameType]
        if frame then
            local settings = self.settings.frames[frameType]
            frame:SetSize(settings.width, settings.height)
            
            -- Update health and power bars
            local healthBar = frame:GetName() and _G[frame:GetName().."HealthBar"]
            local powerBar = frame:GetName() and _G[frame:GetName().."PowerBar"]
            
            if healthBar then
                healthBar:SetHeight(settings.height * 0.7)
            end
            
            if powerBar then
                powerBar:SetHeight(settings.height * 0.3)
            end
        end
    end
end

-- Show all frames
function UnitFrames:ShowFrames()
    if not self.frames then return end
    
    -- Show individual frames based on enabled setting
    for frameType, frameSettings in pairs(self.settings.frames) do
        if frameSettings.enabled then
            if frameType == "party" or frameType == "boss" or frameType == "arena" then
                local container = self.frames[frameType.."Container"]
                if container then
                    container:Show()
                end
            else
                local frame = self.frames[frameType]
                if frame then
                    frame:Show()
                end
            end
        end
    end
    
    -- Run updates for all frames
    self:UpdateAllFrames()
end

-- Hide all frames
function UnitFrames:HideFrames()
    if not self.frames then return end
    
    -- Hide all frames regardless of enabled setting
    for frameType, _ in pairs(self.settings.frames) do
        if frameType == "party" or frameType == "boss" or frameType == "arena" then
            local container = self.frames[frameType.."Container"]
            if container then
                container:Hide()
            end
        else
            local frame = self.frames[frameType]
            if frame then
                frame:Hide()
            end
        end
    end
end

-- Update frames based on settings
function UnitFrames:UpdateFrames()
    -- Update all frames based on settings
    self:UpdateFrameVisibility()
    self:UpdateFrameScale()
    self:UpdateFrameSize()
    self:UpdateAllFrames()
    self:ApplyTheme()
end

-- Apply theme to all frames
function UnitFrames:ApplyTheme()
    if not self.frames then return end
    
    -- Get theme colors
    local theme = VUI.db.profile.appearance.theme or "dark"
    local themeData = VUI.media and VUI.media.themes and VUI.media.themes[theme]
    
    if not themeData then
        -- Default theme colors
        themeData = {
            colors = {
                backdrop = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
                border = {r = 0.4, g = 0.4, b = 0.4, a = 1.0},
                header = {r = 0.2, g = 0.2, b = 0.2, a = 1.0},
                text = {r = 1.0, g = 1.0, b = 1.0, a = 1.0}
            }
        }
    end
    
    -- Apply theme to all frames
    for frameType, _ in pairs(self.settings.frames) do
        if frameType == "party" or frameType == "boss" or frameType == "arena" then
            local container = self.frames[frameType.."Container"]
            if container then
                -- Apply theme to container
                container:SetBackdropColor(
                    themeData.colors.backdrop.r,
                    themeData.colors.backdrop.g,
                    themeData.colors.backdrop.b,
                    themeData.colors.backdrop.a
                )
                
                container:SetBackdropBorderColor(
                    themeData.colors.border.r,
                    themeData.colors.border.g,
                    themeData.colors.border.b,
                    themeData.colors.border.a
                )
                
                -- Apply theme to individual frames
                for i = 1, 5 do
                    local frame = self.frames[frameType][i]
                    if frame then
                        self:ApplyThemeToFrame(frame, themeData)
                    end
                end
            end
        else
            local frame = self.frames[frameType]
            if frame then
                self:ApplyThemeToFrame(frame, themeData)
            end
        end
    end
end

-- Apply theme to a specific frame
function UnitFrames:ApplyThemeToFrame(frame, themeData)
    if not frame then return end
    
    -- Apply backdrop colors
    frame:SetBackdropColor(
        themeData.colors.backdrop.r,
        themeData.colors.backdrop.g,
        themeData.colors.backdrop.b,
        themeData.colors.backdrop.a
    )
    
    -- Apply border colors - either theme or class color
    if self.settings.classColoredBorders and frame.unit and UnitIsPlayer(frame.unit) then
        local _, class = UnitClass(frame.unit)
        if class and RAID_CLASS_COLORS[class] then
            local color = RAID_CLASS_COLORS[class]
            frame:SetBackdropBorderColor(color.r, color.g, color.b, 1.0)
        end
    else
        frame:SetBackdropBorderColor(
            themeData.colors.border.r,
            themeData.colors.border.g,
            themeData.colors.border.b,
            themeData.colors.border.a
        )
    end
    
    -- Apply theme to portrait if present
    if frame.Portrait then
        frame.Portrait:SetBackdropColor(
            themeData.colors.backdrop.r,
            themeData.colors.backdrop.g,
            themeData.colors.backdrop.b,
            themeData.colors.backdrop.a
        )
        
        frame.Portrait:SetBackdropBorderColor(
            themeData.colors.border.r,
            themeData.colors.border.g,
            themeData.colors.border.b,
            themeData.colors.border.a
        )
    end
    
    -- Apply text colors
    if frame.Name then
        frame.Name:SetTextColor(
            themeData.colors.text.r,
            themeData.colors.text.g,
            themeData.colors.text.b,
            themeData.colors.text.a
        )
    end
    
    if frame.Health then
        frame.Health:SetTextColor(
            themeData.colors.text.r,
            themeData.colors.text.g,
            themeData.colors.text.b,
            themeData.colors.text.a
        )
    end
    
    if frame.Power then
        frame.Power:SetTextColor(
            themeData.colors.text.r,
            themeData.colors.text.g,
            themeData.colors.text.b,
            themeData.colors.text.a
        )
    end
    
    if frame.Level then
        frame.Level:SetTextColor(
            themeData.colors.text.r,
            themeData.colors.text.g,
            themeData.colors.text.b,
            themeData.colors.text.a
        )
    end
end

-- Event handlers
function UnitFrames:UpdateHealth(unit)
    if not unit then return end
    
    -- Update the appropriate frame based on the unit
    if unit == "player" then
        self:UpdatePlayerFrame()
    elseif unit == "target" then
        self:UpdateTargetFrame()
    elseif unit == "focus" then
        self:UpdateFocusFrame()
    elseif unit == "pet" then
        self:UpdatePetFrame()
    elseif unit == "targettarget" then
        self:UpdateTargetTargetFrame()
    elseif string.find(unit, "party") then
        self:UpdatePartyFrames()
    elseif string.find(unit, "boss") then
        self:UpdateBossFrames()
    elseif string.find(unit, "arena") then
        self:UpdateArenaFrames()
    end
end

function UnitFrames:UpdatePower(unit)
    -- Same as UpdateHealth
    self:UpdateHealth(unit)
end

function UnitFrames:UpdateName(unit)
    -- Same as UpdateHealth
    self:UpdateHealth(unit)
end

function UnitFrames:UpdateLevel(unit)
    -- Same as UpdateHealth
    self:UpdateHealth(unit)
end

function UnitFrames:UpdateClassification(unit)
    -- Same as UpdateHealth
    self:UpdateHealth(unit)
end

function UnitFrames:UpdateReaction(unit)
    -- Same as UpdateHealth
    self:UpdateHealth(unit)
end

function UnitFrames:UpdatePortrait(unit)
    -- Same as UpdateHealth
    self:UpdateHealth(unit)
end

function UnitFrames:UpdateTarget()
    self:UpdateTargetFrame()
    self:UpdateTargetTargetFrame()
end

function UnitFrames:UpdateFocus()
    self:UpdateFocusFrame()
end

function UnitFrames:UpdateParty()
    self:UpdatePartyFrames()
end
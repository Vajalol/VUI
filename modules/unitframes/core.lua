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
    
    -- Initialize animations for all frames
    self:InitializeAllAnimations()
    
    -- Apply theme
    self:ApplyTheme()
    
    -- Update visibility based on settings
    self:UpdateFrameVisibility()
    
    -- Setup animation updater
    self:SetupAnimationUpdater()
end

-- Initialize animations for all unit frames
function UnitFrames:InitializeAllAnimations()
    -- Player frame
    if self.frames.player then
        self:InitializeFrameAnimations(self.frames.player)
    end
    
    -- Target frame
    if self.frames.target then
        self:InitializeFrameAnimations(self.frames.target)
    end
    
    -- Focus frame
    if self.frames.focus then
        self:InitializeFrameAnimations(self.frames.focus)
    end
    
    -- Pet frame
    if self.frames.pet then
        self:InitializeFrameAnimations(self.frames.pet)
    end
    
    -- Target of target frame
    if self.frames.targettarget then
        self:InitializeFrameAnimations(self.frames.targettarget)
    end
    
    -- Party frames
    if self.frames.party then
        for i = 1, 5 do
            if self.frames.party[i] then
                self:InitializeFrameAnimations(self.frames.party[i])
            end
        end
    end
    
    -- Boss frames
    if self.frames.boss then
        for i = 1, 5 do
            if self.frames.boss[i] then
                self:InitializeFrameAnimations(self.frames.boss[i])
            end
        end
    end
    
    -- Arena frames
    if self.frames.arena then
        for i = 1, 5 do
            if self.frames.arena[i] then
                self:InitializeFrameAnimations(self.frames.arena[i])
            end
        end
    end
end

-- Setup animation update frame
function UnitFrames:SetupAnimationUpdater()
    if self.animationUpdater then return end
    
    -- Create an OnUpdate handler for animations
    self.animationUpdater = CreateFrame("Frame", nil, UIParent)
    self.animationUpdater:SetScript("OnUpdate", function(_, elapsed)
        -- Add any per-frame animation updates here
        
        -- Add throttled updates (advanced animation handling)
        if self.lastAnimationUpdate and (GetTime() - self.lastAnimationUpdate) < 0.05 then
            return
        end
        
        self.lastAnimationUpdate = GetTime()
        
        -- Update any ongoing transitions for animated frames
        for frame in pairs(self.animatedFrames or {}) do
            if frame and frame.transitions then
                -- Process ongoing transitions
                for valueType, transition in pairs(frame.transitions) do
                    if transition.inProgress then
                        -- Each transition updates its own values based on specific frame elements
                        if valueType == "health" and frame.HealthBar then
                            local value = self:UpdateSmoothValue(frame, "health", transition.target)
                            if frame.HealthBar.SetValue then
                                frame.HealthBar:SetValue(value)
                            end
                        elseif valueType == "power" and frame.PowerBar then
                            local value = self:UpdateSmoothValue(frame, "power", transition.target)
                            if frame.PowerBar.SetValue then
                                frame.PowerBar:SetValue(value)
                            end
                        end
                    end
                end
            end
        end
    end)
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
    
    -- Initialize animations if not already done
    if not frame.animationsInitialized then
        self:InitializeFrameAnimations(frame)
    end
    
    -- Save previous values for animation triggers
    local oldHealth = frame.currentHealth or 0
    local oldPower = frame.currentPower or 0
    local oldCombatState = frame.inCombat or false
    
    -- Update name with proper coloring
    if frame.Name then
        local name = UnitName(unit)
        
        -- Apply class or reaction coloring
        if UnitIsPlayer(unit) then
            local _, class = UnitClass(unit)
            if class and RAID_CLASS_COLORS[class] then
                local color = RAID_CLASS_COLORS[class]
                frame.Name:SetText(name)
                frame.Name:SetTextColor(color.r, color.g, color.b)
            else
                frame.Name:SetText(name)
                frame.Name:SetTextColor(1, 1, 1)
            end
        else
            -- Color by reaction for NPCs
            local r, g, b = UnitSelectionColor(unit)
            frame.Name:SetText(name)
            frame.Name:SetTextColor(r, g, b)
        end
    end
    
    -- Update health bar with smooth transitions
    local healthBar = frame.HealthBar or (frame:GetName() and _G[frame:GetName().."HealthBar"])
    if healthBar then
        local health = UnitHealth(unit)
        local maxHealth = UnitHealthMax(unit)
        
        -- Store values for reference
        frame.currentHealth = health
        frame.maxHealth = maxHealth
        
        if maxHealth > 0 then
            healthBar:SetMinMaxValues(0, maxHealth)
            
            -- Apply smooth transition if animations are enabled
            if self.settings.enableSmoothUpdates and frame.transitions and frame.transitions.health then
                -- Set target value (actual animation happens in the updater)
                frame.transitions.health.target = health
                
                -- If this is a major health change, trigger the visual effect
                if oldHealth > 0 and oldHealth > health and (oldHealth - health) / maxHealth > 0.05 then
                    self:AnimateHealthChange(frame, oldHealth, health)
                end
            else
                -- Direct update without animation
                healthBar:SetValue(health)
            end
            
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
    
    -- Update power bar with smooth transitions
    local powerBar = frame.PowerBar or (frame:GetName() and _G[frame:GetName().."PowerBar"])
    if powerBar then
        local power = UnitPower(unit)
        local maxPower = UnitPowerMax(unit)
        local powerType = UnitPowerType(unit)
        
        -- Store values for reference
        frame.currentPower = power
        frame.maxPower = maxPower
        frame.powerType = powerType
        
        if maxPower > 0 then
            powerBar:SetMinMaxValues(0, maxPower)
            
            -- Apply smooth transition if animations are enabled
            if self.settings.enableSmoothUpdates and frame.transitions and frame.transitions.power then
                -- Set target value (actual animation happens in the updater)
                frame.transitions.power.target = power
                
                -- If this is a significant power gain, trigger the visual effect
                if power > oldPower and (power - oldPower) / maxPower > 0.1 then
                    self:AnimatePowerChange(frame, oldPower, power)
                end
            else
                -- Direct update without animation
                powerBar:SetValue(power)
            end
            
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
    
    -- Get theme name and info
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    
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
        
        -- Apply theme-specific portrait animations
        self:ApplyThemePortraitAnimations(frame, theme)
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
        
        -- Apply theme-specific health bar animations
        self:ApplyThemeHealthBarAnimations(frame, theme)
    end
    
    if frame.Power then
        frame.Power:SetTextColor(
            themeData.colors.text.r,
            themeData.colors.text.g,
            themeData.colors.text.b,
            themeData.colors.text.a
        )
        
        -- Apply theme-specific power bar animations
        self:ApplyThemePowerBarAnimations(frame, theme)
    end
    
    if frame.Level then
        frame.Level:SetTextColor(
            themeData.colors.text.r,
            themeData.colors.text.g,
            themeData.colors.text.b,
            themeData.colors.text.a
        )
    end
    
    -- Apply theme-specific combat animation visuals
    if frame.combatStateAnimation then
        self:ApplyThemeCombatAnimations(frame, theme)
    end
    
    -- Apply theme-specific border glow and effects
    if frame.borderGlow then
        self:ApplyThemeBorderEffects(frame, theme)
    end
end

-- Apply theme-specific portrait animations
function UnitFrames:ApplyThemePortraitAnimations(frame, theme)
    if not frame or not frame.Portrait then return end
    
    -- Clear any existing animations
    if frame.Portrait.animationGroup then
        frame.Portrait.animationGroup:Stop()
        frame.Portrait.animationGroup = nil
    end
    
    if frame.Portrait.highlightAnimation then
        frame.Portrait.highlightAnimation:Stop()
        frame.Portrait.highlightAnimation = nil
    end
    
    -- Create new animation group for the portrait
    frame.Portrait.animationGroup = frame.Portrait:CreateAnimationGroup()
    frame.Portrait.animationGroup:SetLooping("REPEAT")
    
    -- Add theme-specific animations
    if theme == "phoenixflame" then
        -- Phoenix Flame: Subtle burning effect on portraits
        local fadeIn = frame.Portrait.animationGroup:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0.8)
        fadeIn:SetToAlpha(1.0)
        fadeIn:SetDuration(1.5)
        fadeIn:SetSmoothing("IN_OUT")
        fadeIn:SetOrder(1)
        
        local fadeOut = frame.Portrait.animationGroup:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(1.0)
        fadeOut:SetToAlpha(0.8)
        fadeOut:SetDuration(1.5)
        fadeOut:SetSmoothing("IN_OUT")
        fadeOut:SetOrder(2)
        
        -- Create an overlay with flame texture
        if not frame.Portrait.flameOverlay then
            frame.Portrait.flameOverlay = frame.Portrait:CreateTexture(nil, "OVERLAY")
            frame.Portrait.flameOverlay:SetPoint("TOPLEFT", frame.Portrait, "TOPLEFT", -2, 2)
            frame.Portrait.flameOverlay:SetPoint("BOTTOMRIGHT", frame.Portrait, "BOTTOMRIGHT", 2, -2)
            frame.Portrait.flameOverlay:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\animation\\flame1.tga")
            frame.Portrait.flameOverlay:SetBlendMode("ADD")
            frame.Portrait.flameOverlay:SetAlpha(0.3)
        end
        
        -- Animate the flame overlay
        local flameAnim = frame.Portrait.animationGroup:CreateAnimation("TexCoordTranslation")
        flameAnim:SetTexCoord(0, 1, 0, 1)
        flameAnim:SetDuration(3.0)
        flameAnim:SetOrder(1)
        
    elseif theme == "thunderstorm" then
        -- Thunder Storm: Electric pulses
        local pulse1 = frame.Portrait.animationGroup:CreateAnimation("Scale")
        pulse1:SetScaleFrom(1.0, 1.0)
        pulse1:SetScaleTo(1.03, 1.03)
        pulse1:SetDuration(0.5)
        pulse1:SetSmoothing("IN_OUT")
        pulse1:SetOrder(1)
        
        local pulse2 = frame.Portrait.animationGroup:CreateAnimation("Scale")
        pulse2:SetScaleFrom(1.03, 1.03)
        pulse2:SetScaleTo(1.0, 1.0)
        pulse2:SetDuration(0.5)
        pulse2:SetSmoothing("IN_OUT")
        pulse2:SetOrder(2)
        
        -- Create lightning overlay
        if not frame.Portrait.lightningOverlay then
            frame.Portrait.lightningOverlay = frame.Portrait:CreateTexture(nil, "OVERLAY")
            frame.Portrait.lightningOverlay:SetPoint("TOPLEFT", frame.Portrait, "TOPLEFT", -2, 2)
            frame.Portrait.lightningOverlay:SetPoint("BOTTOMRIGHT", frame.Portrait, "BOTTOMRIGHT", 2, -2)
            frame.Portrait.lightningOverlay:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\animation\\lightning1.tga")
            frame.Portrait.lightningOverlay:SetBlendMode("ADD")
            frame.Portrait.lightningOverlay:SetAlpha(0)
        end
        
        -- Periodic lightning flash
        local lightningIn = frame.Portrait.animationGroup:CreateAnimation("Alpha")
        lightningIn:SetTarget(frame.Portrait.lightningOverlay)
        lightningIn:SetFromAlpha(0)
        lightningIn:SetToAlpha(0.4)
        lightningIn:SetDuration(0.1)
        lightningIn:SetSmoothing("IN")
        lightningIn:SetOrder(3)
        
        local lightningOut = frame.Portrait.animationGroup:CreateAnimation("Alpha")
        lightningOut:SetTarget(frame.Portrait.lightningOverlay)
        lightningOut:SetFromAlpha(0.4)
        lightningOut:SetToAlpha(0)
        lightningOut:SetDuration(0.2)
        lightningOut:SetSmoothing("OUT")
        lightningOut:SetOrder(4)
        
    elseif theme == "arcanemystic" then
        -- Arcane Mystic: Magical pulsing
        local arcaneRotate = frame.Portrait.animationGroup:CreateAnimation("Rotation")
        arcaneRotate:SetDegrees(360)
        arcaneRotate:SetDuration(12)
        arcaneRotate:SetOrder(1)
        
        -- Create arcane overlay
        if not frame.Portrait.arcaneOverlay then
            frame.Portrait.arcaneOverlay = frame.Portrait:CreateTexture(nil, "OVERLAY")
            frame.Portrait.arcaneOverlay:SetPoint("TOPLEFT", frame.Portrait, "TOPLEFT", -4, 4)
            frame.Portrait.arcaneOverlay:SetPoint("BOTTOMRIGHT", frame.Portrait, "BOTTOMRIGHT", 4, -4)
            frame.Portrait.arcaneOverlay:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\animation\\arcane1.tga")
            frame.Portrait.arcaneOverlay:SetBlendMode("ADD")
            frame.Portrait.arcaneOverlay:SetAlpha(0.25)
        end
        
        -- Arcane pulse animation
        local pulseIn = frame.Portrait.animationGroup:CreateAnimation("Alpha")
        pulseIn:SetTarget(frame.Portrait.arcaneOverlay)
        pulseIn:SetFromAlpha(0.25)
        pulseIn:SetToAlpha(0.5)
        pulseIn:SetDuration(2.0)
        pulseIn:SetSmoothing("IN_OUT")
        pulseIn:SetOrder(1)
        
        local pulseOut = frame.Portrait.animationGroup:CreateAnimation("Alpha")
        pulseOut:SetTarget(frame.Portrait.arcaneOverlay)
        pulseOut:SetFromAlpha(0.5)
        pulseOut:SetToAlpha(0.25)
        pulseOut:SetDuration(2.0)
        pulseOut:SetSmoothing("IN_OUT")
        pulseOut:SetOrder(2)
        
    elseif theme == "felenergy" then
        -- Fel Energy: Toxic pulsing
        local felPulse1 = frame.Portrait.animationGroup:CreateAnimation("Scale")
        felPulse1:SetScaleFrom(0.97, 0.97)
        felPulse1:SetScaleTo(1.0, 1.0)
        felPulse1:SetDuration(2.0)
        felPulse1:SetSmoothing("IN_OUT")
        felPulse1:SetOrder(1)
        
        local felPulse2 = frame.Portrait.animationGroup:CreateAnimation("Scale")
        felPulse2:SetScaleFrom(1.0, 1.0)
        felPulse2:SetScaleTo(0.97, 0.97)
        felPulse2:SetDuration(2.0)
        felPulse2:SetSmoothing("IN_OUT")
        felPulse2:SetOrder(2)
        
        -- Create fel overlay
        if not frame.Portrait.felOverlay then
            frame.Portrait.felOverlay = frame.Portrait:CreateTexture(nil, "OVERLAY")
            frame.Portrait.felOverlay:SetPoint("TOPLEFT", frame.Portrait, "TOPLEFT", -3, 3)
            frame.Portrait.felOverlay:SetPoint("BOTTOMRIGHT", frame.Portrait, "BOTTOMRIGHT", 3, -3)
            frame.Portrait.felOverlay:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\felenergy\\animation\\fel1.tga")
            frame.Portrait.felOverlay:SetBlendMode("ADD")
            frame.Portrait.felOverlay:SetAlpha(0.3)
        end
        
        -- Fel energy animation
        local felGlow = frame.Portrait.animationGroup:CreateAnimation("Alpha")
        felGlow:SetTarget(frame.Portrait.felOverlay)
        felGlow:SetFromAlpha(0.3)
        felGlow:SetToAlpha(0.5)
        felGlow:SetDuration(2.0)
        felGlow:SetSmoothing("IN_OUT")
        felGlow:SetOrder(1)
        
        local felFade = frame.Portrait.animationGroup:CreateAnimation("Alpha")
        felFade:SetTarget(frame.Portrait.felOverlay)
        felFade:SetFromAlpha(0.5)
        felFade:SetToAlpha(0.3)
        felFade:SetDuration(2.0)
        felFade:SetSmoothing("IN_OUT")
        felFade:SetOrder(2)
    end
    
    -- Create highlight animation for target/focus changes
    frame.Portrait.highlightAnimation = frame.Portrait:CreateAnimationGroup()
    frame.Portrait.highlightAnimation:SetLooping("NONE")
    
    -- Add theme-specific highlight animations
    if theme == "phoenixflame" then
        -- Phoenix Flame: Fiery flare when targeted
        local flare = frame.Portrait.highlightAnimation:CreateAnimation("Alpha")
        if frame.Portrait.flameOverlay then
            flare:SetTarget(frame.Portrait.flameOverlay)
            flare:SetFromAlpha(0.3)
            flare:SetToAlpha(0.8)
            flare:SetDuration(0.3)
            flare:SetSmoothing("IN")
            flare:SetOrder(1)
            
            local flareOut = frame.Portrait.highlightAnimation:CreateAnimation("Alpha")
            flareOut:SetTarget(frame.Portrait.flameOverlay)
            flareOut:SetFromAlpha(0.8)
            flareOut:SetToAlpha(0.3)
            flareOut:SetDuration(0.7)
            flareOut:SetSmoothing("OUT")
            flareOut:SetOrder(2)
        end
        
    elseif theme == "thunderstorm" then
        -- Thunder Storm: Lightning flash when targeted
        if frame.Portrait.lightningOverlay then
            local flash1 = frame.Portrait.highlightAnimation:CreateAnimation("Alpha")
            flash1:SetTarget(frame.Portrait.lightningOverlay)
            flash1:SetFromAlpha(0)
            flash1:SetToAlpha(0.7)
            flash1:SetDuration(0.1)
            flash1:SetOrder(1)
            
            local flash2 = frame.Portrait.highlightAnimation:CreateAnimation("Alpha")
            flash2:SetTarget(frame.Portrait.lightningOverlay)
            flash2:SetFromAlpha(0.7)
            flash2:SetToAlpha(0)
            flash2:SetDuration(0.1)
            flash2:SetOrder(2)
            
            local flash3 = frame.Portrait.highlightAnimation:CreateAnimation("Alpha")
            flash3:SetTarget(frame.Portrait.lightningOverlay)
            flash3:SetFromAlpha(0)
            flash3:SetToAlpha(0.5)
            flash3:SetDuration(0.1)
            flash3:SetOrder(3)
            
            local flash4 = frame.Portrait.highlightAnimation:CreateAnimation("Alpha")
            flash4:SetTarget(frame.Portrait.lightningOverlay)
            flash4:SetFromAlpha(0.5)
            flash4:SetToAlpha(0)
            flash4:SetDuration(0.3)
            flash4:SetOrder(4)
        end
        
    elseif theme == "arcanemystic" then
        -- Arcane Mystic: Magical flash when targeted
        if frame.Portrait.arcaneOverlay then
            local arcaneFlare = frame.Portrait.highlightAnimation:CreateAnimation("Alpha")
            arcaneFlare:SetTarget(frame.Portrait.arcaneOverlay)
            arcaneFlare:SetFromAlpha(0.25)
            arcaneFlare:SetToAlpha(0.8)
            arcaneFlare:SetDuration(0.3)
            arcaneFlare:SetSmoothing("IN")
            arcaneFlare:SetOrder(1)
            
            local arcaneFade = frame.Portrait.highlightAnimation:CreateAnimation("Alpha")
            arcaneFade:SetTarget(frame.Portrait.arcaneOverlay)
            arcaneFade:SetFromAlpha(0.8)
            arcaneFade:SetToAlpha(0.25)
            arcaneFade:SetDuration(0.7)
            arcaneFade:SetSmoothing("OUT")
            arcaneFade:SetOrder(2)
        end
        
    elseif theme == "felenergy" then
        -- Fel Energy: Green flare when targeted
        if frame.Portrait.felOverlay then
            local felFlare = frame.Portrait.highlightAnimation:CreateAnimation("Alpha")
            felFlare:SetTarget(frame.Portrait.felOverlay)
            felFlare:SetFromAlpha(0.3)
            felFlare:SetToAlpha(0.9)
            felFlare:SetDuration(0.3)
            felFlare:SetSmoothing("IN")
            felFlare:SetOrder(1)
            
            local felFade = frame.Portrait.highlightAnimation:CreateAnimation("Alpha")
            felFade:SetTarget(frame.Portrait.felOverlay)
            felFade:SetFromAlpha(0.9)
            felFade:SetToAlpha(0.3)
            felFade:SetDuration(0.7)
            felFade:SetSmoothing("OUT")
            felFade:SetOrder(2)
        end
    end
    
    -- Start the animation if not in combat
    if not UnitAffectingCombat("player") and frame.Portrait.animationGroup then
        frame.Portrait.animationGroup:Play()
    end
end

-- Apply theme-specific health bar animations
function UnitFrames:ApplyThemeHealthBarAnimations(frame, theme)
    if not frame or not frame.HealthBar then return end
    
    -- Clear any existing health bar animations
    if frame.HealthBar.themeAnimation then
        frame.HealthBar.themeAnimation:Stop()
        frame.HealthBar.themeAnimation = nil
    end
    
    -- Create a new animation group for the health bar
    frame.HealthBar.themeAnimation = frame.HealthBar:CreateAnimationGroup()
    frame.HealthBar.themeAnimation:SetLooping("REPEAT")
    
    -- Add theme-specific health bar animations
    if theme == "phoenixflame" then
        -- Phoenix Flame: Subtle fire effect on health bars
        if not frame.HealthBar.flameOverlay then
            frame.HealthBar.flameOverlay = frame.HealthBar:CreateTexture(nil, "OVERLAY")
            frame.HealthBar.flameOverlay:SetAllPoints(frame.HealthBar)
            frame.HealthBar.flameOverlay:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\flame.tga")
            frame.HealthBar.flameOverlay:SetBlendMode("ADD")
            frame.HealthBar.flameOverlay:SetAlpha(0.2)
            frame.HealthBar.flameOverlay:SetVertexColor(1.0, 0.5, 0.0) -- Orange-red
        end
        
        -- Create pulsing effect for the flame overlay
        local flamePulse1 = frame.HealthBar.themeAnimation:CreateAnimation("Alpha")
        flamePulse1:SetTarget(frame.HealthBar.flameOverlay)
        flamePulse1:SetFromAlpha(0.1)
        flamePulse1:SetToAlpha(0.3)
        flamePulse1:SetDuration(2.0)
        flamePulse1:SetSmoothing("IN_OUT")
        flamePulse1:SetOrder(1)
        
        local flamePulse2 = frame.HealthBar.themeAnimation:CreateAnimation("Alpha")
        flamePulse2:SetTarget(frame.HealthBar.flameOverlay)
        flamePulse2:SetFromAlpha(0.3)
        flamePulse2:SetToAlpha(0.1)
        flamePulse2:SetDuration(2.0)
        flamePulse2:SetSmoothing("IN_OUT")
        flamePulse2:SetOrder(2)
        
    elseif theme == "thunderstorm" then
        -- Thunder Storm: Lightning effect on health bars
        if not frame.HealthBar.lightningOverlay then
            frame.HealthBar.lightningOverlay = frame.HealthBar:CreateTexture(nil, "OVERLAY")
            frame.HealthBar.lightningOverlay:SetAllPoints(frame.HealthBar)
            frame.HealthBar.lightningOverlay:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\glow.tga")
            frame.HealthBar.lightningOverlay:SetBlendMode("ADD")
            frame.HealthBar.lightningOverlay:SetAlpha(0.0)
            frame.HealthBar.lightningOverlay:SetVertexColor(0.4, 0.6, 1.0) -- Blue-white
        end
        
        -- Create periodic lightning flashes
        local lightningIn = frame.HealthBar.themeAnimation:CreateAnimation("Alpha")
        lightningIn:SetTarget(frame.HealthBar.lightningOverlay)
        lightningIn:SetFromAlpha(0.0)
        lightningIn:SetToAlpha(0.3)
        lightningIn:SetDuration(0.2)
        lightningIn:SetSmoothing("IN")
        lightningIn:SetOrder(1)
        
        local lightningHold = frame.HealthBar.themeAnimation:CreateAnimation("Alpha")
        lightningHold:SetTarget(frame.HealthBar.lightningOverlay)
        lightningHold:SetFromAlpha(0.3)
        lightningHold:SetToAlpha(0.3)
        lightningHold:SetDuration(0.1)
        lightningHold:SetOrder(2)
        
        local lightningOut = frame.HealthBar.themeAnimation:CreateAnimation("Alpha")
        lightningOut:SetTarget(frame.HealthBar.lightningOverlay)
        lightningOut:SetFromAlpha(0.3)
        lightningOut:SetToAlpha(0.0)
        lightningOut:SetDuration(0.3)
        lightningOut:SetSmoothing("OUT")
        lightningOut:SetOrder(3)
        
        local lightningWait = frame.HealthBar.themeAnimation:CreateAnimation("Alpha")
        lightningWait:SetTarget(frame.HealthBar.lightningOverlay)
        lightningWait:SetFromAlpha(0.0)
        lightningWait:SetToAlpha(0.0)
        lightningWait:SetDuration(math.random(3, 8)) -- Random interval between flashes
        lightningWait:SetOrder(4)
        
    elseif theme == "arcanemystic" then
        -- Arcane Mystic: Magical glow effect on health bars
        if not frame.HealthBar.arcaneOverlay then
            frame.HealthBar.arcaneOverlay = frame.HealthBar:CreateTexture(nil, "OVERLAY")
            frame.HealthBar.arcaneOverlay:SetAllPoints(frame.HealthBar)
            frame.HealthBar.arcaneOverlay:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\glow.tga")
            frame.HealthBar.arcaneOverlay:SetBlendMode("ADD")
            frame.HealthBar.arcaneOverlay:SetAlpha(0.2)
            frame.HealthBar.arcaneOverlay:SetVertexColor(0.8, 0.4, 1.0) -- Purple
        end
        
        -- Create a smooth pulsing effect
        local arcanePulse1 = frame.HealthBar.themeAnimation:CreateAnimation("Alpha")
        arcanePulse1:SetTarget(frame.HealthBar.arcaneOverlay)
        arcanePulse1:SetFromAlpha(0.2)
        arcanePulse1:SetToAlpha(0.4)
        arcanePulse1:SetDuration(2.5)
        arcanePulse1:SetSmoothing("IN_OUT")
        arcanePulse1:SetOrder(1)
        
        local arcanePulse2 = frame.HealthBar.themeAnimation:CreateAnimation("Alpha")
        arcanePulse2:SetTarget(frame.HealthBar.arcaneOverlay)
        arcanePulse2:SetFromAlpha(0.4)
        arcanePulse2:SetToAlpha(0.2)
        arcanePulse2:SetDuration(2.5)
        arcanePulse2:SetSmoothing("IN_OUT")
        arcanePulse2:SetOrder(2)
        
    elseif theme == "felenergy" then
        -- Fel Energy: Toxic glow effect on health bars
        if not frame.HealthBar.felOverlay then
            frame.HealthBar.felOverlay = frame.HealthBar:CreateTexture(nil, "OVERLAY")
            frame.HealthBar.felOverlay:SetAllPoints(frame.HealthBar)
            frame.HealthBar.felOverlay:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\felenergy\\glow.tga")
            frame.HealthBar.felOverlay:SetBlendMode("ADD")
            frame.HealthBar.felOverlay:SetAlpha(0.15)
            frame.HealthBar.felOverlay:SetVertexColor(0.0, 0.8, 0.0) -- Fel green
        end
        
        -- Create a toxic pulsing effect
        local felPulse1 = frame.HealthBar.themeAnimation:CreateAnimation("Alpha")
        felPulse1:SetTarget(frame.HealthBar.felOverlay)
        felPulse1:SetFromAlpha(0.15)
        felPulse1:SetToAlpha(0.3)
        felPulse1:SetDuration(3.0)
        felPulse1:SetSmoothing("IN_OUT")
        felPulse1:SetOrder(1)
        
        local felPulse2 = frame.HealthBar.themeAnimation:CreateAnimation("Alpha")
        felPulse2:SetTarget(frame.HealthBar.felOverlay)
        felPulse2:SetFromAlpha(0.3)
        felPulse2:SetToAlpha(0.15)
        felPulse2:SetDuration(3.0)
        felPulse2:SetSmoothing("IN_OUT")
        felPulse2:SetOrder(2)
    end
    
    -- Only play the animation when not in combat
    if not UnitAffectingCombat("player") and frame.HealthBar.themeAnimation then
        frame.HealthBar.themeAnimation:Play()
    end
end

-- Apply theme-specific power bar animations
function UnitFrames:ApplyThemePowerBarAnimations(frame, theme)
    if not frame or not frame.PowerBar then return end
    
    -- Clear any existing power bar animations
    if frame.PowerBar.themeAnimation then
        frame.PowerBar.themeAnimation:Stop()
        frame.PowerBar.themeAnimation = nil
    end
    
    -- Create a new animation group for the power bar
    frame.PowerBar.themeAnimation = frame.PowerBar:CreateAnimationGroup()
    frame.PowerBar.themeAnimation:SetLooping("REPEAT")
    
    -- Add theme-specific power bar animations
    if theme == "phoenixflame" then
        -- Phoenix Flame: Subtle ember effect on power bars
        if not frame.PowerBar.emberOverlay then
            frame.PowerBar.emberOverlay = frame.PowerBar:CreateTexture(nil, "OVERLAY")
            frame.PowerBar.emberOverlay:SetAllPoints(frame.PowerBar)
            frame.PowerBar.emberOverlay:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\embers.tga")
            frame.PowerBar.emberOverlay:SetBlendMode("ADD")
            frame.PowerBar.emberOverlay:SetAlpha(0.15)
            
            -- Color based on power type
            if frame.unit then
                local powerType = UnitPowerType(frame.unit)
                if powerType == 0 then -- Mana
                    frame.PowerBar.emberOverlay:SetVertexColor(0.2, 0.4, 1.0) -- Blue
                elseif powerType == 1 then -- Rage
                    frame.PowerBar.emberOverlay:SetVertexColor(1.0, 0.0, 0.0) -- Red
                elseif powerType == 2 then -- Focus
                    frame.PowerBar.emberOverlay:SetVertexColor(1.0, 0.5, 0.0) -- Orange
                elseif powerType == 3 then -- Energy
                    frame.PowerBar.emberOverlay:SetVertexColor(1.0, 1.0, 0.0) -- Yellow
                elseif powerType == 6 then -- Runic Power
                    frame.PowerBar.emberOverlay:SetVertexColor(0.0, 0.8, 1.0) -- Light blue
                else
                    frame.PowerBar.emberOverlay:SetVertexColor(0.7, 0.7, 0.7) -- Gray default
                end
            else
                frame.PowerBar.emberOverlay:SetVertexColor(0.7, 0.7, 0.7) -- Gray default
            end
        end
        
        -- Create pulsing effect for the ember overlay
        local emberPulse1 = frame.PowerBar.themeAnimation:CreateAnimation("Alpha")
        emberPulse1:SetTarget(frame.PowerBar.emberOverlay)
        emberPulse1:SetFromAlpha(0.15)
        emberPulse1:SetToAlpha(0.3)
        emberPulse1:SetDuration(2.0)
        emberPulse1:SetSmoothing("IN_OUT")
        emberPulse1:SetOrder(1)
        
        local emberPulse2 = frame.PowerBar.themeAnimation:CreateAnimation("Alpha")
        emberPulse2:SetTarget(frame.PowerBar.emberOverlay)
        emberPulse2:SetFromAlpha(0.3)
        emberPulse2:SetToAlpha(0.15)
        emberPulse2:SetDuration(2.0)
        emberPulse2:SetSmoothing("IN_OUT")
        emberPulse2:SetOrder(2)
        
    elseif theme == "thunderstorm" then
        -- Thunder Storm: Energy sparks effect on power bars
        if not frame.PowerBar.sparkOverlay then
            frame.PowerBar.sparkOverlay = frame.PowerBar:CreateTexture(nil, "OVERLAY")
            frame.PowerBar.sparkOverlay:SetAllPoints(frame.PowerBar)
            frame.PowerBar.sparkOverlay:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\glow.tga")
            frame.PowerBar.sparkOverlay:SetBlendMode("ADD")
            frame.PowerBar.sparkOverlay:SetAlpha(0.0)
            
            -- Color based on power type
            if frame.unit then
                local powerType = UnitPowerType(frame.unit)
                if powerType == 0 then -- Mana
                    frame.PowerBar.sparkOverlay:SetVertexColor(0.2, 0.4, 1.0) -- Blue
                elseif powerType == 1 then -- Rage
                    frame.PowerBar.sparkOverlay:SetVertexColor(1.0, 0.0, 0.0) -- Red
                elseif powerType == 2 then -- Focus
                    frame.PowerBar.sparkOverlay:SetVertexColor(1.0, 0.5, 0.0) -- Orange
                elseif powerType == 3 then -- Energy
                    frame.PowerBar.sparkOverlay:SetVertexColor(1.0, 1.0, 0.0) -- Yellow
                elseif powerType == 6 then -- Runic Power
                    frame.PowerBar.sparkOverlay:SetVertexColor(0.0, 0.8, 1.0) -- Light blue
                else
                    frame.PowerBar.sparkOverlay:SetVertexColor(0.7, 0.7, 0.7) -- Gray default
                end
            else
                frame.PowerBar.sparkOverlay:SetVertexColor(0.7, 0.7, 0.7) -- Gray default
            end
        end
        
        -- Create periodic spark flashes
        local sparkIn = frame.PowerBar.themeAnimation:CreateAnimation("Alpha")
        sparkIn:SetTarget(frame.PowerBar.sparkOverlay)
        sparkIn:SetFromAlpha(0.0)
        sparkIn:SetToAlpha(0.3)
        sparkIn:SetDuration(0.2)
        sparkIn:SetSmoothing("IN")
        sparkIn:SetOrder(1)
        
        local sparkHold = frame.PowerBar.themeAnimation:CreateAnimation("Alpha")
        sparkHold:SetTarget(frame.PowerBar.sparkOverlay)
        sparkHold:SetFromAlpha(0.3)
        sparkHold:SetToAlpha(0.3)
        sparkHold:SetDuration(0.1)
        sparkHold:SetOrder(2)
        
        local sparkOut = frame.PowerBar.themeAnimation:CreateAnimation("Alpha")
        sparkOut:SetTarget(frame.PowerBar.sparkOverlay)
        sparkOut:SetFromAlpha(0.3)
        sparkOut:SetToAlpha(0.0)
        sparkOut:SetDuration(0.3)
        sparkOut:SetSmoothing("OUT")
        sparkOut:SetOrder(3)
        
        local sparkWait = frame.PowerBar.themeAnimation:CreateAnimation("Alpha")
        sparkWait:SetTarget(frame.PowerBar.sparkOverlay)
        sparkWait:SetFromAlpha(0.0)
        sparkWait:SetToAlpha(0.0)
        sparkWait:SetDuration(math.random(2, 6)) -- Random interval between sparks
        sparkWait:SetOrder(4)
        
    elseif theme == "arcanemystic" then
        -- Arcane Mystic: Runes effect on power bars
        if not frame.PowerBar.runeOverlay then
            frame.PowerBar.runeOverlay = frame.PowerBar:CreateTexture(nil, "OVERLAY")
            frame.PowerBar.runeOverlay:SetAllPoints(frame.PowerBar)
            frame.PowerBar.runeOverlay:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\glow.tga")
            frame.PowerBar.runeOverlay:SetBlendMode("ADD")
            frame.PowerBar.runeOverlay:SetAlpha(0.2)
            
            -- Color based on power type
            if frame.unit then
                local powerType = UnitPowerType(frame.unit)
                if powerType == 0 then -- Mana
                    frame.PowerBar.runeOverlay:SetVertexColor(0.4, 0.4, 0.8) -- Blue-purple
                elseif powerType == 1 then -- Rage
                    frame.PowerBar.runeOverlay:SetVertexColor(0.8, 0.2, 0.4) -- Red-purple
                elseif powerType == 2 then -- Focus
                    frame.PowerBar.runeOverlay:SetVertexColor(0.8, 0.4, 0.2) -- Orange-purple
                elseif powerType == 3 then -- Energy
                    frame.PowerBar.runeOverlay:SetVertexColor(0.8, 0.8, 0.2) -- Yellow-purple
                elseif powerType == 6 then -- Runic Power
                    frame.PowerBar.runeOverlay:SetVertexColor(0.2, 0.6, 0.8) -- Light blue-purple
                else
                    frame.PowerBar.runeOverlay:SetVertexColor(0.6, 0.4, 0.8) -- Purple default
                end
            else
                frame.PowerBar.runeOverlay:SetVertexColor(0.6, 0.4, 0.8) -- Purple default
            end
        end
        
        -- Create rune glow animation
        local runeGlow1 = frame.PowerBar.themeAnimation:CreateAnimation("Alpha")
        runeGlow1:SetTarget(frame.PowerBar.runeOverlay)
        runeGlow1:SetFromAlpha(0.2)
        runeGlow1:SetToAlpha(0.4)
        runeGlow1:SetDuration(3.0)
        runeGlow1:SetSmoothing("IN_OUT")
        runeGlow1:SetOrder(1)
        
        local runeGlow2 = frame.PowerBar.themeAnimation:CreateAnimation("Alpha")
        runeGlow2:SetTarget(frame.PowerBar.runeOverlay)
        runeGlow2:SetFromAlpha(0.4)
        runeGlow2:SetToAlpha(0.2)
        runeGlow2:SetDuration(3.0)
        runeGlow2:SetSmoothing("IN_OUT")
        runeGlow2:SetOrder(2)
        
    elseif theme == "felenergy" then
        -- Fel Energy: Toxic glow effect on power bars
        if not frame.PowerBar.felOverlay then
            frame.PowerBar.felOverlay = frame.PowerBar:CreateTexture(nil, "OVERLAY")
            frame.PowerBar.felOverlay:SetAllPoints(frame.PowerBar)
            frame.PowerBar.felOverlay:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\felenergy\\glow.tga")
            frame.PowerBar.felOverlay:SetBlendMode("ADD")
            frame.PowerBar.felOverlay:SetAlpha(0.15)
            
            -- Color based on power type but with fel green tint
            if frame.unit then
                local powerType = UnitPowerType(frame.unit)
                if powerType == 0 then -- Mana
                    frame.PowerBar.felOverlay:SetVertexColor(0.0, 0.6, 0.4) -- Green-blue
                elseif powerType == 1 then -- Rage
                    frame.PowerBar.felOverlay:SetVertexColor(0.5, 0.6, 0.0) -- Green-red
                elseif powerType == 2 then -- Focus
                    frame.PowerBar.felOverlay:SetVertexColor(0.5, 0.7, 0.0) -- Green-orange
                elseif powerType == 3 then -- Energy
                    frame.PowerBar.felOverlay:SetVertexColor(0.5, 0.8, 0.0) -- Green-yellow
                elseif powerType == 6 then -- Runic Power
                    frame.PowerBar.felOverlay:SetVertexColor(0.0, 0.8, 0.4) -- Green-blue
                else
                    frame.PowerBar.felOverlay:SetVertexColor(0.0, 0.8, 0.0) -- Fel green default
                end
            else
                frame.PowerBar.felOverlay:SetVertexColor(0.0, 0.8, 0.0) -- Fel green default
            end
        end
        
        -- Create a toxic pulsing effect
        local felPulse1 = frame.PowerBar.themeAnimation:CreateAnimation("Alpha")
        felPulse1:SetTarget(frame.PowerBar.felOverlay)
        felPulse1:SetFromAlpha(0.15)
        felPulse1:SetToAlpha(0.3)
        felPulse1:SetDuration(3.0)
        felPulse1:SetSmoothing("IN_OUT")
        felPulse1:SetOrder(1)
        
        local felPulse2 = frame.PowerBar.themeAnimation:CreateAnimation("Alpha")
        felPulse2:SetTarget(frame.PowerBar.felOverlay)
        felPulse2:SetFromAlpha(0.3)
        felPulse2:SetToAlpha(0.15)
        felPulse2:SetDuration(3.0)
        felPulse2:SetSmoothing("IN_OUT")
        felPulse2:SetOrder(2)
    end
    
    -- Only play the animation when not in combat
    if not UnitAffectingCombat("player") and frame.PowerBar.themeAnimation then
        frame.PowerBar.themeAnimation:Play()
    end
end

-- Apply theme-specific combat animations
function UnitFrames:ApplyThemeCombatAnimations(frame, theme)
    if not frame or not frame.combatStateAnimation then return end
    
    -- Clear existing animation
    frame.combatStateAnimation:Stop()
    frame.combatStateAnimation = nil
    
    -- Create new animation group
    frame.combatStateAnimation = frame:CreateAnimationGroup()
    frame.combatStateAnimation:SetLooping("REPEAT")
    
    if theme == "phoenixflame" then
        -- Phoenix Flame: Fiery border in combat
        if not frame.fireBorder then
            frame.fireBorder = frame:CreateTexture(nil, "OVERLAY")
            frame.fireBorder:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\border.tga")
            frame.fireBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 5)
            frame.fireBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 5, -5)
            frame.fireBorder:SetBlendMode("ADD")
            frame.fireBorder:SetVertexColor(1.0, 0.4, 0.0) -- Orange-red
            frame.fireBorder:SetAlpha(0)
        end
        
        -- Create pulsing animation for the border
        local fireIn = frame.combatStateAnimation:CreateAnimation("Alpha")
        fireIn:SetTarget(frame.fireBorder)
        fireIn:SetFromAlpha(0.3)
        fireIn:SetToAlpha(0.7)
        fireIn:SetDuration(1.0)
        fireIn:SetSmoothing("IN_OUT")
        fireIn:SetOrder(1)
        
        local fireOut = frame.combatStateAnimation:CreateAnimation("Alpha")
        fireOut:SetTarget(frame.fireBorder)
        fireOut:SetFromAlpha(0.7)
        fireOut:SetToAlpha(0.3)
        fireOut:SetDuration(1.0)
        fireOut:SetSmoothing("IN_OUT")
        fireOut:SetOrder(2)
        
    elseif theme == "thunderstorm" then
        -- Thunder Storm: Electric border in combat
        if not frame.lightningBorder then
            frame.lightningBorder = frame:CreateTexture(nil, "OVERLAY")
            frame.lightningBorder:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\border.tga")
            frame.lightningBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 5)
            frame.lightningBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 5, -5)
            frame.lightningBorder:SetBlendMode("ADD")
            frame.lightningBorder:SetVertexColor(0.3, 0.6, 1.0) -- Blue
            frame.lightningBorder:SetAlpha(0)
        end
        
        -- Create lightning flash animation for the border
        local lightningIn = frame.combatStateAnimation:CreateAnimation("Alpha")
        lightningIn:SetTarget(frame.lightningBorder)
        lightningIn:SetFromAlpha(0.2)
        lightningIn:SetToAlpha(0.6)
        lightningIn:SetDuration(0.2)
        lightningIn:SetSmoothing("IN")
        lightningIn:SetOrder(1)
        
        local lightningOut = frame.combatStateAnimation:CreateAnimation("Alpha")
        lightningOut:SetTarget(frame.lightningBorder)
        lightningOut:SetFromAlpha(0.6)
        lightningOut:SetToAlpha(0.2)
        lightningOut:SetDuration(0.3)
        lightningOut:SetSmoothing("OUT")
        lightningOut:SetOrder(2)
        
        local lightningWait = frame.combatStateAnimation:CreateAnimation("Alpha")
        lightningWait:SetTarget(frame.lightningBorder)
        lightningWait:SetFromAlpha(0.2)
        lightningWait:SetToAlpha(0.2)
        lightningWait:SetDuration(math.random(1, 3)) -- Random interval between flashes
        lightningWait:SetOrder(3)
        
    elseif theme == "arcanemystic" then
        -- Arcane Mystic: Mystical border in combat
        if not frame.arcaneBorder then
            frame.arcaneBorder = frame:CreateTexture(nil, "OVERLAY")
            frame.arcaneBorder:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\border.tga")
            frame.arcaneBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 5)
            frame.arcaneBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 5, -5)
            frame.arcaneBorder:SetBlendMode("ADD")
            frame.arcaneBorder:SetVertexColor(0.7, 0.3, 1.0) -- Purple
            frame.arcaneBorder:SetAlpha(0)
        end
        
        -- Create smooth pulsing animation
        local arcaneIn = frame.combatStateAnimation:CreateAnimation("Alpha")
        arcaneIn:SetTarget(frame.arcaneBorder)
        arcaneIn:SetFromAlpha(0.2)
        arcaneIn:SetToAlpha(0.6)
        arcaneIn:SetDuration(2.0)
        arcaneIn:SetSmoothing("IN_OUT")
        arcaneIn:SetOrder(1)
        
        local arcaneOut = frame.combatStateAnimation:CreateAnimation("Alpha")
        arcaneOut:SetTarget(frame.arcaneBorder)
        arcaneOut:SetFromAlpha(0.6)
        arcaneOut:SetToAlpha(0.2)
        arcaneOut:SetDuration(2.0)
        arcaneOut:SetSmoothing("IN_OUT")
        arcaneOut:SetOrder(2)
        
    elseif theme == "felenergy" then
        -- Fel Energy: Toxic border in combat
        if not frame.felBorder then
            frame.felBorder = frame:CreateTexture(nil, "OVERLAY")
            frame.felBorder:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\felenergy\\border.tga")
            frame.felBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 5)
            frame.felBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 5, -5)
            frame.felBorder:SetBlendMode("ADD")
            frame.felBorder:SetVertexColor(0.0, 0.8, 0.0) -- Fel green
            frame.felBorder:SetAlpha(0)
        end
        
        -- Create toxic pulsing animation
        local felIn = frame.combatStateAnimation:CreateAnimation("Alpha")
        felIn:SetTarget(frame.felBorder)
        felIn:SetFromAlpha(0.3)
        felIn:SetToAlpha(0.7)
        felIn:SetDuration(2.0)
        felIn:SetSmoothing("IN_OUT")
        felIn:SetOrder(1)
        
        local felOut = frame.combatStateAnimation:CreateAnimation("Alpha")
        felOut:SetTarget(frame.felBorder)
        felOut:SetFromAlpha(0.7)
        felOut:SetToAlpha(0.3)
        felOut:SetDuration(2.0)
        felOut:SetSmoothing("IN_OUT")
        felOut:SetOrder(2)
    end
end

-- Apply theme-specific border glow and effects
function UnitFrames:ApplyThemeBorderEffects(frame, theme)
    if not frame or not frame.borderGlow then return end
    
    -- Reset the border glow
    frame.borderGlow:SetTexture(nil)
    frame.borderGlow:SetAlpha(0)
    
    -- Apply theme-specific border glow texture and color
    if theme == "phoenixflame" then
        frame.borderGlow:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\glow.tga")
        frame.borderGlow:SetVertexColor(1.0, 0.4, 0.0) -- Orange-red
    elseif theme == "thunderstorm" then
        frame.borderGlow:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\glow.tga")
        frame.borderGlow:SetVertexColor(0.3, 0.6, 1.0) -- Blue
    elseif theme == "arcanemystic" then
        frame.borderGlow:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\glow.tga")
        frame.borderGlow:SetVertexColor(0.7, 0.3, 1.0) -- Purple
    elseif theme == "felenergy" then
        frame.borderGlow:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\felenergy\\glow.tga")
        frame.borderGlow:SetVertexColor(0.0, 0.8, 0.0) -- Fel green
    end
    
    -- Ensure correct positioning
    frame.borderGlow:ClearAllPoints()
    frame.borderGlow:SetPoint("TOPLEFT", frame, "TOPLEFT", -8, 8)
    frame.borderGlow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 8, -8)
    frame.borderGlow:SetBlendMode("ADD")
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
    if not unit then return end
    
    -- First update the relevant frame as usual
    if unit == "player" then
        self:UpdatePlayerFrame()
        -- Animate the portrait if enabled
        if self.frames.player and self.frames.player.Portrait then
            self:AnimatePortrait(self.frames.player, unit)
        end
    elseif unit == "target" then
        self:UpdateTargetFrame()
        -- Animate the portrait if enabled
        if self.frames.target and self.frames.target.Portrait then
            self:AnimatePortrait(self.frames.target, unit)
        end
    elseif unit == "focus" then
        self:UpdateFocusFrame()
        -- Animate the portrait if enabled
        if self.frames.focus and self.frames.focus.Portrait then
            self:AnimatePortrait(self.frames.focus, unit)
        end
    elseif unit == "pet" then
        self:UpdatePetFrame()
        -- Animate the portrait if enabled
        if self.frames.pet and self.frames.pet.Portrait then
            self:AnimatePortrait(self.frames.pet, unit)
        end
    elseif string.find(unit, "party") then
        self:UpdatePartyFrames()
        -- Animate the relevant party member's portrait
        local index = tonumber(string.match(unit, "party(%d+)"))
        if index and self.frames.party and self.frames.party[index] and 
           self.frames.party[index].Portrait then
            self:AnimatePortrait(self.frames.party[index], unit)
        end
    else
        -- For other units fallback to the standard update
        self:UpdateHealth(unit)
    end
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

-- Handle entering combat
function UnitFrames:OnEnterCombat()
    if not self.settings.showCombatAnimations then return end
    
    -- Player frame combat state
    if self.frames.player and self.frames.player.animationsInitialized then
        self.frames.player.inCombat = true
        self:SetCombatState(self.frames.player, true)
        
        -- Animate player health value text for emphasis
        if self.frames.player.Health then
            self:AnimateText(self.frames.player.Health, 1.0, 1.3, 0.5, 0.3)
        end
    end
    
    -- Also apply combat animation to party frames
    if self.frames.party then
        for i = 1, 5 do
            if self.frames.party[i] and self.frames.party[i].animationsInitialized then
                if UnitExists("party"..i) and UnitAffectingCombat("party"..i) then
                    self.frames.party[i].inCombat = true
                    self:SetCombatState(self.frames.party[i], true)
                end
            end
        end
    end
    
    -- Update portrait animations - stop subtle animations during combat
    self:UpdatePortraitAnimations(true)
end

-- Handle leaving combat
function UnitFrames:OnLeaveCombat()
    if not self.settings.showCombatAnimations then return end
    
    -- Player frame combat state
    if self.frames.player and self.frames.player.animationsInitialized then
        self.frames.player.inCombat = false
        self:SetCombatState(self.frames.player, false)
    end
    
    -- Also clear combat animation from party frames
    if self.frames.party then
        for i = 1, 5 do
            if self.frames.party[i] and self.frames.party[i].animationsInitialized then
                self.frames.party[i].inCombat = false
                self:SetCombatState(self.frames.party[i], false)
            end
        end
    end
    
    -- Restart portrait animations after leaving combat
    self:UpdatePortraitAnimations(false)
end

-- Handle power type changes
function UnitFrames:UpdatePowerType(unit)
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

-- Handle combat events for animation triggers
function UnitFrames:OnUnitCombatEvent(unit, eventType, flagText, amount)
    if not self.settings.showHealthChangeAnimations then return end
    
    -- Only process damage events with significant amounts
    if eventType == "DAMAGE" and amount and amount > 0 then
        local frame = nil
        
        -- Determine which frame to apply the effect to
        if unit == "player" then
            frame = self.frames.player
        elseif unit == "target" then
            frame = self.frames.target
        elseif unit == "focus" then
            frame = self.frames.focus
        elseif unit == "pet" then
            frame = self.frames.pet
        elseif unit == "targettarget" then
            frame = self.frames.targettarget
        elseif string.find(unit, "party") then
            local index = tonumber(string.match(unit, "party(%d+)"))
            if index and self.frames.party and self.frames.party[index] then
                frame = self.frames.party[index]
            end
        end
        
        -- Apply the animation if the frame exists and damage is significant
        if frame and frame.animationsInitialized then
            local maxHealth = UnitHealthMax(unit) or 1
            local damagePercent = amount / maxHealth
            
            -- Only trigger for significant damage (more than 5% of max health)
            if damagePercent > 0.05 then
                -- Get the current health value for animation
                local currentHealth = UnitHealth(unit) or 0
                local previousHealth = currentHealth + amount
                
                -- Call the animation function
                self:AnimateHealthChange(frame, previousHealth, currentHealth)
            end
        end
    end
end

-- Handle threat state changes
function UnitFrames:UpdateThreatState(unit)
    if not unit or not self.settings.showCombatAnimations then return end
    
    local frame = nil
    
    -- Determine which frame to update
    if unit == "player" then
        frame = self.frames.player
    elseif unit == "target" then
        frame = self.frames.target
    elseif unit == "focus" then
        frame = self.frames.focus
    elseif unit == "pet" then
        frame = self.frames.pet
    elseif string.find(unit, "party") then
        local index = tonumber(string.match(unit, "party(%d+)"))
        if index and self.frames.party and self.frames.party[index] then
            frame = self.frames.party[index]
        end
    end
    
    -- Apply threat state changes if frame exists
    if frame and frame.animationsInitialized then
        local threatStatus = UnitThreatSituation(unit)
        
        -- Add threat highlighting if necessary
        if threatStatus and threatStatus > 0 then
            -- High threat gets aggressive animation
            if threatStatus >= 2 and frame.combatStateAnimation then
                if not frame.combatStateAnimation:IsPlaying() then
                    frame.combatStateAnimation:Play()
                end
                
                -- Color the glow based on threat level (yellow for caution, red for danger)
                if frame.borderGlow then
                    if threatStatus == 3 then
                        -- Tanking - set to red
                        frame.borderGlow:SetVertexColor(1, 0, 0, 0.7)
                    else
                        -- High threat but not tanking - set to yellow/orange
                        frame.borderGlow:SetVertexColor(1, 0.6, 0, 0.7)
                    end
                end
            end
        else
            -- No threat, remove highlighting
            if frame.combatStateAnimation and frame.combatStateAnimation:IsPlaying() and not frame.inCombat then
                frame.combatStateAnimation:Stop()
                if frame.borderGlow then
                    frame.borderGlow:SetAlpha(0)
                end
            end
        end
    end
end
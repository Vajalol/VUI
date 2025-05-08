local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()
local P = VUICD.Party
local SB = {}
P.StatusBar = SB

-- Local variables
local activeBars = {}
local framePool = {}

-- Initialize status bars
function SB:Initialize(parent, iconSize)
    if not parent then return end
    
    local settings = VUICD:GetPartySettings().icons.statusBar
    if not settings.enabled then return end
    
    -- Clear existing status bars
    for _, bar in pairs(activeBars) do
        self:ReleaseBar(bar)
    end
    wipe(activeBars)
    
    -- Create status bars for each cooldown icon
    for i = 1, parent:GetNumChildren() do
        local child = select(i, parent:GetChildren())
        if child:IsShown() and child.spellID then
            local bar = self:CreateBar(child, settings)
            activeBars[child] = bar
        end
    end
end

-- Create a status bar for a cooldown icon
function SB:CreateBar(parent, settings)
    local bar = self:AcquireBar()
    
    -- Set size based on parent and settings
    local size = parent:GetWidth()
    
    if settings.position == "TOP" or settings.position == "BOTTOM" then
        bar:SetSize(size, settings.height)
    else
        bar:SetSize(settings.width, size)
    end
    
    -- Set anchor based on position
    bar:ClearAllPoints()
    if settings.position == "TOP" then
        bar:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 0, 0)
        bar:SetPoint("BOTTOMRIGHT", parent, "TOPRIGHT", 0, 0)
    elseif settings.position == "BOTTOM" then
        bar:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, 0)
        bar:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    elseif settings.position == "LEFT" then
        bar:SetPoint("TOPRIGHT", parent, "TOPLEFT", 0, 0)
        bar:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", 0, 0)
    elseif settings.position == "RIGHT" then
        bar:SetPoint("TOPLEFT", parent, "TOPRIGHT", 0, 0)
        bar:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", 0, 0)
    end
    
    -- Set texture
    local texture = settings.statusBarTexture
    if VUICD.Libs.LSM:IsValid("statusbar", texture) then
        texture = VUICD.Libs.LSM:Fetch("statusbar", texture)
    end
    bar:SetStatusBarTexture(texture)
    
    -- Set color
    if settings.useClassColor and parent.class then
        local classColor = RAID_CLASS_COLORS[parent.class]
        if classColor then
            bar:SetStatusBarColor(classColor.r, classColor.g, classColor.b)
        end
    end
    
    -- Set script to update the bar
    bar.parent = parent
    bar.spellID = parent.spellID
    bar.startTime = 0
    bar.duration = 0
    bar:SetScript("OnUpdate", self.OnUpdate)
    
    -- Show spark if enabled
    if settings.showSpark then
        if not bar.spark then
            bar.spark = bar:CreateTexture(nil, "OVERLAY")
            bar.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
            bar.spark:SetBlendMode("ADD")
            bar.spark:SetWidth(8)
            bar.spark:SetPoint("TOP", bar:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
            bar.spark:SetPoint("BOTTOM", bar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
        end
        bar.spark:Show()
    elseif bar.spark then
        bar.spark:Hide()
    end
    
    -- Show the bar
    bar:Show()
    
    return bar
end

-- Update status bar based on cooldown
function SB:OnUpdate(elapsed)
    if not self.parent or not self.parent:IsShown() or not self.spellID then
        self:Hide()
        return
    end
    
    local start, duration = self.startTime, self.duration
    if start == 0 or duration == 0 then
        -- Check if spell is on cooldown
        local onCD, newStart, newDuration = VUICD.Cooldowns:IsOnCooldown(self.spellID, self.parent.unit)
        if onCD then
            start = newStart
            duration = newDuration
            self.startTime = start
            self.duration = duration
        else
            self:SetValue(0)
            return
        end
    end
    
    local now = GetTime()
    local remaining = duration - (now - start)
    
    if remaining <= 0 then
        self.startTime = 0
        self.duration = 0
        self:SetValue(0)
    else
        local progress = remaining / duration
        self:SetValue(progress)
        
        -- Update spark position
        if self.spark then
            local sparkPosition = math.max(0, math.min(1, progress))
            local barWidth = self:GetWidth()
            self.spark:SetPoint("CENTER", self:GetStatusBarTexture(), "RIGHT", 0, 0)
        end
    end
end

-- Pool management functions
function SB:AcquireBar()
    local bar
    
    if #framePool > 0 then
        bar = table.remove(framePool)
    else
        bar = CreateFrame("StatusBar", nil, UIParent, "VUICD_StatusBarTemplate")
    end
    
    bar:SetValue(0)
    bar:Show()
    
    return bar
end

function SB:ReleaseBar(bar)
    if not bar then return end
    
    bar:Hide()
    bar:SetScript("OnUpdate", nil)
    bar.parent = nil
    bar.spellID = nil
    bar.startTime = 0
    bar.duration = 0
    
    table.insert(framePool, bar)
end
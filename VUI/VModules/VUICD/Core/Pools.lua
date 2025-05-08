local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()

-- Object pooling system
VUICD.Pools = {}

-- Frame pools
local framePools = {}

-- Initialize object pooling
function VUICD.Pools:Initialize()
    -- Create pools for commonly used objects
    self:CreatePool("CooldownIcon", self.CreateCooldownIcon)
    self:CreatePool("StatusBar", self.CreateStatusBar)
    self:CreatePool("PartyMember", self.CreatePartyMember)
    self:CreatePool("PixelGlow", self.CreatePixelGlow)
    self:CreatePool("AutoCastGlow", self.CreateAutoCastGlow)
end

-- Create a new object pool
function VUICD.Pools:CreatePool(name, createFunc)
    if not name or not createFunc then return end
    
    framePools[name] = {
        create = createFunc,
        objects = {},
        active = {}
    }
end

-- Acquire an object from a pool
function VUICD.Pools:Acquire(poolName, parent)
    if not poolName or not framePools[poolName] then return nil end
    
    local pool = framePools[poolName]
    local object
    
    -- Get object from pool or create a new one
    if #pool.objects > 0 then
        object = table.remove(pool.objects)
    else
        object = pool.create(parent)
    end
    
    -- Set parent if provided
    if parent and object.SetParent then
        object:SetParent(parent)
    end
    
    -- Mark as active
    pool.active[object] = true
    
    -- Show object
    if object.Show then
        object:Show()
    end
    
    return object
end

-- Release an object back to the pool
function VUICD.Pools:Release(poolName, object)
    if not poolName or not framePools[poolName] or not object then return end
    
    local pool = framePools[poolName]
    
    -- Skip if not active
    if not pool.active[object] then return end
    
    -- Hide object
    if object.Hide then
        object:Hide()
    end
    
    -- Clear parent
    if object.SetParent then
        object:SetParent(nil)
    end
    
    -- Clear scripts
    if object.HookScript then
        object:SetScript("OnUpdate", nil)
        object:SetScript("OnEvent", nil)
        object:SetScript("OnShow", nil)
        object:SetScript("OnHide", nil)
        object:SetScript("OnEnter", nil)
        object:SetScript("OnLeave", nil)
    end
    
    -- Return to pool
    pool.active[object] = nil
    table.insert(pool.objects, object)
end

-- Release all objects from a pool
function VUICD.Pools:ReleaseAll(poolName)
    if not poolName or not framePools[poolName] then return end
    
    local pool = framePools[poolName]
    
    -- Release all active objects
    for object in pairs(pool.active) do
        self:Release(poolName, object)
    end
end

-- Get counts for a pool
function VUICD.Pools:GetCounts(poolName)
    if not poolName or not framePools[poolName] then return 0, 0 end
    
    local pool = framePools[poolName]
    local activeCount = 0
    
    for _ in pairs(pool.active) do
        activeCount = activeCount + 1
    end
    
    return activeCount, #pool.objects
end

-- Create functions for each pool type
function VUICD.Pools.CreateCooldownIcon(parent)
    local frame = CreateFrame("Frame", nil, parent, "VUICD_CooldownIconTemplate")
    frame.isVUICDIcon = true
    
    -- Create references to icon parts
    frame.icon = frame:CreateTexture(nil, "BACKGROUND")
    frame.icon:SetAllPoints()
    frame.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim icon border
    
    frame.count = frame:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    frame.count:SetPoint("BOTTOMRIGHT", -2, 2)
    
    frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.cooldown:SetAllPoints()
    frame.cooldown:SetHideCountdownNumbers(true)
    frame.cooldown:SetReverse(true)
    
    return frame
end

function VUICD.Pools.CreateStatusBar(parent)
    local bar = CreateFrame("StatusBar", nil, parent, "VUICD_StatusBarTemplate")
    
    -- Create background texture
    bar.bg = bar:CreateTexture(nil, "BACKGROUND")
    bar.bg:SetAllPoints()
    bar.bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    
    -- Create text
    bar.text = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bar.text:SetPoint("CENTER")
    
    -- Set default texture
    bar:SetStatusBarTexture("Interface\\AddOns\\VUI\\Media\\modules\\VUICD\\statusbar.tga")
    
    return bar
end

function VUICD.Pools.CreatePartyMember(parent)
    local frame = CreateFrame("Frame", nil, parent, "VUICD_PartyMemberTemplate")
    
    -- Create class icon
    frame.classIcon = frame:CreateTexture(nil, "ARTWORK")
    frame.classIcon:SetSize(16, 16)
    frame.classIcon:SetPoint("LEFT", 2, 0)
    
    -- Create name text
    frame.nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.nameText:SetPoint("LEFT", frame.classIcon, "RIGHT", 4, 0)
    frame.nameText:SetSize(100, 12)
    frame.nameText:SetJustifyH("LEFT")
    
    -- Create icons container
    frame.iconContainer = CreateFrame("Frame", nil, frame)
    frame.iconContainer:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -2)
    
    return frame
end

function VUICD.Pools.CreatePixelGlow(parent)
    local frame = CreateFrame("Frame", nil, parent, "VUICD_PixelGlowTemplate")
    
    -- Create glow textures
    for i = 1, 4 do
        local texture = frame:CreateTexture(nil, "BACKGROUND")
        texture:SetTexture("Interface\\AddOns\\VUI\\Media\\modules\\VUICD\\glow.tga")
        texture:SetBlendMode("ADD")
        texture:SetPoint("CENTER")
        texture:SetSize(32, 32)
        texture:Hide()
        
        frame["glow" .. i] = texture
    end
    
    return frame
end

function VUICD.Pools.CreateAutoCastGlow(parent)
    local frame = CreateFrame("Frame", nil, parent, "VUICD_AutoCastGlowTemplate")
    
    -- Create shine textures
    for i = 1, 4 do
        local texture = frame:CreateTexture(nil, "OVERLAY")
        texture:SetTexture("Interface\\Buttons\\UI-AutoCastButton")
        texture:SetSize(16, 16)
        texture:Hide()
        
        frame["shine" .. i] = texture
    end
    
    -- Set up shine texcoords
    frame.shine1:SetTexCoord(0.5, 1, 0, 0.5)
    frame.shine2:SetTexCoord(0, 0.5, 0, 0.5)
    frame.shine3:SetTexCoord(0, 0.5, 0.5, 1)
    frame.shine4:SetTexCoord(0.5, 1, 0.5, 1)
    
    -- Set up shine positions
    frame.shine1:SetPoint("CENTER", 6, 6)
    frame.shine2:SetPoint("CENTER", 6, -6)
    frame.shine3:SetPoint("CENTER", -6, -6)
    frame.shine4:SetPoint("CENTER", -6, 6)
    
    -- Set up autocast animation
    frame:SetScript("OnUpdate", function(self, elapsed)
        AutoCastShine_OnUpdate(self, elapsed)
    end)
    
    return frame
end
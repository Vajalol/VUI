local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()
local P = VUICD.Party
local HL = {}
P.Highlights = HL

-- Local variables
local activeHighlights = {}
local pixelGlowPool = {}
local autoCastGlowPool = {}

-- Initialize highlights
function HL:Initialize()
    self.settings = VUICD:GetPartySettings().highlight
end

-- Apply highlight to a frame
function HL:ApplyHighlight(frame, highlightType)
    if not frame or not self.settings or not self.settings.glow.enabled then
        return
    end
    
    -- Remove any existing highlight
    self:RemoveHighlight(frame)
    
    local glowType = self.settings.glow.type or "pixel"
    
    if glowType == "pixel" then
        self:ApplyPixelGlow(frame)
    elseif glowType == "autocast" then
        self:ApplyAutoCastGlow(frame)
    end
    
    -- Store active highlight
    activeHighlights[frame] = glowType
end

-- Remove highlight from a frame
function HL:RemoveHighlight(frame)
    if not frame then return end
    
    local glowType = activeHighlights[frame]
    if not glowType then return end
    
    if glowType == "pixel" then
        self:RemovePixelGlow(frame)
    elseif glowType == "autocast" then
        self:RemoveAutoCastGlow(frame)
    end
    
    -- Remove from active highlights
    activeHighlights[frame] = nil
end

-- Apply pixel glow to a frame
function HL:ApplyPixelGlow(frame)
    local glow = self:AcquirePixelGlow(frame)
    local color = self.settings.glow.color
    
    -- Set color
    for i = 1, 4 do
        local texture = glow["glow" .. i]
        if texture then
            texture:SetVertexColor(color.r, color.g, color.b, color.a)
            texture:Show()
        end
    end
    
    -- Set size
    local size = frame:GetWidth() * 1.1
    glow:SetSize(size, size)
    
    -- Show glow
    glow:Show()
end

-- Remove pixel glow from a frame
function HL:RemovePixelGlow(frame)
    for i = 1, #pixelGlowPool do
        local glow = pixelGlowPool[i]
        if glow:GetParent() == frame then
            for j = 1, 4 do
                local texture = glow["glow" .. j]
                if texture then
                    texture:Hide()
                end
            end
            glow:Hide()
            table.remove(pixelGlowPool, i)
            glow:SetParent(nil)
            table.insert(pixelGlowPool, glow)
            break
        end
    end
end

-- Apply autocast glow to a frame
function HL:ApplyAutoCastGlow(frame)
    local glow = self:AcquireAutoCastGlow(frame)
    local color = self.settings.glow.color
    
    -- Set color
    for i = 1, 4 do
        local texture = glow["shine" .. i]
        if texture then
            texture:SetVertexColor(color.r, color.g, color.b, color.a)
            texture:Show()
        end
    end
    
    -- Set size
    local size = frame:GetWidth() * 1.4
    glow:SetSize(size, size)
    
    -- Set up autocast animation
    AutoCastShine_AutoCastStart(glow)
    
    -- Show glow
    glow:Show()
end

-- Remove autocast glow from a frame
function HL:RemoveAutoCastGlow(frame)
    for i = 1, #autoCastGlowPool do
        local glow = autoCastGlowPool[i]
        if glow:GetParent() == frame then
            AutoCastShine_AutoCastStop(glow)
            for j = 1, 4 do
                local texture = glow["shine" .. j]
                if texture then
                    texture:Hide()
                end
            end
            glow:Hide()
            table.remove(autoCastGlowPool, i)
            glow:SetParent(nil)
            table.insert(autoCastGlowPool, glow)
            break
        end
    end
end

-- Pool management functions
function HL:AcquirePixelGlow(parent)
    local glow
    
    if #pixelGlowPool > 0 then
        glow = table.remove(pixelGlowPool)
        glow:SetParent(parent)
    else
        glow = CreateFrame("Frame", nil, parent, "VUICD_PixelGlowTemplate")
    end
    
    glow:SetPoint("CENTER", parent, "CENTER", 0, 0)
    
    return glow
end

function HL:AcquireAutoCastGlow(parent)
    local glow
    
    if #autoCastGlowPool > 0 then
        glow = table.remove(autoCastGlowPool)
        glow:SetParent(parent)
    else
        glow = CreateFrame("Frame", nil, parent, "VUICD_AutoCastGlowTemplate")
    end
    
    glow:SetPoint("CENTER", parent, "CENTER", 0, 0)
    
    return glow
end

-- Update all highlights
function HL:UpdateAll()
    for frame, glowType in pairs(activeHighlights) do
        self:RemoveHighlight(frame)
        self:ApplyHighlight(frame, glowType)
    end
end
local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()
local P = VUICD.Party
local IC = {}
P.Icons = IC

-- Local variables
local activeIcons = {}
local iconPool = {}

-- Initialize icons
function IC:Initialize(parent, unit, className)
    if not parent or not unit or not className then return end
    
    -- Get settings
    local settings = VUICD:GetPartySettings().icons
    
    -- Clear existing icons
    self:ClearIcons(parent)
    
    -- Get spells for the class
    local spells = VUICD.Cooldowns:GetSpells(className)
    
    -- Create icons for each spell
    local iconSize = parent:GetHeight() * settings.scale
    local padding = settings.padding
    local maxColumns = settings.columns or 10
    local count = 0
    local row = 0
    local column = 0
    
    for _, spell in pairs(spells) do
        local icon = self:CreateIcon(parent, spell, unit, settings)
        
        -- Position the icon
        icon:ClearAllPoints()
        local xOffset = column * (iconSize + padding)
        local yOffset = -row * (iconSize + padding)
        
        -- Set position based on anchor point
        local relativePoint = settings.relativePoint or "TOPLEFT"
        local anchor = settings.anchor or "TOPLEFT"
        icon:SetPoint(anchor, parent, relativePoint, xOffset, yOffset)
        
        -- Update positioning for next icon
        count = count + 1
        column = column + 1
        if column >= maxColumns then
            column = 0
            row = row + 1
        end
    end
    
    -- Initialize status bars if enabled
    if VUICD:GetPartySettings().icons.statusBar.enabled and P.StatusBar then
        P.StatusBar:Initialize(parent, iconSize)
    end
    
    -- Return the number of icons created
    return count
end

-- Create an icon for a spell
function IC:CreateIcon(parent, spell, unit, settings)
    local icon = self:AcquireIcon(parent)
    local size = parent:GetHeight() * settings.scale
    
    -- Set size
    icon:SetSize(size, size)
    
    -- Set icon texture
    icon.icon:SetTexture(GetSpellTexture(spell.id) or spell.icon)
    
    -- Store spell information
    icon.spellID = spell.id
    icon.spellName = spell.name
    icon.spellType = spell.type
    icon.unit = unit
    icon.class = select(2, UnitClass(unit))
    
    -- Apply settings
    if settings.desaturate then
        icon.icon:SetDesaturated(true)
    else
        icon.icon:SetDesaturated(false)
    end
    
    -- Set up tooltip if enabled
    if settings.showTooltip then
        icon:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(self.spellID)
            GameTooltip:Show()
        end)
        
        icon:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    else
        icon:SetScript("OnEnter", nil)
        icon:SetScript("OnLeave", nil)
    end
    
    -- Set up counter if enabled
    if settings.showCounter then
        icon.count:Show()
        -- Count will be updated by cooldown tracking
    else
        icon.count:Hide()
    end
    
    -- Apply cooldown
    local onCD, start, duration = VUICD.Cooldowns:IsOnCooldown(spell.id, unit)
    if onCD then
        CooldownFrame_Set(icon.cooldown, start, duration, true)
    else
        CooldownFrame_Clear(icon.cooldown)
    end
    
    -- Store in active icons list
    activeIcons[icon] = true
    
    -- Show the icon
    icon:Show()
    
    return icon
end

-- Clear icons for a parent frame
function IC:ClearIcons(parent)
    if not parent then return end
    
    for i = 1, parent:GetNumChildren() do
        local child = select(i, parent:GetChildren())
        if child.isVUICDIcon and activeIcons[child] then
            self:ReleaseIcon(child)
        end
    end
end

-- Pool management functions
function IC:AcquireIcon(parent)
    local icon
    
    if #iconPool > 0 then
        icon = table.remove(iconPool)
        icon:SetParent(parent)
    else
        icon = CreateFrame("Frame", nil, parent, "VUICD_CooldownIconTemplate")
        icon.isVUICDIcon = true
        
        -- Create references to icon parts
        icon.icon = _G[icon:GetName() .. "Icon"]
        icon.count = _G[icon:GetName() .. "Count"]
        icon.cooldown = _G[icon:GetName() .. "Cooldown"]
    end
    
    return icon
end

function IC:ReleaseIcon(icon)
    if not icon then return end
    
    icon:Hide()
    icon:SetScript("OnEnter", nil)
    icon:SetScript("OnLeave", nil)
    icon.spellID = nil
    icon.spellName = nil
    icon.spellType = nil
    icon.unit = nil
    icon.class = nil
    
    activeIcons[icon] = nil
    table.insert(iconPool, icon)
end

-- Update icon cooldowns
function IC:UpdateCooldowns()
    for icon in pairs(activeIcons) do
        if icon.spellID and icon.unit then
            local onCD, start, duration = VUICD.Cooldowns:IsOnCooldown(icon.spellID, icon.unit)
            if onCD then
                CooldownFrame_Set(icon.cooldown, start, duration, true)
                
                -- Update counter if shown
                if icon.count:IsShown() then
                    local timeLeft = start + duration - GetTime()
                    if timeLeft > 0 then
                        icon.count:SetText(math.floor(timeLeft))
                    else
                        icon.count:SetText("")
                    end
                end
            else
                CooldownFrame_Clear(icon.cooldown)
                if icon.count:IsShown() then
                    icon.count:SetText("")
                end
            end
        end
    end
end
-- VUITGCD IconQueue.lua
-- Manages a queue of ability icons for display

local _, ns = ...
local VUITGCD = _G.VUI and _G.VUI.TGCD or {}

-- Create a class-like structure for IconQueue
---@class IconQueue
ns.IconQueue = {}
ns.IconQueue.__index = ns.IconQueue

---@param owner Frame
---@param maxIcons number
---@param iconSize number
---@param direction string
---@return IconQueue
function ns.IconQueue:New(owner, maxIcons, iconSize, direction)
    local self = setmetatable({}, ns.IconQueue)
    
    self.owner = owner
    self.maxIcons = maxIcons or 8
    self.iconSize = iconSize or ns.constants.defaultIconSize
    self.direction = direction or "horizontal" -- "horizontal" or "vertical"
    self.spacing = 2 -- Space between icons
    self.icons = {}
    self.activeIcons = 0
    self.frame = nil
    
    -- Create container frame
    self:CreateFrame()
    
    return self
end

-- Create the container frame
function ns.IconQueue:CreateFrame()
    -- Get parent frame
    local parent = self.owner or UIParent
    
    -- Calculate size based on direction
    local width, height
    if self.direction == "horizontal" then
        width = (self.iconSize * self.maxIcons) + (self.spacing * (self.maxIcons - 1))
        height = self.iconSize
    else -- vertical
        width = self.iconSize
        height = (self.iconSize * self.maxIcons) + (self.spacing * (self.maxIcons - 1))
    end
    
    -- Create frame
    self.frame = CreateFrame("Frame", nil, parent)
    self.frame:SetSize(width, height)
    self.frame:SetPoint("CENTER", parent, "CENTER", 0, 0)
    self.frame.iconQueue = self -- Reference back to IconQueue object
    
    -- Create backdrop for debugging (hidden by default)
    self.frame.bg = self.frame:CreateTexture(nil, "BACKGROUND")
    self.frame.bg:SetAllPoints()
    self.frame.bg:SetColorTexture(0, 0, 0, 0.3)
    self.frame.bg:Hide()
    
    -- Make it movable
    self.frame:SetMovable(true)
    self.frame:EnableMouse(true)
    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", self.frame.StartMoving)
    self.frame:SetScript("OnDragStop", function(f) 
        f:StopMovingOrSizing() 
        -- Save position
        if ns.settings and ns.settings.activeProfile then
            local point, _, relativePoint, xOfs, yOfs = f:GetPoint()
            if point and relativePoint then
                -- Save position data to settings here
            end
        end
    end)
    
    -- Create icon slots
    self:CreateIconSlots()
end

-- Create visual placeholders for icon slots
function ns.IconQueue:CreateIconSlots()
    self.slots = {}
    
    for i = 1, self.maxIcons do
        local slot = CreateFrame("Frame", nil, self.frame)
        slot:SetSize(self.iconSize, self.iconSize)
        
        -- Position based on direction
        if self.direction == "horizontal" then
            slot:SetPoint("LEFT", self.frame, "LEFT", (i-1) * (self.iconSize + self.spacing), 0)
        else -- vertical
            slot:SetPoint("TOP", self.frame, "TOP", 0, -((i-1) * (self.iconSize + self.spacing)))
        end
        
        -- Debug texture (hidden by default)
        slot.bg = slot:CreateTexture(nil, "BACKGROUND")
        slot.bg:SetAllPoints()
        slot.bg:SetColorTexture(0.2, 0.2, 0.2, 0.3)
        slot.bg:Hide()
        
        self.slots[i] = slot
    end
end

-- Add an icon to the queue
---@param spellId number
---@param duration number|nil
function ns.IconQueue:AddIcon(spellId, duration)
    if not spellId or spellId == 0 then return end
    
    -- Get spell info
    local spellName = ns.utils.GetSpellName(spellId)
    if not spellName then return end
    
    -- Check if spell is in blocklist
    if ns.settings and ns.settings.activeProfile and 
       ns.settings.activeProfile.innerBlocklist and 
       ns.settings.activeProfile.innerBlocklist[spellId] then
        return
    end
    
    -- Shift existing icons
    self:ShiftIcons()
    
    -- Create new icon
    local icon = ns.Icon:New(self.frame, spellId, self.iconSize)
    
    -- Position the icon at the first slot
    if self.direction == "horizontal" then
        icon:SetPosition("LEFT", "LEFT", 0, 0)
    else -- vertical
        icon:SetPosition("TOP", "TOP", 0, 0)
    end
    
    -- Set cooldown if provided
    if duration and duration > 0 then
        icon:StartCooldown(duration)
    end
    
    -- Apply glow if enabled
    if ns.settings and ns.settings.activeProfile and 
       ns.settings.activeProfile.showGlow and 
       ns.settings.activeProfile.glowEffect ~= "none" then
        icon:ApplyGlow(ns.settings.activeProfile.glowEffect)
    end
    
    -- Show spell name if enabled
    if ns.settings and ns.settings.activeProfile and 
       ns.settings.activeProfile.showSpellNames then
        icon:ShowSpellName(true)
    end
    
    -- Insert at beginning of table
    table.insert(self.icons, 1, icon)
    self.activeIcons = self.activeIcons + 1
    
    -- Remove excess icons
    self:TrimIcons()
    
    return icon
end

-- Shift existing icons to make room for a new one
function ns.IconQueue:ShiftIcons()
    for i, icon in ipairs(self.icons) do
        local targetSlotIndex = i + 1
        
        if targetSlotIndex <= self.maxIcons then
            -- Position based on direction
            if self.direction == "horizontal" then
                icon:SetPosition("LEFT", "LEFT", (targetSlotIndex-1) * (self.iconSize + self.spacing), 0)
            else -- vertical
                icon:SetPosition("TOP", "TOP", 0, -((targetSlotIndex-1) * (self.iconSize + self.spacing)))
            end
        else
            -- Icon is now off the end of the queue, fade it out
            icon:StartFadeOut(0.2)
        end
    end
end

-- Remove icons beyond the maximum allowed
function ns.IconQueue:TrimIcons()
    while #self.icons > self.maxIcons do
        local lastIcon = self.icons[#self.icons]
        
        if lastIcon then
            lastIcon:Destroy()
            table.remove(self.icons, #self.icons)
            self.activeIcons = math.max(0, self.activeIcons - 1)
        end
    end
end

-- Clear all icons
function ns.IconQueue:Clear()
    for _, icon in ipairs(self.icons) do
        icon:Destroy()
    end
    
    self.icons = {}
    self.activeIcons = 0
end

-- Update all icons
---@param elapsed number
function ns.IconQueue:Update(elapsed)
    for i = #self.icons, 1, -1 do
        local icon = self.icons[i]
        
        if icon and icon.isActive then
            icon:Update(elapsed)
        else
            -- Remove inactive icons
            icon:Destroy()
            table.remove(self.icons, i)
            self.activeIcons = math.max(0, self.activeIcons - 1)
        end
    end
end

-- Set queue direction
---@param direction string
function ns.IconQueue:SetDirection(direction)
    if direction ~= "horizontal" and direction ~= "vertical" then
        return
    end
    
    if self.direction == direction then
        return
    end
    
    self.direction = direction
    
    -- Resize container frame
    if self.direction == "horizontal" then
        self.frame:SetSize((self.iconSize * self.maxIcons) + (self.spacing * (self.maxIcons - 1)), self.iconSize)
    else -- vertical
        self.frame:SetSize(self.iconSize, (self.iconSize * self.maxIcons) + (self.spacing * (self.maxIcons - 1)))
    end
    
    -- Reposition slots
    for i = 1, self.maxIcons do
        local slot = self.slots[i]
        if slot then
            slot:ClearAllPoints()
            if self.direction == "horizontal" then
                slot:SetPoint("LEFT", self.frame, "LEFT", (i-1) * (self.iconSize + self.spacing), 0)
            else -- vertical
                slot:SetPoint("TOP", self.frame, "TOP", 0, -((i-1) * (self.iconSize + self.spacing)))
            end
        end
    end
    
    -- Reposition existing icons
    for i, icon in ipairs(self.icons) do
        if icon and icon.isActive then
            if self.direction == "horizontal" then
                icon:SetPosition("LEFT", "LEFT", (i-1) * (self.iconSize + self.spacing), 0)
            else -- vertical
                icon:SetPosition("TOP", "TOP", 0, -((i-1) * (self.iconSize + self.spacing)))
            end
        end
    end
end

-- Set maximum number of icons
---@param max number
function ns.IconQueue:SetMaxIcons(max)
    if not max or max < 1 then
        return
    end
    
    if self.maxIcons == max then
        return
    end
    
    local oldMax = self.maxIcons
    self.maxIcons = max
    
    -- Resize container frame
    if self.direction == "horizontal" then
        self.frame:SetSize((self.iconSize * self.maxIcons) + (self.spacing * (self.maxIcons - 1)), self.iconSize)
    else -- vertical
        self.frame:SetSize(self.iconSize, (self.iconSize * self.maxIcons) + (self.spacing * (self.maxIcons - 1)))
    end
    
    -- Create or destroy slots as needed
    if max > oldMax then
        -- Create additional slots
        for i = oldMax + 1, max do
            local slot = CreateFrame("Frame", nil, self.frame)
            slot:SetSize(self.iconSize, self.iconSize)
            
            if self.direction == "horizontal" then
                slot:SetPoint("LEFT", self.frame, "LEFT", (i-1) * (self.iconSize + self.spacing), 0)
            else -- vertical
                slot:SetPoint("TOP", self.frame, "TOP", 0, -((i-1) * (self.iconSize + self.spacing)))
            end
            
            slot.bg = slot:CreateTexture(nil, "BACKGROUND")
            slot.bg:SetAllPoints()
            slot.bg:SetColorTexture(0.2, 0.2, 0.2, 0.3)
            slot.bg:Hide()
            
            self.slots[i] = slot
        end
    else
        -- Remove excess slots
        for i = oldMax, max + 1, -1 do
            if self.slots[i] then
                self.slots[i]:Hide()
                self.slots[i] = nil
            end
        end
    end
    
    -- Trim icons if necessary
    self:TrimIcons()
end

-- Set icon size
---@param size number
function ns.IconQueue:SetIconSize(size)
    if not size or size < 10 then
        return
    end
    
    if self.iconSize == size then
        return
    end
    
    self.iconSize = size
    
    -- Resize container frame
    if self.direction == "horizontal" then
        self.frame:SetSize((self.iconSize * self.maxIcons) + (self.spacing * (self.maxIcons - 1)), self.iconSize)
    else -- vertical
        self.frame:SetSize(self.iconSize, (self.iconSize * self.maxIcons) + (self.spacing * (self.maxIcons - 1)))
    end
    
    -- Resize and reposition slots
    for i = 1, self.maxIcons do
        local slot = self.slots[i]
        if slot then
            slot:SetSize(self.iconSize, self.iconSize)
            slot:ClearAllPoints()
            
            if self.direction == "horizontal" then
                slot:SetPoint("LEFT", self.frame, "LEFT", (i-1) * (self.iconSize + self.spacing), 0)
            else -- vertical
                slot:SetPoint("TOP", self.frame, "TOP", 0, -((i-1) * (self.iconSize + self.spacing)))
            end
        end
    end
    
    -- Clear existing icons and recreate them
    -- This is easier than resizing existing icons
    self:Clear()
end

-- Set visibility of debug visuals
---@param visible boolean
function ns.IconQueue:SetDebugVisible(visible)
    if self.frame and self.frame.bg then
        if visible then
            self.frame.bg:Show()
        else
            self.frame.bg:Hide()
        end
    end
    
    for _, slot in pairs(self.slots) do
        if slot and slot.bg then
            if visible then
                slot.bg:Show()
            else
                slot.bg:Hide()
            end
        end
    end
end

-- Export to global if needed
if _G.VUI then
    _G.VUI.TGCD.IconQueue = ns.IconQueue
end
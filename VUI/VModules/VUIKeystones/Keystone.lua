-- VUIKeystones - Keystone functionality
local VUIKeystones = LibStub("AceAddon-3.0"):GetAddon("VUIKeystones")
local Keystone = VUIKeystones:NewModule('Keystone')
local L = VUIKeystones.L

-- Local variables
local isHooked = false
local affixTooltipHooked = false
local keystoneItemID = 180653 -- Subject to change with patches
local tooltipLines = {}

-- Register for events
function Keystone:OnInitialize()
    -- Nothing to do yet
end

-- Hook the tooltip display when we enter the world
function Keystone:PLAYER_ENTERING_WORLD()
    if not isHooked then
        self:HookTooltip()
        isHooked = true
    end
end

-- Hook into tooltip display to show keystone info
function Keystone:HookTooltip()
    -- Hook the SetHyperlink method to catch links
    hooksecurefunc(GameTooltip, "SetHyperlink", function(self, link)
        local linkType, linkParams = link:match("^([^:]+):(.+)$")
        if linkType == "keystone" then
            -- This is a keystone link, process it
            self:ProcessKeystoneLink(link, linkParams)
        end
    end)
    
    -- Hook the SetBagItem method to catch direct inspections
    hooksecurefunc(GameTooltip, "SetBagItem", function(self, bag, slot)
        local itemID = C_Container.GetContainerItemID(bag, slot)
        if itemID == keystoneItemID then
            -- This is a keystone, process it
            local link = C_Container.GetContainerItemLink(bag, slot)
            if link then
                self:ProcessKeystoneLink(link)
            end
        end
    end)
    
    -- Hook the GameTooltip_OnHide to clear our lines
    GameTooltip:HookScript("OnHide", function()
        wipe(tooltipLines)
    end)
end

-- Process keystone links to show enhanced info
function Keystone:ProcessKeystoneLink(link, linkParams)
    -- Extract map ID and level from link
    local mapID, level, affixes = self:ParseKeystoneLink(link)
    
    if mapID and level then
        -- Add our own enhanced information
        self:AddKeystoneTooltipInfo(mapID, level, affixes)
    end
end

-- Parse a keystone link to extract key information
function Keystone:ParseKeystoneLink(link)
    -- This would parse the actual keystone link format from the game
    -- For this example, we'll use a simplified approach
    local mapID, level, affix1, affix2, affix3, affix4 = link:match("keystone:(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)")
    
    if mapID and level then
        return tonumber(mapID), tonumber(level), {
            tonumber(affix1), 
            tonumber(affix2), 
            tonumber(affix3), 
            tonumber(affix4)
        }
    end
    
    return nil, nil, {}
end

-- Add enhanced information to the keystone tooltip
function Keystone:AddKeystoneTooltipInfo(mapID, level, affixes)
    -- In a real implementation, we'd format this based on the dungeon and level
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("VUI Keystones", 1, 0.85, 0)
    
    -- Add level modifier info
    local levelModifier = self:GetLevelModifier(level)
    if levelModifier then
        GameTooltip:AddLine("Level modifier: +" .. levelModifier .. "%", 1, 1, 1)
    end
    
    -- Add timer info
    local timer = self:GetDungeonTimer(mapID)
    if timer then
        GameTooltip:AddLine("Timer: " .. VUIKeystones:FormatTime(timer), 1, 1, 1)
        
        -- Add +2 timer
        local plus2 = math.floor(timer * 0.8)
        GameTooltip:AddLine("+2 Timer: " .. VUIKeystones:FormatTime(plus2), 1, 1, 1)
        
        -- Add +3 timer
        local plus3 = math.floor(timer * 0.6)
        GameTooltip:AddLine("+3 Timer: " .. VUIKeystones:FormatTime(plus3), 1, 1, 1)
    end
    
    GameTooltip:Show()
end

-- Get the level modifier for enemy damage and health
function Keystone:GetLevelModifier(level)
    -- These values are approximations and should be updated based on current game data
    if level <= 0 then return 0 end
    
    return (level - 1) * 8
end

-- Get the timer for a specific dungeon (in seconds)
function Keystone:GetDungeonTimer(mapID)
    -- Updated with The War Within Season 2 dungeons and timers
    local timers = {
        -- The War Within Season 2 Dungeons
        [1180] = 1620, -- Cinderbrew Meadery
        [1182] = 1500, -- Darkflame Cleft
        [537] = 1500,  -- Algeth'ar Academy
        [195] = 1800,  -- The Everbloom
        [1154] = 1560, -- The Dawnbreaker
        [168] = 1800,  -- Neltharion's Lair
        [438] = 1800,  -- Uldaman: Legacy of Tyr
        [204] = 1800,  -- Assault on Violet Hold

        -- Older dungeons kept for compatibility
        [375] = 1800, -- Mists of Tirna Scithe
        [376] = 1500, -- The Necrotic Wake
        [377] = 1800, -- De Other Side
        [378] = 1440, -- Halls of Atonement
        [379] = 1800, -- Plaguefall
        [380] = 1440, -- Sanguine Depths
        [381] = 2160, -- Spires of Ascension
        [382] = 1440, -- Theater of Pain
        [2] = 1500,   -- Temple of the Jade Serpent
        [165] = 1320, -- Neltharion's Lair
        [197] = 1800, -- Eye of Azshara
        [199] = 1800, -- Vault of the Wardens
        [244] = 1800, -- Atal'Dazar
        [245] = 1800, -- Freehold
        [246] = 1560, -- Tol Dagor
        [247] = 1800, -- The MOTHERLODE!!
        [248] = 2160, -- Waycrest Manor
        [249] = 1800, -- Kings' Rest
        [250] = 2160, -- Temple of Sethraliss
        [252] = 2160, -- Shrine of the Storm
        [353] = 1800, -- Mists of Tirna Scithe
        [369] = 1800, -- Operation: Mechagon - Junkyard
        [370] = 1800, -- Operation: Mechagon - Workshop
        [391] = 1920, -- Tazavesh: Streets of Wonder
        [392] = 1320, -- Tazavesh: So'leah's Gambit
    }
    
    return timers[mapID]
end

-- Register callback for config updates
function Keystone:UpdateConfig()
    -- Update any settings based on configuration changes
end
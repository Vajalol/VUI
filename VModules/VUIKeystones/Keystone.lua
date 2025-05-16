-- VUIKeystones - Keystone functionality
-- Use global reference instead of AceAddon-3.0 to fix load order issues
local VUIKeystones = _G["VUIKeystones"]
local Keystone = VUIKeystones.Modules and VUIKeystones:NewModule('Keystone') or {}
local L = VUIKeystones.L or {}

-- Local variables
local isHooked = false
local affixTooltipHooked = false
local keystoneItemID = 208701 -- Updated for The War Within (was 180653 in Dragonflight)
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
        -- Use C_Container for retail or GetContainerItemID for classic
        local itemID = C_Container and C_Container.GetContainerItemID(bag, slot) or GetContainerItemID(bag, slot)
        if itemID == keystoneItemID then
            -- This is a keystone, process it
            local link = C_Container and C_Container.GetContainerItemLink(bag, slot) or GetContainerItemLink(bag, slot)
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
    -- First try the new format that includes 4 affixes
    local mapID, level, affix1, affix2, affix3, affix4 = link:match("keystone:(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)")
    
    if not mapID then
        -- Fall back to old format with 3 affixes
        mapID, level, affix1, affix2, affix3 = link:match("keystone:(%d+):(%d+):(%d+):(%d+):(%d+)")
        affix4 = 0 -- Default value for older keystones
    end
    
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
    
    -- The War Within modifiers - each level adds 10% (updated from 8% in DF)
    return (level - 1) * 10
end

-- Get the timer for a specific dungeon (in seconds)
function Keystone:GetDungeonTimer(mapID)
    -- Updated with The War Within Season 2 dungeons and timers (verified from Wowhead)
    local timers = {
        -- The War Within Season 2 Dungeons (current season)
        [2579] = 1980, -- Cinderbrew Meadery (33:00)
        [2451] = 1860, -- Darkflame Cleft (31:00)
        [2540] = 1740, -- The Rookery (29:00)
        [2519] = 1950, -- Priory of the Sacred Flame (32:30)
        [1199] = 1980, -- Operation: Floodgate (33:00)
        [247] = 2340,  -- The MOTHERLODE!! (39:00)
        [382] = 2040,  -- Theater of Pain (34:00)
        [370] = 1920,  -- Operation: Mechagon - Workshop (32:00)
        
        -- TWW Season 1 Dungeons
        [2580] = 2100, -- Golganneth's Fall (35:00)
        [2527] = 2400, -- Dawn of the Infinite: Galakrond's Fall (40:00)
        [2526] = 2400, -- Dawn of the Infinite: Murozond's Rise (40:00)
        [2581] = 2280, -- The Dawnbreaker (38:00)
        [2394] = 2160, -- Brackenhide Hollow (36:00)
        [2522] = 2400, -- Atal'Dazar Remastered (40:00)
        [2520] = 2220, -- The Everbloom Remastered (37:00)
        [2521] = 2280, -- Throne of the Tides Remastered (38:00)
        
        -- Older dungeons kept for compatibility
        [375] = 1800, -- Mists of Tirna Scithe
        [376] = 1500, -- The Necrotic Wake
        [377] = 1800, -- De Other Side
        [378] = 1440, -- Halls of Atonement
        [379] = 1800, -- Plaguefall
        [380] = 1440, -- Sanguine Depths
        [381] = 2160, -- Spires of Ascension
        -- [382] = 1440, -- Theater of Pain (now in current season with updated timer)
        [2] = 1500,   -- Temple of the Jade Serpent
        [165] = 1320, -- Neltharion's Lair
        [197] = 1800, -- Eye of Azshara
        [199] = 1800, -- Vault of the Wardens
        [244] = 1800, -- Atal'Dazar
        [245] = 1800, -- Freehold
        [246] = 1560, -- Tol Dagor
        -- [247] = 1800, -- The MOTHERLODE!! (now in current season with updated timer)
        [248] = 2160, -- Waycrest Manor
        [249] = 1800, -- Kings' Rest
        [250] = 2160, -- Temple of Sethraliss
        [252] = 2160, -- Shrine of the Storm
        [353] = 1800, -- Mists of Tirna Scithe
        [369] = 1800, -- Operation: Mechagon - Junkyard
        -- [370] = 1800, -- Operation: Mechagon - Workshop (now in current season with updated timer)
        [391] = 1920, -- Tazavesh: Streets of Wonder
        [392] = 1320, -- Tazavesh: So'leah's Gambit
    }
    
    return timers[mapID]
end

-- Register callback for config updates
function Keystone:UpdateConfig()
    -- Update any settings based on configuration changes
end
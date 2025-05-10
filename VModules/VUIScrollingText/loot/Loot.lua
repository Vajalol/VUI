-------------------------------------------------------------------------------
-- Title: VUI Scrolling Text - Loot
-- Author: Vortex-WoW
-- Based on MikScrollingBattleText by Mik
-------------------------------------------------------------------------------

local addonName, VUI = ...
local ST = VUI.ScrollingText
if not ST then return end

-- Local variables
local isEnabled = false
local eventFrame
local moneyPattern = "^%+(%d+) ([^%d]+)$"

-- Local references for increased performance
local string_find = string.find
local string_match = string.match
local pairs = pairs

-------------------------------------------------------------------------------
-- Utility Functions
-------------------------------------------------------------------------------

-- Parse item link and return quality, name, quantity
local function ParseItemLink(itemLink)
    if not itemLink then return nil, nil, 1 end
    
    local _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(itemLink)
    local name = itemLink:match("%[(.-)%]")
    local quantity = tonumber(itemLink:match("x(%d+)")) or 1
    
    return quality, name, quantity, texture
end

-- Get color for item quality
local function GetQualityColor(quality)
    if not quality then return 1, 1, 1 end
    
    local r, g, b = GetItemQualityColor(quality)
    return r, g, b
end

-- Format money amount
local function FormatMoney(amount)
    amount = tonumber(amount) or 0
    local gold = math.floor(amount / 10000)
    local silver = math.floor((amount % 10000) / 100)
    local copper = amount % 100
    
    local formatted = ""
    if gold > 0 then formatted = formatted .. gold .. "g " end
    if silver > 0 or gold > 0 then formatted = formatted .. silver .. "s " end
    formatted = formatted .. copper .. "c"
    
    return formatted
end

-- Event handler
local function OnEvent(self, event, ...)
    -- Return immediately if disabled
    if not isEnabled then return end
    
    if event == "CHAT_MSG_LOOT" then
        local lootString, _, _, _, player = ...
        -- Only process the player's own loot
        if player ~= UnitName("player") then return end
        
        -- Skip if this is a currency message
        if string_find(lootString, "currency:") then return end
        
        -- Look for item links
        local itemLink = string_match(lootString, "|H(.-)|h")
        if itemLink then
            local quality, name, quantity, texture = ParseItemLink("item:" .. itemLink)
            local r, g, b = GetQualityColor(quality)
            
            -- Use VUI theme color for epic+ quality items if enabled
            if quality and quality >= 4 and ST.useThemeColorForEpics then
                local themeColor = VUI:GetThemeColor()
                r, g, b = themeColor.r, themeColor.g, themeColor.b
            end
            
            -- Build message
            local message
            if quantity > 1 then
                message = "+" .. quantity .. " " .. name
            else
                message = "+" .. name
            end
            
            -- Display the loot message
            if ST.DisplayMessage then
                ST.DisplayMessage(message, "Notification", r, g, b)
            end
        end
    elseif event == "CHAT_MSG_MONEY" then
        local moneyString = ...
        
        -- Parse the money amount
        local amount, currency = string_match(moneyString, moneyPattern)
        if amount then
            amount = tonumber(amount)
            
            -- Get appropriate color (use VUI theme color)
            local r, g, b = 1, 1, 0 -- Default gold color
            
            -- Use theme color if enabled
            if ST.useThemeColorForMoney then
                local themeColor = VUI:GetThemeColor()
                r, g, b = themeColor.r, themeColor.g, themeColor.b
            end
            
            -- Display the money message
            if ST.DisplayMessage then
                local message = "+" .. FormatMoney(amount)
                ST.DisplayMessage(message, "Notification", r, g, b)
            end
        end
    end
end

-------------------------------------------------------------------------------
-- Public Methods
-------------------------------------------------------------------------------

-- Enable loot tracking
local function EnableLoot()
    -- Create the event frame if it doesn't exist
    if not eventFrame then
        eventFrame = CreateFrame("Frame")
        eventFrame:SetScript("OnEvent", OnEvent)
    end
    
    -- Register necessary events
    eventFrame:RegisterEvent("CHAT_MSG_LOOT")
    eventFrame:RegisterEvent("CHAT_MSG_MONEY")
    
    isEnabled = true
end

-- Disable loot tracking
local function DisableLoot()
    isEnabled = false
    
    -- Unregister events
    if eventFrame then
        eventFrame:UnregisterAllEvents()
    end
end

-- Apply VUI theme to loot display
local function ApplyTheme()
    -- Theme settings are applied at display time
    -- No need to update anything here
end

-------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------

-- Module public interface
ST.Loot = {
    EnableLoot = EnableLoot,
    DisableLoot = DisableLoot,
    ApplyTheme = ApplyTheme,
    
    -- Settings
    useThemeColorForEpics = true,
    useThemeColorForMoney = true,
}

-- Register with theme system
if VUI.RegisterCallback then
    VUI:RegisterCallback("OnThemeChanged", function()
        ApplyTheme()
    end)
end
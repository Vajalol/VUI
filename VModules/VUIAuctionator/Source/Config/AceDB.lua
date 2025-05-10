local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- This file provides compatibility between the Auctionator config system
-- and the VUI AceDB structure

-- Cache option mappings for performance
local optionMap = {}

-- Initialize the config to use AceDB
function Auctionator.Config.InitializeFromAceDB(dbProfile)
    -- Store reference to AceDB profile
    Auctionator.db = dbProfile
    
    -- Map standard option names to AceDB format
    for option, _ in pairs(Auctionator.Config.Defaults) do
        local dbKey = string.lower(option)
        optionMap[option] = dbKey
    end
    
    -- Migrate data from old VUI_SavedVariables structure if it exists
    if VUI_SavedVariables and VUI_SavedVariables.VUIAuctionator then
        local module = VUI:GetModule("VUIAuctionator")
        if module then
            module:Debug("Migrating legacy Auctionator settings")
        end
        
        -- Copy any existing values to the new db
        for option, value in pairs(VUI_SavedVariables.VUIAuctionator) do
            local dbKey = optionMap[option] or option
            Auctionator.db[dbKey] = value
        end
    end
end

-- Override the original Get method
local originalGet = Auctionator.Config.Get
function Auctionator.Config.Get(option)
    -- Use AceDB if available
    if Auctionator.db then
        local dbKey = optionMap[option] or string.lower(option)
        
        -- Check if the option exists in AceDB
        if Auctionator.db[dbKey] ~= nil then
            return Auctionator.db[dbKey]
        end
        
        -- Fall back to defaults
        return Auctionator.Config.Defaults[option]
    end
    
    -- Fall back to original method if AceDB not initialized
    return originalGet(option)
end

-- Override the original Set method
local originalSet = Auctionator.Config.Set
function Auctionator.Config.Set(option, value)
    -- Use AceDB if available
    if Auctionator.db then
        local dbKey = optionMap[option] or string.lower(option)
        Auctionator.db[dbKey] = value
        
        -- Trigger a configuration changed event
        if Auctionator.EventBus then
            Auctionator.EventBus:Fire({}, Auctionator.Config.Events.CONFIG_CHANGED, option, value)
        end
        return
    end
    
    -- Fall back to original method if AceDB not initialized
    originalSet(option, value)
end

-- Override the Reset method
function Auctionator.Config.Reset(option)
    Auctionator.Config.Set(option, Auctionator.Config.Defaults[option])
end

-- Override the ResetAll method
function Auctionator.Config.ResetAll()
    if Auctionator.db then
        -- Reset all values in AceDB
        for option, value in pairs(Auctionator.Config.Defaults) do
            local dbKey = optionMap[option] or string.lower(option)
            Auctionator.db[dbKey] = value
        end
    else
        -- Fall back to original method if AceDB not initialized
        if VUI_SavedVariables and VUI_SavedVariables.VUIAuctionator then
            VUI_SavedVariables.VUIAuctionator = {}
            
            -- Copy all defaults
            for option, value in pairs(Auctionator.Config.Defaults) do
                VUI_SavedVariables.VUIAuctionator[option] = value
            end
        end
    end
    
    -- Trigger a full config reset event
    if Auctionator.EventBus then
        Auctionator.EventBus:Fire({}, Auctionator.Config.Events.CONFIG_RESET)
    end
end
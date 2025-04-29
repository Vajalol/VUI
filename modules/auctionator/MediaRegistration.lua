-------------------------------------------------------------------------------
-- Title: Auctionator Media Registration
-- Author: VortexQ8
-- Register Auctionator module media with LibSharedMedia
-------------------------------------------------------------------------------

local _, VUI = ...
local Auctionator = VUI.modules.auctionator
if not Auctionator then return end

local LSM = LibStub("LibSharedMedia-3.0")
if not LSM then return end

-- Media categories
local MEDIA_TYPE_BACKGROUND = LSM.MediaType.BACKGROUND
local MEDIA_TYPE_BORDER = LSM.MediaType.BORDER
local MEDIA_TYPE_FONT = LSM.MediaType.FONT
local MEDIA_TYPE_STATUSBAR = LSM.MediaType.STATUSBAR
local MEDIA_TYPE_SOUND = LSM.MediaType.SOUND

-- Register theme-specific Auctionator textures
local function RegisterAuctionatorMedia()
    -- Register logos for each theme
    local themes = {"phoenixflame", "thunderstorm", "arcanemystic", "felenergy"}
    
    for _, theme in ipairs(themes) do
        -- Register the logo as a background texture
        local logoPath = "Interface\\AddOns\\VUI\\media\\textures\\" .. theme .. "\\auctionator\\Logo"
        local logoName = "VUI:Auctionator:" .. theme .. ":Logo"
        
        -- Register with LSM
        LSM:Register(MEDIA_TYPE_BACKGROUND, logoName, logoPath)
    end
    
    -- Register other Auctionator textures if needed
    -- Example: LSM:Register(MEDIA_TYPE_STATUSBAR, "VUI:Auctionator:SellBar", "Interface\\AddOns\\VUI\\media\\textures\\auctionator\\SellBar")
end

-- Initialize
RegisterAuctionatorMedia()
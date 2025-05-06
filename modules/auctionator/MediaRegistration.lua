-------------------------------------------------------------------------------
-- Title: Auctionator Media Registration
-- Author: VortexQ8
-- Register Auctionator module media with LibSharedMedia
-------------------------------------------------------------------------------

local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
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
    -- Register logos and icons for each theme
    local themes = {"phoenixflame", "thunderstorm", "arcanemystic", "felenergy"}
    
    for _, theme in ipairs(themes) do
        -- Register the logo as a background texture
        local logoPath = "Interface\\AddOns\\VUI\\media\\textures\\" .. theme .. "\\auctionator\\Logo"
        local logoName = "VUI:Auctionator:" .. theme .. ":Logo"
        
        -- Register with LSM
        LSM:Register(MEDIA_TYPE_BACKGROUND, logoName, logoPath)
        
        -- Register search icon
        local searchIconPath = "Interface\\AddOns\\VUI\\media\\textures\\" .. theme .. "\\auctionator\\SearchIcon"
        local searchIconName = "VUI:Auctionator:" .. theme .. ":SearchIcon"
        LSM:Register(MEDIA_TYPE_BACKGROUND, searchIconName, searchIconPath)
    end
    
    -- Register additional assets for the Auctionator UI
    -- Tab backgrounds
    LSM:Register(MEDIA_TYPE_BACKGROUND, "VUI:Auctionator:TabBackground", "Interface\\AddOns\\VUI\\media\\textures\\shared\\tab_background")
    
    -- Button textures
    LSM:Register(MEDIA_TYPE_BORDER, "VUI:Auctionator:ButtonBorder", "Interface\\AddOns\\VUI\\media\\textures\\shared\\button_border")
    
    -- Status bars for auction listings
    LSM:Register(MEDIA_TYPE_STATUSBAR, "VUI:Auctionator:ListingBar", "Interface\\AddOns\\VUI\\media\\textures\\shared\\smooth_statusbar")
    
    -- Font for auction prices
    if LSM:IsValid(MEDIA_TYPE_FONT, "Expressway") then
        LSM:Register(MEDIA_TYPE_FONT, "VUI:Auctionator:PriceFont", LSM:Fetch(MEDIA_TYPE_FONT, "Expressway"))
    end
end

-- Initialize
RegisterAuctionatorMedia()
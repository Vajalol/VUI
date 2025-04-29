-------------------------------------------------------------------------------
-- Title: Auctionator Theme Integration
-- Author: VortexQ8
-- VUI Theme integration for Auctionator
-------------------------------------------------------------------------------

local _, VUI = ...
local Auctionator = VUI.modules.auctionator

-- Skip if Auctionator module is not available
if not Auctionator then return end

-- Create the theme integration namespace
Auctionator.ThemeIntegration = {}
local ThemeIntegration = Auctionator.ThemeIntegration

-- Theme color definitions (matching the VUI theme palette)
local themeColors = {
    phoenixflame = {
        background = {26/255, 10/255, 5/255, 0.85}, -- Dark red/brown background
        border = {230/255, 77/255, 13/255}, -- Fiery orange borders
        highlight = {255/255, 163/255, 26/255}, -- Amber highlights
        text = {255/255, 204/255, 153/255}, -- Light orange text
        header = {255/255, 128/255, 64/255}, -- Orange header text
    },
    thunderstorm = {
        background = {10/255, 10/255, 26/255, 0.85}, -- Deep blue backgrounds
        border = {13/255, 157/255, 230/255}, -- Electric blue borders
        highlight = {64/255, 179/255, 255/255}, -- Light blue highlights
        text = {153/255, 204/255, 255/255}, -- Light blue text
        header = {0/255, 153/255, 255/255}, -- Blue header text
    },
    arcanemystic = {
        background = {26/255, 10/255, 47/255, 0.85}, -- Deep purple backgrounds
        border = {157/255, 13/255, 230/255}, -- Violet borders
        highlight = {179/255, 64/255, 255/255}, -- Light purple highlights
        text = {204/255, 153/255, 255/255}, -- Light purple text
        header = {178/255, 102/255, 255/255}, -- Purple header text
    },
    felenergy = {
        background = {10/255, 26/255, 10/255, 0.85}, -- Dark green backgrounds
        border = {26/255, 255/255, 26/255}, -- Fel green borders
        highlight = {64/255, 255/255, 64/255}, -- Light green highlights
        text = {153/255, 255/255, 153/255}, -- Light green text
        header = {0/255, 204/255, 0/255}, -- Green header text
    },
}

-- Get the current theme colors
function ThemeIntegration:GetThemeColors()
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    return themeColors[currentTheme] or themeColors.thunderstorm
end

-- Get the theme-specific texture path
function ThemeIntegration:GetThemeTexture(textureName)
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    local path = "Interface\\Addons\\VUI\\media\\textures\\" .. currentTheme .. "\\auctionator\\" .. textureName
    
    -- Check if the texture exists for the current theme
    if not TextureExists(path) then
        -- Fall back to the default texture
        path = "Interface\\Addons\\VUI\\media\\textures\\auctionator\\" .. textureName
    end
    
    return path
end

-- Apply theme to a frame
function ThemeIntegration:ApplyThemeToFrame(frame)
    if not frame then return end
    
    local colors = self:GetThemeColors()
    
    -- Apply background
    if not frame.themeBg then
        frame.themeBg = frame:CreateTexture(nil, "BACKGROUND")
        frame.themeBg:SetAllPoints()
    end
    frame.themeBg:SetColorTexture(colors.background[1], colors.background[2], colors.background[3], colors.background[4] or 0.85)
    
    -- Apply border if the frame has a backdrop
    if frame.SetBackdrop then
        local backdrop = {
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            tile = true, tileSize = 16, edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 }
        }
        
        frame:SetBackdrop(backdrop)
        frame:SetBackdropColor(colors.background[1], colors.background[2], colors.background[3], colors.background[4] or 0.85)
        frame:SetBackdropBorderColor(colors.border[1], colors.border[2], colors.border[3], 1)
    end
    
    -- Process children
    for _, child in pairs({frame:GetChildren()}) do
        -- Apply theme to buttons
        if child:IsObjectType("Button") and not child.isThemedButton then
            self:ApplyThemeToButton(child)
            child.isThemedButton = true
        end
        
        -- Apply theme to edit boxes
        if child:IsObjectType("EditBox") and not child.isThemedEditBox then
            self:ApplyThemeToEditBox(child)
            child.isThemedEditBox = true
        end
        
        -- Apply theme to font strings
        if child:IsObjectType("FontString") then
            child:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
        end
    end
end

-- Apply theme to a button
function ThemeIntegration:ApplyThemeToButton(button)
    if not button then return end
    
    local colors = self:GetThemeColors()
    
    -- Save original colors for restore on hover end
    if not button.originalColors then
        if button:GetNormalTexture() then
            local r, g, b = button:GetNormalTexture():GetVertexColor()
            button.originalColors = {r = r, g = g, b = b}
        else
            button.originalColors = {r = 1, g = 1, b = 1}
        end
    end
    
    -- Create highlight backdrop if needed
    if not button.highlightBg then
        button.highlightBg = button:CreateTexture(nil, "HIGHLIGHT")
        button.highlightBg:SetAllPoints()
    end
    button.highlightBg:SetColorTexture(colors.highlight[1], colors.highlight[2], colors.highlight[3], 0.2)
    
    -- Tint button normal texture if exists
    if button:GetNormalTexture() then
        button:GetNormalTexture():SetVertexColor(colors.border[1], colors.border[2], colors.border[3])
    end
    
    -- Recolor text if exists
    local buttonText = button:GetFontString()
    if buttonText then
        buttonText:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
    end
    
    -- Add hover effect
    button:HookScript("OnEnter", function(self)
        if self:GetNormalTexture() then
            self:GetNormalTexture():SetVertexColor(colors.highlight[1], colors.highlight[2], colors.highlight[3])
        end
        if buttonText then
            buttonText:SetTextColor(colors.highlight[1], colors.highlight[2], colors.highlight[3], 1)
        end
    end)
    
    button:HookScript("OnLeave", function(self)
        if self:GetNormalTexture() then
            self:GetNormalTexture():SetVertexColor(colors.border[1], colors.border[2], colors.border[3])
        end
        if buttonText then
            buttonText:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
        end
    end)
end

-- Apply theme to an edit box
function ThemeIntegration:ApplyThemeToEditBox(editBox)
    if not editBox then return end
    
    local colors = self:GetThemeColors()
    
    -- Create backdrop for edit box
    if editBox.SetBackdrop then
        local backdrop = {
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            tile = true, tileSize = 16, edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 }
        }
        
        editBox:SetBackdrop(backdrop)
        editBox:SetBackdropColor(colors.background[1] * 1.2, colors.background[2] * 1.2, colors.background[3] * 1.2, colors.background[4] or 0.85)
        editBox:SetBackdropBorderColor(colors.border[1], colors.border[2], colors.border[3], 1)
    end
    
    -- Set text color
    editBox:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
    
    -- Add focus effect
    editBox:HookScript("OnEditFocusGained", function(self)
        if self.SetBackdrop then
            self:SetBackdropBorderColor(colors.highlight[1], colors.highlight[2], colors.highlight[3], 1)
        end
    end)
    
    editBox:HookScript("OnEditFocusLost", function(self)
        if self.SetBackdrop then
            self:SetBackdropBorderColor(colors.border[1], colors.border[2], colors.border[3], 1)
        end
    end)
end

-- Apply theme to slider
function ThemeIntegration:ApplyThemeToSlider(slider)
    if not slider then return end
    
    local colors = self:GetThemeColors()
    
    -- Recolor the slider
    local thumbTexture = slider:GetThumbTexture()
    if thumbTexture then
        thumbTexture:SetColorTexture(colors.border[1], colors.border[2], colors.border[3], 1)
    end
    
    -- Recolor text if exists
    for i = 1, slider:GetNumRegions() do
        local region = select(i, slider:GetRegions())
        if region:IsObjectType("FontString") then
            region:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
        end
    end
end

-- Apply theme to dropdown
function ThemeIntegration:ApplyThemeToDropdown(dropdown)
    if not dropdown then return end
    
    local colors = self:GetThemeColors()
    
    -- Apply to button part
    local button = dropdown.Button or dropdown:GetChildren()[1]
    if button then
        self:ApplyThemeToButton(button)
    end
    
    -- Apply to text
    local text = dropdown.Text or select(1, dropdown:GetRegions())
    if text and text:IsObjectType("FontString") then
        text:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
    end
end

-- Apply theme to the auction house UI frames
function ThemeIntegration:ApplyThemeToAuctionUI()
    if not Auctionator.mainFrame then return end
    
    -- Apply theme to main frame
    self:ApplyThemeToFrame(Auctionator.mainFrame)
    
    -- Apply to search tab frame
    if Auctionator.searchTabFrame then
        self:ApplyThemeToFrame(Auctionator.searchTabFrame)
        
        -- Apply to search box
        if Auctionator.searchBox then
            self:ApplyThemeToEditBox(Auctionator.searchBox)
        end
        
        -- Apply to search list frame
        if Auctionator.searchListFrame then
            self:ApplyThemeToFrame(Auctionator.searchListFrame)
        end
        
        -- Apply to results frame
        if Auctionator.searchResultsFrame then
            self:ApplyThemeToFrame(Auctionator.searchResultsFrame)
        end
    end
    
    -- Apply to sell tab frame
    if Auctionator.sellTabFrame then
        self:ApplyThemeToFrame(Auctionator.sellTabFrame)
    end
    
    -- Apply to cancel tab frame
    if Auctionator.cancelTabFrame then
        self:ApplyThemeToFrame(Auctionator.cancelTabFrame)
    end
    
    -- Apply to more tab frame
    if Auctionator.moreTabFrame then
        self:ApplyThemeToFrame(Auctionator.moreTabFrame)
    end
    
    -- Apply to tab buttons
    if Auctionator.tabButtons then
        for _, button in pairs(Auctionator.tabButtons) do
            self:ApplyThemeToButton(button)
        end
    end
    
    -- Replace the logo with theme-specific version
    if Auctionator.logo then
        local logoTexture = self:GetThemeTexture("Logo.tga")
        Auctionator.logo:SetTexture(logoTexture)
    end
end

-- Initialize the theme integration
function ThemeIntegration:Initialize()
    -- Register for theme change events
    VUI:RegisterCallback("ThemeChanged", function()
        self:ApplyTheme()
    end)
    
    -- Apply current theme
    self:ApplyTheme()
end

-- Apply current theme to all elements
function ThemeIntegration:ApplyTheme()
    -- Only proceed if Auction House is open
    if not Auctionator.mainFrame or not Auctionator.mainFrame:IsShown() then
        -- Hook into frame creation to apply theme when frames are created
        if not self.hooked then
            hooksecurefunc(Auctionator, "CreateAuctionHouseFrame", function()
                self:ApplyThemeToAuctionUI()
            end)
            self.hooked = true
        end
        return
    end
    
    -- Apply theme to all UI elements
    self:ApplyThemeToAuctionUI()
end

-- Helper function to check if a texture exists
function TextureExists(texturePath)
    return true -- For now, always return true as we can't easily check file existence in WoW
end
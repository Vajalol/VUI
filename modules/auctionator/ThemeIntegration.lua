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

-- Get a texture from LibSharedMedia
function ThemeIntegration:GetLSMTexture(textureType, textureName)
    local LSM = LibStub("LibSharedMedia-3.0")
    if not LSM then return nil end
    
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Try to get theme-specific texture first
    local themeSpecificName = "VUI:Auctionator:" .. currentTheme .. ":" .. textureName
    if LSM:IsValid(textureType, themeSpecificName) then
        return LSM:Fetch(textureType, themeSpecificName)
    end
    
    -- Fall back to generic texture
    local genericName = "VUI:Auctionator:" .. textureName
    if LSM:IsValid(textureType, genericName) then
        return LSM:Fetch(textureType, genericName)
    end
    
    -- Return nil if not found
    return nil
end

-- Get a font from LibSharedMedia
function ThemeIntegration:GetFont()
    local LSM = LibStub("LibSharedMedia-3.0")
    if not LSM then return "Fonts\\FRIZQT__.TTF" end
    
    if LSM:IsValid(LSM.MediaType.FONT, "VUI:Auctionator:PriceFont") then
        return LSM:Fetch(LSM.MediaType.FONT, "VUI:Auctionator:PriceFont")
    else
        return "Fonts\\FRIZQT__.TTF"
    end
end

-- Apply theme to a frame
function ThemeIntegration:ApplyThemeToFrame(frame)
    if not frame then return end
    
    local colors = self:GetThemeColors()
    
    -- Get theme options
    local showBorders = VUI.db.profile.modules.auctionator.showBorders
    if showBorders == nil then showBorders = true end
    
    local bgAlpha = VUI.db.profile.modules.auctionator.bgAlpha or 0.85
    
    -- Apply background
    if not frame.themeBg then
        frame.themeBg = frame:CreateTexture(nil, "BACKGROUND")
        frame.themeBg:SetAllPoints()
    end
    frame.themeBg:SetColorTexture(colors.background[1], colors.background[2], colors.background[3], bgAlpha)
    
    -- Apply border if the frame has a backdrop and borders are enabled
    if frame.SetBackdrop then
        if showBorders then
            local backdrop = {
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                tile = true, tileSize = 16, edgeSize = 1,
                insets = { left = 1, right = 1, top = 1, bottom = 1 }
            }
            
            frame:SetBackdrop(backdrop)
            frame:SetBackdropColor(colors.background[1], colors.background[2], colors.background[3], bgAlpha)
            frame:SetBackdropBorderColor(colors.border[1], colors.border[2], colors.border[3], 1)
        else
            -- Simple backdrop without borders
            local backdrop = {
                bgFile = "Interface\\Buttons\\WHITE8x8",
                tile = true, tileSize = 16,
                insets = { left = 0, right = 0, top = 0, bottom = 0 }
            }
            
            frame:SetBackdrop(backdrop)
            frame:SetBackdropColor(colors.background[1], colors.background[2], colors.background[3], bgAlpha)
        end
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
    
    -- Check if VUI theme is enabled
    if not VUI.db.profile.modules.auctionator.useVUITheme then
        return
    end
    
    local colors = self:GetThemeColors()
    local LSM = LibStub("LibSharedMedia-3.0")
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Get theme options
    local showBorders = VUI.db.profile.modules.auctionator.showBorders
    if showBorders == nil then showBorders = true end
    
    local showIcons = VUI.db.profile.modules.auctionator.showIcons
    if showIcons == nil then showIcons = true end
    
    local bgAlpha = VUI.db.profile.modules.auctionator.bgAlpha or 0.85
    
    -- Apply theme to main frame
    self:ApplyThemeToFrame(Auctionator.mainFrame)
    
    -- Apply theme-specific header
    if Auctionator.headerFrame then
        self:ApplyThemeToFrame(Auctionator.headerFrame)
        
        -- Add custom header gradient if not already present
        if not Auctionator.headerFrame.gradient then
            Auctionator.headerFrame.gradient = Auctionator.headerFrame:CreateTexture(nil, "BACKGROUND", nil, -5)
            Auctionator.headerFrame.gradient:SetPoint("TOPLEFT", 1, -1)
            Auctionator.headerFrame.gradient:SetPoint("BOTTOMRIGHT", -1, 1)
        end
        
        -- Style the gradient based on theme
        local gradientAlpha = 0.2
        if currentTheme == "phoenixflame" then
            Auctionator.headerFrame.gradient:SetColorTexture(colors.highlight[1], colors.highlight[2], colors.highlight[3], gradientAlpha)
        elseif currentTheme == "thunderstorm" then
            Auctionator.headerFrame.gradient:SetColorTexture(colors.highlight[1], colors.highlight[2], colors.highlight[3], gradientAlpha)
        elseif currentTheme == "arcanemystic" then
            Auctionator.headerFrame.gradient:SetColorTexture(colors.highlight[1], colors.highlight[2], colors.highlight[3], gradientAlpha)
        elseif currentTheme == "felenergy" then
            Auctionator.headerFrame.gradient:SetColorTexture(colors.highlight[1], colors.highlight[2], colors.highlight[3], gradientAlpha)
        end
    end
    
    -- Apply to search tab frame
    if Auctionator.searchTabFrame then
        self:ApplyThemeToFrame(Auctionator.searchTabFrame)
        
        -- Apply to search box with enhanced styling
        if Auctionator.searchBox then
            self:ApplyThemeToEditBox(Auctionator.searchBox)
            
            -- Handle search icon based on user settings
            if showIcons then
                -- Add search icon if not already present
                if not Auctionator.searchBox.searchIcon then
                    Auctionator.searchBox.searchIcon = Auctionator.searchBox:CreateTexture(nil, "ARTWORK")
                    Auctionator.searchBox.searchIcon:SetSize(16, 16)
                    Auctionator.searchBox.searchIcon:SetPoint("RIGHT", Auctionator.searchBox, "RIGHT", -5, 0)
                end
                
                -- Use theme-specific search icon
                local searchIconTexture = self:GetLSMTexture(LSM.MediaType.BACKGROUND, "SearchIcon")
                if searchIconTexture then
                    Auctionator.searchBox.searchIcon:SetTexture(searchIconTexture)
                    Auctionator.searchBox.searchIcon:Show()
                else
                    -- Fallback to colored texture
                    Auctionator.searchBox.searchIcon:SetColorTexture(colors.border[1], colors.border[2], colors.border[3], 0.7)
                    Auctionator.searchBox.searchIcon:Show()
                end
                
                -- Adjust text insets to make room for the icon
                Auctionator.searchBox:SetTextInsets(8, 24, 0, 0)
            else
                -- Hide icon if it exists
                if Auctionator.searchBox.searchIcon then
                    Auctionator.searchBox.searchIcon:Hide()
                end
                
                -- Reset text insets
                Auctionator.searchBox:SetTextInsets(8, 8, 0, 0)
            end
            
            -- Apply font if available
            local font = self:GetFont()
            if font then
                Auctionator.searchBox:SetFont(font, 12, "")
            end
        end
        
        -- Apply to search list frame with enhanced styling
        if Auctionator.searchListFrame then
            self:ApplyThemeToFrame(Auctionator.searchListFrame)
            
            -- Style the category headers if they exist
            if Auctionator.categoryHeaders then
                for _, header in pairs(Auctionator.categoryHeaders) do
                    header:SetBackdropColor(colors.background[1] * 1.2, colors.background[2] * 1.2, colors.background[3] * 1.2, colors.background[4] or 0.85)
                    header:SetBackdropBorderColor(colors.border[1], colors.border[2], colors.border[3], 0.7)
                    
                    -- Style header text
                    local headerText = header:GetFontString() or header.text
                    if headerText then
                        headerText:SetTextColor(colors.header[1], colors.header[2], colors.header[3], 1)
                        
                        -- Apply font if available
                        local font = self:GetFont()
                        if font then
                            headerText:SetFont(font, 14, "")
                        end
                    end
                end
            end
        end
        
        -- Apply to results frame with enhanced styling
        if Auctionator.searchResultsFrame then
            self:ApplyThemeToFrame(Auctionator.searchResultsFrame)
            
            -- Style item rows if they exist
            if Auctionator.itemRows then
                for _, row in pairs(Auctionator.itemRows) do
                    -- Style row background
                    if row.background then
                        row.background:SetColorTexture(colors.background[1], colors.background[2], colors.background[3], 0.2)
                    end
                    
                    -- Style row highlight
                    if row.highlight then
                        row.highlight:SetColorTexture(colors.highlight[1], colors.highlight[2], colors.highlight[3], 0.3)
                    end
                    
                    -- Style price text
                    if row.priceText then
                        row.priceText:SetTextColor(colors.text[1] * 1.2, colors.text[2] * 1.2, colors.text[3] * 1.2, 1)
                        
                        -- Apply font if available
                        local font = self:GetFont()
                        if font then
                            row.priceText:SetFont(font, 12, "")
                        end
                    end
                end
            end
            
            -- Apply to column headers if they exist
            if Auctionator.columnHeaders then
                for _, header in pairs(Auctionator.columnHeaders) do
                    if header.text then
                        header.text:SetTextColor(colors.header[1], colors.header[2], colors.header[3], 1)
                        
                        -- Apply font if available
                        local font = self:GetFont()
                        if font then
                            header.text:SetFont(font, 12, "")
                        end
                    end
                    
                    -- Style sort buttons
                    if header.sortButton then
                        self:ApplyThemeToButton(header.sortButton)
                    end
                end
            end
        end
    end
    
    -- Apply to sell tab frame with enhanced styling
    if Auctionator.sellTabFrame then
        self:ApplyThemeToFrame(Auctionator.sellTabFrame)
        
        -- Style price input if it exists
        if Auctionator.priceInput then
            self:ApplyThemeToEditBox(Auctionator.priceInput)
            
            -- Handle gold coin icon based on user settings
            if showIcons then
                -- Add gold coin icon if not already present
                if not Auctionator.priceInput.coinIcon then
                    Auctionator.priceInput.coinIcon = Auctionator.priceInput:CreateTexture(nil, "ARTWORK")
                    Auctionator.priceInput.coinIcon:SetSize(16, 16)
                    Auctionator.priceInput.coinIcon:SetPoint("RIGHT", Auctionator.priceInput, "RIGHT", -5, 0)
                end
                
                -- Default gold texture with theme color
                Auctionator.priceInput.coinIcon:SetTexture("Interface\\MoneyFrame\\UI-GoldIcon")
                Auctionator.priceInput.coinIcon:SetVertexColor(colors.highlight[1], colors.highlight[2], colors.highlight[3], 0.8)
                Auctionator.priceInput.coinIcon:Show()
                
                -- Adjust text insets to make room for the icon
                Auctionator.priceInput:SetTextInsets(8, 24, 0, 0)
            else
                -- Hide icon if it exists
                if Auctionator.priceInput.coinIcon then
                    Auctionator.priceInput.coinIcon:Hide()
                end
                
                -- Reset text insets
                Auctionator.priceInput:SetTextInsets(8, 8, 0, 0)
            end
            
            -- Apply font if available
            local font = self:GetFont()
            if font then
                Auctionator.priceInput:SetFont(font, 14, "")
            end
        end
        
        -- Style quantity input if it exists
        if Auctionator.quantityInput then
            self:ApplyThemeToEditBox(Auctionator.quantityInput)
            
            -- Apply font if available
            local font = self:GetFont()
            if font then
                Auctionator.quantityInput:SetFont(font, 14, "")
            end
        end
        
        -- Style post button if it exists
        if Auctionator.postButton then
            self:ApplyThemeToButton(Auctionator.postButton)
            
            -- Enhance post button with theme-specific styling
            local postButtonBackdrop = {
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                tile = true, tileSize = 16, edgeSize = 2,
                insets = { left = 2, right = 2, top = 2, bottom = 2 }
            }
            
            Auctionator.postButton:SetBackdrop(postButtonBackdrop)
            Auctionator.postButton:SetBackdropColor(colors.border[1] * 0.7, colors.border[2] * 0.7, colors.border[3] * 0.7, 0.5)
            Auctionator.postButton:SetBackdropBorderColor(colors.border[1], colors.border[2], colors.border[3], 0.8)
            
            -- Style post button text
            local postButtonText = Auctionator.postButton:GetFontString()
            if postButtonText then
                postButtonText:SetTextColor(colors.highlight[1], colors.highlight[2], colors.highlight[3], 1)
                
                -- Apply font if available
                local font = self:GetFont()
                if font then
                    postButtonText:SetFont(font, 14, "OUTLINE")
                end
            end
        end
    end
    
    -- Apply to cancel tab frame
    if Auctionator.cancelTabFrame then
        self:ApplyThemeToFrame(Auctionator.cancelTabFrame)
        
        -- Style cancel button if it exists
        if Auctionator.cancelButton then
            self:ApplyThemeToButton(Auctionator.cancelButton)
            
            -- Add subtle danger color to cancel button
            if currentTheme == "phoenixflame" then
                Auctionator.cancelButton:SetBackdropColor(0.4, 0.1, 0.1, 0.5)
            elseif currentTheme == "thunderstorm" then
                Auctionator.cancelButton:SetBackdropColor(0.1, 0.1, 0.4, 0.5)
            elseif currentTheme == "arcanemystic" then
                Auctionator.cancelButton:SetBackdropColor(0.3, 0.1, 0.4, 0.5)
            elseif currentTheme == "felenergy" then
                Auctionator.cancelButton:SetBackdropColor(0.1, 0.4, 0.1, 0.5)
            end
        end
    end
    
    -- Apply to more tab frame
    if Auctionator.moreTabFrame then
        self:ApplyThemeToFrame(Auctionator.moreTabFrame)
    end
    
    -- Apply to tab buttons with enhanced styling
    if Auctionator.tabButtons then
        for _, button in pairs(Auctionator.tabButtons) do
            self:ApplyThemeToButton(button)
            
            -- Check if this is the selected tab
            if button.selected then
                -- Add glow effect for selected tab
                if not button.selectionGlow then
                    button.selectionGlow = button:CreateTexture(nil, "OVERLAY")
                    button.selectionGlow:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0)
                    button.selectionGlow:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
                    button.selectionGlow:SetHeight(3)
                end
                
                -- Set color based on theme
                button.selectionGlow:SetColorTexture(colors.highlight[1], colors.highlight[2], colors.highlight[3], 0.8)
                
                -- Style selected tab text
                local buttonText = button:GetFontString()
                if buttonText then
                    buttonText:SetTextColor(colors.highlight[1], colors.highlight[2], colors.highlight[3], 1)
                end
            else
                -- Remove glow if tab is not selected
                if button.selectionGlow then
                    button.selectionGlow:SetAlpha(0)
                end
            end
        end
    end
    
    -- Replace the logo with theme-specific version from LibSharedMedia
    if Auctionator.logo then
        local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
        local logoTexture = self:GetLSMTexture(LSM.MediaType.BACKGROUND, "Logo")
        
        if logoTexture then
            Auctionator.logo:SetTexture(logoTexture)
        else
            -- Fallback to texture path method
            local logoPath = self:GetThemeTexture("Logo.tga")
            Auctionator.logo:SetTexture(logoPath)
        end
    end
    
    -- Style scrollbars
    if Auctionator.scrollFrames then
        for _, scrollFrame in pairs(Auctionator.scrollFrames) do
            local scrollBar = scrollFrame.ScrollBar or scrollFrame.scrollBar or scrollFrame:GetChildren()
            
            if scrollBar and scrollBar.thumbTexture then
                scrollBar.thumbTexture:SetColorTexture(colors.border[1], colors.border[2], colors.border[3], 0.7)
                scrollBar.thumbTexture:SetSize(scrollBar.thumbTexture:GetWidth() - 2, scrollBar.thumbTexture:GetHeight())
            end
        end
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
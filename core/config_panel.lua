local _, VUI = ...
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local AceGUI = LibStub("AceGUI-3.0")

-- Enhanced configuration panel for VUI
-- Provides a user-friendly, theme-aware interface with tab-based navigation

-- Create the configuration panel
function VUI:CreateEnhancedConfigPanel()
    -- If the panel already exists and is shown, just return it
    if self.configFrame and self.configFrame:IsShown() then
        return self.configFrame
    end
    
    -- Create or reset the config frame
    if not self.configFrame then
        -- Create the main frame
        self.configFrame = CreateFrame("Frame", "VUIConfigFrame", UIParent)
        self.configFrame:SetSize(950, 680)
        self.configFrame:SetPoint("CENTER")
        self.configFrame:SetFrameStrata("DIALOG")
        self.configFrame:EnableMouse(true)
        self.configFrame:SetMovable(true)
        self.configFrame:RegisterForDrag("LeftButton")
        self.configFrame:SetScript("OnDragStart", self.configFrame.StartMoving)
        self.configFrame:SetScript("OnDragStop", self.configFrame.StopMovingOrSizing)
        
        -- Get the current theme colors
        local theme = self.db.profile.appearance.theme or "thunderstorm"
        local backdropColor = {r=0.04, g=0.04, b=0.1, a=0.9} -- Default Thunder Storm
        local borderColor = {r=0.05, g=0.62, b=0.9, a=1}
        local highlightColor = {r=0.1, g=0.7, b=1, a=0.3}
        local headerColor = "|cff1784d1" -- Blue
        
        -- Set theme-specific colors
        if theme == "phoenixflame" then
            backdropColor = {r=0.1, g=0.04, b=0.02, a=0.9}
            borderColor = {r=0.9, g=0.3, b=0.05, a=1}
            highlightColor = {r=1, g=0.4, b=0.1, a=0.3}
            headerColor = "|cffE64D0D" -- Fiery orange
        elseif theme == "arcanemystic" then
            backdropColor = {r=0.1, g=0.04, b=0.18, a=0.9}
            borderColor = {r=0.61, g=0.05, b=0.9, a=1}
            highlightColor = {r=0.7, g=0.1, b=1, a=0.3}
            headerColor = "|cff9D0DE6" -- Violet
        elseif theme == "felenergy" then
            backdropColor = {r=0.04, g=0.1, b=0.04, a=0.9}
            borderColor = {r=0.1, g=1.0, b=0.1, a=1}
            highlightColor = {r=0.2, g=1, b=0.2, a=0.3}
            headerColor = "|cff1AFF1A" -- Fel green
        end
        
        -- Store theme data for reuse
        self.configFrame.themeData = {
            backdropColor = backdropColor,
            borderColor = borderColor,
            highlightColor = highlightColor,
            headerColor = headerColor
        }
        
        -- Add a themed background and border
        self.configFrame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 }
        })
        
        self.configFrame:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a)
        self.configFrame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        
        -- Add a themed header
        local headerTexture = self.configFrame:CreateTexture(nil, "ARTWORK")
        headerTexture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
        headerTexture:SetWidth(300)
        headerTexture:SetHeight(64)
        headerTexture:SetPoint("TOP", 0, 12)
        
        -- Add title with theme color
        self.configFrame.title = self.configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        self.configFrame.title:SetPoint("TOP", headerTexture, "TOP", 0, -14)
        self.configFrame.title:SetText(headerColor .. "VUI Configuration|r")
        
        -- Add addon version text
        self.configFrame.version = self.configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        self.configFrame.version:SetPoint("TOPRIGHT", -20, -20)
        self.configFrame.version:SetText(headerColor .. "v" .. self.version .. "|r")
        
        -- Add a themed close button
        self.configFrame.closeButton = CreateFrame("Button", nil, self.configFrame, "UIPanelCloseButton")
        self.configFrame.closeButton:SetPoint("TOPRIGHT", -5, -5)
        
        -- Create sections container
        self.configFrame.sections = {}
        
        -- Create navigation sidebar with theme colors
        self.configFrame.sidebar = CreateFrame("Frame", nil, self.configFrame)
        self.configFrame.sidebar:SetSize(220, self.configFrame:GetHeight() - 40)
        self.configFrame.sidebar:SetPoint("TOPLEFT", 16, -40)
        
        -- Add themed sidebar background
        self.configFrame.sidebar:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        
        -- Make sidebar slightly darker than main panel
        local sidebarColor = {
            r = backdropColor.r * 0.7,
            g = backdropColor.g * 0.7,
            b = backdropColor.b * 0.7,
            a = backdropColor.a + 0.1
        }
        
        self.configFrame.sidebar:SetBackdropColor(sidebarColor.r, sidebarColor.g, sidebarColor.b, sidebarColor.a)
        self.configFrame.sidebar:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        
        -- Add sidebar title
        self.configFrame.sidebar.title = self.configFrame.sidebar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        self.configFrame.sidebar.title:SetPoint("TOP", 0, -10)
        self.configFrame.sidebar.title:SetText(headerColor .. "Navigation|r")
        
        -- Create content area with theme colors
        self.configFrame.content = CreateFrame("Frame", nil, self.configFrame)
        self.configFrame.content:SetSize(self.configFrame:GetWidth() - 260, self.configFrame:GetHeight() - 40)
        self.configFrame.content:SetPoint("TOPLEFT", self.configFrame.sidebar, "TOPRIGHT", 20, 0)
        
        -- Add themed content background
        self.configFrame.content:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        
        self.configFrame.content:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a)
        self.configFrame.content:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        
        -- Create navigation buttons with theme-aware appearance
        local buttons = {
            { text = "General", section = "General", icon = "Interface\\Icons\\INV_Misc_Note_01" },
            { text = "Appearance", section = "Appearance", icon = "Interface\\Icons\\INV_Misc_Gem_Pearl_06" },
            { text = "Modules", section = "Modules", icon = "Interface\\Icons\\INV_Misc_Gear_01" },
            { text = "Profiles", section = "Profiles", icon = "Interface\\Icons\\INV_Misc_Note_06" },
            { text = "About", section = "About", icon = "Interface\\Icons\\INV_Misc_QuestionMark" }
        }
        
        for i, buttonInfo in ipairs(buttons) do
            local button = CreateFrame("Button", nil, self.configFrame.sidebar)
            button:SetSize(190, 40)
            button:SetPoint("TOP", self.configFrame.sidebar, "TOP", 0, -40 - ((i-1) * 45))
            
            -- Create a themed button appearance
            button:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
                insets = { left = 1, right = 1, top = 1, bottom = 1 }
            })
            
            -- Normal state (darker than sidebar)
            local normalColor = {
                r = sidebarColor.r * 0.8, 
                g = sidebarColor.g * 0.8, 
                b = sidebarColor.b * 0.8, 
                a = 0.8
            }
            button:SetBackdropColor(normalColor.r, normalColor.g, normalColor.b, normalColor.a)
            button:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, 0.6)
            
            -- Create icon
            button.icon = button:CreateTexture(nil, "ARTWORK")
            button.icon:SetSize(20, 20)
            button.icon:SetPoint("LEFT", 10, 0)
            button.icon:SetTexture(buttonInfo.icon)
            
            -- Text with nice font
            button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            button.text:SetPoint("LEFT", button.icon, "RIGHT", 10, 0)
            button.text:SetText(buttonInfo.text)
            button.text:SetTextColor(0.9, 0.9, 0.9)
            
            -- Highlight texture
            button.highlighttexture = button:CreateTexture(nil, "HIGHLIGHT")
            button.highlighttexture:SetAllPoints()
            button.highlighttexture:SetColorTexture(
                highlightColor.r, 
                highlightColor.g, 
                highlightColor.b, 
                highlightColor.a
            )
            button:SetHighlightTexture(button.highlighttexture)
            
            -- Click handler
            button:SetScript("OnClick", function()
                self:ShowEnhancedConfigSection(buttonInfo.section)
            end)
            
            -- Store button
            self.configFrame.sidebar["button"..i] = button
        end
        
        -- Create section frames
        self:CreateEnhancedGeneralSection()
        self:CreateEnhancedAppearanceSection()
        self:CreateEnhancedModulesSection()
        self:CreateEnhancedProfilesSection()
        self:CreateEnhancedAboutSection()
        
        -- Add a theme refresh method to update colors when theme changes
        self.configFrame.RefreshTheme = function()
            -- Implementation will be added later
            self:UpdateConfigTheme()
        end
    end
    
    -- Show the default section
    self:ShowEnhancedConfigSection("General")
    
    -- Show the frame
    self.configFrame:Show()
    
    return self.configFrame
end

-- Show a specific section of the enhanced config panel
function VUI:ShowEnhancedConfigSection(section)
    -- Hide all sections
    for name, frame in pairs(self.configFrame.sections) do
        frame:Hide()
    end
    
    -- Show the requested section
    if self.configFrame.sections[section] then
        self.configFrame.sections[section]:Show()
        
        -- Update button highlights
        for i = 1, 5 do
            local button = self.configFrame.sidebar["button"..i]
            if button and button.text:GetText() == section then
                -- Apply selected state
                local borderColor = self.configFrame.themeData.borderColor
                button:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, 1)
                
                -- Use a slightly lighter background for the selected button
                local selectedColor = {
                    r = self.configFrame.themeData.backdropColor.r * 1.3,
                    g = self.configFrame.themeData.backdropColor.g * 1.3,
                    b = self.configFrame.themeData.backdropColor.b * 1.3,
                    a = 0.9
                }
                button:SetBackdropColor(selectedColor.r, selectedColor.g, selectedColor.b, selectedColor.a)
            else
                -- Reset other buttons
                local normalColor = {
                    r = self.configFrame.themeData.backdropColor.r * 0.6,
                    g = self.configFrame.themeData.backdropColor.g * 0.6,
                    b = self.configFrame.themeData.backdropColor.b * 0.6,
                    a = 0.8
                }
                button:SetBackdropColor(normalColor.r, normalColor.g, normalColor.b, normalColor.a)
                button:SetBackdropBorderColor(
                    self.configFrame.themeData.borderColor.r,
                    self.configFrame.themeData.borderColor.g,
                    self.configFrame.themeData.borderColor.b,
                    0.6
                )
            end
        end
    end
end

-- Update the theme of the config panel
function VUI:UpdateConfigTheme()
    if not self.configFrame then return end
    
    -- Get the current theme colors
    local theme = self.db.profile.appearance.theme or "thunderstorm"
    local backdropColor = {r=0.04, g=0.04, b=0.1, a=0.9} -- Default Thunder Storm
    local borderColor = {r=0.05, g=0.62, b=0.9, a=1}
    local highlightColor = {r=0.1, g=0.7, b=1, a=0.3}
    local headerColor = "|cff1784d1" -- Blue
    
    -- Set theme-specific colors
    if theme == "phoenixflame" then
        backdropColor = {r=0.1, g=0.04, b=0.02, a=0.9}
        borderColor = {r=0.9, g=0.3, b=0.05, a=1}
        highlightColor = {r=1, g=0.4, b=0.1, a=0.3}
        headerColor = "|cffE64D0D" -- Fiery orange
    elseif theme == "arcanemystic" then
        backdropColor = {r=0.1, g=0.04, b=0.18, a=0.9}
        borderColor = {r=0.61, g=0.05, b=0.9, a=1}
        highlightColor = {r=0.7, g=0.1, b=1, a=0.3}
        headerColor = "|cff9D0DE6" -- Violet
    elseif theme == "felenergy" then
        backdropColor = {r=0.04, g=0.1, b=0.04, a=0.9}
        borderColor = {r=0.1, g=1.0, b=0.1, a=1}
        highlightColor = {r=0.2, g=1, b=0.2, a=0.3}
        headerColor = "|cff1AFF1A" -- Fel green
    end
    
    -- Store new theme data
    self.configFrame.themeData = {
        backdropColor = backdropColor,
        borderColor = borderColor,
        highlightColor = highlightColor,
        headerColor = headerColor
    }
    
    -- Update main frame appearance
    self.configFrame:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a)
    self.configFrame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
    
    -- Update title with theme color
    self.configFrame.title:SetText(headerColor .. "VUI Configuration|r")
    
    -- Update version text
    self.configFrame.version:SetText(headerColor .. "v" .. self.version .. "|r")
    
    -- Update sidebar
    local sidebarColor = {
        r = backdropColor.r * 0.7,
        g = backdropColor.g * 0.7,
        b = backdropColor.b * 0.7,
        a = backdropColor.a + 0.1
    }
    
    self.configFrame.sidebar:SetBackdropColor(sidebarColor.r, sidebarColor.g, sidebarColor.b, sidebarColor.a)
    self.configFrame.sidebar:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
    
    -- Update sidebar title
    self.configFrame.sidebar.title:SetText(headerColor .. "Navigation|r")
    
    -- Update content area
    self.configFrame.content:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a)
    self.configFrame.content:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
    
    -- Update navigation button colors
    -- This will also handle the highlighting for the currently selected section
    local currentSection = nil
    for name, frame in pairs(self.configFrame.sections) do
        if frame:IsShown() then
            currentSection = name
            break
        end
    end
    
    if currentSection then
        self:ShowEnhancedConfigSection(currentSection)
    end
    
    -- Update section headers and other themed elements
    for _, sectionName in ipairs({"General", "Appearance", "Modules", "Profiles", "About"}) do
        local section = self.configFrame.sections[sectionName]
        if section and section.title then
            section.title:SetText(headerColor .. sectionName .. " Settings|r")
        end
    end
end

-- Create a themed scrollframe container for a config section
function VUI:CreateScrollFrame(parent)
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(parent:GetWidth() - 30, parent:GetHeight() - 40)
    scrollFrame:SetPoint("TOPLEFT", 15, -30)
    
    -- Theme the scroll bar
    local scrollBar = _G[scrollFrame:GetName() .. "ScrollBar"]
    scrollBar:GetThumbTexture():SetColorTexture(
        self.configFrame.themeData.borderColor.r,
        self.configFrame.themeData.borderColor.g,
        self.configFrame.themeData.borderColor.b,
        0.5
    )
    
    -- Create the content frame
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetWidth(), 1000) -- Height will be adjusted dynamically
    scrollFrame:SetScrollChild(content)
    
    return scrollFrame, content
end

-- Helper function to create themed controls
function VUI:CreateThemedControl(controlType, parent, name, width, height)
    local control
    
    if controlType == "Button" then
        control = CreateFrame("Button", nil, parent)
        control:SetSize(width or 150, height or 30)
        
        -- Button appearance
        control:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 }
        })
        
        -- Use theme colors for the button
        local bgColor = {
            r = self.configFrame.themeData.backdropColor.r * 1.3,
            g = self.configFrame.themeData.backdropColor.g * 1.3,
            b = self.configFrame.themeData.backdropColor.b * 1.3,
            a = 0.8
        }
        control:SetBackdropColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
        control:SetBackdropBorderColor(
            self.configFrame.themeData.borderColor.r,
            self.configFrame.themeData.borderColor.g,
            self.configFrame.themeData.borderColor.b,
            1
        )
        
        -- Button text
        control.text = control:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        control.text:SetPoint("CENTER")
        control.text:SetText(name or "Button")
        
        -- Highlight effect
        control.highlighttexture = control:CreateTexture(nil, "HIGHLIGHT")
        control.highlighttexture:SetAllPoints()
        control.highlighttexture:SetColorTexture(
            self.configFrame.themeData.highlightColor.r,
            self.configFrame.themeData.highlightColor.g,
            self.configFrame.themeData.highlightColor.b,
            self.configFrame.themeData.highlightColor.a
        )
        control:SetHighlightTexture(control.highlighttexture)
    
    elseif controlType == "CheckButton" then
        control = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
        control:SetSize(26, 26)
        
        -- Set the text
        _G[control:GetName() .. "Text"]:SetText(name or "CheckButton")
        _G[control:GetName() .. "Text"]:SetTextColor(0.9, 0.9, 0.9)
        
        -- Theme the check texture
        control:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
        local checkedTexture = control:GetCheckedTexture()
        checkedTexture:SetVertexColor(
            self.configFrame.themeData.borderColor.r,
            self.configFrame.themeData.borderColor.g,
            self.configFrame.themeData.borderColor.b,
            1
        )
    
    elseif controlType == "Slider" then
        control = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
        control:SetWidth(width or 200)
        control:SetHeight(height or 16)
        
        -- Set the text
        _G[control:GetName() .. "Text"]:SetText(name or "Slider")
        _G[control:GetName() .. "Text"]:SetTextColor(0.9, 0.9, 0.9)
        _G[control:GetName() .. "Low"]:SetTextColor(0.7, 0.7, 0.7)
        _G[control:GetName() .. "High"]:SetTextColor(0.7, 0.7, 0.7)
        
        -- Theme the slider
        control:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
        local thumbTexture = control:GetThumbTexture()
        thumbTexture:SetVertexColor(
            self.configFrame.themeData.borderColor.r,
            self.configFrame.themeData.borderColor.g,
            self.configFrame.themeData.borderColor.b,
            1
        )
    end
    
    return control
end

-- Create the modules section with improved organization
function VUI:CreateEnhancedModulesSection()
    -- Create the section frame if it doesn't exist
    if not self.configFrame.sections.Modules then
        local frame = CreateFrame("Frame", nil, self.configFrame.content)
        frame:SetAllPoints()
        
        -- Title with theme color
        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.title:SetPoint("TOPLEFT", 20, -20)
        frame.title:SetText(self.configFrame.themeData.headerColor .. "Modules Settings|r")
        
        -- Description
        frame.desc = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.desc:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -10)
        frame.desc:SetText("Enable or disable VUI modules and configure their settings")
        frame.desc:SetTextColor(0.9, 0.9, 0.9)
        
        -- Create a module category system
        local categories = {
            { name = "Core Addons", modules = {"buffoverlay", "trufigcd", "moveany", "auctionator", "angrykeystone", "omnicc", "omnicd", "idtip", "premadegroupfinder", "spellnotifications", "msbt"} },
            { name = "Interface Enhancements", modules = {"bags", "paperdoll", "actionbars", "nameplates", "epf"} },
            { name = "Visual & Performance", modules = {"unitframes", "skins", "detailsskin"} },
            { name = "Tools", modules = {"tools"} }
        }
        
        -- Create scrollable frame for module content
        local scrollFrame, content = self:CreateScrollFrame(frame)
        frame.scrollFrame = scrollFrame
        frame.content = content
        
        -- Store currently expanded category
        frame.expandedCategory = nil
        
        -- Store module config containers
        frame.moduleConfigs = {}
        
        -- Create category headers and module toggles
        local yOffset = 10
        
        for i, category in ipairs(categories) do
            -- Create category header
            local header = CreateFrame("Button", nil, content)
            header:SetSize(content:GetWidth() - 30, 30)
            header:SetPoint("TOPLEFT", 15, -yOffset)
            
            -- Header background
            header:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
                insets = { left = 1, right = 1, top = 1, bottom = 1 }
            })
            
            local headerBgColor = {
                r = self.configFrame.themeData.borderColor.r * 0.5,
                g = self.configFrame.themeData.borderColor.g * 0.5,
                b = self.configFrame.themeData.borderColor.b * 0.5,
                a = 0.7
            }
            header:SetBackdropColor(headerBgColor.r, headerBgColor.g, headerBgColor.b, headerBgColor.a)
            header:SetBackdropBorderColor(
                self.configFrame.themeData.borderColor.r,
                self.configFrame.themeData.borderColor.g,
                self.configFrame.themeData.borderColor.b,
                0.8
            )
            
            -- Expand/collapse indicator
            header.expandIcon = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            header.expandIcon:SetPoint("LEFT", 10, 0)
            header.expandIcon:SetText("+")
            header.expandIcon:SetTextColor(1, 1, 1)
            
            -- Header text
            header.text = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            header.text:SetPoint("LEFT", header.expandIcon, "RIGHT", 8, 0)
            header.text:SetText(category.name)
            header.text:SetTextColor(1, 1, 1)
            
            -- Store category data
            header.categoryIndex = i
            header.modules = category.modules
            header.expanded = false
            
            -- Create container for module entries
            header.moduleContainer = CreateFrame("Frame", nil, content)
            header.moduleContainer:SetSize(content:GetWidth() - 50, 1)
            header.moduleContainer:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 20, -5)
            header.moduleContainer:Hide()
            
            -- Populate module entries
            local moduleYOffset = 5
            for j, moduleName in ipairs(category.modules) do
                local module = CreateFrame("Frame", nil, header.moduleContainer)
                module:SetSize(header.moduleContainer:GetWidth(), 40)
                module:SetPoint("TOPLEFT", 0, -moduleYOffset)
                
                -- Module background
                module:SetBackdrop({
                    bgFile = "Interface\\Buttons\\WHITE8x8",
                    edgeFile = "Interface\\Buttons\\WHITE8x8",
                    edgeSize = 1,
                    insets = { left = 1, right = 1, top = 1, bottom = 1 }
                })
                
                local moduleBgColor = {
                    r = self.configFrame.themeData.backdropColor.r * 0.8,
                    g = self.configFrame.themeData.backdropColor.g * 0.8,
                    b = self.configFrame.themeData.backdropColor.b * 0.8,
                    a = 0.5
                }
                module:SetBackdropColor(moduleBgColor.r, moduleBgColor.g, moduleBgColor.b, moduleBgColor.a)
                module:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
                
                -- Module name
                local displayName = moduleName:gsub("^%l", string.upper)
                module.text = module:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                module.text:SetPoint("LEFT", 40, 0)
                module.text:SetText(displayName)
                module.text:SetTextColor(0.9, 0.9, 0.9)
                
                -- Enable/disable checkbox
                module.checkbox = CreateFrame("CheckButton", nil, module, "UICheckButtonTemplate")
                module.checkbox:SetSize(24, 24)
                module.checkbox:SetPoint("LEFT", 8, 0)
                
                -- Theme the checkbox
                module.checkbox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
                local checkedTexture = module.checkbox:GetCheckedTexture()
                checkedTexture:SetVertexColor(
                    self.configFrame.themeData.borderColor.r,
                    self.configFrame.themeData.borderColor.g,
                    self.configFrame.themeData.borderColor.b,
                    1
                )
                
                -- Set checkbox state based on module enabled status
                module.checkbox:SetChecked(self:IsModuleEnabled(moduleName))
                
                -- Checkbox click handler
                module.checkbox:SetScript("OnClick", function(checkbox)
                    local isChecked = checkbox:GetChecked()
                    if isChecked then
                        self:EnableModule(moduleName)
                    else
                        self:DisableModule(moduleName)
                    end
                end)
                
                -- Settings button
                module.configButton = self:CreateThemedControl("Button", module, "Settings", 80, 24)
                module.configButton:SetPoint("RIGHT", -10, 0)
                
                -- Config button click handler
                module.configButton:SetScript("OnClick", function()
                    self:ShowModuleConfig(moduleName, frame)
                end)
                
                moduleYOffset = moduleYOffset + 45
            end
            
            -- Update container height
            header.moduleContainer:SetHeight(moduleYOffset)
            
            -- Toggle expand/collapse on click
            header:SetScript("OnClick", function()
                header.expanded = not header.expanded
                
                -- Update expand icon
                header.expandIcon:SetText(header.expanded and "-" or "+")
                
                -- Show/hide module container
                if header.expanded then
                    -- Hide any previously expanded category
                    if frame.expandedCategory and frame.expandedCategory ~= header then
                        frame.expandedCategory.expanded = false
                        frame.expandedCategory.expandIcon:SetText("+")
                        frame.expandedCategory.moduleContainer:Hide()
                    end
                    
                    header.moduleContainer:Show()
                    frame.expandedCategory = header
                else
                    header.moduleContainer:Hide()
                    if frame.expandedCategory == header then
                        frame.expandedCategory = nil
                    end
                end
                
                -- Recalculate content height
                self:RecalculateModuleContentHeight(frame)
            end)
            
            yOffset = yOffset + 40
            
            -- Store header for later access
            frame["categoryHeader"..i] = header
        end
        
        -- Set initial content height
        content:SetHeight(math.max(1000, yOffset + 100))
        
        -- Store the section
        self.configFrame.sections.Modules = frame
    end
end

-- Helper function to recalculate module content height based on expanded categories
function VUI:RecalculateModuleContentHeight(frame)
    if not frame or not frame.content then return end
    
    local height = 10 -- Start with some padding
    
    -- Add height for each category header
    for i = 1, 4 do
        local header = frame["categoryHeader"..i]
        if header then
            height = height + 40 -- Header height
            
            -- If expanded, add container height
            if header.expanded and header.moduleContainer then
                height = height + header.moduleContainer:GetHeight() + 10 -- Add some padding
            end
        end
    end
    
    -- Set content height (with a minimum size)
    frame.content:SetHeight(math.max(500, height))
end

-- Show configuration for a specific module
function VUI:ShowModuleConfig(moduleName, parentFrame)
    if not self.configFrame or not parentFrame then return end
    
    -- Create a module config frame if it doesn't exist
    if not parentFrame.moduleConfigFrame then
        local configFrame = CreateFrame("Frame", nil, parentFrame)
        configFrame:SetSize(parentFrame:GetWidth() - 40, parentFrame:GetHeight() - 100)
        configFrame:SetPoint("TOP", 0, -60)
        
        -- Config frame background
        configFrame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        
        local bgColor = {
            r = self.configFrame.themeData.backdropColor.r * 1.2,
            g = self.configFrame.themeData.backdropColor.g * 1.2,
            b = self.configFrame.themeData.backdropColor.b * 1.2,
            a = 0.95
        }
        configFrame:SetBackdropColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
        configFrame:SetBackdropBorderColor(
            self.configFrame.themeData.borderColor.r,
            self.configFrame.themeData.borderColor.g,
            self.configFrame.themeData.borderColor.b,
            1
        )
        
        -- Title
        configFrame.title = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        configFrame.title:SetPoint("TOPLEFT", 20, -15)
        
        -- Close button
        configFrame.closeButton = CreateFrame("Button", nil, configFrame, "UIPanelCloseButton")
        configFrame.closeButton:SetPoint("TOPRIGHT", -5, -5)
        configFrame.closeButton:SetScript("OnClick", function()
            configFrame:Hide()
        end)
        
        -- Back button
        configFrame.backButton = self:CreateThemedControl("Button", configFrame, "Back to Modules", 150, 30)
        configFrame.backButton:SetPoint("BOTTOMRIGHT", -20, 15)
        configFrame.backButton:SetScript("OnClick", function()
            configFrame:Hide()
        end)
        
        -- Create scrollable content area
        local scrollFrame, content = self:CreateScrollFrame(configFrame)
        configFrame.scrollFrame = scrollFrame
        configFrame.content = content
        
        parentFrame.moduleConfigFrame = configFrame
    end
    
    -- Configure the frame for this module
    local configFrame = parentFrame.moduleConfigFrame
    
    -- Set module name in title (with color)
    local displayName = moduleName:gsub("^%l", string.upper)
    configFrame.title:SetText(self.configFrame.themeData.headerColor .. displayName .. " Module Settings|r")
    
    -- Clear existing content
    for i = 1, configFrame.content:GetNumChildren() do
        local child = select(i, configFrame.content:GetChildren())
        child:Hide()
    end
    
    -- Get module config if available
    local moduleConfig = nil
    if self[moduleName] and self[moduleName].GetConfig then
        moduleConfig = self[moduleName]:GetConfig()
    end
    
    -- If no specific config is available, show a default message
    if not moduleConfig then
        local defaultText = configFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        defaultText:SetPoint("TOP", 0, -30)
        defaultText:SetWidth(configFrame.content:GetWidth() - 40)
        defaultText:SetText("No specific configuration options are available for this module.")
        defaultText:SetTextColor(0.9, 0.9, 0.9)
        
        -- Add module description
        local description = ""
        if moduleName == "buffoverlay" then
            description = "Displays buff and debuff icons around your character or target frame."
        elseif moduleName == "trufigcd" then
            description = "Shows recently used abilities with a visual history tracker."
        elseif moduleName == "moveany" then
            description = "Allows repositioning of any UI element by unlocking frames."
        elseif moduleName == "auctionator" then
            description = "Enhances the auction house interface with advanced buying and selling tools."
        elseif moduleName == "angrykeystone" then
            description = "Improves Mythic+ UI with timer, objectives tracking and detailed information."
        elseif moduleName == "omnicc" then
            description = "Adds cooldown count text to all abilities and items."
        elseif moduleName == "omnicd" then
            description = "Tracks party member cooldowns for better group coordination."
        elseif moduleName == "idtip" then
            description = "Adds IDs to tooltips for spells, items, and more."
        elseif moduleName == "premadegroupfinder" then
            description = "Enhanced group finder with advanced filtering and scoring."
        elseif moduleName == "bags" then
            description = "Improved bag interface with item level display and sorting features."
        elseif moduleName == "paperdoll" then
            description = "Enhanced character panel with detailed stats and item information."
        elseif moduleName == "actionbars" then
            description = "Customizable action bars with enhanced visual features."
        elseif moduleName == "nameplates" then
            description = "Advanced nameplate customization with WhiiskeyZ and Maeraad profiles."
        elseif moduleName == "epf" then
            description = "Enhanced Player Frame with customizable health/power text and portrait options."
        elseif moduleName == "tools" then
            description = "WeakAura-inspired tools including Position of Power, Buff Checker, and Mouse Trail."
        else
            description = "Core module for VUI functionality."
        end
        
        local descHeader = configFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        descHeader:SetPoint("TOP", defaultText, "BOTTOM", 0, -20)
        descHeader:SetText(self.configFrame.themeData.headerColor .. "Description:|r")
        
        local descText = configFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        descText:SetPoint("TOP", descHeader, "BOTTOM", 0, -10)
        descText:SetWidth(configFrame.content:GetWidth() - 60)
        descText:SetText(description)
        descText:SetTextColor(0.9, 0.9, 0.9)
        
        -- Add enabled status
        local statusHeader = configFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        statusHeader:SetPoint("TOP", descText, "BOTTOM", 0, -30)
        statusHeader:SetText(self.configFrame.themeData.headerColor .. "Status:|r")
        
        local enableToggle = CreateFrame("CheckButton", nil, configFrame.content, "UICheckButtonTemplate")
        enableToggle:SetSize(26, 26)
        enableToggle:SetPoint("TOP", statusHeader, "BOTTOM", -70, -10)
        
        -- Theme the checkbox
        enableToggle:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
        local checkedTexture = enableToggle:GetCheckedTexture()
        checkedTexture:SetVertexColor(
            self.configFrame.themeData.borderColor.r,
            self.configFrame.themeData.borderColor.g,
            self.configFrame.themeData.borderColor.b,
            1
        )
        
        -- Set checkbox state and handler
        enableToggle:SetChecked(self:IsModuleEnabled(moduleName))
        enableToggle:SetScript("OnClick", function(checkbox)
            local isChecked = checkbox:GetChecked()
            if isChecked then
                self:EnableModule(moduleName)
            else
                self:DisableModule(moduleName)
            end
            
            -- Update status text
            if statusText then
                statusText:SetText(isChecked and "Enabled" or "Disabled")
                statusText:SetTextColor(isChecked and 0.0, 1.0, 0.0 or 1.0, 0.0, 0.0)
            end
        end)
        
        -- Status text label
        _G[enableToggle:GetName() .. "Text"]:SetText("Enable Module")
        _G[enableToggle:GetName() .. "Text"]:SetTextColor(0.9, 0.9, 0.9)
        
        -- Current status
        local isEnabled = self:IsModuleEnabled(moduleName)
        local statusText = configFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        statusText:SetPoint("LEFT", enableToggle, "RIGHT", 80, 0)
        statusText:SetText(isEnabled and "Enabled" or "Disabled")
        statusText:SetTextColor(isEnabled and 0.0, 1.0, 0.0 or 1.0, 0.0, 0.0)
    else
        -- Show module-specific config options
        -- This would be implemented differently for each module
        local yOffset = 20
        
        -- Display module name and enabled status at the top
        local moduleHeader = configFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        moduleHeader:SetPoint("TOPLEFT", 20, -yOffset)
        moduleHeader:SetText(self.configFrame.themeData.headerColor .. displayName .. "|r")
        
        yOffset = yOffset + 30
        
        -- Enabled toggle
        local enabledText = configFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        enabledText:SetPoint("TOPLEFT", 40, -yOffset)
        enabledText:SetText("Enable Module")
        
        local enableToggle = CreateFrame("CheckButton", nil, configFrame.content, "UICheckButtonTemplate")
        enableToggle:SetSize(26, 26)
        enableToggle:SetPoint("LEFT", enabledText, "RIGHT", 10, 0)
        
        -- Theme the checkbox
        enableToggle:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
        local checkedTexture = enableToggle:GetCheckedTexture()
        checkedTexture:SetVertexColor(
            self.configFrame.themeData.borderColor.r,
            self.configFrame.themeData.borderColor.g,
            self.configFrame.themeData.borderColor.b,
            1
        )
        
        -- Set checkbox state and handler
        enableToggle:SetChecked(self:IsModuleEnabled(moduleName))
        enableToggle:SetScript("OnClick", function(checkbox)
            local isChecked = checkbox:GetChecked()
            if isChecked then
                self:EnableModule(moduleName)
            else
                self:DisableModule(moduleName)
            end
        end)
        
        yOffset = yOffset + 40
        
        -- Render module-specific options
        -- This is a simplified example; actual implementation would handle different option types
        for optionName, optionData in pairs(moduleConfig) do
            if optionData.type == "toggle" then
                local optionText = configFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                optionText:SetPoint("TOPLEFT", 40, -yOffset)
                optionText:SetText(optionData.name)
                optionText:SetTextColor(0.9, 0.9, 0.9)
                
                if optionData.desc then
                    optionText.tooltipText = optionData.desc
                    optionText:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
                        GameTooltip:Show()
                    end)
                    optionText:SetScript("OnLeave", function()
                        GameTooltip:Hide()
                    end)
                end
                
                local toggle = CreateFrame("CheckButton", nil, configFrame.content, "UICheckButtonTemplate")
                toggle:SetSize(26, 26)
                toggle:SetPoint("LEFT", optionText, "RIGHT", 10, 0)
                
                -- Theme the checkbox
                toggle:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
                local toggleCheckedTexture = toggle:GetCheckedTexture()
                toggleCheckedTexture:SetVertexColor(
                    self.configFrame.themeData.borderColor.r,
                    self.configFrame.themeData.borderColor.g,
                    self.configFrame.themeData.borderColor.b,
                    1
                )
                
                -- Set checkbox state and handler using the getter/setter functions
                if optionData.get then
                    toggle:SetChecked(optionData.get())
                end
                
                toggle:SetScript("OnClick", function(checkbox)
                    if optionData.set then
                        optionData.set(checkbox:GetChecked())
                    end
                end)
                
                yOffset = yOffset + 30
                
            elseif optionData.type == "range" then
                local optionText = configFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                optionText:SetPoint("TOPLEFT", 40, -yOffset)
                optionText:SetText(optionData.name)
                optionText:SetTextColor(0.9, 0.9, 0.9)
                
                yOffset = yOffset + 20
                
                local slider = CreateFrame("Slider", nil, configFrame.content, "OptionsSliderTemplate")
                slider:SetWidth(200)
                slider:SetHeight(16)
                slider:SetPoint("TOPLEFT", 60, -yOffset)
                slider:SetMinMaxValues(optionData.min or 0, optionData.max or 1)
                slider:SetValueStep(optionData.step or 0.1)
                
                -- Theme the slider
                slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
                local thumbTexture = slider:GetThumbTexture()
                thumbTexture:SetVertexColor(
                    self.configFrame.themeData.borderColor.r,
                    self.configFrame.themeData.borderColor.g,
                    self.configFrame.themeData.borderColor.b,
                    1
                )
                
                -- Set slider values
                _G[slider:GetName() .. "Low"]:SetText(optionData.min or 0)
                _G[slider:GetName() .. "High"]:SetText(optionData.max or 1)
                
                -- Set current value
                if optionData.get then
                    slider:SetValue(optionData.get())
                end
                
                -- Value display text
                local valueText = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                valueText:SetPoint("TOP", slider, "BOTTOM", 0, -5)
                valueText:SetText(slider:GetValue())
                
                -- Set up event handlers
                slider:SetScript("OnValueChanged", function(self, value)
                    -- Update the value text
                    valueText:SetText(string.format("%.2f", value))
                    
                    -- Call the setter function
                    if optionData.set then
                        optionData.set(value)
                    end
                end)
                
                yOffset = yOffset + 40
            end
        end
    end
    
    -- Set content height
    configFrame.content:SetHeight(math.max(500, yOffset + 100))
    
    -- Show the config frame
    configFrame:Show()
end

-- Create other section implementations
function VUI:CreateEnhancedGeneralSection()
    -- Implementation for General section
    if not self.configFrame.sections.General then
        local frame = CreateFrame("Frame", nil, self.configFrame.content)
        frame:SetAllPoints()
        
        -- Title with theme color
        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.title:SetPoint("TOPLEFT", 20, -20)
        frame.title:SetText(self.configFrame.themeData.headerColor .. "General Settings|r")
        
        -- Set up the rest of the general settings here...
        -- This is a placeholder for now
        
        self.configFrame.sections.General = frame
    end
end

function VUI:CreateEnhancedAppearanceSection()
    -- Implementation for Appearance section
    if not self.configFrame.sections.Appearance then
        local frame = CreateFrame("Frame", nil, self.configFrame.content)
        frame:SetAllPoints()
        
        -- Title with theme color
        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.title:SetPoint("TOPLEFT", 20, -20)
        frame.title:SetText(self.configFrame.themeData.headerColor .. "Appearance Settings|r")
        
        -- Description
        frame.desc = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.desc:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -10)
        frame.desc:SetText("Customize the visual appearance of VUI across all modules")
        frame.desc:SetTextColor(0.9, 0.9, 0.9)
        
        -- Create a scrollable frame for the content
        local scrollFrame, content = self:CreateScrollFrame(frame)
        frame.scrollFrame = scrollFrame
        frame.content = content
        
        -- Theme selection section
        local themeSection = CreateFrame("Frame", nil, content)
        themeSection:SetSize(content:GetWidth() - 40, 300)
        themeSection:SetPoint("TOPLEFT", 20, -20)
        
        -- Theme section title
        themeSection.title = themeSection:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        themeSection.title:SetPoint("TOPLEFT", 0, 0)
        themeSection.title:SetText(self.configFrame.themeData.headerColor .. "Theme Selection|r")
        
        -- Theme preview containers
        local themes = {
            { name = "Thunder Storm", value = "thunderstorm", desc = "Deep blue theme with electric blue accents and lightning effects" },
            { name = "Phoenix Flame", value = "phoenixflame", desc = "Warm red-orange theme with fiery accents and ember effects" },
            { name = "Arcane Mystic", value = "arcanemystic", desc = "Rich purple theme with arcane rune accents and mystic effects" },
            { name = "Fel Energy", value = "felenergy", desc = "Vibrant green theme with fel energy accents and corruption effects" }
        }
        
        local activeTheme = self.db.profile.appearance.theme or "thunderstorm"
        local previewWidth = (content:GetWidth() - 100) / 2
        local previewHeight = 120
        
        for i, theme in ipairs(themes) do
            local col = (i-1) % 2
            local row = math.floor((i-1) / 2)
            
            local preview = CreateFrame("Button", nil, themeSection)
            preview:SetSize(previewWidth, previewHeight)
            preview:SetPoint("TOPLEFT", col * (previewWidth + 40), -40 - (row * (previewHeight + 30)))
            
            -- Theme preview background
            preview:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
                insets = { left = 1, right = 1, top = 1, bottom = 1 }
            })
            
            -- Set theme-specific colors
            local backdropColor, borderColor
            if theme.value == "thunderstorm" then
                backdropColor = {r=0.04, g=0.04, b=0.1, a=0.9}
                borderColor = {r=0.05, g=0.62, b=0.9, a=1}
            elseif theme.value == "phoenixflame" then
                backdropColor = {r=0.1, g=0.04, b=0.02, a=0.9}
                borderColor = {r=0.9, g=0.3, b=0.05, a=1}
            elseif theme.value == "arcanemystic" then
                backdropColor = {r=0.1, g=0.04, b=0.18, a=0.9}
                borderColor = {r=0.61, g=0.05, b=0.9, a=1}
            elseif theme.value == "felenergy" then
                backdropColor = {r=0.04, g=0.1, b=0.04, a=0.9}
                borderColor = {r=0.1, g=1.0, b=0.1, a=1}
            end
            
            preview:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a)
            preview:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
            
            -- Theme name
            preview.name = preview:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            preview.name:SetPoint("TOP", 0, -10)
            preview.name:SetText(theme.name)
            preview.name:SetTextColor(1, 1, 1)
            
            -- Theme icon/logo
            preview.icon = preview:CreateTexture(nil, "ARTWORK")
            preview.icon:SetSize(64, 64)
            preview.icon:SetPoint("CENTER", 0, 0)
            preview.icon:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\themes\\" .. theme.value .. "\\icon.tga")
            
            -- Theme description
            preview.desc = preview:CreateFontString(nil, "OVERLAY", "GameFontSmall")
            preview.desc:SetPoint("BOTTOM", 0, 10)
            preview.desc:SetWidth(previewWidth - 20)
            preview.desc:SetText(theme.desc)
            preview.desc:SetTextColor(0.9, 0.9, 0.9)
            
            -- Active theme indicator
            if theme.value == activeTheme then
                preview.activeIndicator = preview:CreateTexture(nil, "OVERLAY")
                preview.activeIndicator:SetSize(24, 24)
                preview.activeIndicator:SetPoint("TOPRIGHT", -5, -5)
                preview.activeIndicator:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
            end
            
            -- Highlight on mouseover
            preview.highlightTexture = preview:CreateTexture(nil, "HIGHLIGHT")
            preview.highlightTexture:SetAllPoints()
            preview.highlightTexture:SetColorTexture(1, 1, 1, 0.1)
            preview:SetHighlightTexture(preview.highlightTexture)
            
            -- Set click handler
            preview:SetScript("OnClick", function()
                -- Remove active indicator from previous active theme
                for _, otherPreview in ipairs(themeSection.previews or {}) do
                    if otherPreview.activeIndicator then
                        otherPreview.activeIndicator:Hide()
                        otherPreview.activeIndicator = nil
                    end
                end
                
                -- Set active indicator on this theme
                if not preview.activeIndicator then
                    preview.activeIndicator = preview:CreateTexture(nil, "OVERLAY")
                    preview.activeIndicator:SetSize(24, 24)
                    preview.activeIndicator:SetPoint("TOPRIGHT", -5, -5)
                    preview.activeIndicator:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
                end
                
                -- Apply the theme
                self.db.profile.appearance.theme = theme.value
                self:ApplySettings()
                
                -- Update config panel with new theme colors
                self:UpdateConfigTheme()
            end)
            
            -- Store for later reference
            themeSection.previews = themeSection.previews or {}
            themeSection.previews[i] = preview
        end
        
        -- Statusbar texture section
        local statusbarSection = CreateFrame("Frame", nil, content)
        statusbarSection:SetSize(content:GetWidth() - 40, 200)
        statusbarSection:SetPoint("TOPLEFT", themeSection, "BOTTOMLEFT", 0, -40)
        
        -- Statusbar section title
        statusbarSection.title = statusbarSection:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        statusbarSection.title:SetPoint("TOPLEFT", 0, 0)
        statusbarSection.title:SetText(self.configFrame.themeData.headerColor .. "Status Bar Texture|r")
        
        -- Statusbar preview containers
        local statusbars = {
            { name = "Flat", value = "flat", texture = "statusbar-flat.blp" },
            { name = "Gloss", value = "gloss", texture = "statusbar-gloss.tga" },
            { name = "Smooth", value = "smooth", texture = "statusbar-smooth.blp" }
        }
        
        local activeStatusbar = self.db.profile.appearance.statusbarTexture or "smooth"
        local statusbarPreviewWidth = (content:GetWidth() - 100) / 3
        local statusbarPreviewHeight = 30
        
        for i, statusbar in ipairs(statusbars) do
            local preview = CreateFrame("Button", nil, statusbarSection)
            preview:SetSize(statusbarPreviewWidth, statusbarPreviewHeight)
            preview:SetPoint("TOPLEFT", (i-1) * (statusbarPreviewWidth + 20), -40)
            
            -- Preview background for contrast
            preview:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
                insets = { left = 1, right = 1, top = 1, bottom = 1 }
            })
            preview:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
            
            -- Set border color based on active theme
            local theme = self.db.profile.appearance.theme or "thunderstorm"
            local borderColor = {r=0.05, g=0.62, b=0.9, a=1} -- Default Thunder Storm
            
            if theme == "phoenixflame" then
                borderColor = {r=0.9, g=0.3, b=0.05, a=1}
            elseif theme == "arcanemystic" then
                borderColor = {r=0.61, g=0.05, b=0.9, a=1}
            elseif theme == "felenergy" then
                borderColor = {r=0.1, g=1.0, b=0.1, a=1}
            end
            
            preview:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
            
            -- Statusbar texture sample
            preview.bar = CreateFrame("StatusBar", nil, preview)
            preview.bar:SetPoint("TOPLEFT", 5, -5)
            preview.bar:SetPoint("BOTTOMRIGHT", -5, 5)
            preview.bar:SetStatusBarTexture("Interface\\AddOns\\VUI\\media\\textures\\common\\" .. statusbar.texture)
            preview.bar:SetStatusBarColor(borderColor.r, borderColor.g, borderColor.b, 1)
            preview.bar:SetMinMaxValues(0, 100)
            preview.bar:SetValue(75)
            
            -- Statusbar name
            preview.name = statusbarSection:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            preview.name:SetPoint("TOP", preview, "BOTTOM", 0, -5)
            preview.name:SetText(statusbar.name)
            preview.name:SetTextColor(0.9, 0.9, 0.9)
            
            -- Active statusbar indicator
            if statusbar.value == activeStatusbar then
                preview.activeIndicator = preview:CreateTexture(nil, "OVERLAY")
                preview.activeIndicator:SetSize(16, 16)
                preview.activeIndicator:SetPoint("TOPRIGHT", -2, -2)
                preview.activeIndicator:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
            end
            
            -- Highlight on mouseover
            preview.highlightTexture = preview:CreateTexture(nil, "HIGHLIGHT")
            preview.highlightTexture:SetAllPoints()
            preview.highlightTexture:SetColorTexture(1, 1, 1, 0.1)
            preview:SetHighlightTexture(preview.highlightTexture)
            
            -- Set click handler
            preview:SetScript("OnClick", function()
                -- Remove active indicator from previous active statusbar
                for _, otherPreview in ipairs(statusbarSection.previews or {}) do
                    if otherPreview.activeIndicator then
                        otherPreview.activeIndicator:Hide()
                        otherPreview.activeIndicator = nil
                    end
                end
                
                -- Set active indicator on this statusbar
                if not preview.activeIndicator then
                    preview.activeIndicator = preview:CreateTexture(nil, "OVERLAY")
                    preview.activeIndicator:SetSize(16, 16)
                    preview.activeIndicator:SetPoint("TOPRIGHT", -2, -2)
                    preview.activeIndicator:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
                end
                
                -- Apply the statusbar
                self.db.profile.appearance.statusbarTexture = statusbar.value
                self:ApplySettings()
            end)
            
            -- Store for later reference
            statusbarSection.previews = statusbarSection.previews or {}
            statusbarSection.previews[i] = preview
        end
        
        -- Additional appearance options
        local optionsSection = CreateFrame("Frame", nil, content)
        optionsSection:SetSize(content:GetWidth() - 40, 180)
        optionsSection:SetPoint("TOPLEFT", statusbarSection, "BOTTOMLEFT", 0, -40)
        
        -- Options section title
        optionsSection.title = optionsSection:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        optionsSection.title:SetPoint("TOPLEFT", 0, 0)
        optionsSection.title:SetText(self.configFrame.themeData.headerColor .. "Additional Options|r")
        
        -- UI scale option
        local scaleLabel = optionsSection:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        scaleLabel:SetPoint("TOPLEFT", 20, -40)
        scaleLabel:SetText("UI Scale:")
        scaleLabel:SetTextColor(0.9, 0.9, 0.9)
        
        local scaleSlider = CreateFrame("Slider", nil, optionsSection, "OptionsSliderTemplate")
        scaleSlider:SetWidth(200)
        scaleSlider:SetHeight(16)
        scaleSlider:SetPoint("LEFT", scaleLabel, "RIGHT", 20, 0)
        scaleSlider:SetMinMaxValues(0.5, 1.5)
        scaleSlider:SetValueStep(0.05)
        scaleSlider:SetValue(self.db.profile.appearance.scale or 1.0)
        
        _G[scaleSlider:GetName() .. "Low"]:SetText("0.5")
        _G[scaleSlider:GetName() .. "High"]:SetText("1.5")
        _G[scaleSlider:GetName() .. "Text"]:SetText(scaleSlider:GetValue())
        
        -- Theme the slider based on current theme
        scaleSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
        local thumbTexture = scaleSlider:GetThumbTexture()
        thumbTexture:SetVertexColor(
            self.configFrame.themeData.borderColor.r,
            self.configFrame.themeData.borderColor.g,
            self.configFrame.themeData.borderColor.b,
            1
        )
        
        scaleSlider:SetScript("OnValueChanged", function(self, value)
            value = math.floor(value * 100 + 0.5) / 100 -- Round to 2 decimal places
            _G[self:GetName() .. "Text"]:SetText(value)
            VUI.db.profile.appearance.scale = value
            
            -- Apply the scale change
            VUI:ApplySettings()
        end)
        
        -- Toggle for compact mode
        local compactModeCheckbox = CreateFrame("CheckButton", nil, optionsSection, "UICheckButtonTemplate")
        compactModeCheckbox:SetSize(26, 26)
        compactModeCheckbox:SetPoint("TOPLEFT", 20, -80)
        
        -- Theme the checkbox
        compactModeCheckbox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
        local checkedTexture = compactModeCheckbox:GetCheckedTexture()
        checkedTexture:SetVertexColor(
            self.configFrame.themeData.borderColor.r,
            self.configFrame.themeData.borderColor.g,
            self.configFrame.themeData.borderColor.b,
            1
        )
        
        -- Set checkbox state and handler
        compactModeCheckbox:SetChecked(self.db.profile.appearance.compactMode or false)
        compactModeCheckbox:SetScript("OnClick", function(checkbox)
            local isChecked = checkbox:GetChecked()
            self.db.profile.appearance.compactMode = isChecked
            self:ApplySettings()
        end)
        
        -- Checkbox label
        local compactModeLabel = optionsSection:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        compactModeLabel:SetPoint("LEFT", compactModeCheckbox, "RIGHT", 5, 0)
        compactModeLabel:SetText("Compact Mode - Use smaller UI elements for a more minimalist interface")
        compactModeLabel:SetTextColor(0.9, 0.9, 0.9)
        
        -- Toggle for class-colored borders
        local classColorCheckbox = CreateFrame("CheckButton", nil, optionsSection, "UICheckButtonTemplate")
        classColorCheckbox:SetSize(26, 26)
        classColorCheckbox:SetPoint("TOPLEFT", 20, -110)
        
        -- Theme the checkbox
        classColorCheckbox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
        local classColorCheckedTexture = classColorCheckbox:GetCheckedTexture()
        classColorCheckedTexture:SetVertexColor(
            self.configFrame.themeData.borderColor.r,
            self.configFrame.themeData.borderColor.g,
            self.configFrame.themeData.borderColor.b,
            1
        )
        
        -- Set checkbox state and handler
        classColorCheckbox:SetChecked(self.db.profile.appearance.useClassColors or false)
        classColorCheckbox:SetScript("OnClick", function(checkbox)
            local isChecked = checkbox:GetChecked()
            self.db.profile.appearance.useClassColors = isChecked
            self:ApplySettings()
        end)
        
        -- Checkbox label
        local classColorLabel = optionsSection:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        classColorLabel:SetPoint("LEFT", classColorCheckbox, "RIGHT", 5, 0)
        classColorLabel:SetText("Use Class Colors - Border and accent colors will be based on your character's class")
        classColorLabel:SetTextColor(0.9, 0.9, 0.9)
        
        -- Toggle for animations
        local animationsCheckbox = CreateFrame("CheckButton", nil, optionsSection, "UICheckButtonTemplate")
        animationsCheckbox:SetSize(26, 26)
        animationsCheckbox:SetPoint("TOPLEFT", 20, -140)
        
        -- Theme the checkbox
        animationsCheckbox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
        local animationsCheckedTexture = animationsCheckbox:GetCheckedTexture()
        animationsCheckedTexture:SetVertexColor(
            self.configFrame.themeData.borderColor.r,
            self.configFrame.themeData.borderColor.g,
            self.configFrame.themeData.borderColor.b,
            1
        )
        
        -- Set checkbox state and handler
        animationsCheckbox:SetChecked(self.db.profile.appearance.enableAnimations or true)
        animationsCheckbox:SetScript("OnClick", function(checkbox)
            local isChecked = checkbox:GetChecked()
            self.db.profile.appearance.enableAnimations = isChecked
            self:ApplySettings()
        end)
        
        -- Checkbox label
        local animationsLabel = optionsSection:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        animationsLabel:SetPoint("LEFT", animationsCheckbox, "RIGHT", 5, 0)
        animationsLabel:SetText("Enable Animations - Use animated effects for a more dynamic interface")
        animationsLabel:SetTextColor(0.9, 0.9, 0.9)
        
        -- Set content height to accommodate all sections
        content:SetHeight(700)
        
        -- Store the section
        self.configFrame.sections.Appearance = frame
    end
end

function VUI:CreateEnhancedProfilesSection()
    -- Implementation for Profiles section
    if not self.configFrame.sections.Profiles then
        local frame = CreateFrame("Frame", nil, self.configFrame.content)
        frame:SetAllPoints()
        
        -- Title with theme color
        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.title:SetPoint("TOPLEFT", 20, -20)
        frame.title:SetText(self.configFrame.themeData.headerColor .. "Profiles Settings|r")
        
        -- Set up the rest of the profiles settings here...
        -- This is a placeholder for now
        
        self.configFrame.sections.Profiles = frame
    end
end

function VUI:CreateEnhancedAboutSection()
    -- Implementation for About section
    if not self.configFrame.sections.About then
        local frame = CreateFrame("Frame", nil, self.configFrame.content)
        frame:SetAllPoints()
        
        -- Title with theme color
        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.title:SetPoint("TOPLEFT", 20, -20)
        frame.title:SetText(self.configFrame.themeData.headerColor .. "About VUI|r")
        
        -- Set up the rest of the about info here...
        -- This is a placeholder for now
        
        self.configFrame.sections.About = frame
    end
end

-- Override the original function to use the enhanced panel
function VUI:CreateConfigPanel()
    return self:CreateEnhancedConfigPanel()
end

-- Override the original function to open the enhanced panel
function VUI:OpenConfigPanel()
    return self:CreateEnhancedConfigPanel()
end
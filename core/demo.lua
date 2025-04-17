-- VUI Demo
-- This file contains examples of UI elements created with the VUI framework
local _, VUI = ...

-- Create demo module
VUI.Demo = {}

-- Function to create a demo UI panel
function VUI.Demo:CreateDemoPanel()
    -- Don't create multiple panels
    if self.panel and self.panel:IsShown() then
        self.panel:Hide()
        return
    end
    
    -- Create main panel
    local panel = VUI.UI:CreateFrame("VUIDemoPanel", UIParent)
    panel:SetSize(600, 500)
    panel:SetPoint("CENTER")
    panel:SetFrameStrata("DIALOG")
    panel:EnableMouse(true)
    panel:SetMovable(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    
    -- Add title
    local title = panel:CreateFontString(nil, "OVERLAY")
    title:SetPoint("TOP", 0, -15)
    title:SetText("VUI Framework Demo")
    title.fontName = VUI:GetFont(VUI.db.profile.appearance.font)
    title.fontSize = VUI.db.profile.appearance.fontSize + 6
    title:SetFont(title.fontName, title.fontSize, "OUTLINE")
    title:SetTextColor(1, 0.9, 0.8)
    
    -- Add close button
    local closeButton = VUI.UI:CreateButton("VUIDemoCloseButton", panel, "Close")
    closeButton:SetPoint("TOPRIGHT", -10, -10)
    closeButton:SetSize(80, 25)
    closeButton:SetScript("OnClick", function() panel:Hide() end)
    
    -- Create tabs
    local tabs = {}
    local tabTexts = {"Basic Elements", "Widgets", "Color Themes", "Media"}
    local tabFrames = {}
    
    for i, text in ipairs(tabTexts) do
        -- Create tab button
        tabs[i] = VUI.UI:CreateTabButton("VUIDemoTab"..i, panel, text, i)
        tabs[i]:SetPoint("TOPLEFT", panel, "TOPLEFT", 20 + (i-1) * 120, -50)
        
        -- Create tab content frame
        tabFrames[i] = VUI.UI:CreateFrame("VUIDemoTabFrame"..i, panel)
        tabFrames[i]:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -80)
        tabFrames[i]:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -20, 20)
        tabFrames[i]:Hide()
        
        -- Tab click handler
        tabs[i]:SetScript("OnClick", function()
            -- Hide all tab frames
            for j = 1, #tabFrames do
                tabFrames[j]:Hide()
                tabs[j]:Select(false)
            end
            
            -- Show clicked tab
            tabFrames[i]:Show()
            tabs[i]:Select(true)
            
            -- Play sound
            VUI:PlaySound("select")
        end)
    end
    
    -- Populate Basic Elements tab
    self:PopulateBasicElementsTab(tabFrames[1])
    
    -- Populate Widgets tab
    self:PopulateWidgetsTab(tabFrames[2])
    
    -- Populate Color Themes tab
    self:PopulateThemesTab(tabFrames[3])
    
    -- Populate Media tab
    self:PopulateMediaTab(tabFrames[4])
    
    -- Show first tab by default
    tabs[1]:GetScript("OnClick")(tabs[1])
    
    -- Store panel reference
    self.panel = panel
    
    return panel
end

-- Populate Basic Elements tab
function VUI.Demo:PopulateBasicElementsTab(frame)
    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetPoint("TOPLEFT", 10, -10)
    title:SetText("Basic UI Elements")
    VUI:ApplyFont(title, VUI.db.profile.appearance.font, VUI.db.profile.appearance.fontSize + 4, "OUTLINE")
    VUI:ApplyFontColor(title, VUI:GetColor("header"))
    
    -- Create a standard button
    local button = VUI.UI:CreateButton("VUIBasicButton", frame, "Standard Button")
    button:SetPoint("TOPLEFT", 30, -50)
    button:SetSize(150, 30)
    button:SetScript("OnClick", function() VUI:PlaySound("button") end)
    
    -- Create a check button
    local checkButton = VUI.UI:CreateCheckButton("VUIBasicCheckButton", frame, "Checkbox Example")
    checkButton:SetPoint("TOPLEFT", 30, -100)
    
    -- Create a slider
    local slider = VUI.UI:CreateSlider(frame, "VUIBasicSlider", "Slider Example", 0, 100, 1)
    slider:SetPoint("TOPLEFT", 30, -150)
    slider:SetWidth(200)
    slider:SetValue(50)
    
    -- Create an edit box
    local editBox = VUI.UI:CreateEditBox("VUIBasicEditBox", frame, 200, 25)
    editBox:SetPoint("TOPLEFT", 30, -200)
    editBox:SetText("Edit Box Example")
    
    -- Create a frame with specific backdrop
    local backdropFrame = VUI.UI:CreateFrame("VUIBasicBackdropFrame", frame)
    backdropFrame:SetPoint("TOPLEFT", 300, -50)
    backdropFrame:SetSize(200, 100)
    backdropFrame:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
    backdropFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    
    -- Add text to the backdrop frame
    local backdropText = backdropFrame:CreateFontString(nil, "OVERLAY")
    backdropText:SetPoint("CENTER")
    backdropText:SetText("Backdrop Frame Example")
    VUI:ApplyFont(backdropText, VUI.db.profile.appearance.font, VUI.db.profile.appearance.fontSize)
    VUI:ApplyFontColor(backdropText, VUI:GetColor("white"))
    
    -- Create an icon button
    local iconButton = VUI.UI:CreateIconButton("VUIBasicIconButton", frame, 
        "Interface\\Icons\\INV_Misc_QuestionMark", 40)
    iconButton:SetPoint("TOPLEFT", 300, -180)
    
    -- Add text label
    local iconText = frame:CreateFontString(nil, "OVERLAY")
    iconText:SetPoint("LEFT", iconButton, "RIGHT", 10, 0)
    iconText:SetText("Icon Button Example")
    VUI:ApplyFont(iconText, VUI.db.profile.appearance.font, VUI.db.profile.appearance.fontSize)
    VUI:ApplyFontColor(iconText, VUI:GetColor("white"))
end

-- Populate Widgets tab
function VUI.Demo:PopulateWidgetsTab(frame)
    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetPoint("TOPLEFT", 10, -10)
    title:SetText("Advanced Widgets")
    VUI:ApplyFont(title, VUI.db.profile.appearance.font, VUI.db.profile.appearance.fontSize + 4, "OUTLINE")
    VUI:ApplyFontColor(title, VUI:GetColor("header"))
    
    -- Create a progress bar
    local progressBar = VUI.Widgets:CreateProgressBar("VUIDemoProgressBar", frame, 200, 25, "Progress:")
    progressBar:SetPoint("TOPLEFT", 30, -50)
    progressBar:SetValue(75, 100)
    progressBar:SetColor(0.2, 0.8, 0.2)
    
    -- Create a panel widget
    local panel = VUI.Widgets:CreatePanel("VUIDemoPanel", frame, 200, 150, "Panel Widget")
    panel:SetPoint("TOPLEFT", 30, -100)
    
    -- Add some content to the panel
    local panelText = panel.content:CreateFontString(nil, "OVERLAY")
    panelText:SetPoint("CENTER")
    panelText:SetWidth(180)
    panelText:SetJustifyH("CENTER")
    panelText:SetText("This is a panel widget with a title bar and content area")
    VUI:ApplyFont(panelText, VUI.db.profile.appearance.font, VUI.db.profile.appearance.fontSize)
    VUI:ApplyFontColor(panelText, VUI:GetColor("white"))
    
    -- Create an icon grid
    local grid = VUI.Widgets:CreateIconGrid("VUIDemoIconGrid", frame, 4, 40, 5)
    grid:SetPoint("TOPLEFT", 250, -50)
    
    -- Add some icons to the grid
    for i = 1, 8 do
        local icon = "Interface\\Icons\\INV_Misc_QuestionMark"
        grid:AddIcon(icon, "Icon " .. i, function() VUI:PlaySound("button") end)
    end
    
    -- Create a dialog button that shows a dialog widget
    local dialogButton = VUI.UI:CreateButton("VUIDemoDialogButton", frame, "Show Dialog")
    dialogButton:SetPoint("TOPLEFT", 250, -150)
    dialogButton:SetScript("OnClick", function()
        local dialog = VUI.Widgets:CreateDialog("VUIDemoDialog", UIParent, 300, 150, "Dialog Example", 
            "This is an example of a dialog widget with buttons.")
        
        -- Add buttons to the dialog
        dialog:AddButton("OK", function() VUI:Print("OK clicked") end, true)
        dialog:AddButton("Cancel")
        
        -- Show the dialog
        dialog:Show()
    end)
end

-- Populate Themes tab
function VUI.Demo:PopulateThemesTab(frame)
    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetPoint("TOPLEFT", 10, -10)
    title:SetText("Color Themes")
    VUI:ApplyFont(title, VUI.db.profile.appearance.font, VUI.db.profile.appearance.fontSize + 4, "OUTLINE")
    VUI:ApplyFontColor(title, VUI:GetColor("header"))
    
    -- Create a theme preview panel for each theme
    local themes = {"dark", "light", "classic", "minimal"}
    local positions = {
        {30, -50},
        {280, -50},
        {30, -230},
        {280, -230}
    }
    
    for i, themeName in ipairs(themes) do
        -- Create theme panel
        local themePanel = VUI.UI:CreateFrame("VUIThemePanel"..i, frame)
        themePanel:SetSize(220, 150)
        themePanel:SetPoint("TOPLEFT", positions[i][1], positions[i][2])
        
        -- Apply theme colors
        local colors = VUI.media.themes[themeName].colors
        themePanel:SetBackdropColor(colors.backdrop.r, colors.backdrop.g, colors.backdrop.b, colors.backdrop.a)
        themePanel:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
        
        -- Add theme title
        local themeTitle = themePanel:CreateFontString(nil, "OVERLAY")
        themeTitle:SetPoint("TOP", 0, -10)
        themeTitle:SetText(themeName:gsub("^%l", string.upper) .. " Theme")
        VUI:ApplyFont(themeTitle, VUI.db.profile.appearance.font, VUI.db.profile.appearance.fontSize + 2)
        themeTitle:SetTextColor(colors.header.r, colors.header.g, colors.header.b, colors.header.a)
        
        -- Add a button with theme styling
        local themeButton = VUI.UI:CreateButton("VUIThemeButton"..i, themePanel, "Button Example")
        themeButton:SetPoint("TOP", 0, -40)
        themeButton:SetSize(120, 30)
        
        -- Add some text with theme styling
        local themeText = themePanel:CreateFontString(nil, "OVERLAY")
        themeText:SetPoint("TOP", themeButton, "BOTTOM", 0, -10)
        themeText:SetWidth(200)
        themeText:SetText("This is an example of text in the " .. themeName .. " theme with appropriate coloring.")
        VUI:ApplyFont(themeText, VUI.db.profile.appearance.font, VUI.db.profile.appearance.fontSize)
        themeText:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a)
        
        -- Add apply theme button
        local applyButton = VUI.UI:CreateButton("VUIApplyTheme"..i, themePanel, "Apply Theme")
        applyButton:SetPoint("BOTTOM", 0, 10)
        applyButton:SetSize(100, 25)
        applyButton:SetScript("OnClick", function()
            -- Update the theme setting
            VUI.db.profile.appearance.theme = themeName
            
            -- Apply the new theme
            VUI:UpdateUI()
            
            -- Notify
            VUI:Print("Applied " .. themeName .. " theme")
        end)
    end
end

-- Populate Media tab
function VUI.Demo:PopulateMediaTab(frame)
    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetPoint("TOPLEFT", 10, -10)
    title:SetText("Media Examples")
    VUI:ApplyFont(title, VUI.db.profile.appearance.font, VUI.db.profile.appearance.fontSize + 4, "OUTLINE")
    VUI:ApplyFontColor(title, VUI:GetColor("header"))
    
    -- Create sections
    local sections = {
        {name = "Fonts", y = -50},
        {name = "Textures", y = -150},
        {name = "Borders", y = -250},
        {name = "Sounds", y = -350}
    }
    
    for _, section in ipairs(sections) do
        -- Section title
        local sectionTitle = frame:CreateFontString(nil, "OVERLAY")
        sectionTitle:SetPoint("TOPLEFT", 30, section.y)
        sectionTitle:SetText(section.name)
        VUI:ApplyFont(sectionTitle, VUI.db.profile.appearance.font, VUI.db.profile.appearance.fontSize + 2, "OUTLINE")
        VUI:ApplyFontColor(sectionTitle, VUI:GetColor("title"))
    end
    
    -- Font examples
    local fontNames = {"normal", "bold", "header", "avant", "expressway", "inter", "prototype"}
    local fontFrame = VUI.UI:CreateFrame("VUIFontFrame", frame)
    fontFrame:SetPoint("TOPLEFT", 120, sections[1].y - 10)
    fontFrame:SetSize(400, 80)
    
    for i, fontName in ipairs(fontNames) do
        local fontExample = fontFrame:CreateFontString(nil, "OVERLAY")
        fontExample:SetPoint("TOPLEFT", 0, -i * 20 + 20)
        fontExample:SetText(fontName .. ": The quick brown fox jumps over the lazy dog")
        
        local fontPath = VUI:GetFont(fontName)
        fontExample:SetFont(fontPath, 12, "")
    end
    
    -- Texture examples
    local textureFrame = VUI.UI:CreateFrame("VUITextureFrame", frame)
    textureFrame:SetPoint("TOPLEFT", 120, sections[2].y - 10)
    textureFrame:SetSize(400, 80)
    
    local textures = {
        {name = "logo", path = VUI.media.textures.logo},
        {name = "glow", path = VUI.media.textures.glow},
        {name = "highlight", path = VUI.media.textures.highlight}
    }
    
    for i, tex in ipairs(textures) do
        -- Create texture
        local texture = textureFrame:CreateTexture(nil, "ARTWORK")
        texture:SetPoint("TOPLEFT", (i-1) * 80, 0)
        texture:SetSize(64, 64)
        texture:SetTexture(tex.path)
        
        -- Create label
        local textureLabel = textureFrame:CreateFontString(nil, "OVERLAY")
        textureLabel:SetPoint("TOP", texture, "BOTTOM", 0, -5)
        textureLabel:SetText(tex.name)
        VUI:ApplyFont(textureLabel, VUI.db.profile.appearance.font, 10)
    end
    
    -- Border examples
    local borderFrame = VUI.UI:CreateFrame("VUIBorderFrame", frame)
    borderFrame:SetPoint("TOPLEFT", 120, sections[3].y - 10)
    borderFrame:SetSize(400, 80)
    
    local borders = {
        {name = "thin", path = VUI.media.borders.thin},
        {name = "dialog", path = VUI.media.borders.dialog},
        {name = "simple", path = VUI.media.borders.simple}
    }
    
    for i, border in ipairs(borders) do
        -- Create border example frame
        local borderExample = CreateFrame("Frame", "VUIBorderExample"..i, borderFrame, "BackdropTemplate")
        borderExample:SetPoint("TOPLEFT", (i-1) * 120, 0)
        borderExample:SetSize(100, 50)
        borderExample:SetBackdrop({
            edgeFile = border.path,
            edgeSize = 16,
            insets = {left = 4, right = 4, top = 4, bottom = 4}
        })
        
        -- Create label
        local borderLabel = borderFrame:CreateFontString(nil, "OVERLAY")
        borderLabel:SetPoint("TOP", borderExample, "BOTTOM", 0, -5)
        borderLabel:SetText(border.name)
        VUI:ApplyFont(borderLabel, VUI.db.profile.appearance.font, 10)
    end
    
    -- Sound examples
    local soundFrame = VUI.UI:CreateFrame("VUISoundFrame", frame)
    soundFrame:SetPoint("TOPLEFT", 120, sections[4].y - 10)
    soundFrame:SetSize(400, 80)
    
    local sounds = {
        {name = "Select", key = "select"},
        {name = "Close", key = "close"},
        {name = "Warning", key = "warning"},
        {name = "Button", key = "button"}
    }
    
    for i, sound in ipairs(sounds) do
        -- Create sound button
        local soundButton = VUI.UI:CreateButton("VUISoundButton"..i, soundFrame, sound.name)
        soundButton:SetPoint("TOPLEFT", (i-1) * 80, 0)
        soundButton:SetSize(70, 25)
        
        -- Set click handler
        soundButton:SetScript("OnClick", function()
            VUI:PlaySound(sound.key)
        end)
    end
end

-- Register slash command to show demo
VUI:RegisterEvent("ADDON_LOADED", function()
    SLASH_VUIDEMO1 = "/vuidemo"
    SlashCmdList["VUIDEMO"] = function()
        VUI.Demo:CreateDemoPanel()
    end
end)
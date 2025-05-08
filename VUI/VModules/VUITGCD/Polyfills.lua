-- Slider polyfills for compatibility

-- Define slider template - converted from XML to Lua
local function CreatePolyfillFrames()
    -- Create UISliderTemplateWithLabels slider template
    local VUITGCD_UISliderTemplateWithLabels = CreateFrame("Slider", "VUITGCD_UISliderTemplateWithLabels", UIParent, "UISliderTemplate")
    VUITGCD_UISliderTemplateWithLabels:Hide()
    VUITGCD_UISliderTemplateWithLabels:SetSize(144, 17)
    
    -- Create text layers
    local text = VUITGCD_UISliderTemplateWithLabels:CreateFontString("$parentText", "ARTWORK", "GameFontHighlight")
    text:SetPoint("BOTTOM", VUITGCD_UISliderTemplateWithLabels, "TOP")
    VUITGCD_UISliderTemplateWithLabels.Text = text
    
    local low = VUITGCD_UISliderTemplateWithLabels:CreateFontString("$parentLow", "ARTWORK", "GameFontHighlightSmall")
    low:SetText("LOW")
    low:SetPoint("TOPLEFT", VUITGCD_UISliderTemplateWithLabels, "BOTTOMLEFT", -4, 3)
    VUITGCD_UISliderTemplateWithLabels.Low = low
    
    local high = VUITGCD_UISliderTemplateWithLabels:CreateFontString("$parentHigh", "ARTWORK", "GameFontHighlightSmall")
    high:SetText("HIGH")
    high:SetPoint("TOPRIGHT", VUITGCD_UISliderTemplateWithLabels, "BOTTOMRIGHT", 4, 3)
    VUITGCD_UISliderTemplateWithLabels.High = high
    
    -- Make it virtual
    VUITGCD_UISliderTemplateWithLabels:SetScript("OnLoad", nil)
    
    -- Create options slider template inheriting from the UISliderTemplateWithLabels
    local VUITGCD_OptionsSliderTemplate = CreateFrame("Slider", "VUITGCD_OptionsSliderTemplate", UIParent, "VUITGCD_UISliderTemplateWithLabels")
    VUITGCD_OptionsSliderTemplate:Hide()
    VUITGCD_OptionsSliderTemplate:SetSize(144, 17)
    
    -- Make it virtual
    VUITGCD_OptionsSliderTemplate:SetScript("OnLoad", nil)
end

-- Register for PLAYER_LOGIN to create polyfill frames when needed
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        CreatePolyfillFrames()
        self:UnregisterEvent("PLAYER_LOGIN")
    end
end)
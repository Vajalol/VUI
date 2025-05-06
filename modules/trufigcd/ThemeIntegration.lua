-- VUI TrufiGCD Theme Integration
-- Author: VortexQ8

local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
local TrufiGCD = VUI.modules.trufigcd

-- Apply theme colors to TrufiGCD elements
function TrufiGCD:ApplyTheme()
    if not VUI.enabledModules.TrufiGCD then return end
    
    local theme = VUI.activeTheme
    local config = VUI.db.profile.modules.trufigcd
    
    -- Apply theme colors to icon frames
    if self.iconFrames then
        for _, frame in ipairs(self.iconFrames) do
            -- Apply colors to standard borders
            if frame.border then
                frame.border:SetVertexColor(theme.borderColor[1], theme.borderColor[2], theme.borderColor[3], config.borderAlpha or 0.8)
            end
            
            -- Apply colors to atlas-based icon frames if available
            if frame.iconFrame then
                frame.iconFrame:SetVertexColor(theme.borderColor[1], theme.borderColor[2], theme.borderColor[3], config.borderAlpha or 0.8)
            end
            
            -- Apply colors to background
            if frame.background then
                frame.background:SetVertexColor(theme.backdropColor[1], theme.backdropColor[2], theme.backdropColor[3], config.bgAlpha or 0.5)
            end
        end
    end
    
    -- Apply theme colors to container frame
    if self.container and self.container.border then
        self.container.border:SetVertexColor(theme.borderColor[1], theme.borderColor[2], theme.borderColor[3], config.containerBorderAlpha or 0.8)
    end
    
    if self.container and self.container.background then
        self.container.background:SetVertexColor(theme.backdropColor[1], theme.backdropColor[2], theme.backdropColor[3], config.containerBgAlpha or 0.3)
    end
    
    -- Apply theme colors to config button if using atlas textures
    if self.configButton then
        local normal = self.configButton:GetNormalTexture()
        if normal and normal.SetVertexColor then
            normal:SetVertexColor(theme.borderColor[1], theme.borderColor[2], theme.borderColor[3], 1.0)
        end
        
        local highlight = self.configButton:GetHighlightTexture()
        if highlight and highlight.SetVertexColor then
            highlight:SetVertexColor(theme.highlightColor[1], theme.highlightColor[2], theme.highlightColor[3], 1.0)
        end
    end
    
    -- Apply theme colors to config panel elements if they exist
    if self.configPanel then
        if self.configPanel.border then
            self.configPanel.border:SetVertexColor(theme.borderColor[1], theme.borderColor[2], theme.borderColor[3], 0.8)
        end
        
        if self.configPanel.background then
            self.configPanel.background:SetVertexColor(theme.backdropColor[1], theme.backdropColor[2], theme.backdropColor[3], 0.5)
        end
    end
    

end

-- Hook for theme changes
function TrufiGCD:RegisterThemeHooks()
    -- Register for theme change events
    VUI:RegisterCallback("ThemeChanged", function()
        TrufiGCD:ApplyTheme()
    end)
end
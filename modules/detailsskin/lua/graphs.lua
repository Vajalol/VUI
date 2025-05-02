local _, VUI = ...
local DS = VUI.detailsskin or {}
VUI.detailsskin = DS

-- Local references for performance
local _G = _G
local Details = _G.Details
local CreateFrame = CreateFrame
local tinsert = table.insert

-- Graph styling functions
DS.Graphs = {}

-- Apply theme styling to Details graphs
function DS.Graphs:ApplyStyle(instance, theme)
    if not instance then return end
    
    -- Get theme settings
    theme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    local settings = VUI.db.profile.modules.detailsskin
    local colors = DS:GetThemeColors(theme)
    
    -- Apply theme to line graphs
    self:StyleLineGraphs(instance, colors, settings, theme)
    
    -- Apply theme to bar graphs
    self:StyleBarGraphs(instance, colors, settings, theme)
    
    -- Apply theme to pie charts
    self:StylePieCharts(instance, colors, settings, theme)
    
    -- Handle custom window elements
    self:StyleCustomDisplays(instance, colors, settings, theme)
end

-- Style line graphs in reports
function DS.Graphs:StyleLineGraphs(instance, colors, settings, theme)
    if not instance.data_showed or not instance.showing then
        return
    end
    
    local display = instance.showing
    
    -- Only apply to displays that use line graphs
    if not display or not display.GetLineGraphData then
        return
    end
    
    -- Get the current line graph settings
    local graphSettings = {
        -- Line appearance
        line_color = {
            colors.primary.r,
            colors.primary.g,
            colors.primary.b,
            0.9
        },
        line_width = settings.graphLineWidth or 2,
        
        -- Point appearance
        point_color = {
            colors.highlight.r,
            colors.highlight.g,
            colors.highlight.b,
            1
        },
        point_size = settings.graphPointSize or 4,
        
        -- Background appearance
        background_color = {
            colors.background.r,
            colors.background.g,
            colors.background.b,
            0.3
        },
        background_frame_color = {
            colors.border.r,
            colors.border.g,
            colors.border.b,
            0.5
        },
        background_frame_width = settings.graphFrameWidth or 1,
        
        -- Grid appearance
        grid_color = {
            colors.shadow.r + 0.2,
            colors.shadow.g + 0.2,
            colors.shadow.b + 0.2,
            0.25
        },
        grid_width = settings.graphGridWidth or 1,
        grid_spacing_x = settings.graphGridSpacingX or 50,
        grid_spacing_y = settings.graphGridSpacingY or 20
    }
    
    -- Store the current graph settings in the instance
    instance.v_bars_line_graph_config = graphSettings
    
    -- If a graph is already visible, update it
    if instance.v_bars_line_graph then
        instance.v_bars_line_graph:SetLineColor(unpack(graphSettings.line_color))
        instance.v_bars_line_graph:SetLineWidth(graphSettings.line_width)
        instance.v_bars_line_graph:SetPointColor(unpack(graphSettings.point_color))
        instance.v_bars_line_graph:SetPointSize(graphSettings.point_size)
        instance.v_bars_line_graph:SetBackgroundColor(unpack(graphSettings.background_color))
        instance.v_bars_line_graph:SetBackgroundFrameColor(unpack(graphSettings.background_frame_color))
        instance.v_bars_line_graph:SetBackgroundFrameWidth(graphSettings.background_frame_width)
        instance.v_bars_line_graph:SetGridColor(unpack(graphSettings.grid_color))
        instance.v_bars_line_graph:SetGridWidth(graphSettings.grid_width)
        instance.v_bars_line_graph:SetGridSpacing(graphSettings.grid_spacing_x, graphSettings.grid_spacing_y)
        
        -- Force a redraw
        instance.v_bars_line_graph:Refresh()
    end
end

-- Style bar graphs in reports
function DS.Graphs:StyleBarGraphs(instance, colors, settings, theme)
    -- Bar graph settings
    local barSettings = {
        -- Bar appearance using atlas texture if available
        bar_texture = DS:GetBarTexture(theme),
        bar_color = {
            colors.primary.r,
            colors.primary.g,
            colors.primary.b,
            0.9
        },
        bar_background_color = {
            colors.background.r * 0.7,
            colors.background.g * 0.7,
            colors.background.b * 0.7,
            0.3
        },
        bar_spacing = settings.barGraphSpacing or 1,
        bar_height = settings.barGraphHeight or 15,
        
        -- Text settings
        text_color = {
            colors.text.r,
            colors.text.g,
            colors.text.b,
            1
        },
        text_size = settings.barGraphTextSize or 11,
        text_outline = settings.barGraphTextOutline or true,
        
        -- Frame settings
        frame_color = {
            colors.border.r,
            colors.border.g,
            colors.border.b,
            0.7
        },
        frame_width = settings.barGraphFrameWidth or 1,
        background_color = {
            colors.background.r,
            colors.background.g,
            colors.background.b,
            0.2
        }
    }
    
    -- Store the settings for future bar graph creation
    instance.v_bars_graph_config = barSettings
    
    -- Apply to existing bar graphs
    if instance.v_bars and #instance.v_bars > 0 then
        for _, bar in ipairs(instance.v_bars) do
            if bar.statusbar then
                bar.statusbar:SetStatusBarTexture(barSettings.bar_texture)
                bar.statusbar:SetStatusBarColor(unpack(barSettings.bar_color))
                
                if bar.background then
                    bar.background:SetColorTexture(unpack(barSettings.bar_background_color))
                end
                
                if bar.text then
                    bar.text:SetTextColor(unpack(barSettings.text_color))
                    bar.text:SetFont(bar.text:GetFont(), barSettings.text_size, barSettings.text_outline and "OUTLINE" or "")
                end
                
                if bar.border then
                    bar.border:SetBackdropBorderColor(unpack(barSettings.frame_color))
                end
            end
        end
    end
end

-- Style pie charts in reports
function DS.Graphs:StylePieCharts(instance, colors, settings, theme)
    -- Get background texture from atlas if available
    local backgroundTexture
    if DS.Atlas and DS.Atlas.GetBackgroundTexture then
        backgroundTexture = DS.Atlas:GetBackgroundTexture(theme)
    end
    
    -- Pie chart settings
    local pieSettings = {
        -- General appearance
        background_texture = backgroundTexture,
        background_color = {
            colors.background.r,
            colors.background.g,
            colors.background.b,
            0.5
        },
        border_color = {
            colors.border.r,
            colors.border.g,
            colors.border.b,
            0.7
        },
        border_width = settings.pieChartBorderWidth or 1,
        
        -- Segment appearance
        segment_gradient = settings.pieChartSegmentGradient or true,
        segment_spacing = settings.pieChartSegmentSpacing or 0.5,
        segment_highlight_color = {
            colors.highlight.r,
            colors.highlight.g,
            colors.highlight.b,
            0.9
        },
        
        -- Text settings
        text_color = {
            colors.text.r,
            colors.text.g,
            colors.text.b,
            1
        },
        text_size = settings.pieChartTextSize or 11,
        text_outline = settings.pieChartTextOutline or true
    }
    
    -- Store the settings
    instance.pie_chart_config = pieSettings
    
    -- Apply to existing pie charts if any
    if instance.pie_chart then
        instance.pie_chart:SetBackgroundColor(unpack(pieSettings.background_color))
        instance.pie_chart:SetBorderColor(unpack(pieSettings.border_color))
        instance.pie_chart:SetBorderWidth(pieSettings.border_width)
        
        -- Refresh the chart to apply other settings
        instance.pie_chart:Refresh()
    end
end

-- Style custom displays (scrolls, texts, etc.)
function DS.Graphs:StyleCustomDisplays(instance, colors, settings, theme)
    -- Get atlas textures if available
    local backgroundTexture, borderTexture
    if DS.Atlas then
        if DS.Atlas.GetBackgroundTexture then
            backgroundTexture = DS.Atlas:GetBackgroundTexture(theme)
        end
        if DS.Atlas.GetBorderTexture then
            borderTexture = DS.Atlas:GetBorderTexture()
        end
    end
    
    -- Text area styling (used in various places)
    local textAreaSettings = {
        font_size = settings.textAreaFontSize or 11,
        font_color = {
            colors.text.r,
            colors.text.g,
            colors.text.b,
            1
        },
        background_texture = backgroundTexture,
        background_color = {
            colors.background.r,
            colors.background.g,
            colors.background.b,
            0.3
        },
        border_texture = borderTexture,
        border_color = {
            colors.border.r,
            colors.border.g,
            colors.border.b,
            0.5
        },
        border_width = settings.textAreaBorderWidth or 1
    }
    
    -- Store the settings
    instance.text_area_config = textAreaSettings
    
    -- Apply to existing text areas
    if instance.text_panel then
        instance.text_panel:SetBackdropColor(unpack(textAreaSettings.background_color))
        instance.text_panel:SetBackdropBorderColor(unpack(textAreaSettings.border_color))
        
        if instance.text_panel.editbox then
            instance.text_panel.editbox:SetTextColor(unpack(textAreaSettings.font_color))
            instance.text_panel.editbox:SetFont(instance.text_panel.editbox:GetFont(), textAreaSettings.font_size, "")
        end
    end
    
    -- Scrollbar styling
    local scrollbarSettings = {
        thumb_color = {
            colors.primary.r,
            colors.primary.g,
            colors.primary.b,
            0.7
        },
        background_color = {
            colors.background.r,
            colors.background.g,
            colors.background.b,
            0.3
        },
        border_color = {
            colors.border.r,
            colors.border.g,
            colors.border.b,
            0.5
        }
    }
    
    -- Apply to scrollbars
    if instance.scroll then
        if instance.scroll.slider then
            local thumbTexture = instance.scroll.slider:GetThumbTexture()
            if thumbTexture then
                thumbTexture:SetColorTexture(unpack(scrollbarSettings.thumb_color))
            end
            
            if instance.scroll.bg then
                instance.scroll.bg:SetColorTexture(unpack(scrollbarSettings.background_color))
            end
            
            if instance.scroll.border then
                instance.scroll.border:SetBackdropBorderColor(unpack(scrollbarSettings.border_color))
            end
        end
    end
end
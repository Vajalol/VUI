local _, VUI = ...
local DS = VUI.detailsskin or {}
VUI.detailsskin = DS

-- Local references for performance
local _G = _G
local Details = _G.Details
local CreateFrame = CreateFrame
local tinsert = table.insert
local pairs = pairs
local math_floor = math.floor
local math_abs = math.abs
local math_min = math.min
local math_max = math.max
local string_format = string.format

-- Graph styling functions
DS.Graphs = {}

-- Constants for graph styling
local GRAPH_TYPES = {
    LINE = "line",
    BAR = "bar",
    PIE = "pie",
    SCATTER = "scatter",
    AREA = "area",
    CANDLESTICK = "candlestick"
}

-- Animation data for graphs
local ANIMATION_PRESETS = {
    DEFAULT = {
        duration = 0.3,
        easing = "OUT_CUBIC",
        delay = 0,
        stagger = 0.02
    },
    FAST = {
        duration = 0.2,
        easing = "OUT_QUINT",
        delay = 0,
        stagger = 0.01
    },
    SLOW = {
        duration = 0.5,
        easing = "OUT_ELASTIC",
        delay = 0.1,
        stagger = 0.03
    },
    BOUNCE = {
        duration = 0.6,
        easing = "OUT_BOUNCE",
        delay = 0,
        stagger = 0.03
    },
    FADE = {
        duration = 0.4,
        easing = "OUT_SINE",
        delay = 0.05,
        stagger = 0.02
    }
}

-- Apply theme styling to Details graphs
function DS.Graphs:ApplyStyle(instance, theme)
    if not instance then return end
    
    -- Get theme settings
    theme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    local settings = DS:GetSettings()
    local colors = DS:GetThemeColors(theme)
    
    -- Apply theme to various graph types
    self:StyleLineGraphs(instance, colors, settings, theme)
    self:StyleBarGraphs(instance, colors, settings, theme)
    self:StylePieCharts(instance, colors, settings, theme)
    self:StyleCustomDisplays(instance, colors, settings, theme)
    self:StyleScatterPlots(instance, colors, settings, theme)
    self:StyleAreaGraphs(instance, colors, settings, theme)
    
    -- Apply custom tooltips for graphs
    self:ApplyCustomTooltips(instance, colors, settings, theme)
    
    -- Apply theme-specific animation preset
    self:ApplyAnimationPreset(instance, settings.graphAnimationStyle or "DEFAULT", theme)
    
    -- Register for instance refresh events to catch graph rebuilds
    if not instance._vuiGraphHooksRegistered then
        self:RegisterGraphRefreshHooks(instance)
        instance._vuiGraphHooksRegistered = true
    end
    
    -- Enhanced frame tracking for performance
    self:TrackGraphPerformance(instance)
    
    -- Apply to DetailsDpsGraph plugin if present
    self:ApplyToDetailsDpsGraphPlugin(theme)
end

-- Style line graphs in reports with enhanced features
function DS.Graphs:StyleLineGraphs(instance, colors, settings, theme)
    if not instance.data_showed or not instance.showing then
        return
    end
    
    local display = instance.showing
    
    -- Only apply to displays that use line graphs
    if not display or not display.GetLineGraphData then
        return
    end
    
    -- Get atlas textures if available
    local lineTexture
    if DS.Atlas and DS.Atlas.GetLineTexture then
        lineTexture = DS.Atlas:GetLineTexture(theme)
    end
    
    -- Enhanced line graph settings with more configuration options
    local graphSettings = {
        -- Line appearance with texture and enhanced styling
        line_texture = lineTexture, -- Theme-specific line texture from atlas
        line_color = {
            colors.primary.r,
            colors.primary.g,
            colors.primary.b,
            0.9
        },
        line_secondary_color = { -- For multi-line graphs
            colors.secondary.r,
            colors.secondary.g,
            colors.secondary.b,
            0.9
        },
        line_highlight_color = { -- For highlighted segments
            colors.highlight.r,
            colors.highlight.g,
            colors.highlight.b,
            1
        },
        line_width = settings.graphLineWidth or 2,
        line_style = settings.graphLineStyle or "SOLID", -- SOLID, DASHED, DOTTED
        line_shadow = settings.graphLineShadow or true,
        line_antialiasing = settings.graphLineAntialiasing or true,
        
        -- Enhanced point appearance
        point_color = {
            colors.highlight.r,
            colors.highlight.g,
            colors.highlight.b,
            1
        },
        point_border_color = {
            colors.border.r,
            colors.border.g,
            colors.border.b,
            0.8
        },
        point_size = settings.graphPointSize or 4,
        point_style = settings.graphPointStyle or "CIRCLE", -- CIRCLE, SQUARE, DIAMOND, TRIANGLE
        point_show_value = settings.graphPointShowValue or true,
        point_value_format = settings.graphPointValueFormat or "%.1f",
        point_shadow = settings.graphPointShadow or true,
        
        -- Enhanced background appearance
        background_color = {
            colors.background.r,
            colors.background.g,
            colors.background.b,
            0.3
        },
        background_gradient = settings.graphBackgroundGradient or true,
        background_gradient_dir = settings.graphBackgroundGradientDir or "VERTICAL",
        background_gradient_alpha_start = settings.graphBackgroundGradientAlphaStart or 0.4,
        background_gradient_alpha_end = settings.graphBackgroundGradientAlphaEnd or 0.1,
        background_frame_color = {
            colors.border.r,
            colors.border.g,
            colors.border.b,
            0.5
        },
        background_frame_width = settings.graphFrameWidth or 1,
        
        -- Enhanced grid appearance
        grid_color = {
            colors.shadow.r + 0.2,
            colors.shadow.g + 0.2,
            colors.shadow.b + 0.2,
            0.25
        },
        grid_width = settings.graphGridWidth or 1,
        grid_style = settings.graphGridStyle or "SOLID", -- SOLID, DASHED, DOTTED
        grid_spacing_x = settings.graphGridSpacingX or 50,
        grid_spacing_y = settings.graphGridSpacingY or 20,
        grid_show_x = settings.graphGridShowX or true,
        grid_show_y = settings.graphGridShowY or true,
        grid_labels = settings.graphGridLabels or true,
        grid_label_font_size = settings.graphGridLabelFontSize or 9,
        grid_label_color = {
            colors.text.r,
            colors.text.g,
            colors.text.b,
            0.7
        },
        
        -- Value range settings
        auto_scale = settings.graphAutoScale or true,
        min_value = settings.graphMinValue or 0,
        max_value = settings.graphMaxValue or nil, -- Auto calculated if nil
        value_step = settings.graphValueStep or nil, -- Auto calculated if nil
        
        -- Highlight regions - highlight specific areas of the graph
        highlight_regions = settings.graphHighlightRegions or {},
        
        -- Data line settings
        smoothing = settings.graphSmoothing or 0.2, -- 0 for no smoothing, 0.2 for moderate
        show_area = settings.graphShowArea or true, -- Fill area under the line
        area_alpha = settings.graphAreaAlpha or 0.2, -- Transparency of area fill
        area_gradient = settings.graphAreaGradient or true,
        
        -- Animation settings
        animation_enabled = settings.graphAnimationEnabled or true,
        animation_duration = settings.graphAnimationDuration or 0.5,
        animation_style = settings.graphAnimationStyle or "DEFAULT",
        
        -- Tooltip settings
        tooltip_enabled = settings.graphTooltipEnabled or true,
        tooltip_format = settings.graphTooltipFormat or "${x}: ${y}",
        tooltip_anchor = settings.graphTooltipAnchor or "ANCHOR_CURSOR",
        
        -- Interaction settings
        interactive = settings.graphInteractive or true,
        zoom_enabled = settings.graphZoomEnabled or true,
        pan_enabled = settings.graphPanEnabled or true
    }
    
    -- Store the current graph settings in the instance
    instance.v_bars_line_graph_config = graphSettings
    
    -- Apply theme-specific colors for multi-line graphs
    if theme == "phoenixflame" then
        -- Use fiery gradient for phoenix flame theme
        graphSettings.line_gradient = true
        graphSettings.line_gradient_colors = {
            {1.0, 0.6, 0.1, 0.9}, -- Fiery orange
            {0.9, 0.3, 0.1, 0.9}, -- Deep red
        }
    elseif theme == "thunderstorm" then
        -- Use electric blue gradient for thunderstorm theme
        graphSettings.line_gradient = true
        graphSettings.line_gradient_colors = {
            {0.4, 0.7, 1.0, 0.9}, -- Light electric blue
            {0.1, 0.4, 0.9, 0.9}, -- Deep blue
        }
    elseif theme == "arcanemystic" then
        -- Use arcane purple gradient for arcane mystic theme
        graphSettings.line_gradient = true
        graphSettings.line_gradient_colors = {
            {0.8, 0.5, 1.0, 0.9}, -- Light purple
            {0.5, 0.1, 0.9, 0.9}, -- Deep purple
        }
    elseif theme == "felenergy" then
        -- Use fel green gradient for fel energy theme
        graphSettings.line_gradient = true
        graphSettings.line_gradient_colors = {
            {0.7, 1.0, 0.3, 0.9}, -- Light fel green
            {0.2, 0.8, 0.2, 0.9}, -- Deep fel green
        }
    end
    
    -- If a graph is already visible, update it with all our new settings
    if instance.v_bars_line_graph then
        local graph = instance.v_bars_line_graph
        
        -- Basic settings from original function
        graph:SetLineColor(unpack(graphSettings.line_color))
        graph:SetLineWidth(graphSettings.line_width)
        graph:SetPointColor(unpack(graphSettings.point_color))
        graph:SetPointSize(graphSettings.point_size)
        graph:SetBackgroundColor(unpack(graphSettings.background_color))
        graph:SetBackgroundFrameColor(unpack(graphSettings.background_frame_color))
        graph:SetBackgroundFrameWidth(graphSettings.background_frame_width)
        graph:SetGridColor(unpack(graphSettings.grid_color))
        graph:SetGridWidth(graphSettings.grid_width)
        graph:SetGridSpacing(graphSettings.grid_spacing_x, graphSettings.grid_spacing_y)
        
        -- Apply enhanced settings if the graph object supports them
        if graph.SetLineTexture then
            graph:SetLineTexture(graphSettings.line_texture)
        end
        
        if graph.SetLineStyle then
            graph:SetLineStyle(graphSettings.line_style)
        end
        
        if graph.SetLineShadow then
            graph:SetLineShadow(graphSettings.line_shadow)
        end
        
        if graph.SetPointStyle then
            graph:SetPointStyle(graphSettings.point_style)
        end
        
        if graph.SetPointBorderColor then
            graph:SetPointBorderColor(unpack(graphSettings.point_border_color))
        end
        
        if graph.SetGridStyle then
            graph:SetGridStyle(graphSettings.grid_style)
        end
        
        if graph.SetGridVisible then
            graph:SetGridVisible(graphSettings.grid_show_x, graphSettings.grid_show_y)
        end
        
        if graph.SetGridLabels then
            graph:SetGridLabels(graphSettings.grid_labels)
        end
        
        if graph.SetSmoothing then
            graph:SetSmoothing(graphSettings.smoothing)
        end
        
        if graph.SetAreaFill then
            graph:SetAreaFill(graphSettings.show_area, graphSettings.area_alpha, graphSettings.area_gradient)
        end
        
        if graph.SetValueRange then
            if graphSettings.auto_scale then
                graph:SetAutoScale(true)
            else
                graph:SetValueRange(graphSettings.min_value, graphSettings.max_value, graphSettings.value_step)
            end
        end
        
        if graph.SetTooltip and graphSettings.tooltip_enabled then
            graph:SetTooltip(graphSettings.tooltip_enabled, graphSettings.tooltip_format, graphSettings.tooltip_anchor)
        end
        
        if graph.SetInteractive then
            graph:SetInteractive(graphSettings.interactive, graphSettings.zoom_enabled, graphSettings.pan_enabled)
        end
        
        -- Apply highlight regions if supported
        if graph.ClearHighlightRegions and graph.AddHighlightRegion then
            graph:ClearHighlightRegions()
            for _, region in pairs(graphSettings.highlight_regions) do
                graph:AddHighlightRegion(region.start_x, region.end_x, region.color or {1, 1, 0, 0.2}, region.label)
            end
        end
        
        -- Apply line gradient if supported
        if graph.SetLineGradient and graphSettings.line_gradient then
            graph:SetLineGradient(true, graphSettings.line_gradient_colors)
        end
        
        -- Apply background gradient if supported
        if graph.SetBackgroundGradient and graphSettings.background_gradient then
            graph:SetBackgroundGradient(
                graphSettings.background_gradient,
                graphSettings.background_gradient_dir,
                graphSettings.background_gradient_alpha_start,
                graphSettings.background_gradient_alpha_end
            )
        end
        
        -- Force a redraw
        if graph.Refresh then
            graph:Refresh()
        end
        
        -- Apply animation if supported and enabled
        if graph.SetAnimation and graphSettings.animation_enabled then
            graph:SetAnimation(
                graphSettings.animation_enabled,
                graphSettings.animation_duration,
                ANIMATION_PRESETS[graphSettings.animation_style] or ANIMATION_PRESETS.DEFAULT
            )
            
            -- Trigger animation if the graph is visible
            if graph:IsVisible() and graph.AnimateData then
                graph:AnimateData()
            end
        end
        
        -- Add mouse hover highlights if not already added
        if not graph._vuiMouseHoverRegistered and graph:IsMouseEnabled() then
            graph:SetScript("OnEnter", function(self)
                -- Enhance focus when hovering
                self:SetBackgroundFrameWidth(graphSettings.background_frame_width + 1)
                
                -- Show tooltip with graph info
                if graphSettings.tooltip_enabled then
                    GameTooltip:SetOwner(self, graphSettings.tooltip_anchor)
                    GameTooltip:AddLine("Graph: " .. (instance.displayName or "Details Data"), 1, 1, 1)
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("Data points: " .. (self.dataPointCount or "N/A"), 0.9, 0.9, 0.9)
                    GameTooltip:AddLine("Range: " .. (self.minValue or 0) .. " to " .. (self.maxValue or 0), 0.9, 0.9, 0.9)
                    if graphSettings.interactive then
                        GameTooltip:AddLine(" ")
                        GameTooltip:AddLine("Mouse wheel: Zoom in/out", 0.7, 0.9, 0.7)
                        GameTooltip:AddLine("Click and drag: Pan graph", 0.7, 0.9, 0.7)
                        GameTooltip:AddLine("Right-click: Reset view", 0.7, 0.9, 0.7)
                    end
                    GameTooltip:Show()
                end
            end)
            
            graph:SetScript("OnLeave", function(self)
                -- Restore normal border width
                self:SetBackgroundFrameWidth(graphSettings.background_frame_width)
                
                -- Hide tooltip
                GameTooltip:Hide()
            end)
            
            graph._vuiMouseHoverRegistered = true
        end
        
        -- Track this graph for performance metrics
        self:TrackGraph(graph, GRAPH_TYPES.LINE)
    end
end

-- Style bar graphs in reports with enhanced features
function DS.Graphs:StyleBarGraphs(instance, colors, settings, theme)
    -- Get atlas textures if available
    local barTexture = DS:GetBarTexture(theme)
    local backgroundTexture
    if DS.Atlas and DS.Atlas.GetBackgroundTexture then
        backgroundTexture = DS.Atlas:GetBackgroundTexture(theme)
    end
    
    -- Enhanced bar graph settings
    local barSettings = {
        -- Bar appearance
        bar_texture = barTexture,
        bar_color = {
            colors.primary.r,
            colors.primary.g,
            colors.primary.b,
            0.9
        },
        bar_secondary_color = { -- For alternating or multi-series
            colors.secondary.r,
            colors.secondary.g,
            colors.secondary.b,
            0.9
        },
        bar_highlight_color = { -- For hover/selection
            colors.highlight.r,
            colors.highlight.g,
            colors.highlight.b,
            1
        },
        bar_gradient = settings.barGraphGradient or true,
        bar_gradient_direction = settings.barGraphGradientDirection or "HORIZONTAL",
        bar_background_color = {
            colors.background.r * 0.7,
            colors.background.g * 0.7,
            colors.background.b * 0.7,
            0.3
        },
        bar_spacing = settings.barGraphSpacing or 1,
        bar_height = settings.barGraphHeight or 16,
        bar_corner_radius = settings.barGraphCornerRadius or 0, -- Rounded corners (if supported)
        bar_shadow = settings.barGraphShadow or true,
        bar_orientation = settings.barGraphOrientation or "HORIZONTAL", -- HORIZONTAL, VERTICAL
        
        -- Text settings
        text_color = {
            colors.text.r,
            colors.text.g,
            colors.text.b,
            1
        },
        text_highlight_color = {
            colors.highlight.r,
            colors.highlight.g,
            colors.highlight.b,
            1
        },
        text_size = settings.barGraphTextSize or 11,
        text_outline = settings.barGraphTextOutline or true,
        text_font = settings.barGraphTextFont or "Friz Quadrata TT",
        value_text_format = settings.barGraphValueFormat or "%.1f",
        show_bar_values = settings.barGraphShowValues or true,
        value_position = settings.barGraphValuePosition or "RIGHT", -- RIGHT, CENTER, INSIDE
        
        -- Frame settings
        frame_color = {
            colors.border.r,
            colors.border.g,
            colors.border.b,
            0.7
        },
        frame_width = settings.barGraphFrameWidth or 1,
        background_texture = backgroundTexture,
        background_color = {
            colors.background.r,
            colors.background.g,
            colors.background.b,
            0.2
        },
        background_gradient = settings.barGraphBackgroundGradient or true,
        background_gradient_dir = settings.barGraphBackgroundGradientDir or "VERTICAL",
        
        -- Animation settings
        animation_enabled = settings.barGraphAnimationEnabled or true,
        animation_duration = settings.barGraphAnimationDuration or 0.3,
        animation_style = settings.barGraphAnimationStyle or "DEFAULT",
        animation_stagger = settings.barGraphAnimationStagger or true,
        
        -- Tooltip settings
        tooltip_enabled = settings.barGraphTooltipEnabled or true,
        tooltip_format = settings.barGraphTooltipFormat or "${name}: ${value}",
        tooltip_anchor = settings.barGraphTooltipAnchor or "ANCHOR_CURSOR",
        
        -- Interaction settings
        interactive = settings.barGraphInteractive or true,
        on_click_behavior = settings.barGraphOnClickBehavior or "SELECT", -- SELECT, EXPAND, LINK
        hover_highlight = settings.barGraphHoverHighlight or true
    }
    
    -- Apply theme-specific styling
    if theme == "phoenixflame" then
        -- Phoenix Flame theme: fiery gradient
        barSettings.bar_gradient_colors = {
            {1.0, 0.6, 0.1, 0.9}, -- Orange
            {0.9, 0.3, 0.1, 0.9}  -- Deep red
        }
    elseif theme == "thunderstorm" then
        -- Thunder Storm theme: electric blue gradient
        barSettings.bar_gradient_colors = {
            {0.1, 0.6, 0.9, 0.9}, -- Light electric blue
            {0.0, 0.3, 0.7, 0.9}  -- Deep blue
        }
    elseif theme == "arcanemystic" then
        -- Arcane Mystic theme: purple gradient
        barSettings.bar_gradient_colors = {
            {0.7, 0.3, 0.9, 0.9}, -- Light purple
            {0.4, 0.1, 0.6, 0.9}  -- Deep purple
        }
    elseif theme == "felenergy" then
        -- Fel Energy theme: green gradient
        barSettings.bar_gradient_colors = {
            {0.3, 0.9, 0.3, 0.9}, -- Light green
            {0.1, 0.6, 0.1, 0.9}  -- Deep green
        }
    end
    
    -- Store the settings for future bar graph creation
    instance.v_bars_graph_config = barSettings
    
    -- Apply to existing bar graphs
    if instance.v_bars and #instance.v_bars > 0 then
        for i, bar in ipairs(instance.v_bars) do
            if bar.statusbar then
                -- Basic styling
                bar.statusbar:SetStatusBarTexture(barSettings.bar_texture)
                
                -- Apply color - alternate colors if configured
                if barSettings.alternating_colors and i % 2 == 0 then
                    bar.statusbar:SetStatusBarColor(unpack(barSettings.bar_secondary_color))
                else
                    bar.statusbar:SetStatusBarColor(unpack(barSettings.bar_color))
                end
                
                -- Apply background color
                if bar.background then
                    bar.background:SetColorTexture(unpack(barSettings.bar_background_color))
                end
                
                -- Apply text styling
                if bar.text then
                    bar.text:SetTextColor(unpack(barSettings.text_color))
                    bar.text:SetFont(
                        barSettings.text_font, 
                        barSettings.text_size, 
                        barSettings.text_outline and "OUTLINE" or ""
                    )
                end
                
                -- Apply value text if available
                if bar.valuetext and barSettings.show_bar_values then
                    bar.valuetext:SetTextColor(unpack(barSettings.text_color))
                    bar.valuetext:SetFont(
                        barSettings.text_font, 
                        barSettings.text_size, 
                        barSettings.text_outline and "OUTLINE" or ""
                    )
                    
                    -- Position the value text
                    if barSettings.value_position == "RIGHT" then
                        bar.valuetext:ClearAllPoints()
                        bar.valuetext:SetPoint("RIGHT", bar.statusbar, "RIGHT", -2, 0)
                    elseif barSettings.value_position == "CENTER" then
                        bar.valuetext:ClearAllPoints()
                        bar.valuetext:SetPoint("CENTER", bar.statusbar, "CENTER", 0, 0)
                    elseif barSettings.value_position == "INSIDE" then
                        bar.valuetext:ClearAllPoints()
                        bar.valuetext:SetPoint("RIGHT", bar.statusbar:GetStatusBarTexture(), "RIGHT", -2, 0)
                    end
                end
                
                -- Apply border styling
                if bar.border then
                    bar.border:SetBackdropBorderColor(unpack(barSettings.frame_color))
                end
                
                -- Apply gradient if supported
                if bar.statusbar.SetStatusBarGradient and barSettings.bar_gradient and barSettings.bar_gradient_colors then
                    bar.statusbar:SetStatusBarGradient(
                        barSettings.bar_gradient_colors[1],
                        barSettings.bar_gradient_colors[2],
                        barSettings.bar_gradient_direction
                    )
                end
                
                -- Apply corner radius if supported
                if bar.statusbar.SetStatusBarCornerRadius and barSettings.bar_corner_radius > 0 then
                    bar.statusbar:SetStatusBarCornerRadius(barSettings.bar_corner_radius)
                end
                
                -- Add hover highlight behavior if not already present
                if barSettings.hover_highlight and barSettings.interactive and not bar._vuiHoverHighlightRegistered then
                    bar:SetScript("OnEnter", function(self)
                        -- Highlight the bar
                        if self.statusbar then
                            self.statusbar:SetStatusBarColor(unpack(barSettings.bar_highlight_color))
                        end
                        
                        -- Highlight text
                        if self.text then
                            self.text:SetTextColor(unpack(barSettings.text_highlight_color))
                        end
                        
                        -- Show tooltip
                        if barSettings.tooltip_enabled then
                            GameTooltip:SetOwner(self, barSettings.tooltip_anchor)
                            
                            -- Get bar data
                            local name = self.text and self.text:GetText() or "Unknown"
                            local value = self.value or 0
                            local percent = self.percent or 0
                            
                            -- Format tooltip text
                            local tooltipText = barSettings.tooltip_format
                            tooltipText = tooltipText:gsub("${name}", name)
                            tooltipText = tooltipText:gsub("${value}", string_format(barSettings.value_text_format, value))
                            tooltipText = tooltipText:gsub("${percent}", string_format("%.1f%%", percent))
                            
                            GameTooltip:AddLine(tooltipText, 1, 1, 1)
                            
                            -- Add extra info if available
                            if self.spellid then
                                GameTooltip:AddLine(" ")
                                GameTooltip:AddLine("Spell ID: " .. self.spellid, 0.7, 0.7, 0.7)
                            end
                            
                            GameTooltip:Show()
                        end
                    end)
                    
                    bar:SetScript("OnLeave", function(self)
                        -- Restore original bar color
                        if self.statusbar then
                            if barSettings.alternating_colors and self._barIndex and self._barIndex % 2 == 0 then
                                self.statusbar:SetStatusBarColor(unpack(barSettings.bar_secondary_color))
                            else
                                self.statusbar:SetStatusBarColor(unpack(barSettings.bar_color))
                            end
                        end
                        
                        -- Restore original text color
                        if self.text then
                            self.text:SetTextColor(unpack(barSettings.text_color))
                        end
                        
                        -- Hide tooltip
                        GameTooltip:Hide()
                    end)
                    
                    -- Store the bar index for alternating colors
                    bar._barIndex = i
                    bar._vuiHoverHighlightRegistered = true
                end
                
                -- Apply animation if supported and not already applied
                if barSettings.animation_enabled and not bar._vuiAnimationApplied then
                    -- Add animation to bar
                    self:ApplyBarAnimation(bar, i, barSettings)
                    bar._vuiAnimationApplied = true
                end
            end
        end
    end
    
    -- Track this graph for performance metrics
    self:TrackGraph(instance, GRAPH_TYPES.BAR)
end

-- Style pie charts in reports with enhanced features
function DS.Graphs:StylePieCharts(instance, colors, settings, theme)
    -- Get background texture from atlas if available
    local backgroundTexture
    if DS.Atlas and DS.Atlas.GetBackgroundTexture then
        backgroundTexture = DS.Atlas:GetBackgroundTexture(theme)
    end
    
    -- Enhanced pie chart settings
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
        segment_border_width = settings.pieChartSegmentBorderWidth or 1,
        segment_border_color = {
            colors.border.r * 0.8,
            colors.border.g * 0.8,
            colors.border.b * 0.8,
            0.5
        },
        segment_highlight_color = {
            colors.highlight.r,
            colors.highlight.g,
            colors.highlight.b,
            0.9
        },
        segment_colors = self:GetPieChartColors(theme, 10), -- Predefined colors based on theme
        
        -- Text settings
        text_color = {
            colors.text.r,
            colors.text.g,
            colors.text.b,
            1
        },
        text_size = settings.pieChartTextSize or 11,
        text_outline = settings.pieChartTextOutline or true,
        text_font = settings.pieChartTextFont or "Friz Quadrata TT",
        show_labels = settings.pieChartShowLabels or true,
        show_values = settings.pieChartShowValues or true,
        show_percentages = settings.pieChartShowPercentages or true,
        label_format = settings.pieChartLabelFormat or "${name}",
        value_format = settings.pieChartValueFormat or "${value} (${percent}%)",
        
        -- Donut chart settings (if supported)
        inner_radius = settings.pieChartInnerRadius or 0, -- 0 for pie, >0 for donut chart
        
        -- Animation settings
        animation_enabled = settings.pieChartAnimationEnabled or true,
        animation_duration = settings.pieChartAnimationDuration or 0.5,
        animation_style = settings.pieChartAnimationStyle or "DEFAULT",
        animation_stagger = settings.pieChartAnimationStagger or true,
        
        -- Tooltip settings
        tooltip_enabled = settings.pieChartTooltipEnabled or true,
        tooltip_format = settings.pieChartTooltipFormat or "${name}: ${value} (${percent}%)",
        tooltip_anchor = settings.pieChartTooltipAnchor or "ANCHOR_CURSOR",
        
        -- Interaction settings
        interactive = settings.pieChartInteractive or true,
        on_click_behavior = settings.pieChartOnClickBehavior or "SELECT", -- SELECT, EXPAND, LINK
        hover_highlight = settings.pieChartHoverHighlight or true,
        drag_rotate = settings.pieChartDragRotate or true
    }
    
    -- Store the settings
    instance.pie_chart_config = pieSettings
    
    -- Apply to existing pie charts if any
    if instance.pie_chart then
        local chart = instance.pie_chart
        
        -- Basic styling from original function
        chart:SetBackgroundColor(unpack(pieSettings.background_color))
        chart:SetBorderColor(unpack(pieSettings.border_color))
        chart:SetBorderWidth(pieSettings.border_width)
        
        -- Apply enhanced settings if the chart object supports them
        if chart.SetSegmentSpacing then
            chart:SetSegmentSpacing(pieSettings.segment_spacing)
        end
        
        if chart.SetSegmentBorder then
            chart:SetSegmentBorder(pieSettings.segment_border_width, pieSettings.segment_border_color)
        end
        
        if chart.SetSegmentGradient then
            chart:SetSegmentGradient(pieSettings.segment_gradient)
        end
        
        if chart.SetSegmentColors then
            chart:SetSegmentColors(pieSettings.segment_colors)
        end
        
        if chart.SetLabels then
            chart:SetLabels(
                pieSettings.show_labels,
                pieSettings.text_font,
                pieSettings.text_size,
                pieSettings.text_outline and "OUTLINE" or "",
                pieSettings.text_color,
                pieSettings.label_format
            )
        end
        
        if chart.SetValues then
            chart:SetValues(
                pieSettings.show_values,
                pieSettings.show_percentages,
                pieSettings.value_format
            )
        end
        
        if chart.SetInnerRadius and pieSettings.inner_radius > 0 then
            chart:SetInnerRadius(pieSettings.inner_radius)
        end
        
        if chart.SetTooltip and pieSettings.tooltip_enabled then
            chart:SetTooltip(
                pieSettings.tooltip_enabled,
                pieSettings.tooltip_format,
                pieSettings.tooltip_anchor
            )
        end
        
        if chart.SetInteractive then
            chart:SetInteractive(
                pieSettings.interactive,
                pieSettings.on_click_behavior,
                pieSettings.hover_highlight,
                pieSettings.drag_rotate
            )
        end
        
        -- Apply animation settings if supported
        if chart.SetAnimation and pieSettings.animation_enabled then
            chart:SetAnimation(
                pieSettings.animation_enabled,
                pieSettings.animation_duration,
                ANIMATION_PRESETS[pieSettings.animation_style] or ANIMATION_PRESETS.DEFAULT,
                pieSettings.animation_stagger
            )
        end
        
        -- Add hover interaction if not already added
        if pieSettings.hover_highlight and pieSettings.interactive and not chart._vuiHoverRegistered then
            chart:SetScript("OnEnter", function(self)
                -- Highlight border
                self:SetBorderColor(
                    pieSettings.segment_highlight_color[1],
                    pieSettings.segment_highlight_color[2],
                    pieSettings.segment_highlight_color[3],
                    pieSettings.segment_highlight_color[4]
                )
                
                -- Highlight the segment under the cursor if applicable
                local segment = self:GetSegmentAtCursor()
                if segment and self.HighlightSegment then
                    self:HighlightSegment(segment, pieSettings.segment_highlight_color)
                end
            end)
            
            chart:SetScript("OnLeave", function(self)
                -- Restore original border
                self:SetBorderColor(unpack(pieSettings.border_color))
                
                -- Clear segment highlight if applicable
                if self.ClearHighlight then
                    self:ClearHighlight()
                end
                
                -- Hide tooltip
                GameTooltip:Hide()
            end)
            
            chart._vuiHoverRegistered = true
        end
        
        -- Refresh the chart to apply all settings
        chart:Refresh()
        
        -- Track this chart for performance metrics
        self:TrackGraph(chart, GRAPH_TYPES.PIE)
    end
end

-- Style scatter plots (if supported)
function DS.Graphs:StyleScatterPlots(instance, colors, settings, theme)
    if not instance.scatter_plot then 
        return -- No scatter plot to style
    end
    
    -- Get atlas textures if available
    local backgroundTexture
    if DS.Atlas and DS.Atlas.GetBackgroundTexture then
        backgroundTexture = DS.Atlas:GetBackgroundTexture(theme)
    end
    
    -- Scatter plot settings
    local scatterSettings = {
        -- Background appearance
        background_texture = backgroundTexture,
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
            0.7
        },
        border_width = settings.scatterPlotBorderWidth or 1,
        
        -- Point appearance
        point_color = {
            colors.primary.r,
            colors.primary.g,
            colors.primary.b,
            0.8
        },
        point_highlight_color = {
            colors.highlight.r,
            colors.highlight.g,
            colors.highlight.b,
            1
        },
        point_size = settings.scatterPlotPointSize or 5,
        point_style = settings.scatterPlotPointStyle or "CIRCLE", -- CIRCLE, SQUARE, DIAMOND, TRIANGLE
        point_outline = settings.scatterPlotPointOutline or true,
        point_outline_color = {
            colors.border.r,
            colors.border.g,
            colors.border.b,
            0.7
        },
        
        -- Grid appearance
        grid_color = {
            colors.shadow.r + 0.2,
            colors.shadow.g + 0.2,
            colors.shadow.b + 0.2,
            0.25
        },
        grid_width = settings.scatterPlotGridWidth or 1,
        grid_style = settings.scatterPlotGridStyle or "SOLID", -- SOLID, DASHED, DOTTED
        
        -- Labels
        show_labels = settings.scatterPlotShowLabels or true,
        label_color = {
            colors.text.r,
            colors.text.g,
            colors.text.b,
            1
        },
        label_font_size = settings.scatterPlotLabelFontSize or 10,
        
        -- Animation
        animation_enabled = settings.scatterPlotAnimationEnabled or true,
        animation_duration = settings.scatterPlotAnimationDuration or 0.4,
        animation_style = settings.scatterPlotAnimationStyle or "BOUNCE",
        
        -- Tooltip
        tooltip_enabled = settings.scatterPlotTooltipEnabled or true,
        tooltip_format = settings.scatterPlotTooltipFormat or "${name}: (${x}, ${y})",
        tooltip_anchor = settings.scatterPlotTooltipAnchor or "ANCHOR_CURSOR",
        
        -- Interaction
        interactive = settings.scatterPlotInteractive or true,
        zoom_enabled = settings.scatterPlotZoomEnabled or true,
        pan_enabled = settings.scatterPlotPanEnabled or true
    }
    
    -- Apply theme-specific color schemes
    if theme == "phoenixflame" then
        -- Phoenix Flame: Use heat gradient
        scatterSettings.color_gradient = true
        scatterSettings.color_gradient_type = "VALUE" -- VALUE, X, Y
        scatterSettings.color_gradient_min = {0.7, 0.2, 0.1, 0.7} -- Red (low)
        scatterSettings.color_gradient_max = {1.0, 0.8, 0.1, 0.9} -- Yellow (high)
    elseif theme == "thunderstorm" then
        -- Thunder Storm: Electric blue gradient
        scatterSettings.color_gradient = true
        scatterSettings.color_gradient_type = "VALUE"
        scatterSettings.color_gradient_min = {0.1, 0.3, 0.7, 0.7} -- Dark blue (low)
        scatterSettings.color_gradient_max = {0.3, 0.7, 1.0, 0.9} -- Light blue (high)
    end
    
    -- Store settings
    instance.scatter_plot_config = scatterSettings
    
    -- Apply settings to the scatter plot
    local plot = instance.scatter_plot
    
    -- Apply basic settings
    if plot.SetBackgroundColor then
        plot:SetBackgroundColor(unpack(scatterSettings.background_color))
    end
    
    if plot.SetBorderColor then
        plot:SetBorderColor(unpack(scatterSettings.border_color))
    end
    
    if plot.SetBorderWidth then
        plot:SetBorderWidth(scatterSettings.border_width)
    end
    
    -- Apply point settings
    if plot.SetPointAppearance then
        plot:SetPointAppearance(
            scatterSettings.point_size,
            scatterSettings.point_style,
            scatterSettings.point_color,
            scatterSettings.point_outline,
            scatterSettings.point_outline_color
        )
    end
    
    -- Apply grid settings
    if plot.SetGridAppearance then
        plot:SetGridAppearance(
            scatterSettings.grid_color,
            scatterSettings.grid_width,
            scatterSettings.grid_style
        )
    end
    
    -- Apply label settings
    if plot.SetLabels then
        plot:SetLabels(
            scatterSettings.show_labels,
            scatterSettings.label_color,
            scatterSettings.label_font_size
        )
    end
    
    -- Apply color gradient if supported
    if plot.SetColorGradient and scatterSettings.color_gradient then
        plot:SetColorGradient(
            scatterSettings.color_gradient,
            scatterSettings.color_gradient_type,
            scatterSettings.color_gradient_min,
            scatterSettings.color_gradient_max
        )
    end
    
    -- Apply animation settings
    if plot.SetAnimation and scatterSettings.animation_enabled then
        plot:SetAnimation(
            scatterSettings.animation_enabled,
            scatterSettings.animation_duration,
            ANIMATION_PRESETS[scatterSettings.animation_style] or ANIMATION_PRESETS.BOUNCE
        )
    end
    
    -- Apply tooltip settings
    if plot.SetTooltip and scatterSettings.tooltip_enabled then
        plot:SetTooltip(
            scatterSettings.tooltip_enabled,
            scatterSettings.tooltip_format,
            scatterSettings.tooltip_anchor
        )
    end
    
    -- Apply interaction settings
    if plot.SetInteractive then
        plot:SetInteractive(
            scatterSettings.interactive,
            scatterSettings.zoom_enabled,
            scatterSettings.pan_enabled
        )
    end
    
    -- Add hover effects if not already added
    if not plot._vuiHoverEffectsRegistered and scatterSettings.interactive then
        plot:SetScript("OnEnter", function(self)
            -- Enhance border
            if self.SetBorderWidth then
                self:SetBorderWidth(scatterSettings.border_width + 1)
            end
            
            -- Adjust point size on hover if supported
            if self.GetPointAtCursor and self.SetPointSize then
                local pointIndex = self:GetPointAtCursor()
                if pointIndex then
                    self:SetPointSize(pointIndex, scatterSettings.point_size * 1.5)
                    self:SetPointColor(pointIndex, unpack(scatterSettings.point_highlight_color))
                end
            end
        end)
        
        plot:SetScript("OnLeave", function(self)
            -- Restore border
            if self.SetBorderWidth then
                self:SetBorderWidth(scatterSettings.border_width)
            end
            
            -- Reset all point sizes if supported
            if self.ResetPointSizes then
                self:ResetPointSizes()
            end
            
            -- Hide tooltip
            GameTooltip:Hide()
        end)
        
        plot._vuiHoverEffectsRegistered = true
    end
    
    -- Refresh the plot
    if plot.Refresh then
        plot:Refresh()
    end
    
    -- Track this graph for performance metrics
    self:TrackGraph(plot, GRAPH_TYPES.SCATTER)
end

-- Style area graphs (if supported)
function DS.Graphs:StyleAreaGraphs(instance, colors, settings, theme)
    if not instance.area_graph then
        return -- No area graph to style
    end
    
    -- Get atlas textures if available
    local backgroundTexture
    if DS.Atlas and DS.Atlas.GetBackgroundTexture then
        backgroundTexture = DS.Atlas:GetBackgroundTexture(theme)
    end
    
    -- Area graph settings
    local areaSettings = {
        -- Background appearance
        background_texture = backgroundTexture,
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
            0.7
        },
        border_width = settings.areaGraphBorderWidth or 1,
        
        -- Line appearance
        line_color = {
            colors.primary.r,
            colors.primary.g,
            colors.primary.b,
            0.9
        },
        line_width = settings.areaGraphLineWidth or 2,
        line_style = settings.areaGraphLineStyle or "SOLID", -- SOLID, DASHED, DOTTED
        
        -- Area fill appearance
        fill_color = {
            colors.primary.r,
            colors.primary.g,
            colors.primary.b,
            0.3
        },
        fill_gradient = settings.areaGraphFillGradient or true,
        fill_gradient_dir = settings.areaGraphFillGradientDir or "VERTICAL",
        fill_gradient_min_alpha = 0.1,
        fill_gradient_max_alpha = 0.4,
        
        -- Grid appearance
        grid_color = {
            colors.shadow.r + 0.2,
            colors.shadow.g + 0.2,
            colors.shadow.b + 0.2,
            0.25
        },
        grid_width = settings.areaGraphGridWidth or 1,
        grid_style = settings.areaGraphGridStyle or "SOLID", -- SOLID, DASHED, DOTTED
        
        -- Labels
        show_labels = settings.areaGraphShowLabels or true,
        label_color = {
            colors.text.r,
            colors.text.g,
            colors.text.b,
            1
        },
        label_font_size = settings.areaGraphLabelFontSize or 10,
        
        -- Data point markers
        show_markers = settings.areaGraphShowMarkers or true,
        marker_size = settings.areaGraphMarkerSize or 4,
        marker_color = {
            colors.highlight.r,
            colors.highlight.g,
            colors.highlight.b,
            1
        },
        
        -- Animation
        animation_enabled = settings.areaGraphAnimationEnabled or true,
        animation_duration = settings.areaGraphAnimationDuration or 0.5,
        animation_style = settings.areaGraphAnimationStyle or "DEFAULT",
        
        -- Tooltip
        tooltip_enabled = settings.areaGraphTooltipEnabled or true,
        tooltip_format = settings.areaGraphTooltipFormat or "${x}: ${y}",
        tooltip_anchor = settings.areaGraphTooltipAnchor or "ANCHOR_CURSOR",
        
        -- Interaction
        interactive = settings.areaGraphInteractive or true,
        zoom_enabled = settings.areaGraphZoomEnabled or true,
        pan_enabled = settings.areaGraphPanEnabled or true
    }
    
    -- Apply theme-specific color schemes
    if theme == "phoenixflame" then
        -- Phoenix Flame: fiery gradient
        areaSettings.fill_gradient_colors = {
            {1.0, 0.6, 0.1, 0.4}, -- Top: orange
            {0.9, 0.3, 0.1, 0.1}  -- Bottom: deep red
        }
    elseif theme == "thunderstorm" then
        -- Thunder Storm: electric blue gradient
        areaSettings.fill_gradient_colors = {
            {0.3, 0.7, 1.0, 0.4}, -- Top: light blue
            {0.1, 0.3, 0.7, 0.1}  -- Bottom: dark blue
        }
    elseif theme == "arcanemystic" then
        -- Arcane Mystic: purple gradient
        areaSettings.fill_gradient_colors = {
            {0.7, 0.3, 0.9, 0.4}, -- Top: light purple
            {0.4, 0.1, 0.6, 0.1}  -- Bottom: deep purple
        }
    elseif theme == "felenergy" then
        -- Fel Energy: green gradient
        areaSettings.fill_gradient_colors = {
            {0.3, 0.9, 0.3, 0.4}, -- Top: light green
            {0.1, 0.6, 0.1, 0.1}  -- Bottom: deep green
        }
    end
    
    -- Store settings
    instance.area_graph_config = areaSettings
    
    -- Apply settings to the area graph
    local graph = instance.area_graph
    
    -- Apply basic settings
    if graph.SetBackgroundColor then
        graph:SetBackgroundColor(unpack(areaSettings.background_color))
    end
    
    if graph.SetBorderColor then
        graph:SetBorderColor(unpack(areaSettings.border_color))
    end
    
    if graph.SetBorderWidth then
        graph:SetBorderWidth(areaSettings.border_width)
    end
    
    -- Apply line settings
    if graph.SetLineAppearance then
        graph:SetLineAppearance(
            areaSettings.line_color,
            areaSettings.line_width,
            areaSettings.line_style
        )
    end
    
    -- Apply fill settings
    if graph.SetFillAppearance then
        graph:SetFillAppearance(
            areaSettings.fill_color,
            areaSettings.fill_gradient,
            areaSettings.fill_gradient_dir
        )
    end
    
    -- Apply gradient colors if supported
    if graph.SetFillGradientColors and areaSettings.fill_gradient and areaSettings.fill_gradient_colors then
        graph:SetFillGradientColors(
            areaSettings.fill_gradient_colors[1],
            areaSettings.fill_gradient_colors[2]
        )
    end
    
    -- Apply grid settings
    if graph.SetGridAppearance then
        graph:SetGridAppearance(
            areaSettings.grid_color,
            areaSettings.grid_width,
            areaSettings.grid_style
        )
    end
    
    -- Apply label settings
    if graph.SetLabels then
        graph:SetLabels(
            areaSettings.show_labels,
            areaSettings.label_color,
            areaSettings.label_font_size
        )
    end
    
    -- Apply marker settings
    if graph.SetMarkers then
        graph:SetMarkers(
            areaSettings.show_markers,
            areaSettings.marker_size,
            areaSettings.marker_color
        )
    end
    
    -- Apply animation settings
    if graph.SetAnimation and areaSettings.animation_enabled then
        graph:SetAnimation(
            areaSettings.animation_enabled,
            areaSettings.animation_duration,
            ANIMATION_PRESETS[areaSettings.animation_style] or ANIMATION_PRESETS.DEFAULT
        )
    end
    
    -- Apply tooltip settings
    if graph.SetTooltip and areaSettings.tooltip_enabled then
        graph:SetTooltip(
            areaSettings.tooltip_enabled,
            areaSettings.tooltip_format,
            areaSettings.tooltip_anchor
        )
    end
    
    -- Apply interaction settings
    if graph.SetInteractive then
        graph:SetInteractive(
            areaSettings.interactive,
            areaSettings.zoom_enabled,
            areaSettings.pan_enabled
        )
    end
    
    -- Refresh the graph
    if graph.Refresh then
        graph:Refresh()
    end
    
    -- Track this graph for performance metrics
    self:TrackGraph(graph, GRAPH_TYPES.AREA)
end

-- Enhanced styling for custom displays (scrolls, texts, etc.)
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
    
    -- Enhanced text area styling
    local textAreaSettings = {
        font_size = settings.textAreaFontSize or 11,
        font_color = {
            colors.text.r,
            colors.text.g,
            colors.text.b,
            1
        },
        font_shadow = settings.textAreaFontShadow or true,
        font_shadow_color = {0, 0, 0, 0.6},
        font_shadow_offset = {1, -1},
        background_texture = backgroundTexture,
        background_color = {
            colors.background.r,
            colors.background.g,
            colors.background.b,
            0.3
        },
        background_gradient = settings.textAreaBackgroundGradient or true,
        background_gradient_dir = settings.textAreaBackgroundGradientDir or "VERTICAL",
        background_gradient_min_alpha = 0.2,
        background_gradient_max_alpha = 0.4,
        border_texture = borderTexture,
        border_color = {
            colors.border.r,
            colors.border.g,
            colors.border.b,
            0.5
        },
        border_width = settings.textAreaBorderWidth or 1,
        corner_radius = settings.textAreaCornerRadius or 0,
        padding = settings.textAreaPadding or 5
    }
    
    -- Enhanced scrollbar styling
    local scrollbarSettings = {
        thumb_texture = DS:GetBarTexture(theme),
        thumb_color = {
            colors.primary.r,
            colors.primary.g,
            colors.primary.b,
            0.7
        },
        thumb_highlight_color = {
            colors.highlight.r,
            colors.highlight.g,
            colors.highlight.b,
            0.9
        },
        track_color = {
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
        },
        width = settings.scrollbarWidth or 12,
        show_buttons = settings.scrollbarShowButtons or true,
        button_color = {
            colors.primary.r * 0.7,
            colors.primary.g * 0.7,
            colors.primary.b * 0.7,
            0.7
        },
        button_highlight_color = {
            colors.highlight.r,
            colors.highlight.g,
            colors.highlight.b,
            0.8
        }
    }
    
    -- Store the settings
    instance.text_area_config = textAreaSettings
    instance.scrollbar_config = scrollbarSettings
    
    -- Apply to existing text areas
    if instance.text_panel then
        -- Apply backdrop if using a custom backdrop
        if type(instance.text_panel.SetBackdrop) == "function" then
            instance.text_panel:SetBackdrop({
                bgFile = textAreaSettings.background_texture,
                edgeFile = textAreaSettings.border_texture,
                edgeSize = textAreaSettings.border_width,
                insets = {
                    left = textAreaSettings.padding,
                    right = textAreaSettings.padding,
                    top = textAreaSettings.padding,
                    bottom = textAreaSettings.padding
                }
            })
        end
        
        instance.text_panel:SetBackdropColor(unpack(textAreaSettings.background_color))
        instance.text_panel:SetBackdropBorderColor(unpack(textAreaSettings.border_color))
        
        -- Apply to editbox if present
        if instance.text_panel.editbox then
            instance.text_panel.editbox:SetTextColor(unpack(textAreaSettings.font_color))
            
            -- Get current font path from editbox
            local fontPath, _, fontFlags = instance.text_panel.editbox:GetFont()
            
            -- Apply font settings
            instance.text_panel.editbox:SetFont(
                fontPath,
                textAreaSettings.font_size,
                fontFlags
            )
            
            -- Apply font shadow
            if textAreaSettings.font_shadow then
                instance.text_panel.editbox:SetShadowColor(unpack(textAreaSettings.font_shadow_color))
                instance.text_panel.editbox:SetShadowOffset(
                    textAreaSettings.font_shadow_offset[1],
                    textAreaSettings.font_shadow_offset[2]
                )
            else
                instance.text_panel.editbox:SetShadowColor(0, 0, 0, 0)
            end
        end
        
        -- Apply background gradient if supported
        if instance.text_panel.SetBackgroundGradient and textAreaSettings.background_gradient then
            instance.text_panel:SetBackgroundGradient(
                textAreaSettings.background_gradient,
                textAreaSettings.background_gradient_dir,
                textAreaSettings.background_gradient_min_alpha,
                textAreaSettings.background_gradient_max_alpha
            )
        end
        
        -- Apply corner radius if supported
        if instance.text_panel.SetCornerRadius and textAreaSettings.corner_radius > 0 then
            instance.text_panel:SetCornerRadius(textAreaSettings.corner_radius)
        end
    end
    
    -- Apply to scrollbars
    if instance.scroll then
        if instance.scroll.slider then
            -- Style thumb texture
            local thumbTexture = instance.scroll.slider:GetThumbTexture()
            if thumbTexture then
                if scrollbarSettings.thumb_texture then
                    thumbTexture:SetTexture(scrollbarSettings.thumb_texture)
                else
                    thumbTexture:SetColorTexture(unpack(scrollbarSettings.thumb_color))
                end
            end
            
            -- Style track
            if instance.scroll.bg then
                instance.scroll.bg:SetColorTexture(unpack(scrollbarSettings.track_color))
            end
            
            -- Style border
            if instance.scroll.border then
                instance.scroll.border:SetBackdropBorderColor(unpack(scrollbarSettings.border_color))
            end
            
            -- Style buttons if present
            if scrollbarSettings.show_buttons then
                if instance.scroll.UpButton then
                    if instance.scroll.UpButton.SetNormalTexture then
                        -- Style button textures if supported
                        local normalTexture = instance.scroll.UpButton:GetNormalTexture()
                        if normalTexture then
                            normalTexture:SetVertexColor(unpack(scrollbarSettings.button_color))
                        end
                        
                        local highlightTexture = instance.scroll.UpButton:GetHighlightTexture()
                        if highlightTexture then
                            highlightTexture:SetVertexColor(unpack(scrollbarSettings.button_highlight_color))
                        end
                    end
                end
                
                if instance.scroll.DownButton then
                    if instance.scroll.DownButton.SetNormalTexture then
                        -- Style button textures if supported
                        local normalTexture = instance.scroll.DownButton:GetNormalTexture()
                        if normalTexture then
                            normalTexture:SetVertexColor(unpack(scrollbarSettings.button_color))
                        end
                        
                        local highlightTexture = instance.scroll.DownButton:GetHighlightTexture()
                        if highlightTexture then
                            highlightTexture:SetVertexColor(unpack(scrollbarSettings.button_highlight_color))
                        end
                    end
                end
            end
            
            -- Add hover effect to thumb if not already added
            if not instance.scroll.slider._vuiHoverEffectAdded then
                instance.scroll.slider:HookScript("OnEnter", function(self)
                    local thumbTexture = self:GetThumbTexture()
                    if thumbTexture then
                        thumbTexture:SetVertexColor(unpack(scrollbarSettings.thumb_highlight_color))
                    end
                end)
                
                instance.scroll.slider:HookScript("OnLeave", function(self)
                    local thumbTexture = self:GetThumbTexture()
                    if thumbTexture then
                        thumbTexture:SetVertexColor(unpack(scrollbarSettings.thumb_color))
                    end
                end)
                
                instance.scroll.slider._vuiHoverEffectAdded = true
            end
        end
    end
}

-- Apply custom tooltips for graph elements
function DS.Graphs:ApplyCustomTooltips(instance, colors, settings, theme)
    if not instance then return end
    
    -- Define the tooltip style for charts
    local tooltipStyle = {
        background_color = {
            colors.background.r,
            colors.background.g,
            colors.background.b,
            0.9
        },
        border_color = {
            colors.border.r,
            colors.border.g,
            colors.border.b,
            0.8
        },
        header_color = {
            colors.primary.r,
            colors.primary.g,
            colors.primary.b,
            1
        },
        text_color = {
            colors.text.r,
            colors.text.g,
            colors.text.b,
            1
        },
        value_color = {
            colors.highlight.r,
            colors.highlight.g,
            colors.highlight.b,
            1
        },
        font_size = settings.tooltipFontSize or 11,
        padding = settings.tooltipPadding or 10,
        show_icon = settings.tooltipShowIcon or true,
        icon_size = settings.tooltipIconSize or 24,
        shadow = settings.tooltipShadow or true
    }
    
    -- Store the tooltip style
    instance.tooltip_style = tooltipStyle
    
    -- Apply tooltip styling hooks if not already applied
    if not instance._vuiTooltipStyleApplied then
        local hookFunc = function(tooltip)
            if not tooltip or not tooltip:IsShown() then return end
            
            -- Apply background color
            tooltip:SetBackdropColor(unpack(tooltipStyle.background_color))
            
            -- Apply border color
            tooltip:SetBackdropBorderColor(unpack(tooltipStyle.border_color))
            
            -- Apply padding if supported
            if tooltip.SetPadding then
                tooltip:SetPadding(tooltipStyle.padding, tooltipStyle.padding, tooltipStyle.padding, tooltipStyle.padding)
            end
            
            -- Apply shadow if supported
            if tooltipStyle.shadow and tooltip.SetShadowColor then
                tooltip:SetShadowColor(0, 0, 0, 0.5)
            end
            
            -- Colorize text lines if possible
            for i = 1, tooltip:NumLines() do
                local line = _G["GameTooltipTextLeft" .. i]
                if line and i == 1 then
                    -- First line is header
                    line:SetTextColor(unpack(tooltipStyle.header_color))
                    line:SetFont(line:GetFont(), tooltipStyle.font_size + 1, "OUTLINE")
                elseif line then
                    -- Regular text lines
                    line:SetTextColor(unpack(tooltipStyle.text_color))
                    line:SetFont(line:GetFont(), tooltipStyle.font_size, "")
                end
                
                -- Right-aligned text (usually values)
                local rightLine = _G["GameTooltipTextRight" .. i]
                if rightLine then
                    rightLine:SetTextColor(unpack(tooltipStyle.value_color))
                    rightLine:SetFont(rightLine:GetFont(), tooltipStyle.font_size, "")
                end
            end
        end
        
        -- Hook tooltip display
        hooksecurefunc("GameTooltip_ShowCompareItem", function(self)
            hookFunc(self)
        end)
        
        GameTooltip:HookScript("OnShow", function(self)
            hookFunc(self)
        end)
        
        GameTooltip:HookScript("OnTooltipSetItem", function(self)
            hookFunc(self)
        end)
        
        GameTooltip:HookScript("OnTooltipSetSpell", function(self)
            hookFunc(self)
        end)
        
        GameTooltip:HookScript("OnTooltipSetUnit", function(self)
            hookFunc(self)
        end)
        
        instance._vuiTooltipStyleApplied = true
    end
end

-- Apply animation preset to graph elements
function DS.Graphs:ApplyAnimationPreset(instance, presetName, theme)
    if not instance then return end
    
    -- Get animation settings
    local preset = ANIMATION_PRESETS[presetName] or ANIMATION_PRESETS.DEFAULT
    
    -- Apply theme-specific adjustments to animation
    if theme == "phoenixflame" then
        -- Phoenix Flame: quicker animations
        preset.duration = preset.duration * 0.8
        preset.easing = "OUT_BACK"
    elseif theme == "thunderstorm" then
        -- Thunder Storm: more elastic animations
        preset.easing = "OUT_ELASTIC"
        preset.duration = preset.duration * 1.1
    elseif theme == "arcanemystic" then
        -- Arcane Mystic: magical effect
        preset.easing = "OUT_BOUNCE"
        preset.duration = preset.duration * 1.2
    elseif theme == "felenergy" then
        -- Fel Energy: quick snappy animations
        preset.easing = "OUT_QUINT"
        preset.duration = preset.duration * 0.7
    end
    
    -- Store the animation settings
    instance.animation_preset = preset
    
    -- Apply to various graph types
    if instance.v_bars_line_graph and instance.v_bars_line_graph.SetAnimation then
        instance.v_bars_line_graph:SetAnimation(true, preset.duration, preset)
    end
    
    if instance.pie_chart and instance.pie_chart.SetAnimation then
        instance.pie_chart:SetAnimation(true, preset.duration, preset)
    end
    
    if instance.area_graph and instance.area_graph.SetAnimation then
        instance.area_graph:SetAnimation(true, preset.duration, preset)
    end
    
    if instance.scatter_plot and instance.scatter_plot.SetAnimation then
        instance.scatter_plot:SetAnimation(true, preset.duration, preset)
    end
    
    -- Apply to bar graphs if present
    if instance.v_bars and #instance.v_bars > 0 then
        for i, bar in ipairs(instance.v_bars) do
            self:ApplyBarAnimation(bar, i, {
                animation_enabled = true,
                animation_duration = preset.duration,
                animation_stagger = true
            }, preset)
        end
    end
}

-- Apply animation to bar elements
function DS.Graphs:ApplyBarAnimation(bar, index, settings, preset)
    if not bar or not bar.statusbar then return end
    
    -- Use provided preset or default
    preset = preset or ANIMATION_PRESETS[settings.animation_style] or ANIMATION_PRESETS.DEFAULT
    
    -- Create animation if not exists
    if not bar._vuiAnimation then
        local animGroup = bar.statusbar:CreateAnimationGroup()
        
        -- Value animation
        local valueAnim = animGroup:CreateAnimation("Progress")
        valueAnim:SetOrder(1)
        valueAnim:SetDuration(settings.animation_duration or preset.duration)
        valueAnim:SetSmoothing(preset.easing)
        valueAnim:SetFromValue(0)
        valueAnim:SetToValue(1)
        
        -- Alpha animation
        local alphaAnim = animGroup:CreateAnimation("Alpha")
        alphaAnim:SetOrder(1)
        alphaAnim:SetDuration((settings.animation_duration or preset.duration) * 0.7)
        alphaAnim:SetSmoothing("OUT_CUBIC")
        alphaAnim:SetFromAlpha(0.3)
        alphaAnim:SetToAlpha(1)
        
        -- Scale animation
        local scaleAnim = animGroup:CreateAnimation("Scale")
        scaleAnim:SetOrder(1)
        scaleAnim:SetDuration((settings.animation_duration or preset.duration) * 0.8)
        scaleAnim:SetSmoothing(preset.easing)
        scaleAnim:SetFromScale(0.9, 1)
        scaleAnim:SetToScale(1, 1)
        scaleAnim:SetOrigin("LEFT", 0, 0)
        
        -- Store animation references
        bar._vuiAnimation = animGroup
        bar._vuiValueAnim = valueAnim
        bar._vuiAlphaAnim = alphaAnim
        bar._vuiScaleAnim = scaleAnim
        
        -- Hook progress update
        valueAnim:SetScript("OnUpdate", function(self)
            local progress = self:GetProgress()
            local value = bar.statusbar:GetValue()
            local minValue, maxValue = bar.statusbar:GetMinMaxValues()
            
            -- Scale current value based on animation progress
            if progress < 1 then
                local animatedValue = minValue + ((value - minValue) * progress)
                bar.statusbar:SetValue(animatedValue)
                
                -- Update value text if present
                if bar.valuetext and bar.valuetext.SetText then
                    if type(bar.value) == "number" then
                        local displayValue = bar.value * progress
                        bar.valuetext:SetText(string_format(settings.value_text_format or "%.1f", displayValue))
                    end
                end
            end
        end)
        
        -- Hook animation finished
        animGroup:SetScript("OnFinished", function()
            -- Ensure final value is set correctly
            bar.statusbar:SetValue(bar.statusbar:GetValue())
            
            -- Update value text to final value
            if bar.valuetext and bar.valuetext.SetText and type(bar.value) == "number" then
                bar.valuetext:SetText(string_format(settings.value_text_format or "%.1f", bar.value))
            end
        end)
    end
    
    -- Calculate staggered start if enabled
    local delay = 0
    if settings.animation_stagger then
        delay = (index - 1) * (preset.stagger or 0.02)
    end
    
    -- Update animation settings
    bar._vuiValueAnim:SetDuration(settings.animation_duration or preset.duration)
    bar._vuiValueAnim:SetSmoothing(preset.easing)
    bar._vuiValueAnim:SetStartDelay(delay)
    
    bar._vuiAlphaAnim:SetDuration((settings.animation_duration or preset.duration) * 0.7)
    bar._vuiAlphaAnim:SetStartDelay(delay)
    
    bar._vuiScaleAnim:SetDuration((settings.animation_duration or preset.duration) * 0.8)
    bar._vuiScaleAnim:SetSmoothing(preset.easing)
    bar._vuiScaleAnim:SetStartDelay(delay)
    
    -- Store initial value
    local value = bar.statusbar:GetValue()
    bar._vuiInitialValue = value
    
    -- Start animation if not already playing
    if not bar._vuiAnimation:IsPlaying() then
        -- Reset bar to initial state for animation
        bar.statusbar:SetValue(0)
        
        -- Set alpha for fade-in
        bar:SetAlpha(0.3)
        
        -- Start animation after a small delay
        C_Timer.After(delay + 0.01, function()
            bar:SetAlpha(1)
            bar._vuiAnimation:Play()
        end)
    end
end

-- Register for graph refresh events to catch rebuilds
function DS.Graphs:RegisterGraphRefreshHooks(instance)
    if not instance then return end
    
    -- Hook instance refresh method
    if instance.InstanceRefresh then
        hooksecurefunc(instance, "InstanceRefresh", function(self)
            -- Reapply styles when instance refreshes
            C_Timer.After(0.1, function()
                DS.Graphs:ApplyStyle(self)
            end)
        end)
    end
    
    -- Hook specific refresh methods for graphs
    if instance.RefreshLine and instance.v_bars_line_graph then
        hooksecurefunc(instance, "RefreshLine", function(self)
            C_Timer.After(0.1, function()
                DS.Graphs:StyleLineGraphs(self, DS:GetThemeColors(), DS:GetSettings(), VUI.db.profile.appearance.theme)
            end)
        end)
    end
    
    if instance.RefreshBars and instance.v_bars then
        hooksecurefunc(instance, "RefreshBars", function(self)
            C_Timer.After(0.1, function()
                DS.Graphs:StyleBarGraphs(self, DS:GetThemeColors(), DS:GetSettings(), VUI.db.profile.appearance.theme)
            end)
        end)
    end
    
    if instance.RefreshPie and instance.pie_chart then
        hooksecurefunc(instance, "RefreshPie", function(self)
            C_Timer.After(0.1, function()
                DS.Graphs:StylePieCharts(self, DS:GetThemeColors(), DS:GetSettings(), VUI.db.profile.appearance.theme)
            end)
        end)
    end
}

-- Track graph usage for performance metrics
function DS.Graphs:TrackGraph(graph, graphType)
    if not graph then return end
    
    -- Initialize tracking system if not already done
    if not DS.graphPerformanceMetrics then
        DS.graphPerformanceMetrics = {
            graphCount = 0,
            typeCount = {},
            lastUpdate = GetTime(),
            renderTime = 0,
            frameTimeImpact = 0,
            memoryUsage = 0
        }
        
        -- Create timer to track performance
        C_Timer.NewTicker(5, function()
            DS.Graphs:UpdatePerformanceMetrics()
        end)
    end
    
    -- Register graph if not already tracked
    if not graph._vuiPerformanceTracking then
        -- Increment counters
        DS.graphPerformanceMetrics.graphCount = DS.graphPerformanceMetrics.graphCount + 1
        DS.graphPerformanceMetrics.typeCount[graphType] = (DS.graphPerformanceMetrics.typeCount[graphType] or 0) + 1
        
        -- Track information about this graph
        graph._vuiPerformanceTracking = {
            graphType = graphType,
            added = GetTime(),
            renderCount = 0,
            lastRenderTime = 0,
            averageRenderTime = 0
        }
        
        -- Hook rendering functions to measure performance
        if graph.Refresh then
            local originalRefresh = graph.Refresh
            graph.Refresh = function(self, ...)
                local startTime = debugprofilestop()
                local result = originalRefresh(self, ...)
                local endTime = debugprofilestop()
                
                -- Update performance metrics
                local renderTime = endTime - startTime
                self._vuiPerformanceTracking.renderCount = self._vuiPerformanceTracking.renderCount + 1
                self._vuiPerformanceTracking.lastRenderTime = renderTime
                
                -- Update average render time
                local oldAvg = self._vuiPerformanceTracking.averageRenderTime
                local newAvg = ((oldAvg * (self._vuiPerformanceTracking.renderCount - 1)) + renderTime) / self._vuiPerformanceTracking.renderCount
                self._vuiPerformanceTracking.averageRenderTime = newAvg
                
                return result
            end
        end
    end
end

-- Update performance metrics for all graphs
function DS.Graphs:UpdatePerformanceMetrics()
    if not DS.graphPerformanceMetrics then return end
    
    local metrics = DS.graphPerformanceMetrics
    local now = GetTime()
    local elapsedTime = now - metrics.lastUpdate
    
    -- Calculate estimated memory usage
    local estimatedMemory = metrics.graphCount * 250 -- Very rough estimate, 250kb per graph
    metrics.memoryUsage = estimatedMemory
    
    -- Calculate frame time impact (rough estimate)
    local totalRenderTime = 0
    local sampleCount = 0
    
    -- Iterate through all graphs and collect render times
    for _, instance in pairs(Details:GetAllInstances()) do
        -- Check line graph
        if instance.v_bars_line_graph and instance.v_bars_line_graph._vuiPerformanceTracking then
            totalRenderTime = totalRenderTime + instance.v_bars_line_graph._vuiPerformanceTracking.averageRenderTime
            sampleCount = sampleCount + 1
        end
        
        -- Check pie chart
        if instance.pie_chart and instance.pie_chart._vuiPerformanceTracking then
            totalRenderTime = totalRenderTime + instance.pie_chart._vuiPerformanceTracking.averageRenderTime
            sampleCount = sampleCount + 1
        end
        
        -- Check area graph
        if instance.area_graph and instance.area_graph._vuiPerformanceTracking then
            totalRenderTime = totalRenderTime + instance.area_graph._vuiPerformanceTracking.averageRenderTime
            sampleCount = sampleCount + 1
        end
        
        -- Check scatter plot
        if instance.scatter_plot and instance.scatter_plot._vuiPerformanceTracking then
            totalRenderTime = totalRenderTime + instance.scatter_plot._vuiPerformanceTracking.averageRenderTime
            sampleCount = sampleCount + 1
        end
    end
    
    -- Calculate average render time and frame impact
    if sampleCount > 0 then
        local avgRenderTime = totalRenderTime / sampleCount
        metrics.renderTime = avgRenderTime
        metrics.frameTimeImpact = avgRenderTime / 16.67 * 100 -- As percentage of a 60fps frame
    end
    
    -- Update last update time
    metrics.lastUpdate = now
    
    -- Debug logging if needed
    if DS.GetSettings().debugGraphs then
        self:Log(
            "Graphs Performance: " .. metrics.graphCount .. " graphs, " ..
            string_format("%.2fms render time, %.1f%% frame impact, %.2f KB estimated memory", 
                metrics.renderTime, 
                metrics.frameTimeImpact,
                metrics.memoryUsage / 1024
            )
        )
    end
}

-- Track performance of all graph instances
function DS.Graphs:TrackGraphPerformance(instance)
    -- Ensure we track this instance's graphs
    if instance then
        if instance.v_bars_line_graph then
            self:TrackGraph(instance.v_bars_line_graph, GRAPH_TYPES.LINE)
        end
        
        if instance.pie_chart then
            self:TrackGraph(instance.pie_chart, GRAPH_TYPES.PIE)
        end
        
        if instance.area_graph then
            self:TrackGraph(instance.area_graph, GRAPH_TYPES.AREA)
        end
        
        if instance.scatter_plot then
            self:TrackGraph(instance.scatter_plot, GRAPH_TYPES.SCATTER)
        end
        
        -- Track all bar graphs
        if instance.v_bars and #instance.v_bars > 0 then
            self:TrackGraph(instance, GRAPH_TYPES.BAR)
        end
    end
}

-- Apply styles to Details DpsGraph plugin if present
function DS.Graphs:ApplyToDetailsDpsGraphPlugin(theme)
    if not Details then return end
    if not Details.DpsGraphs then return end
    
    local colors = DS:GetThemeColors(theme)
    local settings = DS:GetSettings()
    
    -- DPS graph settings
    local dpsGraphSettings = {
        line_color = {
            colors.primary.r,
            colors.primary.g,
            colors.primary.b,
            0.9
        },
        line_width = settings.graphLineWidth or 2,
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
            0.7
        },
        grid_color = {
            colors.shadow.r + 0.2,
            colors.shadow.g + 0.2,
            colors.shadow.b + 0.2,
            0.25
        },
        text_color = {
            colors.text.r,
            colors.text.g,
            colors.text.b,
            1
        }
    }
    
    -- Apply theme-specific gradient colors
    if theme == "phoenixflame" then
        -- Phoenix Flame: fiery gradient
        dpsGraphSettings.gradient = true
        dpsGraphSettings.gradient_colors = {
            {1.0, 0.6, 0.1, 0.9}, -- Orange
            {0.9, 0.3, 0.1, 0.9}  -- Deep red
        }
    elseif theme == "thunderstorm" then
        -- Thunder Storm: electric blue gradient
        dpsGraphSettings.gradient = true
        dpsGraphSettings.gradient_colors = {
            {0.1, 0.6, 0.9, 0.9}, -- Light electric blue
            {0.0, 0.3, 0.7, 0.9}  -- Deep blue
        }
    elseif theme == "arcanemystic" then
        -- Arcane Mystic: purple gradient
        dpsGraphSettings.gradient = true
        dpsGraphSettings.gradient_colors = {
            {0.7, 0.3, 0.9, 0.9}, -- Light purple
            {0.4, 0.1, 0.6, 0.9}  -- Deep purple
        }
    elseif theme == "felenergy" then
        -- Fel Energy: green gradient
        dpsGraphSettings.gradient = true
        dpsGraphSettings.gradient_colors = {
            {0.3, 0.9, 0.3, 0.9}, -- Light green
            {0.1, 0.6, 0.1, 0.9}  -- Deep green
        }
    end
    
    -- Apply to all DPS graphs
    if Details.DpsGraphs.UpdateGraphConfig then
        Details.DpsGraphs:UpdateGraphConfig(dpsGraphSettings)
    end
    
    -- Apply styling to existing graph windows
    if Details.DpsGraphs.RefreshAllGraphs then
        Details.DpsGraphs:RefreshAllGraphs()
    end
}

-- Get theme-specific pie chart colors
function DS.Graphs:GetPieChartColors(theme, count)
    count = count or 10
    local colors = {}
    
    if theme == "phoenixflame" then
        -- Phoenix Flame: fiery colors
        colors = {
            {0.9, 0.3, 0.1, 0.9}, -- Deep red
            {1.0, 0.5, 0.1, 0.9}, -- Orange
            {0.9, 0.4, 0.1, 0.9}, -- Burnt orange
            {0.8, 0.3, 0.1, 0.9}, -- Dark orange
            {1.0, 0.6, 0.1, 0.9}, -- Light orange
            {0.9, 0.5, 0.2, 0.9}, -- Gold
            {0.7, 0.3, 0.1, 0.9}, -- Bronze
            {0.8, 0.4, 0.2, 0.9}, -- Copper
            {0.6, 0.2, 0.1, 0.9}, -- Maroon
            {0.7, 0.2, 0.1, 0.9}  -- Crimson
        }
    elseif theme == "thunderstorm" then
        -- Thunder Storm: electric blue colors
        colors = {
            {0.1, 0.4, 0.8, 0.9}, -- Deep blue
            {0.2, 0.6, 0.9, 0.9}, -- Electric blue
            {0.3, 0.5, 0.8, 0.9}, -- Royal blue
            {0.1, 0.3, 0.7, 0.9}, -- Navy blue
            {0.4, 0.7, 0.9, 0.9}, -- Sky blue
            {0.2, 0.5, 0.7, 0.9}, -- Steel blue
            {0.3, 0.6, 0.8, 0.9}, -- Teal blue
            {0.1, 0.5, 0.8, 0.9}, -- Cobalt
            {0.5, 0.7, 0.9, 0.9}, -- Light blue
            {0.2, 0.4, 0.6, 0.9}  -- Slate blue
        }
    elseif theme == "arcanemystic" then
        -- Arcane Mystic: purple colors
        colors = {
            {0.6, 0.2, 0.8, 0.9}, -- Deep purple
            {0.7, 0.3, 0.9, 0.9}, -- Bright purple
            {0.5, 0.1, 0.7, 0.9}, -- Dark purple
            {0.8, 0.4, 1.0, 0.9}, -- Light purple
            {0.4, 0.1, 0.6, 0.9}, -- Indigo
            {0.6, 0.3, 0.7, 0.9}, -- Amethyst
            {0.5, 0.2, 0.5, 0.9}, -- Plum
            {0.8, 0.5, 0.9, 0.9}, -- Lavender
            {0.7, 0.2, 0.8, 0.9}, -- Violet
            {0.5, 0.3, 0.6, 0.9}  -- Mulberry
        }
    elseif theme == "felenergy" then
        -- Fel Energy: green colors
        colors = {
            {0.2, 0.8, 0.2, 0.9}, -- Bright green
            {0.1, 0.6, 0.1, 0.9}, -- Deep green
            {0.3, 0.9, 0.3, 0.9}, -- Light green
            {0.2, 0.7, 0.3, 0.9}, -- Emerald
            {0.1, 0.5, 0.2, 0.9}, -- Forest green
            {0.4, 0.8, 0.2, 0.9}, -- Lime green
            {0.2, 0.6, 0.3, 0.9}, -- Jade
            {0.3, 0.7, 0.2, 0.9}, -- Mint
            {0.5, 0.9, 0.3, 0.9}, -- Chartreuse
            {0.1, 0.4, 0.1, 0.9}  -- Dark green
        }
    else
        -- Default colors
        local h, s, l = 0, 0.7, 0.5
        local step = 360 / count
        
        for i = 1, count do
            -- Convert HSL to RGB
            local r, g, b = self:HSLtoRGB(h, s, l)
            table.insert(colors, {r, g, b, 0.9})
            h = (h + step) % 360
        end
    end
    
    -- Return the requested number of colors
    local result = {}
    for i = 1, math.min(count, #colors) do
        table.insert(result, colors[i])
    end
    
    return result
end

-- Helper function to convert HSL to RGB
function DS.Graphs:HSLtoRGB(h, s, l)
    h = h / 360
    
    local r, g, b
    
    if s == 0 then
        r, g, b = l, l, l -- Achromatic
    else
        local function hue2rgb(p, q, t)
            if t < 0 then t = t + 1 end
            if t > 1 then t = t - 1 end
            if t < 1/6 then return p + (q - p) * 6 * t end
            if t < 1/2 then return q end
            if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
            return p
        end
        
        local q = l < 0.5 and l * (1 + s) or l + s - l * s
        local p = 2 * l - q
        
        r = hue2rgb(p, q, h + 1/3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1/3)
    end
    
    return r, g, b
end

-- Debug log function
function DS.Graphs:Log(message)
    if DS.GetSettings().debugGraphs then
        print("|cff1784d1VUI DetailsSkin Graphs|r: " .. message)
    end
end
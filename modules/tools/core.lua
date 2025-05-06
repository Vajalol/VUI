local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

-- Access the Tools module
local Tools = VUI.tools

-- List of available tools with their configuration
Tools.availableTools = {
    -- Example tool entry format (will add actual tools later)
    --[[
    instanceReset = {
        name = "Instance Reset",
        description = "Quickly reset your dungeon or raid instances",
        icon = "Interface\\Icons\\INV_Misc_Key_04",
        shortcut = "ALT-R",
        order = 1,
        enabled = true
    },
    --]]
}

-- Tool utility functions (will be expanded as tools are added)
Tools.utility = {
    -- Format time in seconds to a readable format
    FormatTime = function(seconds)
        if seconds < 60 then
            return string.format("%d|cffffffffs|r", seconds)
        elseif seconds < 3600 then
            local mins = math.floor(seconds / 60)
            local secs = seconds % 60
            return string.format("%d|cffffffffm|r %d|cffffffffs|r", mins, secs)
        else
            local hours = math.floor(seconds / 3600)
            local mins = math.floor((seconds % 3600) / 60)
            return string.format("%d|cffffffffh|r %d|cffffffffm|r", hours, mins)
        end
    end,
    
    -- Format large numbers with commas
    FormatNumber = function(num)
        local formatted = tostring(num)
        local k
        while true do
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if k == 0 then break end
        end
        return formatted
    end,
    
    -- Check if player is in a group (party or raid)
    IsInGroup = function()
        return IsInRaid() or IsInGroup()
    end,
    
    -- Check if player is group leader
    IsGroupLeader = function()
        return UnitIsGroupLeader("player")
    end,
    
    -- Get the full player name with realm
    GetFullPlayerName = function()
        local name, realm = UnitFullName("player")
        realm = realm or GetRealmName()
        return name .. "-" .. realm
    end,
    
    -- Create a tooltip to show information
    CreateTooltip = function(parent, title, text)
        local tooltip = GameTooltip
        tooltip:SetOwner(parent, "ANCHOR_RIGHT")
        tooltip:SetText(title, 1, 1, 1)
        if text then
            tooltip:AddLine(text, nil, nil, nil, true)
        end
        tooltip:Show()
    end,
    
    -- Create a themed button
    CreateButton = function(parent, name, text, width, height)
        local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
        button:SetSize(width or 120, height or 25)
        button:SetText(text or name)
        
        -- Apply theme
        local theme = VUI.db.profile.appearance.theme or "thunderstorm"
        local borderColor = {r = 0.05, g = 0.62, b = 0.9, a = 1} -- Electric blue default
        
        if theme == "phoenixflame" then
            borderColor = {r = 0.9, g = 0.3, b = 0.05, a = 1} -- Fiery orange
        elseif theme == "arcanemystic" then
            borderColor = {r = 0.61, g = 0.05, b = 0.9, a = 1} -- Violet
        elseif theme == "felenergy" then
            borderColor = {r = 0.1, g = 0.9, b = 0.1, a = 1} -- Fel green
        end
        
        -- Apply border color
        button:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
        button:GetNormalTexture():SetVertexColor(borderColor.r, borderColor.g, borderColor.b, 0.7)
        
        button:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
        button:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.3)
        
        button:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
        button:GetPushedTexture():SetVertexColor(borderColor.r, borderColor.g, borderColor.b, 0.7)
        
        return button
    end
}

-- Setup default settings for the Tools module
function Tools:SetupDefaults()
    -- Ensure the module has default settings in the VUI database
    if not VUI.defaults.profile.modules.tools then
        VUI.defaults.profile.modules.tools = {
            enabled = true,
            toolSettings = {}
        }
    end
    
    -- Initialize default settings for each tool
    for toolID, toolInfo in pairs(self.availableTools) do
        if not VUI.defaults.profile.modules.tools.toolSettings[toolID] then
            VUI.defaults.profile.modules.tools.toolSettings[toolID] = {
                enabled = toolInfo.enabled or true,
                shortcut = toolInfo.shortcut or "",
                -- Add any tool-specific settings here as needed
            }
        end
    end
end

-- Build the configuration UI based on available tools
function Tools:BuildConfig()
    local config = self:GetConfig()
    
    -- Add each tool to the options
    local toolOrder = 10
    for toolID, toolInfo in pairs(self.availableTools) do
        local optionName = toolID .. "Group"
        
        config.options.args[optionName] = {
            type = "group",
            name = toolInfo.name,
            desc = toolInfo.description,
            order = toolInfo.order or toolOrder,
            args = {
                enabled = {
                    type = "toggle",
                    name = "Enable " .. toolInfo.name,
                    desc = "Enable or disable this tool",
                    order = 1,
                    width = "full",
                    get = function() 
                        return VUI.db.profile.modules.tools.toolSettings[toolID].enabled 
                    end,
                    set = function(_, val) 
                        VUI.db.profile.modules.tools.toolSettings[toolID].enabled = val
                        -- Refresh the tool if needed
                        if val and self[toolID .. "Initialize"] then
                            self[toolID .. "Initialize"]()
                        elseif not val and self[toolID .. "Disable"] then
                            self[toolID .. "Disable"]()
                        end
                    end
                },
                shortcutHeader = {
                    type = "header",
                    name = "Shortcut",
                    order = 2,
                },
                shortcut = {
                    type = "input",
                    name = "Keyboard Shortcut",
                    desc = "Set a keyboard shortcut for this tool (e.g., ALT-R)",
                    order = 3,
                    width = "full",
                    get = function() 
                        return VUI.db.profile.modules.tools.toolSettings[toolID].shortcut 
                    end,
                    set = function(_, val) 
                        VUI.db.profile.modules.tools.toolSettings[toolID].shortcut = val
                        -- Update keyboard bindings if needed
                        if self[toolID .. "UpdateBindings"] then
                            self[toolID .. "UpdateBindings"](val)
                        end
                    end
                },
                -- Each tool can add its own specific options here
            }
        }
        
        -- Add tool-specific config options if they exist
        if self[toolID .. "Config"] then
            local toolSpecificConfig = self[toolID .. "Config"]()
            for k, v in pairs(toolSpecificConfig) do
                config.options.args[optionName].args[k] = v
            end
        end
        
        toolOrder = toolOrder + 10
    end
    
    return config
end

-- Main initialization for all tools
function Tools:InitializeTools()
    if not VUI.db.profile.modules.tools.enabled then
        return
    end
    
    -- Initialize each enabled tool
    for toolID, _ in pairs(self.availableTools) do
        if VUI.db.profile.modules.tools.toolSettings[toolID] and 
           VUI.db.profile.modules.tools.toolSettings[toolID].enabled and
           self[toolID .. "Initialize"] then
            self[toolID .. "Initialize"]()
        end
    end
end

-- Create main tools panel
function Tools:CreateToolsPanel()
    -- Create the main panel frame
    local panel = CreateFrame("Frame", "VUIToolsPanel", UIParent)
    panel:SetSize(300, 400)
    panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    panel:SetFrameStrata("HIGH")
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel:Hide()
    
    -- Apply themed backdrop
    panel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    
    -- Apply theme colors
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    local backdropColor = {r = 0.04, g = 0.04, b = 0.1, a = 0.9} -- Default Thunder Storm
    local borderColor = {r = 0.05, g = 0.62, b = 0.9, a = 1} -- Electric blue
    
    if theme == "phoenixflame" then
        backdropColor = {r = 0.1, g = 0.04, b = 0.02, a = 0.9} -- Dark red/brown
        borderColor = {r = 0.9, g = 0.3, b = 0.05, a = 1} -- Fiery orange
    elseif theme == "arcanemystic" then
        backdropColor = {r = 0.1, g = 0.04, b = 0.18, a = 0.9} -- Deep purple
        borderColor = {r = 0.61, g = 0.05, b = 0.9, a = 1} -- Violet
    elseif theme == "felenergy" then
        backdropColor = {r = 0.04, g = 0.1, b = 0.04, a = 0.9} -- Dark green
        borderColor = {r = 0.1, g = 0.9, b = 0.1, a = 1} -- Fel green
    end
    
    panel:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a)
    panel:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
    
    -- Title
    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOP", panel, "TOP", 0, -10)
    panel.title:SetText("VUI Tools")
    
    -- Close button
    panel.closeButton = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    panel.closeButton:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, 0)
    panel.closeButton:SetScript("OnClick", function() panel:Hide() end)
    
    -- Tools container (scrollable)
    panel.scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    panel.scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -40)
    panel.scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -30, 10)
    
    panel.scrollChild = CreateFrame("Frame")
    panel.scrollFrame:SetScrollChild(panel.scrollChild)
    panel.scrollChild:SetWidth(panel.scrollFrame:GetWidth())
    panel.scrollChild:SetHeight(1) -- Will be adjusted as tools are added
    
    -- Store the panel in the module
    self.toolsPanel = panel
    
    return panel
end
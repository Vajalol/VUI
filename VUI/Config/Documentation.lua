-- VUI Documentation Generator
-- Provides automatic in-game documentation for all VUI modules

local AddonName, VUI = ...

local Documentation = VUI:NewModule("Documentation")

-- List of documentation sections
local docSections = {
    {
        title = "Getting Started with VUI",
        text = [[
VUI is a comprehensive addon suite that enhances the World of Warcraft user interface.
It combines features from multiple popular addons into a single, unified package.

|cFFFFD100How to use VUI:|r
1. Open the configuration panel with |cFF00AAFF/vui|r
2. Browse through the available modules in the left panel
3. Configure each module to suit your preferences
4. Click "Save & Reload" to apply your changes

|cFFFFD100Having trouble?|r
- Reset a specific module's settings from its config panel
- Use the "Reset All Settings" button for a fresh start
- Join our Discord community for support
]]
    },
    {
        title = "Core Addon Modules",
        text = [[
VUI integrates the following core addon modules:

|cFFFFD100VUI Buffs:|r Enhanced buff/debuff display
|cFFFFD100VUI AnyFrame:|r Move and resize default UI frames
|cFFFFD100VUI Keystones:|r Enhanced Mythic+ keystone interface
|cFFFFD100VUI CC:|r Cooldown text on abilities and items
|cFFFFD100VUI CD:|r Track party member cooldowns
|cFFFFD100VUI IDs:|r Show spell and item IDs in tooltips
|cFFFFD100VUI Gfinder:|r Enhanced premade group finder
|cFFFFD100VUI TGCD:|r Track recently used abilities
|cFFFFD100VUI Auctionator:|r Enhanced auction house interface
|cFFFFD100VUI Notifications:|r Custom spell and event alerts
]]
    },
    {
        title = "WeakAura Modules",
        text = [[
VUI includes these WeakAura-inspired modules:

|cFFFFD100VUI Scrolling Text:|r Combat text enhancements
|cFFFFD100VUI Enhanced Player Frame:|r Customized player unit frame
|cFFFFD100VUI Consumables:|r Track consumable buffs
|cFFFFD100VUI Position of Power:|r Track position-based buffs
|cFFFFD100VUI Missing Raid Buffs:|r Monitor missing buffs in groups
|cFFFFD100VUI Mouse Fire Trail:|r Visual trailing effect on mouse cursor
|cFFFFD100VUI Healer Mana:|r Monitor healer mana in groups/raids
]]
    },
    {
        title = "Special Features",
        text = [[
VUI includes these special features:

|cFFFFD100VUI Plater:|r Enhanced nameplate system based on Whiiskeyz Plater profile

|cFFFFD100Animation System:|r
VUI includes a smooth animation system for transitions between UI states. This provides
a more polished feel to the addon and reduces jarring visibility changes.

|cFFFFD100Profile System:|r
All your settings are saved in profiles that can be:
- Exported and shared with others
- Reset individually by module
- Applied to all your characters
]]
    },
    {
        title = "Keyboard Shortcuts",
        text = [[
|cFFFFD100General Shortcuts:|r
/vui - Open the configuration panel
/vui reset - Reset all settings
/vui profile - Manage profiles

|cFFFFD100Module-Specific Commands:|r
/vui module NAME - Open configuration for a specific module
/vui toggle NAME - Toggle a specific module on/off
]]
    },
}

-- Function to generate in-game documentation
function Documentation:GenerateDocumentation(parent)
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(parent:GetWidth() - 30, parent:GetHeight() - 40)
    scrollFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 15, -15)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetWidth() - 30, 100) -- Height will be adjusted
    scrollFrame:SetScrollChild(content)
    
    local totalHeight = 10
    
    -- Create section headers and text
    for i, section in ipairs(docSections) do
        -- Header
        local header = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        header:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -totalHeight)
        header:SetText(section.title)
        header:SetTextColor(1, 0.82, 0, 1) -- Gold color
        totalHeight = totalHeight + header:GetHeight() + 10
        
        -- Text
        local text = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -totalHeight)
        text:SetWidth(scrollFrame:GetWidth() - 30)
        text:SetJustifyH("LEFT")
        text:SetText(section.text)
        text:SetSpacing(2)
        totalHeight = totalHeight + text:GetHeight() + 20
    end
    
    -- Adjust content height to fit all sections
    content:SetHeight(totalHeight)
    
    return scrollFrame
end

-- Add documentation to the FAQ panel
function Documentation:OnInitialize()
    -- We'll hook into the FAQ panel when it's created
    hooksecurefunc(VUI:GetModule("Config.Layout.FAQ"), "GetLayout", function(self)
        if self.layout and self.layout.children and not self.docAdded then
            -- Add our documentation
            local panel = CreateFrame("Frame")
            self:GenerateDocumentation(panel)
            table.insert(self.layout.children, {
                type = "panel",
                size = {
                    width = 480,
                    height = 370
                },
                children = {
                    {
                        type = "frame",
                        size = {
                            width = 480,
                            height = 370
                        },
                        label = "Documentation",
                        object = panel
                    }
                }
            })
            self.docAdded = true
        end
    end)
end

-- Command to show documentation
function Documentation:ShowDocumentation()
    -- Open VUI config to the FAQ tab
    VUI:Config()
    
    -- TODO: Switch to the FAQ tab
end

-- Register slash command for documentation
SLASH_VUIDOCS1 = "/vuidocs"
SlashCmdList["VUIDOCS"] = function(msg)
    Documentation:ShowDocumentation()
end
-- VUI Skins Module - Bags Skinning
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local Skins = VUI.skins

-- Register the skin module
local BagsSkin = Skins:RegisterSkin("Bags")

-- Helper function to style bag backgrounds
local function StyleBagBackground(container)
    if not container or not container.Bg then return end
    
    container.Bg.TopSection:SetVertexColor(unpack(Skins:GetBackdropColor(0.1)))
    container.Bg.BottomEdge:SetVertexColor(unpack(Skins:GetBackdropColor(0.1)))
    container.Bg.BottomLeft:SetVertexColor(0, 0, 0, 0.78)
    container.Bg.BottomRight:SetVertexColor(0, 0, 0, 0.78)
end

-- Helper function to style nine slice elements
local function StyleNineSlice(container)
    if not container or not container.NineSlice then return end
    
    local nineSlice = {
        "BottomEdge",
        "BottomLeftCorner",
        "BottomRightCorner",
        "Center",
        "LeftEdge",
        "RightEdge",
        "TopEdge",
        "TopLeftCorner",
        "TopRightCorner"
    }

    container.NineSlice:SetVertexColor(unpack(Skins:GetBorderColor(1)))

    for _, ns in pairs(nineSlice) do
        if container.NineSlice[ns] then
            container.NineSlice[ns]:SetVertexColor(unpack(Skins:GetBorderColor(0.1)))
        end
    end
end

-- Function to skin combined bags
local function SkinCombinedBags()
    local container = ContainerFrameCombinedBags
    if not container then return end
    
    StyleBagBackground(container)
    StyleNineSlice(container)
    
    if container.MoneyFrame and container.MoneyFrame.Border then
        container.MoneyFrame.Border.Left:SetVertexColor(unpack(Skins:GetBackdropColor(0.1)))
        container.MoneyFrame.Border.Middle:SetVertexColor(unpack(Skins:GetBackdropColor(0.1)))
        container.MoneyFrame.Border.Right:SetVertexColor(unpack(Skins:GetBackdropColor(0.1)))
    end

    -- Hook to style item buttons
    hooksecurefunc(ContainerFrameCombinedBags, "Update", function(self)
        for button, _ in self.itemButtonPool:EnumerateActive() do
            if button.NormalTexture then
                button.NormalTexture:SetVertexColor(unpack(Skins:GetBackdropColor(0.15)))
            end
        end
    end)
end

-- Function to skin default bags
local function SkinDefaultBags()
    for i = 1, 13 do
        local container = _G["ContainerFrame" .. i]
        if not container then break end

        StyleNineSlice(container)
        StyleBagBackground(container)

        -- Hook to style item buttons
        hooksecurefunc(container, "Update", function(self)
            for button, _ in self.itemButtonPool:EnumerateActive() do
                if button.NormalTexture then
                    button.NormalTexture:SetVertexColor(unpack(Skins:GetBackdropColor(0.15)))
                end
            end
        end)
    end

    -- Style money frame borders
    if ContainerFrame1MoneyFrame and ContainerFrame1MoneyFrame.Border then
        ContainerFrame1MoneyFrame.Border.Left:SetVertexColor(unpack(Skins:GetBackdropColor(0.1)))
        ContainerFrame1MoneyFrame.Border.Middle:SetVertexColor(unpack(Skins:GetBackdropColor(0.1)))
        ContainerFrame1MoneyFrame.Border.Right:SetVertexColor(unpack(Skins:GetBackdropColor(0.1)))
    end

    -- Style backpack token frame borders
    if BackpackTokenFrame and BackpackTokenFrame.Border then
        BackpackTokenFrame.Border.Left:SetVertexColor(unpack(Skins:GetBackdropColor(0.1)))
        BackpackTokenFrame.Border.Middle:SetVertexColor(unpack(Skins:GetBackdropColor(0.1)))
        BackpackTokenFrame.Border.Right:SetVertexColor(unpack(Skins:GetBackdropColor(0.1)))
    end
end

function BagsSkin:OnEnable()
    if not Skins.settings.skins.blizzard.bags then return end
    
    SkinCombinedBags()
    SkinDefaultBags()
end
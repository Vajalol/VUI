local Module = VUI:NewModule("Skins.Bags");

function Module:OnEnable()

    function VUICombinedBags()
        local container = ContainerFrameCombinedBags
        VUIStyleBG(container)
        VUIStyleNineSlice(container)
        container.MoneyFrame.Border.Left:SetVertexColor(unpack(VUI:Color(0.1)))
        container.MoneyFrame.Border.Middle:SetVertexColor(unpack(VUI:Color(0.1)))
        container.MoneyFrame.Border.Right:SetVertexColor(unpack(VUI:Color(0.1)))

        hooksecurefunc(ContainerFrameCombinedBags, "Update", function(self)
            for button, _ in self.itemButtonPool:EnumerateActive() do
                button.NormalTexture:SetVertexColor(unpack(VUI:Color(0.15)))
            end
        end)
    end

    function VUIDefaultBags()
        for i = 1, 13 do
            local container = _G["ContainerFrame" .. i]

            VUIStyleNineSlice(container)
            VUIStyleBG(container)

            -- Bag Slots
            local bagSlots = _G["ContainerFrame" .. i]
            hooksecurefunc(bagSlots, "Update", function(self)
                for button, _ in self.itemButtonPool:EnumerateActive() do
                    button.NormalTexture:SetVertexColor(unpack(VUI:Color(0.15)))
                end
            end)
            --print(bagSlots.NormalTexture)
        end

        ContainerFrame1MoneyFrame.Border.Left:SetVertexColor(unpack(VUI:Color(0.1)))
        ContainerFrame1MoneyFrame.Border.Middle:SetVertexColor(unpack(VUI:Color(0.1)))
        ContainerFrame1MoneyFrame.Border.Right:SetVertexColor(unpack(VUI:Color(0.1)))

        BackpackTokenFrame.Border.Left:SetVertexColor(unpack(VUI:Color(0.1)))
        BackpackTokenFrame.Border.Middle:SetVertexColor(unpack(VUI:Color(0.1)))
        BackpackTokenFrame.Border.Right:SetVertexColor(unpack(VUI:Color(0.1)))
    end

    function VUIStyleBG(container)
        container.Bg.TopSection:SetVertexColor(unpack(VUI:Color(0.1)))
        container.Bg.BottomEdge:SetVertexColor(unpack(VUI:Color(0.1)))
        container.Bg.BottomLeft:SetVertexColor(0, 0, 0, 0.78)
        container.Bg.BottomRight:SetVertexColor(0, 0, 0, 0.78)
    end

    function VUIStyleNineSlice(container)
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

        container.NineSlice:SetVertexColor(unpack(VUI:Color(1)))

        for _, ns in pairs(nineSlice) do
            container.NineSlice[ns]:SetVertexColor(unpack(VUI:Color(0.1)))
        end
    end

    if (VUI:Color()) then
        VUICombinedBags()
        VUIDefaultBags()
    end
end

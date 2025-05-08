local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Define local constants
local MINIMAP_ICON_POSITION = "minimapPosition"
local MINIMAP_ICON_PATH = "Interface\\AddOns\\VUI\\Media\\modules\\VUIAuctionator\\MinimapIcon"

-- Minimap icon data
local minimapIconLDB = nil

function VUIAuctionatorMinimapIconFrame_OnLoad(self)
  self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function VUIAuctionatorMinimapIconFrame_OnEvent(self, event, ...)
  if event == "PLAYER_ENTERING_WORLD" then
    if LibStub and LibStub:GetLibrary("LibDataBroker-1.1", true) and LibStub:GetLibrary("LibDBIcon-1.0", true) then
      local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
      local DBIcon = LibStub:GetLibrary("LibDBIcon-1.0")
      
      -- Create LibDataBroker object
      minimapIconLDB = LDB:NewDataObject("VUIAuctionator", {
        type = "launcher",
        text = "VUI Auctionator",
        icon = MINIMAP_ICON_PATH,
        OnClick = function(self, button)
          if button == "LeftButton" then
            -- Open the main AH panel or show Auctionator settings
            if AuctionHouseFrame and AuctionHouseFrame:IsShown() then
              -- Toggle tabs or show Auctionator frame
              if Auctionator.Tabs and Auctionator.Tabs.State then
                local tabButton = Auctionator.Tabs.State.knownTabs[1]
                if tabButton then
                  tabButton:Click()
                end
              end
            else
              -- Try to open AH if we're near an auctioneer
              if AuctionHouseFrame then
                AuctionHouseFrame:Show()
              else
                if C_AuctionHouse and C_AuctionHouse.IsAuctionHouseOpen then
                  if not C_AuctionHouse.IsAuctionHouseOpen() then
                    VUI:Print(VUI.Auctionator.Locales.Translate("MINIMAP_ICON_NOT_NEAR_AUCTIONEER"))
                  end
                end
              end
            end
          elseif button == "RightButton" then
            -- Open config
            if VUI.Config then
              VUI.Config:Open("VUIAuctionator")
            end
          end
        end,
        OnTooltipShow = function(tooltip)
          tooltip:AddLine("VUI Auctionator")
          tooltip:AddLine(" ")
          tooltip:AddLine(VUI.Auctionator.Locales.Translate("MINIMAP_ICON_LEFT_CLICK"))
          tooltip:AddLine(VUI.Auctionator.Locales.Translate("MINIMAP_ICON_RIGHT_CLICK"))
        end,
      })
      
      -- Setup the minimap icon
      DBIcon:Register("VUIAuctionator", minimapIconLDB, VUI.db.auctionator.minimap)
      
      -- Add a function to toggle minimap visibility
      Auctionator.Config.Options.ToggleMinimapIcon = function()
        VUI.db.auctionator.minimap.hide = not VUI.db.auctionator.minimap.hide
        
        if VUI.db.auctionator.minimap.hide then
          DBIcon:Hide("VUIAuctionator")
        else
          DBIcon:Show("VUIAuctionator")
        end
      end
    end
    
    -- Only run this once
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
  end
end
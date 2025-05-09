local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Create the MainFrame controller
Auctionator.UI.MainFrame = {}

-- Initialize the main frame
function Auctionator.UI.MainFrame:Initialize()
  -- Create the main frame
  self.frame = CreateFrame("Frame", "VUIAuctionatorMainFrame", nil)
  self.frame:SetSize(600, 520)
  self.frame:SetPoint("TOPLEFT", 0, 0)
  self.frame:Hide()
  
  -- Create tab system
  self:CreateTabSystem()
  
  -- Initialize all components
  self:InitializeComponents()
  
  -- Register events
  self:RegisterEvents()
end

-- Create the tab system
function Auctionator.UI.MainFrame:CreateTabSystem()
  -- Tab data
  self.tabs = {
    {name = Auctionator.L.BUY, component = "BrowsePanel"},
    {name = Auctionator.L.SELL, component = "SellingPanel"},
    {name = Auctionator.L.CANCEL, component = "CancellingPanel"},
    {name = Auctionator.L.FAVORITES, component = "ShoppingListPanel"},
    {name = Auctionator.L.HISTORY, component = "HistoryPanel"}
  }
  
  -- Create tab buttons
  self.tabButtons = {}
  
  for i, tabData in ipairs(self.tabs) do
    local tab = CreateFrame("Button", self.frame:GetName() .. "Tab" .. i, self.frame, "VUIAuctionatorTabButtonTemplate")
    tab:SetID(i)
    tab:SetText(tabData.name)
    
    -- Position the tabs
    if i == 1 then
      tab:SetPoint("TOPLEFT", self.frame, "BOTTOMLEFT", 10, 2)
    else
      tab:SetPoint("LEFT", self.tabButtons[i-1], "RIGHT", -4, 0)
    end
    
    -- Tab selection handler
    tab:SetScript("OnClick", function()
      self:SelectTab(i)
    end)
    
    -- Store tab button
    self.tabButtons[i] = tab
  end
end

-- Initialize all UI components
function Auctionator.UI.MainFrame:InitializeComponents()
  -- Initialize each component
  for _, componentName in ipairs({"BrowsePanel", "SellingPanel", "CancellingPanel", "ShoppingListPanel", "HistoryPanel"}) do
    if Auctionator.UI[componentName] and Auctionator.UI[componentName].Initialize then
      Auctionator.UI[componentName]:Initialize()
    end
  end
  
  -- Initially select the first tab
  self:SelectTab(1)
end

-- Register for events
function Auctionator.UI.MainFrame:RegisterEvents()
  -- AH open/close events
  Auctionator.EventBus:Register({}, Auctionator.AuctionHouse.Events.AUCTION_HOUSE_SHOW, function()
    self:ShowAuctionator()
  end)
  
  Auctionator.EventBus:Register({}, Auctionator.AuctionHouse.Events.AUCTION_HOUSE_CLOSE, function()
    self:HideAuctionator()
  end)
  
  -- Tab selection events
  Auctionator.EventBus:Register({}, "VUIAUCTIONATOR_SELECT_TAB", function(_, tabIndex)
    self:SelectTab(tabIndex)
  end)
  
  -- Register for auction scans
  Auctionator.EventBus:Register({}, Auctionator.Search.Events.SEARCH_COMPLETE, function()
    -- Switch to Browse tab to show results
    self:SelectTab(1)
  end)
end

-- Select a tab
function Auctionator.UI.MainFrame:SelectTab(tabIndex)
  -- Hide all components
  for i, tabData in ipairs(self.tabs) do
    local component = Auctionator.UI[tabData.component]
    
    if component and component.Hide then
      component:Hide()
    end
    
    -- Update tab appearance
    for _, region in ipairs({self.tabButtons[i]:GetRegions()}) do
      if region:GetName() and region:GetName():find("Disabled") then
        region:Hide()
      end
    end
    
    self.tabButtons[i]:SetNormalFontObject("GameFontNormalSmall")
  end
  
  -- Show selected component
  local selectedComponent = Auctionator.UI[self.tabs[tabIndex].component]
  
  if selectedComponent and selectedComponent.Show then
    selectedComponent:Show()
  end
  
  -- Update selected tab appearance
  for _, region in ipairs({self.tabButtons[tabIndex]:GetRegions()}) do
    if region:GetName() and region:GetName():find("Disabled") then
      region:Show()
    end
  end
  
  self.tabButtons[tabIndex]:SetNormalFontObject("GameFontHighlightSmall")
  
  -- Store current tab
  self.currentTab = tabIndex
end

-- Show Auctionator UI
function Auctionator.UI.MainFrame:ShowAuctionator()
  self.frame:Show()
  
  -- Position the UI next to the Auction House
  self:PositionFrame()
  
  -- Show the current tab
  self:SelectTab(self.currentTab or 1)
end

-- Hide Auctionator UI
function Auctionator.UI.MainFrame:HideAuctionator()
  self.frame:Hide()
end

-- Position the frame relative to the Auction House frame
function Auctionator.UI.MainFrame:PositionFrame()
  if Auctionator.Constants.Features.IsModernAH() then
    -- Retail AH
    if AuctionHouseFrame then
      self.frame:ClearAllPoints()
      self.frame:SetPoint("TOPLEFT", AuctionHouseFrame, "TOPRIGHT", 5, 0)
    end
  else
    -- Classic AH
    if AuctionFrame then
      self.frame:ClearAllPoints()
      self.frame:SetPoint("TOPLEFT", AuctionFrame, "TOPRIGHT", 5, 0)
    end
  end
end

-- Hook into existing AH to add our tabs
function Auctionator.UI.MainFrame:HookIntoAuctionHouse()
  -- If integration already in place, skip
  if self.auctionHouseHooked then
    return
  end
  
  if Auctionator.Constants.Features.IsModernAH() then
    -- Hook into retail AH
    self:HookRetailAuctionHouse()
  else
    -- Hook into classic AH
    self:HookClassicAuctionHouse()
  end
  
  self.auctionHouseHooked = true
end

-- Hook into retail Auction House
function Auctionator.UI.MainFrame:HookRetailAuctionHouse()
  -- This would be implemented with specific hooks for the retail AH
  -- For now, we'll use a standalone UI approach
end

-- Hook into classic Auction House
function Auctionator.UI.MainFrame:HookClassicAuctionHouse()
  -- This would be implemented with specific hooks for the classic AH
  -- For now, we'll use a standalone UI approach
end
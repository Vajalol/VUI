local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Define ResultsListing mixin
AuctionatorResultsListingMixin = {}

function AuctionatorResultsListingMixin:OnLoad()
  -- Initialize properties
  self.isInitialized = false
  self.results = {}
  self.rowTemplate = "AuctionatorResultsListingRowTemplate"
  self.rowHeight = 20
  self.titleRowHeight = 24
  self.visibleRowCount = 0
  self.currentOffset = 0
  self.columnTemplates = {}
  self.columns = {}
  
  -- Set up header
  self.HeaderContainer = CreateFrame("Frame", nil, self)
  self.HeaderContainer:SetPoint("TOPLEFT")
  self.HeaderContainer:SetPoint("TOPRIGHT")
  self.HeaderContainer:SetHeight(self.titleRowHeight)
  
  -- Create background and border
  self.Background = self:CreateTexture(nil, "BACKGROUND")
  self.Background:SetAllPoints()
  self.Background:SetColorTexture(0, 0, 0, 0.4)
  
  -- Apply VUI theme if available
  if VUI.ApplyThemeColor then
    VUI:ApplyThemeColor(self.Background, 0.2)
  end
  
  -- Set up components
  self.ScrollFrame = CreateFrame("ScrollFrame", nil, self, "AuctionatorResultsScrollFrameTemplate")
  self.ScrollFrame:SetPoint("TOPLEFT", self.HeaderContainer, "BOTTOMLEFT", 0, 0)
  self.ScrollFrame:SetPoint("BOTTOMRIGHT", 0, 0)
  self.ScrollFrame.resultsListing = self
  
  -- Set up scroll bar
  self.ScrollBar = CreateFrame("Slider", nil, self.ScrollFrame, "AuctionatorResultsScrollBarTemplate")
  self.ScrollBar:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -self.titleRowHeight)
  self.ScrollBar:SetPoint("BOTTOMRIGHT")
  self.ScrollBar.resultsListing = self
  
  -- Connect scrolling components
  self.ScrollFrame.ScrollBar = self.ScrollBar
  
  -- Create the scrolling table
  self:CreateDataProvider()
  self:SetMoreResultsAvailable(false)
end

function AuctionatorResultsListingMixin:Init(resultsEntry)
  if not self.isInitialized then
    -- Initialize with the provided schema
    self.columnTemplates = resultsEntry.columnTemplates
    self.rowTemplate = resultsEntry.rowTemplate or self.rowTemplate
    self.rowHeight = resultsEntry.rowHeight or self.rowHeight
    self.titleRowHeight = resultsEntry.titleRowHeight or self.titleRowHeight
    self.tableBuilder = resultsEntry.tableBuilder
    self.selectionCallback = resultsEntry.selectionCallback
    self.noResultsString = resultsEntry.noResultsString
    self.onMoreButtonClicked = resultsEntry.onMoreButtonClicked
    
    -- Create columns
    for i, template in ipairs(self.columnTemplates) do
      self:AddColumn(i, template)
    end
    
    -- Update size and scrolling
    self:UpdateSize()
    self.ScrollFrame:SetVerticalScroll(0)
    self.ScrollBar:SetValue(0)
    
    -- Set initialized flag
    self.isInitialized = true
  end
end

function AuctionatorResultsListingMixin:AddColumn(index, template)
  local column = CreateFrame("Button", nil, self.HeaderContainer, template.headerTemplate)
  column:SetPoint("TOPLEFT", (index - 1) * template.width, 0)
  column:SetSize(template.width, self.titleRowHeight)
  column.resultsListing = self
  column.columnIndex = index
  column.shouldShow = true
  
  -- Set up header label if exists
  if column.Text then
    column.Text:SetText(template.headerText)
  end
  
  -- Set tooltip if provided
  if template.headerTooltip then
    column.tooltipText = template.headerTooltip
  end
  
  -- Handle sorting if applicable
  if template.sortable then
    column:SetScript("OnClick", function()
      self:SortByColumn(index)
    end)
  end
  
  -- Store column in our table
  self.columns[index] = column
  
  return column
end

function AuctionatorResultsListingMixin:CreateDataProvider()
  self.dataProvider = CreateFrame("Frame", nil, self)
  self.dataProvider.rows = {}
  self.dataProvider.resultsListing = self
  
  -- Create the "More Results" button
  self.dataProvider.LoadAllResultsButton = CreateFrame("Button", nil, self.ScrollFrame.scrollChild, "AuctionatorLoadAllResultsButtonTemplate")
  self.dataProvider.LoadAllResultsButton:SetPoint("TOP", 0, 0)
  self.dataProvider.LoadAllResultsButton.resultsListing = self
  self.dataProvider.LoadAllResultsButton:SetScript("OnClick", function()
    if self.onMoreButtonClicked then
      self.onMoreButtonClicked()
    end
  end)
  self.dataProvider.LoadAllResultsButton:Hide()
  
  -- Create the "No Results" text
  self.dataProvider.NoResultsText = self.ScrollFrame.scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  self.dataProvider.NoResultsText:SetPoint("TOP", 0, -self.rowHeight / 2)
  self.dataProvider.NoResultsText:SetText(self.noResultsString or AUCTIONATOR_L_NO_RESULTS)
  self.dataProvider.NoResultsText:Hide()
end

function AuctionatorResultsListingMixin:SetMoreResultsAvailable(available)
  self.moreResultsAvailable = available
  self:UpdateMoreResultsButton()
end

function AuctionatorResultsListingMixin:UpdateMoreResultsButton()
  if self.moreResultsAvailable and #self.results > 0 then
    self.dataProvider.LoadAllResultsButton:Show()
  else
    self.dataProvider.LoadAllResultsButton:Hide()
  end
end

function AuctionatorResultsListingMixin:UpdateNoResultsText()
  if #self.results == 0 then
    self.dataProvider.NoResultsText:Show()
  else
    self.dataProvider.NoResultsText:Hide()
  end
end

function AuctionatorResultsListingMixin:UpdateVisibleRows()
  -- Calculate how many rows should be visible
  local frameHeight = self:GetHeight() - self.titleRowHeight
  self.visibleRowCount = math.floor(frameHeight / self.rowHeight)
  
  -- Create or show rows as needed
  for i = 1, self.visibleRowCount do
    if not self.dataProvider.rows[i] then
      -- Create a new row
      local row = CreateFrame("Button", nil, self.ScrollFrame.scrollChild, self.rowTemplate)
      row:SetSize(self:GetWidth() - 20, self.rowHeight)  -- 20 for scrollbar
      row:SetPoint("TOPLEFT", 0, -(i - 1) * self.rowHeight)
      row:SetPoint("TOPRIGHT", -20, -(i - 1) * self.rowHeight)
      row.resultsListing = self
      row.rowIndex = i
      
      -- Add callback
      row:SetScript("OnClick", function() 
        self:RowClicked(row)
      end)
      
      -- Save to the row list
      self.dataProvider.rows[i] = row
    else
      -- Just show existing row
      self.dataProvider.rows[i]:Show()
    end
  end
  
  -- Hide extra rows
  for i = self.visibleRowCount + 1, #self.dataProvider.rows do
    self.dataProvider.rows[i]:Hide()
  end
  
  -- Update row data
  self:UpdateRowData()
end

function AuctionatorResultsListingMixin:UpdateRowData()
  -- Position the Load More Results button
  self.dataProvider.LoadAllResultsButton:SetPoint("TOP", 0, -#self.results * self.rowHeight)
  
  -- Position No Results text
  self.dataProvider.NoResultsText:SetPoint("TOP", 0, -self.rowHeight / 2)
  
  -- Update each visible row
  for i = 1, self.visibleRowCount do
    local row = self.dataProvider.rows[i]
    local dataIndex = i + self.currentOffset
    
    if dataIndex <= #self.results then
      row:Show()
      
      -- Get the data and update row
      local rowData = self.results[dataIndex]
      if self.tableBuilder then
        self.tableBuilder(row, rowData, dataIndex)
      end
      
      -- Update selection state
      row.selected = (self.selected and rowData == self.selected)
      if row.selected then
        row:LockHighlight()
      else
        row:UnlockHighlight()
      end
    else
      -- No data for this row
      row:Hide()
    end
  end
end

function AuctionatorResultsListingMixin:RowClicked(row)
  local dataIndex = row.rowIndex + self.currentOffset
  if dataIndex <= #self.results then
    local rowData = self.results[dataIndex]
    self:SetSelected(rowData)
  end
end

function AuctionatorResultsListingMixin:SetSelected(rowData)
  self.selected = rowData
  
  -- Update visuals
  self:UpdateRowData()
  
  -- Trigger callback
  if self.selectionCallback then
    self.selectionCallback(rowData)
  end
end

function AuctionatorResultsListingMixin:GetResults()
  return self.results
end

function AuctionatorResultsListingMixin:SetResults(results)
  self.results = results or {}
  self.currentOffset = 0
  
  -- Update UI elements
  self:UpdateScrollBarSize()
  self:UpdateNoResultsText()
  self:UpdateRowData()
  
  -- Reset selection
  self.selected = nil
  
  -- Scroll to top
  self.ScrollFrame:SetVerticalScroll(0)
  self.ScrollBar:SetValue(0)
end

function AuctionatorResultsListingMixin:AddResults(newResults)
  -- Add new results
  for _, result in ipairs(newResults) do
    table.insert(self.results, result)
  end
  
  -- Update UI elements
  self:UpdateScrollBarSize()
  self:UpdateNoResultsText()
  self:UpdateRowData()
end

function AuctionatorResultsListingMixin:SortByColumn(columnIndex)
  -- Find column template
  local columnTemplate = self.columnTemplates[columnIndex]
  if not columnTemplate or not columnTemplate.sortable then
    return
  end
  
  -- Get column and reset others
  local column = self.columns[columnIndex]
  for _, otherColumn in pairs(self.columns) do
    if otherColumn ~= column and otherColumn.SortArrow then
      otherColumn.SortArrow:Hide()
      otherColumn.sortDirection = nil
    end
  end
  
  -- Toggle sort direction or set to ascending if first sort
  if not column.sortDirection then
    column.sortDirection = "asc"
  else
    column.sortDirection = column.sortDirection == "asc" and "desc" or "asc"
  end
  
  -- Sort the results
  if columnTemplate.sortFunction then
    table.sort(self.results, function(a, b)
      local result = columnTemplate.sortFunction(a, b)
      return column.sortDirection == "asc" and result or not result
    end)
    
    -- Update UI
    self:UpdateRowData()
  end
  
  -- Update sort arrow
  if column.SortArrow then
    column.SortArrow:Show()
    if column.sortDirection == "asc" then
      column.SortArrow:SetTexCoord(0, 1, 1, 0)
    else
      column.SortArrow:SetTexCoord(0, 1, 0, 1)
    end
  end
end

function AuctionatorResultsListingMixin:UpdateSize()
  -- Calculate content height and scrollable area
  local contentHeight = #self.results * self.rowHeight
  if self.moreResultsAvailable then
    contentHeight = contentHeight + 30  -- Height of the "Load More" button
  end
  
  -- Set scrollable content height
  self.ScrollFrame.scrollChild:SetHeight(math.max(contentHeight, self:GetHeight() - self.titleRowHeight))
  
  -- Update visible rows
  self:UpdateVisibleRows()
  
  -- Update the scroll bar
  self:UpdateScrollBarSize()
end

function AuctionatorResultsListingMixin:UpdateScrollBarSize()
  local contentHeight = #self.results * self.rowHeight
  if self.moreResultsAvailable then
    contentHeight = contentHeight + 30  -- Height of the "Load More" button
  end
  
  local frameHeight = self:GetHeight() - self.titleRowHeight
  
  -- Handle scroll thumb visibility and size
  if contentHeight > frameHeight then
    -- Content is larger than view, show scrollbar
    self.ScrollBar:SetMinMaxValues(0, contentHeight - frameHeight)
    self.ScrollBar:Enable()
    
    -- Calculate thumb size (proportional to visible area)
    local visiblePortion = frameHeight / contentHeight
    local thumbHeight = math.max(frameHeight * visiblePortion, 30)  -- Minimum thumb size
    self.ScrollBar.ThumbTexture:SetHeight(thumbHeight)
  else
    -- Everything fits, disable scrollbar
    self.ScrollBar:SetMinMaxValues(0, 0)
    self.ScrollBar:Disable()
  end
end

function AuctionatorResultsListingMixin:OnVerticalScroll(offset)
  -- Calculate new offset in rows
  self.currentOffset = math.floor(offset / self.rowHeight)
  
  -- Update row data with new offset
  self:UpdateRowData()
end 
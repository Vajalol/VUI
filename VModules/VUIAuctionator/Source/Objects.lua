local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Simple class system for VUIAuctionator
Auctionator.Objects = {}

-- Create a new class
function Auctionator.Objects.CreateClass(className)
  local class = {}
  class.__index = class
  class.__name = className or "AnonymousClass"
  
  -- Constructor method
  function class:Create(...)
    local obj = setmetatable({}, self)
    if obj.Initialize then
      obj:Initialize(...)
    end
    return obj
  end
  
  -- Static method to extend the class
  function class:Extend(subClassName)
    local subclass = setmetatable({}, self)
    subclass.__index = subclass
    subclass.__name = subClassName or (self.__name and (self.__name .. "Child") or "AnonymousSubclass")
    subclass.__super = self
    
    -- Override constructor to allow super calls
    function subclass:Create(...)
      local obj = setmetatable({}, self)
      if obj.Initialize then
        obj:Initialize(...)
      end
      return obj
    end
    
    return subclass
  end
  
  -- Method to call super methods
  function class:Super(methodName, ...)
    if self.__super and self.__super[methodName] then
      return self.__super[methodName](self, ...)
    end
    error("Super method '" .. methodName .. "' not found")
  end
  
  return class
end

-- Create a Frame class to simplify frame creation and handling
Auctionator.Objects.Frame = Auctionator.Objects.CreateClass("Frame")

function Auctionator.Objects.Frame:Initialize(name, parent, template)
  self.frame = CreateFrame("Frame", name, parent, template)
  
  -- Keep a reference to this object in the frame
  self.frame.object = self
  
  -- Default settings
  self:SetSize(200, 100)
  self:SetPoint("CENTER")
  
  -- Forward some common methods to the frame
  self.methods = {
    "SetScript", "GetScript", "HookScript", 
    "SetSize", "GetSize", "SetWidth", "SetHeight", "GetWidth", "GetHeight",
    "SetPoint", "GetPoint", "ClearAllPoints",
    "Show", "Hide", "IsShown", "IsVisible",
    "SetAlpha", "GetAlpha", "SetScale", "GetScale",
    "SetFrameStrata", "GetFrameStrata", "SetFrameLevel", "GetFrameLevel",
    "SetParent", "GetParent",
    "EnableMouse", "IsMouseEnabled", "SetMouseMotionEnabled", "IsMouseMotionEnabled",
    "SetMovable", "IsMovable", "SetResizable", "IsResizable",
    "RegisterEvent", "UnregisterEvent", "UnregisterAllEvents",
    "RegisterForDrag", "RegisterForClicks",
    "StartMoving", "StopMovingOrSizing"
  }
  
  -- Create forwarding methods
  for _, method in ipairs(self.methods) do
    self[method] = function(self, ...)
      return self.frame[method](self.frame, ...)
    end
  end
end

-- Get the underlying frame
function Auctionator.Objects.Frame:GetFrame()
  return self.frame
end

-- Set background color
function Auctionator.Objects.Frame:SetBackgroundColor(r, g, b, a)
  if not self.bg then
    self.bg = self.frame:CreateTexture(nil, "BACKGROUND")
    self.bg:SetAllPoints()
  end
  
  self.bg:SetColorTexture(r, g, b, a or 1)
end

-- Set border
function Auctionator.Objects.Frame:SetBorder(size, r, g, b, a)
  size = size or 1
  
  if not self.border then
    self.border = {}
    for i = 1, 4 do
      self.border[i] = self.frame:CreateTexture(nil, "BORDER")
    end
    
    -- Top
    self.border[1]:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
    self.border[1]:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", 0, 0)
    self.border[1]:SetHeight(size)
    
    -- Right
    self.border[2]:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", 0, 0)
    self.border[2]:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", 0, 0)
    self.border[2]:SetWidth(size)
    
    -- Bottom
    self.border[3]:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", 0, 0)
    self.border[3]:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", 0, 0)
    self.border[3]:SetHeight(size)
    
    -- Left
    self.border[4]:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
    self.border[4]:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", 0, 0)
    self.border[4]:SetWidth(size)
  end
  
  -- Set color
  for i = 1, 4 do
    self.border[i]:SetColorTexture(r, g, b, a or 1)
  end
end

-- Create a Button class
Auctionator.Objects.Button = Auctionator.Objects.Frame:Extend("Button")

function Auctionator.Objects.Button:Initialize(name, parent, template)
  -- Call super constructor with Button frame type
  self.frame = CreateFrame("Button", name, parent, template)
  self.frame.object = self
  
  -- Setup default button settings
  self:SetSize(120, 22)
  
  -- Forward methods
  self.methods = {
    "SetScript", "GetScript", "HookScript", 
    "SetSize", "GetSize", "SetWidth", "SetHeight", "GetWidth", "GetHeight",
    "SetPoint", "GetPoint", "ClearAllPoints",
    "Show", "Hide", "IsShown", "IsVisible",
    "SetAlpha", "GetAlpha", "SetScale", "GetScale",
    "SetFrameStrata", "GetFrameStrata", "SetFrameLevel", "GetFrameLevel",
    "SetParent", "GetParent",
    "EnableMouse", "IsMouseEnabled",
    "RegisterForClicks", "RegisterForDrag",
    "GetText", "SetText", "SetNormalTexture", "SetPushedTexture", "SetHighlightTexture", 
    "SetDisabledTexture", "Enable", "Disable", "IsEnabled", "Click"
  }
  
  -- Create forwarding methods
  for _, method in ipairs(self.methods) do
    self[method] = function(self, ...)
      return self.frame[method](self.frame, ...)
    end
  end
  
  -- Setup default textures and fonts
  if not template or not template:find("Template") then
    self:SetupDefaultButton()
  end
end

-- Setup default button appearance
function Auctionator.Objects.Button:SetupDefaultButton()
  -- Create text
  self.text = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  self.text:SetPoint("CENTER")
  
  -- Create textures
  self.frame:SetNormalTexture("Interface\\Buttons\\UI-Button-Up")
  self.frame:SetPushedTexture("Interface\\Buttons\\UI-Button-Down")
  self.frame:SetHighlightTexture("Interface\\Buttons\\UI-Button-Highlight")
  self.frame:SetDisabledTexture("Interface\\Buttons\\UI-Button-Disabled")
  
  -- Set text method
  self.SetText = function(self, text)
    self.text:SetText(text)
  end
  
  -- Add click sound
  self.frame:HookScript("OnClick", function()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
  end)
end

-- Create a basic EditBox class
Auctionator.Objects.EditBox = Auctionator.Objects.Frame:Extend("EditBox")

function Auctionator.Objects.EditBox:Initialize(name, parent, template)
  -- Call super constructor with EditBox frame type
  self.frame = CreateFrame("EditBox", name, parent, template)
  self.frame.object = self
  
  -- Setup default settings
  self:SetSize(120, 22)
  
  -- Forward methods
  self.methods = {
    "SetScript", "GetScript", "HookScript", 
    "SetSize", "GetSize", "SetWidth", "SetHeight", "GetWidth", "GetHeight",
    "SetPoint", "GetPoint", "ClearAllPoints",
    "Show", "Hide", "IsShown", "IsVisible",
    "SetAlpha", "GetAlpha", "SetScale", "GetScale",
    "SetFrameStrata", "GetFrameStrata", "SetFrameLevel", "GetFrameLevel",
    "SetParent", "GetParent",
    "EnableMouse", "IsMouseEnabled",
    "GetText", "SetText", "SetCursorPosition", "ClearFocus", "SetFocus",
    "SetAutoFocus", "HasFocus", "SetNumeric", "SetMaxLetters", "GetMaxLetters",
    "SetMultiLine", "IsMultiLine", "EnableKeyboard", "IsKeyboardEnabled",
    "Enable", "Disable", "IsEnabled", "HighlightText", "SetTextInsets",
    "SetPassword", "SetBlinkSpeed"
  }
  
  -- Create forwarding methods
  for _, method in ipairs(self.methods) do
    self[method] = function(self, ...)
      return self.frame[method](self.frame, ...)
    end
  end
  
  -- Setup default appearance if not using a template
  if not template or not template:find("Template") then
    self:SetupDefaultEditBox()
  end
end

-- Setup default EditBox appearance
function Auctionator.Objects.EditBox:SetupDefaultEditBox()
  self.frame:SetFontObject("ChatFontNormal")
  self.frame:SetAutoFocus(false)
  self.frame:SetTextInsets(8, 8, 0, 0)
  
  -- Create background
  self.bg = CreateFrame("Frame", nil, self.frame)
  self.bg:SetPoint("TOPLEFT", -5, 0)
  self.bg:SetPoint("BOTTOMRIGHT", 5, 0)
  self.bg:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
  })
  self.bg:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
  self.bg:SetBackdropBorderColor(0.4, 0.4, 0.4)
  
  -- Scripts
  self.frame:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
  end)
  
  self.frame:SetScript("OnEnterPressed", function(self)
    self:ClearFocus()
  end)
end
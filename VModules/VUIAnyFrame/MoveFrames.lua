-- VUIAnyFrame - Frame Movement Handler
-- Use global reference instead of AceAddon-3.0 to fix load order issues
local VUIAnyFrame = _G["VUIAnyFrame"]
local L = VUIAnyFrame.L

-- List of frames that can be moved - directly from MoveAny
local MOVABLE_FRAMES = {"ChatConfigFrame", "CurrencyTransferMenu", "HeroTalentsSelectionDialog", "CurrencyTransferLog", "DelvesCompanionConfigurationFrame", "DelvesDifficultyPickerFrame", "ItemRefTooltip", "ReforgingFrameInvisibleButton", "ReforgingFrame", "WeakAurasOptions", "ProfessionsBookFrame", "PlayerSpellsFrame", "GroupLootHistoryFrame", "ModelPreviewFrame", "ScrappingMachineFrame", "TabardFrame", "PVPFrame", "ArchaeologyFrame", "QuestLogDetailFrame", "InspectRecipeFrame", "PVPParentFrame", "SettingsPanel", "SplashFrame", "InterfaceOptionsFrame", "QuickKeybindFrame", "VideoOptionsFrame", "KeyBindingFrame", "MacroFrame", "AddonList", "ContainerFrameCombinedBags", "LFGParentFrame", "CharacterFrame", "InspectFrame", "SpellBookFrame", "PlayerTalentFrame", "ClassTalentFrame", "FriendsFrame", "HelpFrame", "TradeFrame", "TradeSkillFrame", "CraftFrame", "QuestLogFrame", "ChallengesKeystoneFrame", "CovenantMissionFrame", "OrderHallMissionFrame", "PVPMatchScoreboard", "GossipFrame", "MerchantFrame", "PetStableFrame", "QuestFrame", "ClassTrainerFrame", "AchievementFrame", "PVEFrame", "EncounterJournal", "WeeklyRewardsFrame", "BankFrame", "WardrobeFrame", "DressUpFrame", "MailFrame", "OpenMailFrame", "AuctionHouseFrame", "AuctionFrame", "ProfessionsCustomerOrdersFrame", "AnimaDiversionFrame", "CovenantSanctumFrame", "SoulbindViewer", "GarrisonLandingPage", "PlayerChoiceFrame", "GenericPlayerChoiseTobbleButton", "WorldStateScoreFrame", "ItemTextFrame", "ExpansionLandingPage", "MajorFactionRenownFrame", "GenericTraitFrame", "FlightMapFrame", "TaxiFrame", "ItemUpgradeFrame", "ProfessionsFrame", "CommunitiesFrame", "CollectionsJournal", "CovenantRenownFrame", "ChallengesKeystoneFrame", "ScriptErrorsFrame", "CalendarFrame", "TimeManagerFrame", "GuildBankFrame", "ItemSocketingFrame", "BlackMarketFrame", "QuestLogPopupDetailFrame", "ItemInteractionFrame", "GarrisonCapacitiveDisplayFrame", "ChannelFrame", "WorldMapFrame", "GameMenuFrame", "PVPReadyDialog", "ReadyCheckFrame", "RolePollPopup", "StaticPopup1", "StaticPopup2"}
local IGNORE_CLAMP_FRAMES = {}

-- Local storage
local movedFrames = {}
local currentWindowName = nil
local prevMouseX = nil
local prevMouseY = nil
local updatingFrame = false
local frameSetPoints = {}
local frameScales = {}
local frameIsMoving = {}
local enableMouseFrames = {"PlayerChoiceFrame", "GenericPlayerChoiseTobbleButton"}
local hookedEnableMouseFrames = {}

-- Create the hidden panel for completely hiding frames
VUIAnyFrame.HIDDEN_FRAME = CreateFrame("Frame", "VUIHIDDEN")
VUIAnyFrame.HIDDEN_FRAME:Hide()
VUIAnyFrame.HIDDEN_FRAME.unit = "player"
VUIAnyFrame.HIDDEN_FRAME.auraRows = 0

-- Create a UIParent alternative for custom scaling
VUIAnyFrame.UI_PARENT = CreateFrame("Frame", "VUIUIP")
VUIAnyFrame.UI_PARENT:SetAllPoints(UIParent)
VUIAnyFrame.UI_PARENT.unit = "player" 
VUIAnyFrame.UI_PARENT.auraRows = 0

-- Get color (from MoveAny)
local colors = {}
colors["bg"] = {0.03, 0.03, 0.03}
colors["se"] = {1.0, 1.0, 0.0}
colors["el"] = {0.6, 0.84, 1.0}
colors["hidden"] = {1.0, 0.0, 0.0}
colors["clickthrough"] = {0.2, 0.2, 1.0}

function VUIAnyFrame:GetColor(key)
    return colors[key][1], colors[key][2], colors[key][3]
end

-- Update UI Parent alpha and scale to match UI
function VUIAnyFrame:SetUIParentAlpha(alpha)
    if UIParent:IsShown() then
        self.UI_PARENT:SetAlpha(alpha)
    else
        self.UI_PARENT:SetAlpha(0)
    end
end

-- Hook UI scale changes
local function InitUIScale()
    local uiscalecvar = CreateFrame("Frame")
    uiscalecvar:RegisterEvent("CVAR_UPDATE")
    uiscalecvar:SetScript("OnEvent", function(self, event, target, value)
        if event == "CVAR_UPDATE" and (target == "uiScale" or target == "useUiScale") then
            if GetCVar("useUiScale") == "1" then
                VUIAnyFrame.UI_PARENT:SetScale(GetCVar("uiScale"))
            else
                VUIAnyFrame.UI_PARENT:SetScale(UIParent:GetScale())
            end
            
            VUIAnyFrame:UpdateGrid()
        end
    end)
    
    hooksecurefunc(UIParent, "SetScale", function(sel, scale)
        if InCombatLockdown() and sel:IsProtected() then return false end
        if GetCVar("useUiScale") == "0" and type(scale) == "number" then
            VUIAnyFrame.UI_PARENT:SetScale(scale)
        end
    end)
    
    if GetCVar("useUiScale") == "1" then
        VUIAnyFrame.UI_PARENT:SetScale(GetCVar("uiScale"))
    else
        C_Timer.After(0, function()
            VUIAnyFrame.UI_PARENT:SetScale(UIParent:GetScale())
        end)
    end
    
    VUIAnyFrame:SetUIParentAlpha(UIParent:GetAlpha())
    
    hooksecurefunc(UIParent, "Show", function(self)
        VUIAnyFrame:SetUIParentAlpha(1)
    end)
    
    hooksecurefunc(UIParent, "Hide", function(self)
        VUIAnyFrame:SetUIParentAlpha(0)
    end)
    
    hooksecurefunc(_G, "SetUIVisibility", function(show, ...)
        if show then
            VUIAnyFrame:SetUIParentAlpha(1)
        else
            VUIAnyFrame:SetUIParentAlpha(0)
        end
    end)
end

-- Initialize UI Scale handling
InitUIScale()

-- Set frame scale
function VUIAnyFrame:SetFrameScale(frameName, scale)
    if not frameName or not scale then return end
    
    if not self.db.profile.frames[frameName] then
        self.db.profile.frames[frameName] = {}
    end
    
    self.db.profile.frames[frameName].scale = scale
    
    local frame = _G[frameName]
    if frame then
        frame:SetScale(scale)
    end
end

-- Update current window (for scaling)
function VUIAnyFrame:UpdateCurrentWindow()
    if currentWindowName ~= nil then
        local currentWindow = _G[currentWindowName]
        if currentWindow then
            if updatingFrame then return end
            updatingFrame = true
            
            if not currentWindow:IsShown() then
                currentWindow:SetAlpha(1)
                currentWindowName = nil
                GameTooltip:Hide()
            end
            
            if currentWindowName ~= nil and self.db.profile.global.allowScaling then
                local curMouseX, curMouseY = GetCursorPosition()
                if prevMouseX and prevMouseY then
                    if curMouseY > prevMouseY then
                        local newScale = math.min(currentWindow:GetScale() + 0.006, 2.5)
                        if newScale > 0 then
                            newScale = tonumber(string.format("%.3f", newScale))
                            currentWindow:SetScale(newScale)
                            if currentWindow.isMaximized and newScale > 1 then
                                newScale = 1
                            end
                            
                            self:SetFrameScale(currentWindowName, newScale)
                        end
                    elseif curMouseY < prevMouseY then
                        local newScale = math.max(currentWindow:GetScale() - 0.006, 0.5)
                        if newScale > 0 then
                            newScale = tonumber(string.format("%.3f", newScale))
                            currentWindow:SetScale(newScale)
                            if currentWindow.isMaximized and newScale > 1 then
                                newScale = 1
                            end
                            
                            self:SetFrameScale(currentWindowName, newScale)
                        end
                    end
                end
                
                GameTooltip:SetOwner(currentWindow)
                GameTooltip:SetText(self:MathR(currentWindow:GetScale() * 100) .. "%")
                prevMouseX = curMouseX
                prevMouseY = curMouseY
            end
            
            updatingFrame = false
            C_Timer.After(0.02, function() self:UpdateCurrentWindow() end)
        end
    end
end

-- Set frame point with proper handling
function VUIAnyFrame:SetPoint(window, p1, p2, p3, p4, p5)
    frameSetPoints[window] = frameSetPoints[window] or false
    
    if InCombatLockdown() and window:IsProtected() then return false end
    
    if p1 then
        local ClearAllPoints = window.FClearAllPoints or window.ClearAllPoints
        ClearAllPoints(window)
        local SetPoint = window.FSetPointBase or window.FSetPoint or window.SetPointBase or window.SetPoint
        frameSetPoints[window] = true
        SetPoint(window, p1, p2 or "UIParent", p3, p4, p5)
        frameSetPoints[window] = false
    end
    
    return true
end

-- Round math helper
function VUIAnyFrame:MathR(v)
    return math.floor(v + 0.5)
end

-- Frame drag info tooltip
function VUIAnyFrame:FrameDragInfo(frame, c)
    if c > 0 then
        if IsMouseButtonDown("RightButton") or IsMouseButtonDown("LeftButton") or IsMouseButtonDown("MiddleButton") then
            C_Timer.After(0.01, function()
                self:FrameDragInfo(frame, c - 1)
            end)
        end
    else
        local text = nil
        if IsMouseButtonDown("RightButton") then
            if self.db.profile.global.allowScaling then
                text = "Right-click + drag up/down to scale"
            else
                text = "Frame scaling disabled"
            end
        elseif IsMouseButtonDown("LeftButton") then
            text = "Drag to move frame"
        elseif IsMouseButtonDown("MiddleButton") then
            text = "Middle-click to reset position"
        end
        
        if text then
            GameTooltip:SetOwner(frame)
            GameTooltip:SetText(text)
        end
    end
end

-- Create a grid
function VUIAnyFrame:UpdateGrid()
    if not self.GridFrame then
        self.GridFrame = CreateFrame("Frame", "VUIAnyFrameGrid", UIParent)
        self.GridFrame:SetFrameStrata("BACKGROUND")
        self.GridFrame:SetAllPoints(UIParent)
        self.GridFrame:Hide()
        
        self.GridFrame.texture = self.GridFrame:CreateTexture(nil, "BACKGROUND")
        self.GridFrame.texture:SetAllPoints(self.GridFrame)
        self.GridFrame.texture:SetColorTexture(0.2, 0.2, 0.2, 0.4)
        
        self.GridFrame.lines = {}
        
        -- Create grid lines
        local gridSize = self.db.profile.global.grid or 10
        
        -- Horizontal lines
        for i = 0, math.ceil(GetScreenHeight() / gridSize) do
            local line = self.GridFrame:CreateLine()
            line:SetColorTexture(0.4, 0.4, 0.4, 0.8)
            line:SetStartPoint("TOPLEFT", 0, -i * gridSize)
            line:SetEndPoint("TOPRIGHT", 0, -i * gridSize)
            line:SetThickness(1)
            table.insert(self.GridFrame.lines, line)
        end
        
        -- Vertical lines
        for i = 0, math.ceil(GetScreenWidth() / gridSize) do
            local line = self.GridFrame:CreateLine()
            line:SetColorTexture(0.4, 0.4, 0.4, 0.8)
            line:SetStartPoint("TOPLEFT", i * gridSize, 0)
            line:SetEndPoint("BOTTOMLEFT", i * gridSize, 0)
            line:SetThickness(1)
            table.insert(self.GridFrame.lines, line)
        end
    end
end

-- Set up all frames for moving
function VUIAnyFrame:SetupFrames()
    -- Hook special frames like StaticPopup for better handling
    if StaticPopup1 then
        hooksecurefunc(StaticPopup1, "Hide", function(sel)
            if not InCombatLockdown() or not sel:IsProtected() then
                sel:ClearAllPoints()
            end
        end)
        StaticPopup1:ClearAllPoints()
    end
    
    if StaticPopup2 then
        hooksecurefunc(StaticPopup2, "Hide", function(sel)
            if not InCombatLockdown() or not sel:IsProtected() then
                sel:ClearAllPoints()
            end
        end)
        StaticPopup2:ClearAllPoints()
    end
    
    -- Enable mouse on special frames
    for _, name in pairs(enableMouseFrames) do
        local frame = _G[name]
        if frame and not hookedEnableMouseFrames[name] then
            hookedEnableMouseFrames[name] = true
            hooksecurefunc(frame, "Show", function(sel)
                sel:EnableMouse(true)
            end)
            frame:EnableMouse(true)
        end
    end
    
    -- Register all default frames from our list
    for _, frameName in ipairs(MOVABLE_FRAMES) do
        self:RegisterFrame(frameName)
    end
    
    -- Apply saved settings
    self:ApplyAllFrameSettings()
end

-- Register a frame for movement
function VUIAnyFrame:RegisterFrame(frameName)
    local frame = _G[frameName]
    if not frame then
        -- Frame might not be loaded yet, we'll retry when addons load
        return
    end
    
    if movedFrames[frameName] then
        -- Already registered
        return
    end
    
    -- Create a move border/highlight
    local mover = CreateFrame("Frame", "VUIAnyFrameMover_" .. frameName, frame)
    mover:SetFrameStrata("DIALOG")
    mover:SetAllPoints(frame)
    
    -- Make it visible
    mover.texture = mover:CreateTexture(nil, "OVERLAY")
    mover.texture:SetAllPoints(mover)
    mover.texture:SetColorTexture(self:GetColor("el"))
    mover.texture:SetAlpha(0.3)
    
    -- Add frame name
    mover.text = mover:CreateFontString(nil, "OVERLAY")
    mover.text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    mover.text:SetPoint("TOP", mover, "TOP", 0, 15)
    mover.text:SetText(frameName)
    
    -- Make the frame movable
    frame:SetMovable(true)
    frame:SetUserPlaced(true)
    
    -- Add move and scale handlers
    mover:EnableMouse(true)
    mover:RegisterForDrag("LeftButton")
    
    mover:SetScript("OnDragStart", function(self)
        if not VUIAnyFrame.db.profile.global.lockFrames then
            currentWindowName = frameName
            frame:StartMoving()
            frameIsMoving[frameName] = true
            
            if VUIAnyFrame.db.profile.global.showGrid then
                VUIAnyFrame.GridFrame:Show()
            end
        end
    end)
    
    mover:SetScript("OnDragStop", function(self)
            frame:StopMovingOrSizing()
        frameIsMoving[frameName] = false
        currentWindowName = nil
        GameTooltip:Hide()
        
        if VUIAnyFrame.GridFrame then
            VUIAnyFrame.GridFrame:Hide()
        end
            
            -- Save the position
        if VUIAnyFrame.db.profile.frames[frameName] == nil then
            VUIAnyFrame.db.profile.frames[frameName] = {}
        end
        
        local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint(1)
        if point then
            -- Snap to grid if enabled
            if VUIAnyFrame.db.profile.global.snapToGrid and xOfs and yOfs then
                local gridSize = VUIAnyFrame.db.profile.global.grid or 10
                xOfs = math.floor(xOfs / gridSize + 0.5) * gridSize
                yOfs = math.floor(yOfs / gridSize + 0.5) * gridSize
                
                frame:ClearAllPoints()
                frame:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
            end
            
            -- Save position
            VUIAnyFrame.db.profile.frames[frameName].position = {
                point = point,
                relativeTo = relativeTo and relativeTo:GetName() or "UIParent",
                relativePoint = relativePoint,
                xOfs = xOfs,
                yOfs = yOfs
            }
        end
    end)
    
    -- Right-click to scale
    mover:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" and VUIAnyFrame.db.profile.global.allowScaling then
            currentWindowName = frameName
            prevMouseX, prevMouseY = GetCursorPosition()
            VUIAnyFrame:UpdateCurrentWindow()
        elseif button == "MiddleButton" then
            -- Reset position
            VUIAnyFrame:ResetFramePosition(frame)
        end
    end)
    
    mover:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" then
            currentWindowName = nil
            GameTooltip:Hide()
        end
    end)
    
    -- Tooltip handling
    mover:SetScript("OnEnter", function(self)
        if not VUIAnyFrame.db.profile.global.lockFrames then
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            GameTooltip:ClearLines()
            GameTooltip:AddLine("VUI AnyFrame", 1, 1, 1)
            GameTooltip:AddLine(frameName, 0.6, 0.8, 1)
        GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Drag: Move Frame", 0.8, 0.8, 0.8)
            
            if VUIAnyFrame.db.profile.global.allowScaling then
                GameTooltip:AddLine("Right-click + Drag: Scale Frame", 0.8, 0.8, 0.8)
            end
            
            GameTooltip:AddLine("Middle-click: Reset Position", 0.8, 0.8, 0.8)
        GameTooltip:Show()
        end
    end)
    
    mover:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    -- Apply saved settings
    self:ApplyFrameSettings(frameName)
    
    -- Hide by default
    mover:Hide()
    
    -- Save to our list
    movedFrames[frameName] = mover
end

-- Apply settings to a specific frame
function VUIAnyFrame:ApplyFrameSettings(frameName)
    local frame = _G[frameName]
    if not frame then return end
    
    local settings = self.db.profile.frames[frameName]
    if not settings then return end
    
    -- Apply position if saved
    if settings.position then
        local pos = settings.position
        local relTo = pos.relativeTo == "UIParent" and UIParent or _G[pos.relativeTo]
        
        if relTo then
            frame:ClearAllPoints()
            frame:SetPoint(pos.point, relTo, pos.relativePoint, pos.xOfs, pos.yOfs)
        end
    end
    
    -- Apply scale if saved
    if settings.scale then
        frame:SetScale(settings.scale)
    end
    
    -- Apply hidden state if saved
    if settings.hidden then
        self:HideFrame(frame, settings.softHide)
    end
end

-- Apply settings to all frames
function VUIAnyFrame:ApplyAllFrameSettings()
    for frameName in pairs(self.db.profile.frames) do
        self:ApplyFrameSettings(frameName)
    end
end

-- Toggle frame lock state
function VUIAnyFrame:ToggleFrameLock()
    self.db.profile.global.lockFrames = not self.db.profile.global.lockFrames
    self:UpdateFrameVisibility()
    
    self:Print(self.db.profile.global.lockFrames and "Frames locked" or "Frames unlocked")
    
    return self.db.profile.global.lockFrames
end

-- Update mover frame visibility
function VUIAnyFrame:UpdateFrameVisibility()
    for frameName, mover in pairs(movedFrames) do
        if self.db.profile.global.lockFrames then
            mover:Hide()
        else
            mover:Show()
        end
    end
    
    -- Show/hide grid if enabled
    if self.GridFrame then
        if not self.db.profile.global.lockFrames and self.db.profile.global.showGrid then
            self.GridFrame:Show()
        else
            self.GridFrame:Hide()
        end
    end
end

-- Hide a frame completely
function VUIAnyFrame:HideFrame(frame, soft)
    if not soft then
        if InCombatLockdown() then
            C_Timer.After(0.1, function() 
                self:HideFrame(frame, soft) 
            end)
            return
        end
        
        sethidden[frame] = true
        if sethiddenSetup[frame] == nil then
            sethiddenSetup[frame] = true
            local setparent = false
            hooksecurefunc(frame, "SetParent", function(sel, parent)
                if sethidden[sel] == nil then return end
                if setparent then return end
                setparent = true
                sel:SetParent(self.HIDDEN_FRAME)
                setparent = false
            end)
        end
        
        frame:SetParent(self.HIDDEN_FRAME)
        return
    end
    
    sethidden[frame] = true
    if sethiddenSetup[frame] == nil then
        sethiddenSetup[frame] = true
        local setalpha = false
        hooksecurefunc(frame, "SetAlpha", function(sel, alpha)
            if sethidden[sel] == nil then return end
            if setalpha then return end
            setalpha = true
            sel:SetAlpha(0)
            if not InCombatLockdown() then
                sel:EnableMouse(false)
            end
            
            if sel.GetChildren then
                local function HideChildren(child)
                    child:SetAlpha(0)
                    if not InCombatLockdown() then
                        child:EnableMouse(false)
                    end
                end
                
                local children = {sel:GetChildren()}
                for _, child in ipairs(children) do
                    HideChildren(child)
                end
            end
            
            setalpha = false
        end)
    end
    
    frame:SetAlpha(0)
    frame:EnableMouse(false)
    if InCombatLockdown() then
        C_Timer.After(0.1, function()
            self:HideFrame(frame, soft)
        end)
    end
end

-- Show a previously hidden frame
function VUIAnyFrame:ShowFrame(frame)
    sethidden[frame] = nil
    frame:SetAlpha(1)
    if not InCombatLockdown() then
        frame:EnableMouse(true)
    else
        C_Timer.After(0.1, function()
            self:ShowFrame(frame)
        end)
    end
end

-- Reset a frame's position
function VUIAnyFrame:ResetFramePosition(frame)
    if not frame or not frame:GetName() then return end
    
    local name = frame:GetName()
    
    if self.db.profile.frames[name] then
        self.db.profile.frames[name].position = nil
    end
    
    -- You might need custom code here to set specific frames back to their default positions
    -- For now, we just clear points and let the game position it
    frame:ClearAllPoints()
    -- Let the original OnShow/etc handlers reposition it
    
    VUIAnyFrame:Print(name .. " position has been reset")
end

-- Open options for a specific frame
function VUIAnyFrame:OpenFrameOptions(frame)
    if not frame or not frame:GetName() then return end
    
    -- This function would show a specialized options panel for this specific frame
    -- For now, we'll just open the general options
    self:OpenOptions()
end
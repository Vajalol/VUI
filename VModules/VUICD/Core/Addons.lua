local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()

-- Addon compatibility module
VUICD.Addons = {
    -- List of supported addons
    supported = {
        ["ElvUI"] = false,
        ["TukUI"] = false,
        ["Grid"] = false,
        ["Grid2"] = false,
        ["VuhDo"] = false,
        ["Plater"] = false,
        ["WeakAuras"] = false,
        ["BigWigs"] = false,
        ["DBM"] = false
    },
    
    -- Addon handlers
    handlers = {},
    
    -- Frames provided by addons
    frames = {},
    
    -- Unit frames by addon
    unitFrames = {}
}

-- Initialize addon detection
function VUICD.Addons:Initialize()
    -- Detect installed addons
    self:DetectAddons()
    
    -- Register events
    self.frame = CreateFrame("Frame")
    self.frame:SetScript("OnEvent", function(_, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end)
    
    self.frame:RegisterEvent("ADDON_LOADED")
    self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Initialize handlers for detected addons
    self:InitializeHandlers()
    
    -- Debug output
    local detected = {}
    for name, isLoaded in pairs(self.supported) do
        if isLoaded then
            table.insert(detected, name)
        end
    end
    
    if #detected > 0 then
        VUICD:Debug("Detected addons: " .. table.concat(detected, ", "))
    end
end

-- Detect installed addons
function VUICD.Addons:DetectAddons()
    for name in pairs(self.supported) do
        self.supported[name] = IsAddOnLoaded(name)
    end
end

-- Initialize handlers for detected addons
function VUICD.Addons:InitializeHandlers()
    -- ElvUI
    if self.supported["ElvUI"] then
        self:InitializeElvUI()
    end
    
    -- TukUI
    if self.supported["TukUI"] then
        self:InitializeTukUI()
    end
    
    -- Grid
    if self.supported["Grid"] then
        self:InitializeGrid()
    end
    
    -- Grid2
    if self.supported["Grid2"] then
        self:InitializeGrid2()
    end
    
    -- VuhDo
    if self.supported["VuhDo"] then
        self:InitializeVuhDo()
    end
    
    -- Plater
    if self.supported["Plater"] then
        self:InitializePlater()
    end
    
    -- WeakAuras
    if self.supported["WeakAuras"] then
        self:InitializeWeakAuras()
    end
    
    -- BigWigs
    if self.supported["BigWigs"] then
        self:InitializeBigWigs()
    end
    
    -- DBM
    if self.supported["DBM"] then
        self:InitializeDBM()
    end
end

-- Initialize ElvUI handler
function VUICD.Addons:InitializeElvUI()
    if not ElvUI then return end
    
    local E = ElvUI[1]
    if not E then return end
    
    self.handlers["ElvUI"] = {
        -- Get unit frames
        GetUnitFrames = function()
            local frames = {}
            
            if E.UnitFrames then
                -- Player frame
                if E.UnitFrames.units.player then
                    frames.player = E.UnitFrames.units.player
                end
                
                -- Party frames
                if E.UnitFrames.units.party then
                    frames.party = {}
                    for i = 1, 5 do
                        local frame = _G["ElvUF_Party" .. i]
                        if frame then
                            frames.party[i] = frame
                        end
                    end
                end
                
                -- Raid frames
                if E.UnitFrames.units.raid then
                    frames.raid = {}
                    for i = 1, 40 do
                        local frame = _G["ElvUF_Raid" .. i]
                        if frame then
                            frames.raid[i] = frame
                        end
                    end
                end
            end
            
            return frames
        end,
        
        -- Hook into ElvUI
        HookFrames = function()
            -- Hook into frame creation
            if E.UnitFrames and E.UnitFrames.CreateAndUpdateUF then
                self:Hook(E.UnitFrames, "CreateAndUpdateUF", function(self, unit)
                    VUICD.Addons:UpdateFrames()
                end)
            end
        end
    }
    
    -- Store ElvUI frames
    self.unitFrames["ElvUI"] = self.handlers["ElvUI"].GetUnitFrames()
    
    -- Hook into ElvUI
    self.handlers["ElvUI"].HookFrames()
end

-- Initialize TukUI handler
function VUICD.Addons:InitializeTukUI()
    if not Tukui then return end
    
    local T = Tukui[1]
    if not T then return end
    
    self.handlers["TukUI"] = {
        -- Get unit frames
        GetUnitFrames = function()
            local frames = {}
            
            if T.UnitFrames then
                -- Player frame
                if T.UnitFrames.Player then
                    frames.player = T.UnitFrames.Player
                end
                
                -- Party frames
                if T.UnitFrames.Party then
                    frames.party = {}
                    for i = 1, 5 do
                        local frame = _G["TukuiPartyMember" .. i]
                        if frame then
                            frames.party[i] = frame
                        end
                    end
                end
                
                -- Raid frames
                if T.UnitFrames.Raid then
                    frames.raid = {}
                    for i = 1, 40 do
                        local frame = _G["TukuiRaidMember" .. i]
                        if frame then
                            frames.raid[i] = frame
                        end
                    end
                end
            end
            
            return frames
        end,
        
        -- Hook into TukUI
        HookFrames = function()
            -- Add hooks as needed
        end
    }
    
    -- Store TukUI frames
    self.unitFrames["TukUI"] = self.handlers["TukUI"].GetUnitFrames()
    
    -- Hook into TukUI
    self.handlers["TukUI"].HookFrames()
end

-- Helper function to hook into addon functions
function VUICD.Addons:Hook(object, method, hook)
    if not object or not method or not hook then return end
    
    local original = object[method]
    object[method] = function(...)
        original(...)
        hook(...)
    end
end

-- Update frames when addons load or change
function VUICD.Addons:UpdateFrames()
    -- Update frames from all handlers
    for name, handler in pairs(self.handlers) do
        if handler.GetUnitFrames then
            self.unitFrames[name] = handler.GetUnitFrames()
        end
    end
    
    -- Notify party module of frame updates
    if VUICD.Party and VUICD.Party.UpdateFrames then
        VUICD.Party:UpdateFrames()
    end
end

-- Event handlers
function VUICD.Addons:ADDON_LOADED(addonName)
    if self.supported[addonName] ~= nil then
        self.supported[addonName] = true
        self:InitializeHandlers()
    end
end

function VUICD.Addons:PLAYER_ENTERING_WORLD()
    self:UpdateFrames()
end

-- Get all unit frames from supported addons
function VUICD.Addons:GetAllUnitFrames()
    local allFrames = {
        player = {},
        party = {},
        raid = {}
    }
    
    for _, frames in pairs(self.unitFrames) do
        if frames.player then
            table.insert(allFrames.player, frames.player)
        end
        
        if frames.party then
            for i, frame in ipairs(frames.party) do
                table.insert(allFrames.party, frame)
            end
        end
        
        if frames.raid then
            for i, frame in ipairs(frames.raid) do
                table.insert(allFrames.raid, frame)
            end
        end
    end
    
    return allFrames
end

-- Debug function
function VUICD:Debug(message)
    if self.debug then
        print("|cff33ff99VUICD Debug:|r", message)
    end
end
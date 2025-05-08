local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()

-- Module initialization
function VUICD:OnInitialize()
    -- Initialize database
    if not VUI_SavedVariables.VUICD then
        VUI_SavedVariables.VUICD = {}
    end
    
    self.db = VUI_SavedVariables.VUICD
    
    -- Merge defaults with saved variables
    for k, v in pairs(db) do
        if self.db[k] == nil then
            self.db[k] = v
        end
    end
    
    -- Register media paths
    self:RegisterMedia()
    
    -- Initialize modules
    for moduleName, enabled in pairs(self.db.modules) do
        if enabled and self[moduleName] then
            if self[moduleName].Initialize then
                self[moduleName]:Initialize()
            end
        end
    end
    
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
end

function VUICD:OnEnable()
    -- Enable modules
    for moduleName, enabled in pairs(self.db.modules) do
        if enabled and self[moduleName] then
            if self[moduleName].Enable then
                self[moduleName]:Enable()
            end
        end
    end
end

function VUICD:OnDisable()
    -- Disable modules
    for moduleName, enabled in pairs(self.db.modules) do
        if enabled and self[moduleName] then
            if self[moduleName].Disable then
                self[moduleName]:Disable()
            end
        end
    end
end

function VUICD:PLAYER_ENTERING_WORLD()
    self:CheckInstanceType()
end

function VUICD:GROUP_ROSTER_UPDATE()
    self:UpdateRoster()
end

-- Check instance type for visibility settings
function VUICD:CheckInstanceType()
    local _, instanceType = IsInInstance()
    self.instanceType = instanceType
    
    -- Update module visibility based on instance type
    for moduleName, enabled in pairs(self.db.modules) do
        if enabled and self[moduleName] then
            if self[moduleName].UpdateVisibility then
                self[moduleName]:UpdateVisibility(instanceType)
            end
        end
    end
end

-- Update group roster
function VUICD:UpdateRoster()
    if self.Party and self.Party.UpdateRoster then
        self.Party:UpdateRoster()
    end
end

-- Register media paths
function VUICD:RegisterMedia()
    local LSM = self.Libs.LSM
    
    -- Register textures
    LSM:Register("statusbar", "VUI-Party-StatusBar", "Interface\\AddOns\\VUI\\media\\modules\\VUICD\\statusbar.tga")
end

-- Get party module settings
function VUICD:GetPartySettings()
    return self.db.party
end

-- Register slash commands
SLASH_VUICD1 = "/vuicd"
SLASH_VUICD2 = "/vcd"
SlashCmdList["VUICD"] = function(msg)
    local args = {}
    for word in msg:gmatch("%w+") do
        table.insert(args, word)
    end
    
    local command = args[1] and args[1]:lower() or ""
    
    if command == "test" then
        if VUICD.Party and VUICD.Party.Test then
            VUICD.Party:Test()
        end
    elseif command == "options" or command == "config" then
        VUI.Config:Toggle()
    else
        print("|cff33ff99VUICD|r: Party Cooldown Tracker")
        print("  /vuicd test - Toggle test mode")
        print("  /vuicd options - Open configuration panel")
    end
end